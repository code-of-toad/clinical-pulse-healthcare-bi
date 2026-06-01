# KPI Validation Log

## 1. Purpose

This log records the reconciliation of ClinicalPulse core KPI outputs against gold-layer facts and marts before Power BI dashboard development begins.

The purpose is to confirm that governed KPI definitions, SQL validation queries, and gold reporting marts produce consistent KPI outputs.

## 2. Validation Scope

This validation covers the core KPI set defined in `docs/kpi_dictionary.md` and tested through `sql/08_kpi_validation_queries.sql`.

| KPI | Validation source | Comparison source | Status |
|---|---|---|---|
| Total Encounters | `gold.fact_encounter` | `gold.mart_patient_flow` | Passed |
| Unique Patients | `gold.fact_encounter` | `gold.mart_length_of_stay` | Passed |
| Average Length of Stay | `gold.fact_encounter` | `gold.mart_length_of_stay` | Passed |
| Median Length of Stay | `gold.fact_encounter` | `gold.mart_length_of_stay` | Passed |
| 30-Day Readmission Rate | `gold.fact_readmission` | `gold.mart_readmissions` | Passed |
| Observation Volume | `gold.fact_observation` | `gold.mart_lab_operations` | Passed |
| Procedure Volume | `gold.fact_procedure` | `gold.mart_service_utilization` | Passed |
| Data Quality Pass Rate | `gold.fact_data_quality_issue` | `gold.mart_reporting_trust` | Passed |
| API Resource Coverage | API/FHIR views | Expected API scope | Not implemented |

## 3. Reconciled KPI Outputs

| KPI | Reconciled value | Validation result | Notes |
|---|---:|---|---|
| Total Encounters | 71,663 | Passed | Fact and mart totals match exactly. |
| Unique Patients | 1,145 | Passed | Distinct patient keys reconcile across encounter-grain gold objects. |
| Average Length of Stay | 0.247679 days | Passed | Calculated as total LOS days divided by LOS-eligible encounters. |
| Median Length of Stay | 0.033700 days | Passed | Calculated over LOS-eligible encounter rows. |
| 30-Day Readmission Rate | 0.643707 | Passed | Demonstration-grade logic based on next encounter within 30 days. |
| 30-Day Readmission Numerator | 46,130 | Passed | Fact and mart numerator match exactly. |
| 30-Day Readmission Denominator | 71,663 | Passed | Fact and mart denominator match exactly. |
| Observation Volume | 945,531 | Passed | Fact and lab operations mart totals match exactly. |
| Procedure Volume | 196,207 | Passed | Fact and service utilization mart totals match exactly. |
| Data Quality Pass Rate | 0.950000 | Passed | Based on 19 passed checks out of 20 quality checks. |
| API Resource Coverage | 0.000000 | Not implemented | API/FHIR views are planned but not yet created. |

## 4. Validation Summary

| Validation status | Count |
|---|---:|
| Passed | 10 |
| Failed | 0 |
| Not implemented | 1 |

The only non-passing item is `API Resource Coverage`, which is expected at this point because the API/FHIR views are planned for later implementation.

The following views are not yet present:

- `api.vw_fhir_patient`
- `api.vw_fhir_encounter`
- `api.vw_fhir_observation`
- `api.vw_fhir_condition`

This is not treated as a KPI reconciliation failure. It is recorded as implementation pending.

## 5. Reconciliation Interpretation

The operational and governance KPIs are ready to be used as the SQL reference values for Power BI measure development.

Power BI measures should reconcile back to these values unless dashboard filters intentionally change the reporting context.

## 6. Key Assumptions and Limitations

- ClinicalPulse uses synthetic Synthea data and does not represent real patients, real hospital performance, or clinical decision-support evidence.
- The 30-day readmission rate is demonstration-grade. It identifies the next encounter for the same patient within 30 days and does not distinguish planned versus unplanned readmissions.
- `unique_patients_in_group` fields in aggregate marts should not be summed across rows. Unique patient KPIs should use distinct patient keys under the active filter context.
- API Resource Coverage validates selected API/FHIR view availability only and does not imply full FHIR server compliance.
- Final dashboard values must be reconciled again after Power BI measures are implemented.

## 7. Validation Evidence

Validation was performed using:

```text
python src/validate_kpi_validation_queries_ab1557.py
sql/08_kpi_validation_queries.sql
```

The file-level validation for the KPI SQL validation script passed with 42 checks and 0 failures.

The SQL KPI validation produced 10 passed checks, 0 failed checks, and 1 expected not-implemented result for API Resource Coverage.


## Validation script: `src/validate_kpi_validation_log_ab1561.py`

```python
from pathlib import Path
import re
import sys


REPO_ROOT = Path(__file__).resolve().parents[1]
LOG_PATH = REPO_ROOT / 'docs' / 'kpi_validation_log.md'

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
    'sql/08_kpi_validation_queries.sql',
]

REQUIRED_VALUES = [
    '71,663',
    '1,145',
    '0.247679',
    '0.033700',
    '0.643707',
    '46,130',
    '945,531',
    '196,207',
    '0.950000',
]

REQUIRED_CAVEATS = [
    'synthetic',
    'does not represent real patients',
    'does not distinguish planned versus unplanned readmissions',
    'does not imply full FHIR server compliance',
]

REQUIRED_SUMMARY_PHRASES = [
    'Passed | 10',
    'Failed | 0',
    'Not implemented | 1',
    'Power BI',
    'implementation pending',
]


def normalize(text: str) -> str:
    return re.sub(r'\s+', ' ', text).strip().lower()


def main() -> int:
    results = []

    exists = LOG_PATH.exists()
    results.append((
        'File existence',
        'docs/kpi_validation_log.md exists',
        exists,
        str(LOG_PATH) if exists else 'missing',
    ))

    if not exists:
        print_results(results)
        return 1

    markdown = LOG_PATH.read_text(encoding='utf-8')
    normalized = normalize(markdown)

    for kpi in REQUIRED_KPIS:
        present = kpi.lower() in normalized
        results.append((
            'KPI coverage',
            f'{kpi} is documented',
            present,
            'found' if present else 'missing',
        ))

    for obj in REQUIRED_OBJECT_REFERENCES:
        present = obj.lower() in normalized
        results.append((
            'Source references',
            f'{obj} is referenced',
            present,
            'found' if present else 'missing',
        ))

    for value in REQUIRED_VALUES:
        present = value in markdown
        results.append((
            'Reconciled values',
            f'{value} is documented',
            present,
            'found' if present else 'missing',
        ))

    for caveat in REQUIRED_CAVEATS:
        present = caveat.lower() in normalized
        results.append((
            'Required caveats',
            f'"{caveat}" is documented',
            present,
            'found' if present else 'missing',
        ))

    for phrase in REQUIRED_SUMMARY_PHRASES:
        present = phrase.lower() in normalized
        results.append((
            'Validation summary',
            f'"{phrase}" is documented',
            present,
            'found' if present else 'missing',
        ))

    no_failed_status = 'Failed | 0' in markdown
    results.append((
        'Validation outcome',
        'document records zero failed KPI reconciliation checks',
        no_failed_status,
        'found' if no_failed_status else 'missing',
    ))

    api_pending_documented = (
        'api resource coverage' in normalized
        and 'not implemented' in normalized
        and 'not treated as a kpi reconciliation failure' in normalized
    )
    results.append((
        'API pending status',
        'API Resource Coverage pending status is documented as non-failure',
        api_pending_documented,
        'found' if api_pending_documented else 'missing',
    ))

    power_bi_readiness = (
        'sql reference values for power bi measure development' in normalized
        or 'power bi measures should reconcile' in normalized
    )
    results.append((
        'Power BI readiness',
        'document states KPI values are SQL reference values for Power BI',
        power_bi_readiness,
        'found' if power_bi_readiness else 'missing',
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
