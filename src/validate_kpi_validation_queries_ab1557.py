from pathlib import Path
import re
import sys


REPO_ROOT = Path(__file__).resolve().parents[1]
SQL_PATH = REPO_ROOT / 'sql' / '08_kpi_validation_queries.sql'

REQUIRED_KPIS = [
    'Total Encounters',
    'Unique Patients',
    'Average Length of Stay',
    'Median Length of Stay',
    '30-Day Readmission Rate',
    'Observation Volume',
    'Procedure Volume',
    'Data Quality Pass Rate',
    'API Resource Coverage',
]

REQUIRED_OBJECT_REFERENCES = [
    'gold.fact_encounter',
    'gold.mart_patient_flow',
    'gold.mart_length_of_stay',
    'gold.fact_readmission',
    'gold.mart_readmissions',
    'gold.fact_observation',
    'gold.mart_lab_operations',
    'gold.fact_procedure',
    'gold.mart_service_utilization',
    'gold.fact_data_quality_issue',
    'gold.mart_reporting_trust',
    'api.vw_fhir_patient',
    'api.vw_fhir_encounter',
    'api.vw_fhir_observation',
    'api.vw_fhir_condition',
]

REQUIRED_OUTPUT_COLUMNS = [
    'kpi_name',
    'validation_query_name',
    'source_value',
    'comparison_value',
    'variance_value',
    'validation_status',
    'validation_detail',
]

FORBIDDEN_REAL_TABLE_MUTATIONS = [
    r'\bUPDATE\s+(gold|silver|bronze|governance|audit|api)\.',
    r'\bDELETE\s+FROM\s+(gold|silver|bronze|governance|audit|api)\.',
    r'\bTRUNCATE\s+TABLE\s+(gold|silver|bronze|governance|audit|api)\.',
    r'\bDROP\s+TABLE\s+(gold|silver|bronze|governance|audit|api)\.',
    r'\bALTER\s+TABLE\s+(gold|silver|bronze|governance|audit|api)\.',
    r'\bINSERT\s+INTO\s+(gold|silver|bronze|governance|audit|api)\.',
]


def normalize(text: str) -> str:
    return re.sub(r'\s+', ' ', text).strip().lower()


def main() -> int:
    results = []

    exists = SQL_PATH.exists()
    results.append((
        'File existence',
        'sql/08_kpi_validation_queries.sql exists',
        exists,
        str(SQL_PATH) if exists else 'missing',
    ))

    if not exists:
        print_results(results)
        return 1

    sql_text = SQL_PATH.read_text(encoding='utf-8')
    normalized = normalize(sql_text)

    for kpi in REQUIRED_KPIS:
        present = kpi.lower() in normalized
        results.append((
            'KPI coverage',
            f'{kpi} validation query is present',
            present,
            'found' if present else 'missing',
        ))

    for obj in REQUIRED_OBJECT_REFERENCES:
        present = obj.lower() in normalized
        results.append((
            'Object references',
            f'{obj} is referenced',
            present,
            'found' if present else 'missing',
        ))

    for column in REQUIRED_OUTPUT_COLUMNS:
        present = column.lower() in normalized
        results.append((
            'Output schema',
            f'{column} output column is present',
            present,
            'found' if present else 'missing',
        ))

    temp_table_present = '#kpi_validation_results' in normalized
    results.append((
        'Result structure',
        'temporary KPI validation result table is used',
        temp_table_present,
        'found' if temp_table_present else 'missing',
    ))

    status_summary_present = (
        'validation_status' in normalized
        and 'validation_count' in normalized
        and 'group by validation_status' in normalized
    )
    results.append((
        'Result structure',
        'validation status summary query is present',
        status_summary_present,
        'found' if status_summary_present else 'missing',
    ))

    kpi_summary_present = (
        'validation_query_count' in normalized
        and 'passed_query_count' in normalized
        and 'failed_query_count' in normalized
    )
    results.append((
        'Result structure',
        'per-KPI summary query is present',
        kpi_summary_present,
        'found' if kpi_summary_present else 'missing',
    ))

    readonly_intent_present = 'read-only' in normalized
    results.append((
        'Safety notes',
        'script documents read-only intent',
        readonly_intent_present,
        'found' if readonly_intent_present else 'missing',
    ))

    for pattern in FORBIDDEN_REAL_TABLE_MUTATIONS:
        match = re.search(pattern, sql_text, flags=re.IGNORECASE)
        results.append((
            'Mutation safety',
            f'forbidden mutation pattern absent: {pattern}',
            match is None,
            'absent' if match is None else f'found: {match.group(0)}',
        ))

    print_results(results)

    failed = [row for row in results if not row[2]]
    return 1 if failed else 0


def print_results(results: list[tuple[str, str, bool, str]]) -> None:
    print('validation_group | validation_name | check_status | detail')
    print('--- | --- | --- | ---')

    for group, name, passed, detail in results:
        status = 'passed' if passed else 'failed'
        print(f'{group} | {name} | {status} | {detail}')

    failed = [row for row in results if not row[2]]

    print()
    print('Summary')
    print('---')
    print(f'passed: {len(results) - len(failed)}')
    print(f'failed: {len(failed)}')


if __name__ == '__main__':
    sys.exit(main())
