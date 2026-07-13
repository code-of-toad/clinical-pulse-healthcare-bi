# ClinicalPulse Power BI Measure Definitions

## 1. Purpose

This document defines the initial ClinicalPulse Power BI DAX measures in both plain English and DAX form.

The measures align to the governed ClinicalPulse KPI dictionary and are intended to support the Sprint 6 dashboard pages built from SQL Server gold schema assets.

ClinicalPulse uses synthetic Synthea data. Measures documented here are not real patient records and should not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. This document is not intended for clinical-decision support.

## 2. Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1588 - Document DAX measure definitions |
| Parent area | ClinicalPulse\Power BI |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Primary deliverable | `powerbi/measure_definitions.md` |
| Validation support | `src/validate_measure_definitions_ab1590.py` |
| Related task | AB#1589 - Draft/build artifact for Document DAX measure definitions |
| Validation task | AB#1590 - Validate and document Document DAX measure definitions |
| Evidence task | AB#1591 - Commit and link implementation evidence for Document DAX measure definitions |

## 3. Power BI Implementation Steps for AB#1588

Perform these steps in the local Power BI file:

```text
clinicalpulse_powerbi_reporting.pbix
```

The `.pbix` file remains local and should not be committed.

### 3.1 Create a Dedicated Measures Table

In Power BI Desktop:

1. Go to **Home -> Enter data**.
2. Create one column named:

```text
Measure Table
```

3. Add one row:

```text
ClinicalPulse Measures
```

4. Click **Load**.
5. Rename the table to:

```text
_Measures
```

6. Hide the placeholder column after the first measure is created.

This keeps dashboard measures separate from imported SQL Server gold tables.

### 3.2 Create Measures

For each measure below:

1. Select the `_Measures` table.
2. Choose **Modeling -> New measure**.
3. Paste the DAX expression.
4. Set the correct format:
   - whole number for counts
   - decimal number for LOS values
   - percentage for rates
5. Use the measure names exactly as documented unless a later story intentionally changes them.

### 3.3 Confirm Table Names

The DAX below assumes Power BI imported SQL Server tables with display names like:

```text
gold fact_encounter
gold fact_readmission
gold fact_observation
gold fact_procedure
gold fact_data_quality_issue
```

If the table names were manually renamed in Power BI, update the DAX table references to match the local model.

### 3.4 Confirm Column Names

Some DAX definitions depend on columns that should exist in the gold model, such as:

```text
encounter_count
patient_key
length_of_stay_days
is_30_day_readmission
check_status
```

If a column name differs in Power BI, use the equivalent gold-column field and update this document before committing.

## 4. Measure Summary

| Measure name | KPI / purpose | Primary source object | Format | Dashboard usage |
|---|---|---|---|---|
| `Total Encounters` | Total Encounters | `gold.fact_encounter` | Whole number | Executive Overview; Patient Flow |
| `Unique Patients` | Unique Patients | `gold.fact_encounter` | Whole number | Executive Overview; Patient Flow |
| `Average LOS` | Average Length of Stay | `gold.fact_encounter` | Decimal number | Executive Overview; Patient Flow |
| `Median LOS` | Median Length of Stay | `gold.fact_encounter` | Decimal number | Patient Flow |
| `30-Day Readmissions` | Readmission numerator | `gold.fact_readmission` | Whole number | Readmissions |
| `Readmission Eligible Encounters` | Readmission denominator | `gold.fact_readmission` | Whole number | Readmissions |
| `30-Day Readmission Rate` | 30-Day Readmission Rate | `gold.fact_readmission` | Percentage | Executive Overview; Readmissions |
| `Observation Volume` | Observation Volume | `gold.fact_observation` | Whole number | Executive Overview; Lab / Observation Operations |
| `Procedure Volume` | Procedure Volume | `gold.fact_procedure` | Whole number | Conditions & Procedures |
| `Data Quality Checks` | Total quality checks | `gold.fact_data_quality_issue` | Whole number | Data Quality & Governance |
| `Data Quality Checks Passed` | Passed quality checks | `gold.fact_data_quality_issue` | Whole number | Data Quality & Governance |
| `Data Quality Pass Rate` | Data Quality Pass Rate | `gold.fact_data_quality_issue` | Percentage | Executive Overview; Data Quality & Governance |
| `API Resource Coverage` | API Resource Coverage placeholder | Future API/FHIR governance assets | Percentage | FHIR API Demonstration |

## 5. Core Encounter Measures

### 5.1 Total Encounters

| Field | Definition |
|---|---|
| Plain-English definition | Count of eligible encounters in the current filter context. |
| KPI alignment | Total Encounters |
| Source object | `gold.fact_encounter` |
| Format | Whole number |
| Validation expectation | Should reconcile to SQL gold validation output of 71,663 before filters. |

```DAX
Total Encounters =
SUM ( 'gold fact_encounter'[encounter_count] )
```

### 5.2 Unique Patients

| Field | Definition |
|---|---|
| Plain-English definition | Count of distinct synthetic patients represented by eligible encounters in the current filter context. |
| KPI alignment | Unique Patients |
| Source object | `gold.fact_encounter` |
| Format | Whole number |
| Validation expectation | Should reconcile to SQL gold validation output of 1,145 before filters. |

```DAX
Unique Patients =
DISTINCTCOUNT ( 'gold fact_encounter'[patient_key] )
```

If the local Power BI model uses `patient_id` instead of `patient_key`, use:

```DAX
Unique Patients =
DISTINCTCOUNT ( 'gold fact_encounter'[patient_id] )
```

### 5.3 Average LOS

| Field | Definition |
|---|---|
| Plain-English definition | Average length of stay in days for encounters with valid non-negative LOS values. |
| KPI alignment | Average Length of Stay |
| Source object | `gold.fact_encounter` |
| Format | Decimal number, 2 to 3 decimals |
| Validation expectation | Should reconcile to SQL gold validation output of approximately 0.247679 before filters. |

```DAX
Average LOS =
AVERAGEX (
    FILTER (
        'gold fact_encounter',
        NOT ISBLANK ( 'gold fact_encounter'[length_of_stay_days] )
            && 'gold fact_encounter'[length_of_stay_days] >= 0
    ),
    'gold fact_encounter'[length_of_stay_days]
)
```

### 5.4 Median LOS

| Field | Definition |
|---|---|
| Plain-English definition | Median length of stay in days for encounters with valid non-negative LOS values. |
| KPI alignment | Median Length of Stay |
| Source object | `gold.fact_encounter` |
| Format | Decimal number, 2 to 3 decimals |
| Validation expectation | Should reconcile to SQL median LOS validation output before filters. |

```DAX
Median LOS =
MEDIANX (
    FILTER (
        'gold fact_encounter',
        NOT ISBLANK ( 'gold fact_encounter'[length_of_stay_days] )
            && 'gold fact_encounter'[length_of_stay_days] >= 0
    ),
    'gold fact_encounter'[length_of_stay_days]
)
```

## 6. Readmission Measures

### 6.1 30-Day Readmissions

| Field | Definition |
|---|---|
| Plain-English definition | Number of eligible index encounters followed by a readmission within 30 days. |
| KPI alignment | 30-Day Readmission Rate numerator |
| Source object | `gold.fact_readmission` |
| Format | Whole number |
| Validation expectation | Should reconcile to SQL readmission numerator validation output. |

```DAX
30-Day Readmissions =
CALCULATE (
    COUNTROWS ( 'gold fact_readmission' ),
    'gold fact_readmission'[is_30_day_readmission] = TRUE ()
)
```

If the local Power BI model imports the readmission flag as numeric 1/0 instead of TRUE/FALSE, use:

```DAX
30-Day Readmissions =
CALCULATE (
    COUNTROWS ( 'gold fact_readmission' ),
    'gold fact_readmission'[is_30_day_readmission] = 1
)
```

### 6.2 Readmission Eligible Encounters

| Field | Definition |
|---|---|
| Plain-English definition | Count of eligible index encounters used as the readmission denominator. |
| KPI alignment | 30-Day Readmission Rate denominator |
| Source object | `gold.fact_readmission` |
| Format | Whole number |
| Validation expectation | Should reconcile to SQL readmission denominator validation output. |

```DAX
Readmission Eligible Encounters =
COUNTROWS ( 'gold fact_readmission' )
```

### 6.3 30-Day Readmission Rate

| Field | Definition |
|---|---|
| Plain-English definition | Percentage of eligible encounters followed by another encounter for the same patient within 30 days. |
| KPI alignment | 30-Day Readmission Rate |
| Source object | `gold.fact_readmission` |
| Format | Percentage, 1 to 2 decimals |
| Validation expectation | Should reconcile to SQL gold validation output of approximately 64.37% before filters. |

```DAX
30-Day Readmission Rate =
DIVIDE ( [30-Day Readmissions], [Readmission Eligible Encounters] )
```

## 7. Activity Volume Measures

### 7.1 Observation Volume

| Field | Definition |
|---|---|
| Plain-English definition | Count of observation records in the current filter context. |
| KPI alignment | Observation Volume |
| Source object | `gold.fact_observation` |
| Format | Whole number |
| Validation expectation | Should reconcile to SQL gold validation output of 945,531 before filters. |

```DAX
Observation Volume =
COUNTROWS ( 'gold fact_observation' )
```

### 7.2 Procedure Volume

| Field | Definition |
|---|---|
| Plain-English definition | Count of procedure records in the current filter context. |
| KPI alignment | Procedure Volume |
| Source object | `gold.fact_procedure` |
| Format | Whole number |
| Validation expectation | Should reconcile to SQL gold validation output of 196,207 before filters. |

```DAX
Procedure Volume =
COUNTROWS ( 'gold fact_procedure' )
```

## 8. Data Quality Measures

### 8.1 Data Quality Checks

| Field | Definition |
|---|---|
| Plain-English definition | Count of implemented data quality checks represented in the reporting trust fact. |
| KPI alignment | Data Quality Pass Rate denominator |
| Source object | `gold.fact_data_quality_issue` |
| Format | Whole number |
| Validation expectation | Should reconcile to the current quality-check count before filters. |

```DAX
Data Quality Checks =
COUNTROWS ( 'gold fact_data_quality_issue' )
```

### 8.2 Data Quality Checks Passed

| Field | Definition |
|---|---|
| Plain-English definition | Count of implemented data quality checks with a passed status. |
| KPI alignment | Data Quality Pass Rate numerator |
| Source object | `gold.fact_data_quality_issue` |
| Format | Whole number |
| Validation expectation | Should reconcile to the current passed quality-check count before filters. |

```DAX
Data Quality Checks Passed =
CALCULATE (
    COUNTROWS ( 'gold fact_data_quality_issue' ),
    'gold fact_data_quality_issue'[check_status] = "passed"
)
```

### 8.3 Data Quality Pass Rate

| Field | Definition |
|---|---|
| Plain-English definition | Percentage of implemented data quality checks that passed. |
| KPI alignment | Data Quality Pass Rate |
| Source object | `gold.fact_data_quality_issue` |
| Format | Percentage, 1 to 2 decimals |
| Validation expectation | Should reconcile to governance quality-check status totals. |

```DAX
Data Quality Pass Rate =
DIVIDE ( [Data Quality Checks Passed], [Data Quality Checks] )
```

## 9. API/FHIR Demonstration Measure

### 9.1 API Resource Coverage

| Field | Definition |
|---|---|
| Plain-English definition | Placeholder percentage for selected API/FHIR resources that have implemented mapping and endpoint coverage. |
| KPI alignment | API Resource Coverage |
| Source object | Future API/FHIR mapping and API views |
| Format | Percentage |
| Validation expectation | Not final until API/FHIR implementation is complete. |

```DAX
API Resource Coverage =
BLANK ()
```

This measure is documented for dashboard planning but should not be interpreted as implemented API/FHIR coverage until the API/FHIR user stories are complete.

## 10. Formatting Standards

| Measure type | Format |
|---|---|
| Counts | Whole number with thousands separator |
| LOS values | Decimal number, 2 to 3 decimals |
| Rates | Percentage, 1 to 2 decimals |
| Placeholder / planned measures | Blank until implementation evidence exists |

## 11. Local Sanity Checks After Creating Measures

Create temporary cards in Power BI Desktop to confirm baseline unfiltered values.

| Measure | Expected unfiltered value / behavior |
|---|---|
| `Total Encounters` | 71,663 |
| `Unique Patients` | 1,145 |
| `Average LOS` | Approximately 0.247679 |
| `30-Day Readmission Rate` | Approximately 64.37% |
| `Observation Volume` | 945,531 |
| `Procedure Volume` | 196,207 |
| `Data Quality Pass Rate` | Based on current governance quality-check results; expected 19 passed out of 20 checks if using the latest known run. |
| `API Resource Coverage` | Blank until API/FHIR scope is implemented. |

These are sanity checks only. Formal DAX-to-SQL reconciliation is handled in the next validation user story.

## 12. Assumptions

- Power BI is connected to SQL Server gold schema objects only.
- The local Power BI table names use imported names such as `gold fact_encounter`.
- The relationship model has already been built according to AB#1584.
- `gold.dim_date[full_date]` is marked as the model date table.
- Count measures should respond to slicers from date, encounter class, organization, age band, condition group, and procedure group where relationships support filtering.
- DAX definitions may need minor column-name adjustments if Power BI imported a column with a different name than expected.
- API/FHIR coverage is documented as planned scope until API/FHIR implementation is complete.

## 13. Limitations

- The `.pbix` file remains local and is not committed.
- This document records DAX definitions and implementation guidance; it does not prove values until measures are reconciled against SQL outputs.
- Some readmission interpretation remains limited by synthetic data and planned-versus-unplanned logic.
- Observation volume must be interpreted with the known governed duplicate-observation caveat.
- Synthetic data does not represent real patients, real hospital operations, clinical evidence, or clinical recommendations.
