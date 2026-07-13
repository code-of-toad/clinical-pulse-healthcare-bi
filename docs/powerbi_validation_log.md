# ClinicalPulse Power BI Validation Log

## 1. Purpose

This document records validation of ClinicalPulse Power BI DAX measures against SQL Server gold-layer validation outputs.

The goal is to confirm that Power BI KPI outputs reconcile to governed SQL baselines before dashboard pages are treated as reliable.

ClinicalPulse uses synthetic Synthea data. The values documented here are not real patient records and should not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. This document is not intended for clinical-decision support.

## 2. Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1592 - Validate DAX measures against SQL outputs |
| Parent area | ClinicalPulse\Power BI |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Primary deliverable | `docs/powerbi_validation_log.md` |
| Validation support | `src/validate_powerbi_validation_log_ab1594.py` |
| Related task | AB#1593 - Draft/build artifact for Validate DAX measures against SQL outputs |
| Validation task | AB#1594 - Validate and document Validate DAX measures against SQL outputs |
| Evidence task | AB#1595 - Commit and link implementation evidence for Validate DAX measures against SQL outputs |

## 3. Validation Scope

This validation covers the initial unfiltered Power BI KPI measures created for the governed gold semantic model.

| In scope | Out of scope |
|---|---|
| Power BI DAX measures documented in `powerbi/measure_definitions.md` | Final dashboard layout and visual design |
| SQL Server gold-layer baseline outputs | Published Power BI Service refresh |
| Unfiltered KPI card reconciliation | Row-level clinical interpretation |
| Core operational and governance measures | Certified production FHIR/API validation |
| Documentation of assumptions and limitations | Production access-control testing |

## 4. Actual Power BI Steps for AB#1592

Perform these steps in the local `.pbix` file:

```text
clinicalpulse_powerbi_reporting.pbix
```

The `.pbix` file remains local and should not be committed.

### 4.1 Create a Temporary Validation Page

1. Open Power BI Desktop.
2. Open `clinicalpulse_powerbi_reporting.pbix`.
3. Create a new temporary page named:

```text
Scratch - KPI Validation
```

4. Add KPI card visuals for the measures listed in this document.
5. Make sure no slicers or page-level filters are active.
6. Confirm the values match the SQL baseline values below.
7. Keep or delete the scratch page locally; do not treat it as a final dashboard page.

### 4.2 Validate Filter State

Before recording results:

- clear all slicers
- clear all visual filters
- clear all page filters
- clear all report filters
- use the unfiltered model context
- confirm Power BI is using SQL Server gold objects only

### 4.3 Compare DAX Cards to SQL Outputs

Use Power BI card visuals for DAX results and SQL Server validation outputs for SQL baselines.

Record a result as passed only when:

- whole-number measures match exactly
- percentage measures match after expected percentage formatting
- decimal measures match within reasonable rounding tolerance
- planned placeholder measures remain blank when implementation is not yet complete

## 5. SQL Baseline Queries

The following SQL queries represent the baseline outputs used to validate the Power BI DAX measures.

### 5.1 Total Encounters

```sql
SELECT
    SUM(encounter_count) AS total_encounters
FROM gold.fact_encounter;
```

Expected SQL result:

```text
71663
```

### 5.2 Unique Patients

```sql
SELECT
    COUNT(DISTINCT patient_key) AS unique_patients
FROM gold.fact_encounter;
```

Expected SQL result:

```text
1145
```

### 5.3 Average LOS

```sql
SELECT
    AVG(CAST(length_of_stay_days AS decimal(18, 6))) AS average_los
FROM gold.fact_encounter
WHERE length_of_stay_days IS NOT NULL
  AND length_of_stay_days >= 0;
```

Expected SQL result:

```text
0.247679
```

Power BI may display this as `0.25` when formatted to two decimals.

### 5.4 Median LOS

```sql
SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY length_of_stay_days)
        OVER () AS median_los
FROM gold.fact_encounter
WHERE length_of_stay_days IS NOT NULL
  AND length_of_stay_days >= 0;
```

Expected SQL result:

```text
Use SQL output from local validation query.
```

### 5.5 30-Day Readmission Rate

```sql
SELECT
    SUM(CASE WHEN is_30_day_readmission = 1 THEN 1 ELSE 0 END) AS readmission_numerator,
    COUNT(*) AS readmission_denominator,
    CAST(SUM(CASE WHEN is_30_day_readmission = 1 THEN 1 ELSE 0 END) AS decimal(18, 6))
        / NULLIF(COUNT(*), 0) AS readmission_rate
FROM gold.fact_readmission;
```

Expected SQL result:

```text
64.37%
```

### 5.6 Observation Volume

```sql
SELECT
    COUNT(*) AS observation_volume
FROM gold.fact_observation;
```

Expected SQL result:

```text
945531
```

### 5.7 Procedure Volume

```sql
SELECT
    COUNT(*) AS procedure_volume
FROM gold.fact_procedure;
```

Expected SQL result:

```text
196207
```

### 5.8 Data Quality Pass Rate

```sql
SELECT
    COUNT(*) AS data_quality_checks,
    SUM(CASE WHEN check_status = 'passed' THEN 1 ELSE 0 END) AS data_quality_checks_passed,
    CAST(SUM(CASE WHEN check_status = 'passed' THEN 1 ELSE 0 END) AS decimal(18, 6))
        / NULLIF(COUNT(*), 0) AS data_quality_pass_rate
FROM gold.fact_data_quality_issue;
```

Expected SQL result:

```text
20 total checks
19 passed checks
95.00% pass rate
```

### 5.9 API Resource Coverage

```sql
-- API Resource Coverage is planned future scope.
-- No final SQL validation query is expected until API/FHIR implementation is complete.
```

Expected Power BI result:

```text
Blank
```

## 6. DAX-to-SQL Reconciliation Results

| Measure | SQL baseline | Power BI DAX result | Tolerance / rule | Status |
|---|---:|---:|---|---|
| `Total Encounters` | 71,663 | 71,663 | Exact match | Passed |
| `Unique Patients` | 1,145 | 1,145 | Exact match | Passed |
| `Average LOS` | 0.247679 | 0.25 displayed | Rounded display match | Passed |
| `30-Day Readmission Rate` | 64.37% | 64.37% | Exact percentage display match | Passed |
| `Observation Volume` | 945,531 | 945,531 | Exact match | Passed |
| `Procedure Volume` | 196,207 | 196,207 | Exact match | Passed |
| `Data Quality Checks` | 20 | 20 | Exact match | Passed |
| `Data Quality Checks Passed` | 19 | 19 | Exact match | Passed |
| `Data Quality Pass Rate` | 95.00% | 95.00% | Exact percentage display match | Passed |
| `API Resource Coverage` | Planned / not implemented | Blank | Expected placeholder behavior | Passed |

## 7. Validation Result Summary

| Validation group | Passed | Failed | Notes |
|---|---:|---:|---|
| Encounter measures | 3 | 0 | Total encounters, unique patients, and average LOS reconciled. |
| Readmission measures | 1 | 0 | 30-day readmission rate reconciled to SQL baseline. |
| Activity volume measures | 2 | 0 | Observation and procedure volumes reconciled. |
| Data quality measures | 3 | 0 | Quality-check totals and pass rate reconciled. |
| Planned API/FHIR placeholder | 1 | 0 | API Resource Coverage correctly remains blank until API/FHIR scope is implemented. |
| Overall | 10 | 0 | Initial DAX-to-SQL validation passed. |

## 8. Evidence Notes

Power BI Desktop validation evidence:

- local file: `clinicalpulse_powerbi_reporting.pbix`
- Power BI page used for validation: `Scratch - KPI Validation`
- `.pbix` file intentionally not committed
- DAX measures created in `_Measures`
- Power BI source layer: SQL Server `gold` schema
- raw CSV files, bronze tables, silver tables, and unmanaged extracts excluded from the Power BI source layer

Screenshot evidence may be captured locally or attached to Azure Boards if needed. Screenshots should avoid credentials, local private paths, and unnecessary row-level synthetic patient detail.

## 9. Assumptions

- Power BI is connected to SQL Server gold schema objects only.
- No slicers, report filters, page filters, or visual filters are active during validation.
- DAX measures use the definitions documented in `powerbi/measure_definitions.md`.
- `gold.dim_date[full_date]` has been marked as the model date table.
- The relationship model from AB#1584 is active in the local `.pbix`.
- Percentage formatting may display rates differently from raw SQL decimal values.
- `Average LOS` may display as `0.25` when the unrounded SQL baseline is approximately `0.247679`.

## 10. Limitations

- This validation log records initial unfiltered KPI reconciliation only.
- This log does not replace future dashboard-level visual validation.
- The `.pbix` file remains local and is not committed.
- Median LOS should be checked using the local SQL validation output if it is shown on a dashboard page.
- Readmission logic is limited by synthetic data and does not distinguish planned from unplanned readmissions.
- Observation volume should be interpreted with the known governed duplicate-observation caveat.
- API Resource Coverage remains a placeholder until API/FHIR implementation is complete.
- Synthetic data does not represent real patients, real hospital operations, clinical evidence, or clinical recommendations.
