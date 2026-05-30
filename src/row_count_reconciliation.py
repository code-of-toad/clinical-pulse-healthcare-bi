"""
ClinicalPulse row count reconciliation.

Purpose:
Compare local Synthea CSV source row counts against SQL Server bronze table
row counts after the initial ingestion load.

Assumptions:
- Synthea CSV files are stored locally under data/raw/synthea/.
- Bronze tables have already been created.
- The Synthea CSV ingestion script has already loaded the selected files.
- This script validates source-to-bronze row count alignment only.
"""

from __future__ import annotations

import argparse
import csv
from dataclasses import dataclass
from pathlib import Path

from sqlalchemy import text
from sqlalchemy.engine import Engine

from db_config import get_sqlalchemy_engine
from ingest_synthea_csv_to_sqlserver import TABLE_CONFIGS, TableConfig


@dataclass(frozen=True)
class ReconciliationResult:
    entity: str
    source_file: str
    bronze_table: str
    source_row_count: int
    bronze_row_count: int

    @property
    def difference(self) -> int:
        return self.bronze_row_count - self.source_row_count

    @property
    def status(self) -> str:
        if self.difference == 0:
            return 'matched'

        return 'mismatched'


def count_csv_rows(csv_path: Path) -> int:
    """Count data rows in a CSV file, excluding the header row."""

    if not csv_path.exists():
        raise FileNotFoundError(f'Missing source file: {csv_path}')

    with csv_path.open('r', encoding='utf-8-sig', newline='') as file:
        reader = csv.reader(file)
        row_count = sum(1 for _ in reader)

    return max(row_count - 1, 0)


def count_bronze_rows(engine: Engine, table_name: str) -> int:
    """Count rows in a bronze SQL Server table."""

    statement = text(f'SELECT COUNT_BIG(*) FROM bronze.{table_name};')

    with engine.connect() as connection:
        row_count = connection.execute(statement).scalar_one()

    return int(row_count)


def reconcile_entity(
    engine: Engine,
    raw_dir: Path,
    entity: str,
    config: TableConfig,
) -> ReconciliationResult:
    """Compare one source CSV row count to its bronze table row count."""

    source_path = raw_dir / config.source_file

    return ReconciliationResult(
        entity=entity,
        source_file=config.source_file,
        bronze_table=f'bronze.{config.target_table}',
        source_row_count=count_csv_rows(source_path),
        bronze_row_count=count_bronze_rows(engine, config.target_table),
    )


def print_results(results: list[ReconciliationResult]) -> None:
    """Print reconciliation results as a readable table."""

    headers = [
        'entity',
        'source_file',
        'bronze_table',
        'source_rows',
        'bronze_rows',
        'difference',
        'status',
    ]

    rows = [
        [
            result.entity,
            result.source_file,
            result.bronze_table,
            str(result.source_row_count),
            str(result.bronze_row_count),
            str(result.difference),
            result.status,
        ]
        for result in results
    ]

    all_rows = [headers, *rows]
    widths = [
        max(len(row[index]) for row in all_rows)
        for index in range(len(headers))
    ]

    def format_row(row: list[str]) -> str:
        return ' | '.join(
            value.ljust(widths[index])
            for index, value in enumerate(row)
        )

    print(format_row(headers))
    print('-+-'.join('-' * width for width in widths))

    for row in rows:
        print(format_row(row))


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""

    parser = argparse.ArgumentParser(
        description='Reconcile Synthea CSV source counts against bronze SQL counts.'
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
        help='Specific entities to reconcile. Defaults to all configured entities.',
    )

    return parser.parse_args()


def main() -> None:
    """Run source-to-bronze row count reconciliation."""

    args = parse_args()
    engine = get_sqlalchemy_engine()

    print('ClinicalPulse row count reconciliation started.')
    print(f'Raw directory: {args.raw_dir}')

    results = [
        reconcile_entity(
            engine=engine,
            raw_dir=args.raw_dir,
            entity=entity,
            config=TABLE_CONFIGS[entity],
        )
        for entity in args.entities
    ]

    print_results(results)

    mismatches = [
        result
        for result in results
        if result.status != 'matched'
    ]

    if mismatches:
        print(f'Row count reconciliation failed: {len(mismatches)} mismatch(es) found.')
        raise SystemExit(1)

    total_source_rows = sum(result.source_row_count for result in results)
    total_bronze_rows = sum(result.bronze_row_count for result in results)

    print(f'Row count reconciliation succeeded. Total source rows: {total_source_rows}.')
    print(f'Total bronze rows: {total_bronze_rows}.')


if __name__ == '__main__':
    main()
