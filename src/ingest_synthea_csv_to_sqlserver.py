"""
ClinicalPulse Synthea CSV ingestion script.

Purpose:
Load selected Synthea CSV files into SQL Server bronze tables.

Assumptions:
- Bronze tables already exist.
- Ingestion metadata columns already exist on bronze tables.
- Raw Synthea CSV files are stored locally under data/raw/synthea/.
- This script writes batch-level and file-level ingestion logs to audit tables.
"""

from __future__ import annotations

import argparse
import hashlib
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
from sqlalchemy import text
from sqlalchemy.engine import Engine

from db_config import get_sqlalchemy_engine


try:
    from dotenv import load_dotenv

    load_dotenv()
except ImportError:
    pass


@dataclass(frozen=True)
class TableConfig:
    source_file: str
    target_table: str
    column_map: dict[str, str]


TABLE_CONFIGS: dict[str, TableConfig] = {
    'patients': TableConfig(
        source_file='patients.csv',
        target_table='patients',
        column_map={
            'ID': 'source_patient_id',
            'BIRTHDATE': 'birthdate',
            'DEATHDATE': 'deathdate',
            'SSN': 'ssn',
            'DRIVERS': 'drivers',
            'PASSPORT': 'passport',
            'PREFIX': 'prefix',
            'FIRST': 'first_name',
            'MIDDLE': 'middle_name',
            'LAST': 'last_name',
            'SUFFIX': 'suffix',
            'MAIDEN': 'maiden',
            'MARITAL': 'marital',
            'RACE': 'race',
            'ETHNICITY': 'ethnicity',
            'GENDER': 'gender',
            'BIRTHPLACE': 'birthplace',
            'ADDRESS': 'street_address',
            'CITY': 'city',
            'STATE': 'state_code',
            'COUNTY': 'county',
            'FIPS': 'fips',
            'ZIP': 'zip',
            'LAT': 'lat',
            'LON': 'lon',
            'HEALTHCARE_EXPENSES': 'healthcare_expenses',
            'HEALTHCARE_COVERAGE': 'healthcare_coverage',
            'INCOME': 'income',
        },
    ),
    'organizations': TableConfig(
        source_file='organizations.csv',
        target_table='organizations',
        column_map={
            'ID': 'source_organization_id',
            'NAME': 'organization_name',
            'ADDRESS': 'street_address',
            'CITY': 'city',
            'STATE': 'state_code',
            'ZIP': 'zip',
            'LAT': 'lat',
            'LON': 'lon',
            'PHONE': 'phone',
            'REVENUE': 'revenue',
            'UTILIZATION': 'utilization',
        },
    ),
    'providers': TableConfig(
        source_file='providers.csv',
        target_table='providers',
        column_map={
            'ID': 'source_provider_id',
            'ORGANIZATION': 'source_organization_id',
            'NAME': 'provider_name',
            'GENDER': 'gender',
            'SPECIALITY': 'speciality',
            'ADDRESS': 'street_address',
            'CITY': 'city',
            'STATE': 'state_code',
            'ZIP': 'zip',
            'LAT': 'lat',
            'LON': 'lon',
            'ENCOUNTERS': 'encounter_count',
            'PROCEDURES': 'procedure_count',
        },
    ),
    'encounters': TableConfig(
        source_file='encounters.csv',
        target_table='encounters',
        column_map={
            'ID': 'source_encounter_id',
            'START': 'encounter_start_datetime',
            'STOP': 'encounter_stop_datetime',
            'PATIENT': 'source_patient_id',
            'ORGANIZATION': 'source_organization_id',
            'PROVIDER': 'source_provider_id',
            'PAYER': 'source_payer_id',
            'ENCOUNTERCLASS': 'encounter_class',
            'CODE': 'encounter_code',
            'DESCRIPTION': 'encounter_description',
            'BASE_ENCOUNTER_COST': 'base_encounter_cost',
            'TOTAL_CLAIM_COST': 'total_claim_cost',
            'PAYER_COVERAGE': 'payer_coverage',
            'REASONCODE': 'reason_code',
            'REASONDESCRIPTION': 'reason_description',
        },
    ),
    'conditions': TableConfig(
        source_file='conditions.csv',
        target_table='conditions',
        column_map={
            'START': 'condition_start_datetime',
            'STOP': 'condition_stop_datetime',
            'PATIENT': 'source_patient_id',
            'ENCOUNTER': 'source_encounter_id',
            'SYSTEM': 'condition_system',
            'CODE': 'condition_code',
            'DESCRIPTION': 'condition_description',
        },
    ),
    'observations': TableConfig(
        source_file='observations.csv',
        target_table='observations',
        column_map={
            'DATE': 'observation_datetime',
            'PATIENT': 'source_patient_id',
            'ENCOUNTER': 'source_encounter_id',
            'CATEGORY': 'observation_category',
            'CODE': 'observation_code',
            'DESCRIPTION': 'observation_description',
            'VALUE': 'observation_value',
            'UNITS': 'observation_units',
            'TYPE': 'observation_type',
        },
    ),
    'procedures': TableConfig(
        source_file='procedures.csv',
        target_table='procedures',
        column_map={
            'START': 'procedure_start_datetime',
            'STOP': 'procedure_stop_datetime',
            'PATIENT': 'source_patient_id',
            'ENCOUNTER': 'source_encounter_id',
            'SYSTEM': 'procedure_system',
            'CODE': 'procedure_code',
            'DESCRIPTION': 'procedure_description',
            'BASE_COST': 'base_procedure_cost',
            'REASONCODE': 'reason_code',
            'REASONDESCRIPTION': 'reason_description',
        },
    ),
}


def read_csv_file(csv_path: Path) -> pd.DataFrame:
    """Read a Synthea CSV file as strings and normalize column names."""

    if not csv_path.exists():
        raise FileNotFoundError(f'Missing source file: {csv_path}')

    dataframe = pd.read_csv(csv_path, dtype=str, keep_default_na=False)
    dataframe.columns = [column.strip().upper() for column in dataframe.columns]

    return dataframe


def validate_source_columns(
    dataframe: pd.DataFrame,
    config: TableConfig,
) -> None:
    """Confirm that the source CSV contains every expected column."""

    missing_columns = [
        column for column in config.column_map
        if column not in dataframe.columns
    ]

    if missing_columns:
        missing_text = ', '.join(missing_columns)
        raise ValueError(
            f'{config.source_file} is missing expected column(s): {missing_text}'
        )


def build_row_hash(row: pd.Series, hash_columns: list[str]) -> bytes:
    """Build a SHA-256 hash from the mapped bronze row values."""

    values = []

    for column in hash_columns:
        value = row[column]

        if pd.isna(value):
            values.append('')
        else:
            values.append(str(value))

    row_text = '\x1f'.join(values)

    return hashlib.sha256(row_text.encode('utf-8')).digest()


def transform_for_bronze(
    source_dataframe: pd.DataFrame,
    config: TableConfig,
    batch_id: int,
    source_file: str,
    ingestion_datetime: datetime,
) -> pd.DataFrame:
    """Map Synthea source columns to bronze columns and add metadata."""

    validate_source_columns(source_dataframe, config)

    bronze_dataframe = source_dataframe[list(config.column_map)].rename(
        columns=config.column_map
    )

    bronze_dataframe = bronze_dataframe.replace({'': None})

    hash_columns = list(config.column_map.values())

    bronze_dataframe['ingestion_batch_id'] = batch_id
    bronze_dataframe['ingestion_datetime'] = ingestion_datetime
    bronze_dataframe['source_file'] = source_file
    bronze_dataframe['row_hash'] = bronze_dataframe.apply(
        lambda row: build_row_hash(row, hash_columns),
        axis=1,
    )
    bronze_dataframe['load_status'] = 'loaded'

    return bronze_dataframe


def clear_bronze_table(engine: Engine, table_name: str) -> None:
    """Delete existing rows from a bronze table before repeatable reload."""

    with engine.begin() as connection:
        connection.execute(text(f'DELETE FROM bronze.{table_name};'))


def truncate_error_message(error: Exception) -> str:
    """Return a database-safe error message."""

    return str(error)[:4000]


def start_ingestion_batch(
    engine: Engine,
    raw_dir: Path,
    mode: str,
    entities: list[str],
) -> int:
    """Create an audit batch row and return its generated batch ID."""

    statement = text(
        """
        INSERT INTO audit.ingestion_batch (
            source_system,
            raw_directory,
            ingestion_mode,
            entity_count,
            load_status
        )
        OUTPUT INSERTED.ingestion_batch_id
        VALUES (
            :source_system,
            :raw_directory,
            :ingestion_mode,
            :entity_count,
            N'running'
        );
        """
    )

    with engine.begin() as connection:
        batch_id = connection.execute(
            statement,
            {
                'source_system': 'Synthea CSV',
                'raw_directory': str(raw_dir),
                'ingestion_mode': mode,
                'entity_count': len(entities),
            },
        ).scalar_one()

    return int(batch_id)


def complete_ingestion_batch(
    engine: Engine,
    batch_id: int,
    load_status: str,
    total_rows_loaded: int,
    error_message: str | None = None,
) -> None:
    """Mark an audit batch as succeeded or failed."""

    statement = text(
        """
        UPDATE audit.ingestion_batch
        SET
            completed_at = SYSUTCDATETIME(),
            load_status = :load_status,
            total_rows_loaded = :total_rows_loaded,
            error_message = :error_message
        WHERE ingestion_batch_id = :ingestion_batch_id;
        """
    )

    with engine.begin() as connection:
        connection.execute(
            statement,
            {
                'ingestion_batch_id': batch_id,
                'load_status': load_status,
                'total_rows_loaded': total_rows_loaded,
                'error_message': error_message,
            },
        )


def start_ingestion_file_log(
    engine: Engine,
    batch_id: int,
    config: TableConfig,
) -> int:
    """Create an audit file-log row and return its generated log ID."""

    statement = text(
        """
        INSERT INTO audit.ingestion_file_log (
            ingestion_batch_id,
            source_file,
            target_schema,
            target_table,
            load_status
        )
        OUTPUT INSERTED.ingestion_file_log_id
        VALUES (
            :ingestion_batch_id,
            :source_file,
            N'bronze',
            :target_table,
            N'running'
        );
        """
    )

    with engine.begin() as connection:
        file_log_id = connection.execute(
            statement,
            {
                'ingestion_batch_id': batch_id,
                'source_file': config.source_file,
                'target_table': config.target_table,
            },
        ).scalar_one()

    return int(file_log_id)


def complete_ingestion_file_log(
    engine: Engine,
    file_log_id: int,
    load_status: str,
    rows_loaded: int,
    error_message: str | None = None,
) -> None:
    """Mark an audit file-log row as succeeded or failed."""

    statement = text(
        """
        UPDATE audit.ingestion_file_log
        SET
            completed_at = SYSUTCDATETIME(),
            load_status = :load_status,
            rows_loaded = :rows_loaded,
            error_message = :error_message
        WHERE ingestion_file_log_id = :ingestion_file_log_id;
        """
    )

    with engine.begin() as connection:
        connection.execute(
            statement,
            {
                'ingestion_file_log_id': file_log_id,
                'load_status': load_status,
                'rows_loaded': rows_loaded,
                'error_message': error_message,
            },
        )


def load_bronze_table(
    engine: Engine,
    config: TableConfig,
    raw_dir: Path,
    batch_id: int,
    mode: str,
) -> int:
    """Load one Synthea CSV file into one bronze table."""

    csv_path = raw_dir / config.source_file
    source_dataframe = read_csv_file(csv_path)

    ingestion_datetime = datetime.now(timezone.utc).replace(tzinfo=None)

    bronze_dataframe = transform_for_bronze(
        source_dataframe=source_dataframe,
        config=config,
        batch_id=batch_id,
        source_file=config.source_file,
        ingestion_datetime=ingestion_datetime,
    )

    if mode == 'replace':
        clear_bronze_table(engine, config.target_table)

    bronze_dataframe.to_sql(
        name=config.target_table,
        con=engine,
        schema='bronze',
        if_exists='append',
        index=False,
        chunksize=1000,
    )

    return len(bronze_dataframe)


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""

    parser = argparse.ArgumentParser(
        description='Load Synthea CSV files into ClinicalPulse bronze tables.'
    )

    parser.add_argument(
        '--raw-dir',
        type=Path,
        default=Path('data/raw/synthea'),
        help='Directory containing Synthea CSV files.',
    )

    parser.add_argument(
        '--entities',
        nargs='*',
        choices=sorted(TABLE_CONFIGS),
        default=sorted(TABLE_CONFIGS),
        help='Specific source entities to load. Defaults to all configured entities.',
    )

    parser.add_argument(
        '--mode',
        choices=['replace', 'append'],
        default='replace',
        help='replace deletes existing bronze rows before loading; append only adds rows.',
    )

    return parser.parse_args()


def main() -> None:
    """Load selected Synthea CSV files into SQL Server bronze tables."""

    args = parse_args()
    engine = get_sqlalchemy_engine()

    batch_id = start_ingestion_batch(
        engine=engine,
        raw_dir=args.raw_dir,
        mode=args.mode,
        entities=args.entities,
    )

    print(f'ClinicalPulse Synthea ingestion started. Batch ID: {batch_id}')
    print(f'Raw directory: {args.raw_dir}')
    print(f'Mode: {args.mode}')

    total_rows = 0

    try:
        for entity in args.entities:
            config = TABLE_CONFIGS[entity]

            file_log_id = start_ingestion_file_log(
                engine=engine,
                batch_id=batch_id,
                config=config,
            )

            try:
                row_count = load_bronze_table(
                    engine=engine,
                    config=config,
                    raw_dir=args.raw_dir,
                    batch_id=batch_id,
                    mode=args.mode,
                )
            except Exception as error:
                complete_ingestion_file_log(
                    engine=engine,
                    file_log_id=file_log_id,
                    load_status='failed',
                    rows_loaded=0,
                    error_message=truncate_error_message(error),
                )
                raise

            complete_ingestion_file_log(
                engine=engine,
                file_log_id=file_log_id,
                load_status='succeeded',
                rows_loaded=row_count,
            )

            total_rows += row_count

            print(
                f'Loaded {row_count} row(s) from {config.source_file} '
                f'into bronze.{config.target_table}.'
            )

    except Exception as error:
        complete_ingestion_batch(
            engine=engine,
            batch_id=batch_id,
            load_status='failed',
            total_rows_loaded=total_rows,
            error_message=truncate_error_message(error),
        )
        raise

    complete_ingestion_batch(
        engine=engine,
        batch_id=batch_id,
        load_status='succeeded',
        total_rows_loaded=total_rows,
    )

    print(f'ClinicalPulse Synthea ingestion completed. Total rows loaded: {total_rows}')


if __name__ == '__main__':
    main()
