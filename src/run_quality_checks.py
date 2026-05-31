from __future__ import annotations

import argparse
import sys
import uuid
from pathlib import Path
from typing import Any

from sqlalchemy import text


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = PROJECT_ROOT / 'src'

if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from db_config import get_sqlalchemy_engine  # noqa: E402


QUALITY_CHECK_QUERY = '''
SELECT
    quality_rule_id,
    rule_name,
    quality_dimension,
    target_schema,
    target_table,
    target_column,
    rule_scope,
    severity,
    total_records,
    failed_records,
    passed_records,
    pass_rate,
    check_status,
    checked_datetime
FROM governance.vw_quality_check_current
WHERE quality_dimension IN (
    'completeness',
    'uniqueness',
    'referential_integrity',
    'validity',
    'consistency',
    'freshness'
)
ORDER BY
    CASE quality_dimension
        WHEN 'completeness' THEN 1
        WHEN 'uniqueness' THEN 2
        WHEN 'referential_integrity' THEN 3
        WHEN 'validity' THEN 4
        WHEN 'consistency' THEN 5
        WHEN 'freshness' THEN 6
        ELSE 7
    END,
    quality_rule_id;
'''


INSERT_QUALITY_RESULT = '''
INSERT INTO governance.quality_check_result (
    quality_check_run_id,
    quality_rule_id,
    rule_name,
    quality_dimension,
    target_schema,
    target_table,
    target_column,
    rule_scope,
    severity,
    total_records,
    failed_records,
    passed_records,
    pass_rate,
    check_status,
    checked_datetime,
    run_source
)
VALUES (
    :quality_check_run_id,
    :quality_rule_id,
    :rule_name,
    :quality_dimension,
    :target_schema,
    :target_table,
    :target_column,
    :rule_scope,
    :severity,
    :total_records,
    :failed_records,
    :passed_records,
    :pass_rate,
    :check_status,
    :checked_datetime,
    :run_source
);
'''


def format_value(value: Any) -> str:
    if value is None:
        return 'NULL'
    return str(value)


def print_results(rows: list[dict[str, Any]]) -> None:
    if not rows:
        print('No quality check rows returned.')
        return

    columns = [
        'quality_rule_id',
        'quality_dimension',
        'target_table',
        'severity',
        'total_records',
        'failed_records',
        'pass_rate',
        'check_status',
    ]

    widths = {
        column: max(
            len(column),
            max(len(format_value(row[column])) for row in rows),
        )
        for column in columns
    }

    header = ' | '.join(column.ljust(widths[column]) for column in columns)
    divider = '-+-'.join('-' * widths[column] for column in columns)

    print(header)
    print(divider)

    for row in rows:
        print(
            ' | '.join(
                format_value(row[column]).ljust(widths[column])
                for column in columns
            )
        )


def persist_results(rows: list[dict[str, Any]]) -> str:
    quality_check_run_id = str(uuid.uuid4())

    insert_rows = [
        {
            **row,
            'quality_check_run_id': quality_check_run_id,
            'run_source': 'src/run_quality_checks.py',
        }
        for row in rows
    ]

    engine = get_sqlalchemy_engine()

    with engine.begin() as connection:
        connection.execute(text(INSERT_QUALITY_RESULT), insert_rows)

    return quality_check_run_id


def run_quality_checks(fail_on_error: bool, persist: bool) -> int:
    engine = get_sqlalchemy_engine()

    with engine.connect() as connection:
        result = connection.execute(text(QUALITY_CHECK_QUERY))
        rows = [dict(row._mapping) for row in result]

    print_results(rows)

    failed_rows = [
        row for row in rows
        if row['check_status'] != 'passed'
    ]

    print()
    print(f'Quality checks executed: {len(rows)}')
    print(f'Quality checks passed: {len(rows) - len(failed_rows)}')
    print(f'Quality checks failed: {len(failed_rows)}')

    if persist and rows:
        quality_check_run_id = persist_results(rows)
        print()
        print(f'Quality check run persisted: {quality_check_run_id}')
        print(f'Persisted result rows: {len(rows)}')
    elif not persist:
        print()
        print('Quality check results were not persisted.')

    if failed_rows and fail_on_error:
        return 1

    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description='Run and persist ClinicalPulse data quality checks.'
    )
    parser.add_argument(
        '--fail-on-error',
        action='store_true',
        help='Return a non-zero exit code if any quality check fails.',
    )
    parser.add_argument(
        '--no-persist',
        action='store_true',
        help='Run checks without inserting results into governance.quality_check_result.',
    )

    args = parser.parse_args()

    return run_quality_checks(
        fail_on_error=args.fail_on_error,
        persist=not args.no_persist,
    )


if __name__ == '__main__':
    raise SystemExit(main())
