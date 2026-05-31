from __future__ import annotations

import argparse
import sys
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
    target_table,
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


def run_quality_checks(fail_on_error: bool) -> int:
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

    if failed_rows and fail_on_error:
        return 1

    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description='Run ClinicalPulse completeness, uniqueness, and referential integrity checks.'
    )
    parser.add_argument(
        '--fail-on-error',
        action='store_true',
        help='Return a non-zero exit code if any quality check fails.',
    )

    args = parser.parse_args()
    return run_quality_checks(fail_on_error=args.fail_on_error)


if __name__ == '__main__':
    raise SystemExit(main())
