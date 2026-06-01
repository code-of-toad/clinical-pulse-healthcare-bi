# Sprint 5 Summary: Gold Layer and Marts

## 1. Sprint Purpose

Sprint 5 completed the ClinicalPulse gold reporting layer needed before Power BI development. The sprint converted validated silver-layer healthcare data into reporting-ready dimensions, facts, marts, KPI definitions, KPI validation queries, and KPI reconciliation documentation.

The sprint focused on making the data model usable for hospital operational BI, including patient flow, encounter volume, length of stay, readmissions, lab and observation activity, service utilization, and reporting trust.

## 2. Completed User Stories

| Work Item | User Story | Status | Primary Deliverable(s) |
|---:|---|---|---|
| AB#1504 | Create gold dimensions | Completed | `sql/04_create_gold_tables.sql`, `sql/06_transform_silver_to_gold.sql` |
| AB#1508 | Create gold encounter and readmission facts | Completed | `sql/04_create_gold_tables.sql`, `sql/06_transform_silver_to_gold.sql` |
| AB#1512 | Create gold condition, observation, and procedure facts | Completed | `sql/04_create_gold_tables.sql`, `sql/06_transform_silver_to_gold.sql` |
| AB#1516 | Create gold data quality issue fact | Completed | `sql/04_create_gold_tables.sql`, `sql/06_transform_silver_to_gold.sql` |
| AB#1521 | Create patient flow mart | Completed | `sql/06_transform_silver_to_gold.sql` |
| AB#1525 | Create length-of-stay and readmission marts | Completed | `sql/06_transform_silver_to_gold.sql` |
| AB#1529 | Create lab operations and service utilization marts | Completed | `sql/06_transform_silver_to_gold.sql` |
| AB#1533 | Create reporting trust mart | Completed | `sql/06_transform_silver_to_gold.sql` |
| AB#1554 | Define core KPI dictionary entries | Completed | `docs/kpi_dictionary.md`, `src/validate_kpi_dictionary_ab1554.py` |
| AB#1557 | Write SQL validation queries for core KPIs | Completed | `sql/08_kpi_validation_queries.sql`, `src/validate_kpi_validation_queries_ab1557.py` |
| AB#1561 | Reconcile KPI outputs to gold marts | Completed | `docs/kpi_validation_log.md`, `src/validate_kpi_validation_log_ab1561.py` |

## 3. Gold Dimensions Created

| Object | Purpose | Validated Row Count |
|---|---|---:|
| `gold.dim_patient` | Patient demographic and geographic reporting attributes without direct identifiers | 1,145 |
| `gold.dim_date` | Calendar dimension for date-based reporting | 40,365 |
| `gold.dim_organization` | Organization reference dimension derived from encounter organization IDs | 727 |
| `gold.dim_provider` | Provider reference dimension derived from encounter provider IDs | 727 |
| `gold.dim_encounter_class` | Encounter class grouping and slicer dimension | 10 |
| `gold.dim_condition` | Condition definition dimension | 268 |
| `gold.dim_observation` | Observation definition dimension | 296 |
| `gold.dim_procedure` | Procedure definition dimension | 363 |

Validation result: **30 checks passed, 0 failed**.

## 4. Gold Facts Created

| Object | Grain | Purpose | Validated Row Count |
|---|---|---|---:|
| `gold.fact_encounter` | Encounter | Encounter volume, LOS, encounter class, organization/provider reporting | 71,663 |
| `gold.fact_readmission` | Index encounter | 30-day readmission numerator and denominator logic | 71,663 |
| `gold.fact_condition` | Condition record | Case-mix and condition activity reporting | 43,758 |
| `gold.fact_observation` | Observation record | Lab and clinical observation activity reporting | 945,531 |
| `gold.fact_procedure` | Procedure record | Procedure and service-utilization reporting | 196,207 |
| `gold.fact_data_quality_issue` | Quality-check result | Quality issue, pass/fail, severity, and reporting trust analysis | 20 |

Validation results:

| User Story | Validation Result |
|---|---|
| AB#1508 encounter/readmission facts | 26 checks passed, 0 failed |
| AB#1512 condition/observation/procedure facts | 48 checks passed, 0 failed |
| AB#1516 data quality issue fact | 20 checks passed, 0 failed |

## 5. Gold Marts Created

| Object | Type | Purpose | Validated Row Count |
|---|---|---|---:|
| `gold.mart_patient_flow` | View | Encounter trends, patient flow indicators, encounter class reporting | 68,981 |
| `gold.mart_length_of_stay` | View | Encounter-grain LOS reporting and LOS buckets | 71,663 |
| `gold.mart_readmissions` | View | Index-encounter readmission reporting | 71,663 |
| `gold.mart_lab_operations` | View | Observation volume, numeric observations, lab/clinical activity reporting | 935,704 |
| `gold.mart_service_utilization` | View | Procedure volume, procedure duration, service utilization reporting | 186,119 |
| `gold.mart_reporting_trust` | View | Quality pass/fail status, severity, readiness, and trust score reporting | 20 |

Validation results:

| User Story | Validation Result |
|---|---|
| AB#1521 patient flow mart | 22 checks passed, 0 failed |
| AB#1525 LOS/readmission marts | 32 checks passed, 0 failed |
| AB#1529 lab/service marts | 33 checks passed, 0 failed |
| AB#1533 reporting trust mart | 23 checks passed, 0 failed |

## 6. Core KPI Definitions and Validation

The KPI dictionary was upgraded from a skeleton into defined entries for the governed core KPI set.

| KPI | Status |
|---|---|
| Total Encounters | Defined |
| Unique Patients | Defined |
| Average Length of Stay | Defined |
| Median Length of Stay | Defined |
| 30-Day Readmission Rate | Defined |
| Observation Volume | Defined |
| Procedure Volume | Defined |
| Data Quality Pass Rate | Defined |
| API Resource Coverage | Defined |

KPI dictionary validation result: **202 checks passed, 0 failed**.

## 7. Reconciled KPI Outputs

The core KPI SQL validation script reconciled KPI outputs across gold facts and gold marts.

| KPI | Reconciled Value | Status |
|---|---:|---|
| Total Encounters | 71,663 | Passed |
| Unique Patients | 1,145 | Passed |
| Average Length of Stay | 0.247679 days | Passed |
| Median Length of Stay | 0.033700 days | Passed |
| 30-Day Readmission Rate | 0.643707 | Passed |
| 30-Day Readmission Numerator | 46,130 | Passed |
| 30-Day Readmission Denominator | 71,663 | Passed |
| Observation Volume | 945,531 | Passed |
| Procedure Volume | 196,207 | Passed |
| Data Quality Pass Rate | 0.950000 | Passed |
| API Resource Coverage | 0.000000 | Not implemented |

The API Resource Coverage result is expected at this point because the FHIR/API views are planned but not yet implemented.

SQL KPI validation result: **10 passed, 0 failed, 1 not implemented**.

File-level validation for `sql/08_kpi_validation_queries.sql`: **42 checks passed, 0 failed**.

## 8. Key Assumptions and Limitations

- ClinicalPulse uses synthetic Synthea data and does not represent real patients, real hospital performance, or clinical decision-support evidence.
- The 30-day readmission rate is demonstration-grade. It identifies the next encounter for the same patient within 30 days and does not distinguish planned versus unplanned readmissions.
- The current readmission rate is high because the logic counts any subsequent encounter, including routine or follow-up encounters, where the synthetic data supports that sequence.
- `unique_patients_in_group` fields in aggregate marts should not be summed across rows. Unique patient KPIs should be calculated using distinct patient keys under the active filter context.
- Synthea observations include both lab-like and vital-sign-like records. Strict lab-only classification may be refined later.
- API Resource Coverage validates selected API/FHIR view availability only and does not imply full FHIR server compliance.

## 9. Validation Artifacts

| Artifact | Purpose |
|---|---|
| `src/validate_kpi_dictionary_ab1554.py` | Validates required KPI dictionary entries, fields, source references, and caveats |
| `sql/08_kpi_validation_queries.sql` | Provides independent SQL validation queries for core KPIs |
| `src/validate_kpi_validation_queries_ab1557.py` | Validates structure, coverage, source references, and read-only safety of the KPI SQL validation script |
| `docs/kpi_validation_log.md` | Records reconciled KPI outputs before Power BI work begins |
| `src/validate_kpi_validation_log_ab1561.py` | Validates that the KPI validation log captures required KPIs, outputs, source references, caveats, and Power BI readiness notes |

## 10. Sprint Outcome

Sprint 5 successfully produced a reporting-ready gold layer for ClinicalPulse. The database now contains validated gold dimensions, facts, and marts, along with governed KPI definitions and reconciliation evidence.

The project is now ready to proceed into Power BI semantic modeling and dashboard development, using the Sprint 5 gold marts and KPI validation outputs as the SQL reference layer.

## 11. Recommended Pull Request Summary

```text
Completed Sprint 5 gold layer and mart work for ClinicalPulse.

Implemented reporting-ready gold dimensions, encounter/readmission/condition/observation/procedure/data-quality facts, patient flow, LOS, readmission, lab operations, service utilization, and reporting trust marts. Defined core KPI dictionary entries, added SQL KPI validation queries, and documented KPI reconciliation outputs before Power BI development.

Validation completed with zero failed checks across implemented gold objects and KPI reconciliation. API Resource Coverage remains expectedly not implemented until FHIR/API views are built in a later scope.
```

## 12. Suggested Commit References

```bash
git add sql/04_create_gold_tables.sql sql/06_transform_silver_to_gold.sql docs/kpi_dictionary.md docs/kpi_validation_log.md sql/08_kpi_validation_queries.sql src/validate_kpi_dictionary_ab1554.py src/validate_kpi_validation_queries_ab1557.py src/validate_kpi_validation_log_ab1561.py
git commit -m "Complete Sprint 5 gold layer marts and KPI validation"
git push
```
