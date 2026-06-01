# KPI Dictionary

## 1. Purpose

This document defines the governed KPI entries for ClinicalPulse.

The KPI dictionary exists to prevent conflicting interpretations of dashboard metrics. Each ClinicalPulse KPI should have a documented business question, definition, formal formula, grain, source objects, validation approach, ownership, limitations, and data quality dependencies before it is treated as reporting-ready.

## 2. Intended Audience

This document is intended for:

- data stewards who review metric meaning, ownership, and governance readiness
- BI developers who implement SQL logic, Power BI measures, and validation queries
- operational stakeholders who need to understand what each metric means
- technical reviewers who need to trace dashboard numbers back to source and transformation logic

## 3. KPI Governance Rules

- KPI names should remain stable once used in dashboards.
- Power BI measures should reconcile to SQL validation queries.
- Gold-layer facts, dimensions, and marts are the authoritative reporting layer for implemented KPIs.
- Synthetic-data limitations must remain visible where they affect interpretation.
- Changes to KPI definitions should be documented before dashboard values are refreshed or presented.

## 4. Required KPI Definition Fields

| Field | Purpose |
|---|---|
| KPI name | Business-facing metric name. |
| Business question | Operational question the KPI helps answer. |
| Plain-English definition | Concise explanation of what the KPI means. |
| Formal formula | Precise calculation logic. |
| Grain | Level at which the metric is calculated. |
| Inclusion criteria | Records included in the calculation. |
| Exclusion criteria | Records excluded from the calculation. |
| SQL source objects | SQL objects used to calculate or validate the KPI. |
| Power BI measure name | Planned or implemented DAX measure name. |
| Owner | Accountable business or project role. |
| Steward | Role responsible for definition quality and review. |
| Refresh frequency | Expected refresh cadence. |
| Validation query | SQL validation approach used to reconcile the KPI. |
| Data quality dependencies | Data quality checks that affect trust. |
| Known limitations | Interpretation limits, assumptions, or caveats. |
| Related dashboard page | Dashboard page where the KPI appears or is planned. |
| Related FHIR resources | FHIR-style resources related to the KPI, where applicable. |
| Status | Draft, Defined, Implemented, Validated, or Retired. |

## 5. Core KPI Entries

### 5.1 Total Encounters

| Field | Definition |
|---|---|
| KPI name | Total Encounters |
| Business question | How many healthcare encounters occurred in the selected reporting period? |
| Plain-English definition | Count of eligible encounter records represented in the gold reporting layer. |
| Formal formula | `SUM(gold.fact_encounter.encounter_count)` or `SUM(gold.mart_patient_flow.total_encounters)` within the selected filter context. |
| Grain | Encounter, aggregated by dashboard filter context. |
| Inclusion criteria | Encounters loaded into `gold.fact_encounter` with a valid encounter identifier. |
| Exclusion criteria | Records without a usable encounter identifier. Additional dashboard-specific exclusions must be documented where applied. |
| SQL source objects | `silver.encounter`; `gold.fact_encounter`; `gold.mart_patient_flow`; `gold.mart_length_of_stay`. |
| Power BI measure name | `Total Encounters` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | On gold-layer refresh. |
| Validation query | Reconcile `SUM(encounter_count)` from `gold.fact_encounter` to `SUM(total_encounters)` from `gold.mart_patient_flow`. |
| Data quality dependencies | Encounter identifier completeness, encounter identifier uniqueness, encounter date validity, encounter-to-patient referential integrity. |
| Known limitations | Synthetic encounter volume does not represent real hospital utilization. Encounter class and date filters must be clearly communicated. |
| Related dashboard page | Executive Overview; Patient Flow |
| Related FHIR resources | Encounter |
| Status | Defined |

### 5.2 Unique Patients

| Field | Definition |
|---|---|
| KPI name | Unique Patients |
| Business question | How many distinct synthetic patients had at least one eligible encounter in the selected reporting scope? |
| Plain-English definition | Count of distinct patients represented in eligible encounter activity. |
| Formal formula | `COUNT(DISTINCT gold.fact_encounter.patient_key)` within the selected filter context. |
| Grain | Patient within dashboard filter context. |
| Inclusion criteria | Patient keys linked to eligible encounter records in `gold.fact_encounter`. |
| Exclusion criteria | Encounter records without a resolvable patient key. |
| SQL source objects | `silver.patient`; `silver.encounter`; `gold.dim_patient`; `gold.fact_encounter`; `gold.mart_patient_flow`. |
| Power BI measure name | `Unique Patients` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | On gold-layer refresh. |
| Validation query | Recalculate distinct `patient_key` from `gold.fact_encounter` under the same date and slicer filters used in Power BI. |
| Data quality dependencies | Patient identifier completeness, patient identifier uniqueness, encounter-to-patient referential integrity. |
| Known limitations | `unique_patients_in_group` in marts is distinct only within each mart row and should not be summed across grouped rows. The synthetic population does not represent a real hospital catchment area. |
| Related dashboard page | Executive Overview; Patient Flow |
| Related FHIR resources | Patient; Encounter |
| Status | Defined |

### 5.3 Average Length of Stay

| Field | Definition |
|---|---|
| KPI name | Average Length of Stay |
| Business question | How long do patients remain in care on average for selected encounter classes or reporting groups? |
| Plain-English definition | Average duration between encounter start and stop timestamps for LOS-eligible encounters. |
| Formal formula | `SUM(gold.mart_length_of_stay.los_days_numerator) / SUM(gold.mart_length_of_stay.los_eligible_encounter_count)`. |
| Grain | Encounter, aggregated by dashboard filter context. |
| Inclusion criteria | Encounters with valid start and stop timestamps and non-null `length_of_stay_days`. |
| Exclusion criteria | Encounters with missing start time, missing stop time, stop before start, invalid timestamps, or null LOS. |
| SQL source objects | `silver.encounter`; `gold.fact_encounter`; `gold.mart_length_of_stay`; `gold.dim_encounter_class`; `gold.dim_date`. |
| Power BI measure name | `Average LOS` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | On gold-layer refresh. |
| Validation query | Reconcile `SUM(los_days_numerator) / SUM(los_eligible_encounter_count)` from `gold.mart_length_of_stay` to the Power BI measure. |
| Data quality dependencies | Encounter timestamp validity, duration derivation logic, invalid-date flags, encounter class consistency. |
| Known limitations | Average LOS is sensitive to long-stay outliers and synthetic data patterns. |
| Related dashboard page | Executive Overview; Patient Flow; Length of Stay |
| Related FHIR resources | Encounter |
| Status | Defined |

### 5.4 Median Length of Stay

| Field | Definition |
|---|---|
| KPI name | Median Length of Stay |
| Business question | What is the typical encounter duration after reducing the influence of long-stay outliers? |
| Plain-English definition | Median `length_of_stay_days` among LOS-eligible encounters. |
| Formal formula | Median of `gold.mart_length_of_stay.length_of_stay_days` where `los_eligible_encounter_count = 1`. |
| Grain | Encounter, aggregated by dashboard filter context. |
| Inclusion criteria | Encounters with valid start and stop timestamps and non-null `length_of_stay_days`. |
| Exclusion criteria | Encounters with missing start time, missing stop time, stop before start, invalid timestamps, or null LOS. |
| SQL source objects | `silver.encounter`; `gold.fact_encounter`; `gold.mart_length_of_stay`; `gold.dim_encounter_class`; `gold.dim_date`. |
| Power BI measure name | `Median LOS` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | On gold-layer refresh. |
| Validation query | Recalculate the median over `gold.mart_length_of_stay.length_of_stay_days` where `los_eligible_encounter_count = 1` and reconcile to the Power BI measure. |
| Data quality dependencies | Encounter timestamp validity, duration derivation logic, invalid-date flags, encounter class consistency. |
| Known limitations | Median LOS requires filter context to be clear. It should be interpreted alongside encounter class and organization filters. |
| Related dashboard page | Executive Overview; Patient Flow; Length of Stay |
| Related FHIR resources | Encounter |
| Status | Defined |

### 5.5 30-Day Readmission Rate

| Field | Definition |
|---|---|
| KPI name | 30-Day Readmission Rate |
| Business question | What percentage of eligible encounters are followed by another encounter for the same patient within 30 days? |
| Plain-English definition | Percentage of eligible index encounters that have a subsequent encounter for the same patient within 30 days of the index encounter stop time. |
| Formal formula | `SUM(gold.mart_readmissions.readmission_rate_numerator) / SUM(gold.mart_readmissions.readmission_rate_denominator)`. |
| Grain | Index encounter. |
| Inclusion criteria | Eligible completed encounters with patient linkage, valid start timestamp, valid stop timestamp, and stop time greater than or equal to start time. |
| Exclusion criteria | Encounters without valid patient linkage or valid timing fields. |
| SQL source objects | `silver.encounter`; `gold.fact_encounter`; `gold.fact_readmission`; `gold.mart_readmissions`; `gold.dim_patient`; `gold.dim_encounter_class`; `gold.dim_date`. |
| Power BI measure name | `30-Day Readmission Rate` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | On gold-layer refresh. |
| Validation query | Reconcile `SUM(readmission_rate_numerator)` and `SUM(readmission_rate_denominator)` from `gold.mart_readmissions` to `gold.fact_readmission` and the Power BI measure. |
| Data quality dependencies | Patient linkage, encounter date validity, encounter sequencing, duplicate encounter checks. |
| Known limitations | Current logic is demonstration-grade. It identifies the next encounter for the same patient within 30 days and does not distinguish planned versus unplanned readmissions. The result should not be interpreted as a real hospital readmission rate. |
| Related dashboard page | Executive Overview; Readmissions |
| Related FHIR resources | Patient; Encounter; Condition |
| Status | Defined |

### 5.6 Observation Volume

| Field | Definition |
|---|---|
| KPI name | Observation Volume |
| Business question | How much lab or clinical observation activity occurred in the selected reporting scope? |
| Plain-English definition | Count of eligible observation records in the gold reporting layer. |
| Formal formula | `SUM(gold.mart_lab_operations.observation_volume)`. |
| Grain | Observation, aggregated by dashboard filter context. |
| Inclusion criteria | Observation records loaded into `gold.fact_observation`. |
| Exclusion criteria | Observation records excluded by dashboard filters or future documented lab-only classification rules. |
| SQL source objects | `silver.observation`; `gold.fact_observation`; `gold.dim_observation`; `gold.mart_lab_operations`; `gold.dim_date`; `gold.dim_encounter_class`. |
| Power BI measure name | `Observation Volume` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | On gold-layer refresh. |
| Validation query | Reconcile `SUM(observation_count)` from `gold.fact_observation` to `SUM(observation_volume)` from `gold.mart_lab_operations`. |
| Data quality dependencies | Observation patient linkage, observation encounter linkage when present, observation code completeness, observation datetime validity, duplicate observation findings. |
| Known limitations | Synthea observations include both lab-like and vital-sign-like records. Strict lab-only grouping may be refined later. Governed duplicate observation findings should remain visible and not be silently suppressed. |
| Related dashboard page | Executive Overview; Lab / Observation Operations |
| Related FHIR resources | Observation; Patient; Encounter |
| Status | Defined |

### 5.7 Procedure Volume

| Field | Definition |
|---|---|
| KPI name | Procedure Volume |
| Business question | Which procedures or procedure groups contribute the greatest operational volume? |
| Plain-English definition | Count of eligible procedure records in the gold reporting layer. |
| Formal formula | `SUM(gold.mart_service_utilization.procedure_volume)`. |
| Grain | Procedure, aggregated by dashboard filter context. |
| Inclusion criteria | Procedure records loaded into `gold.fact_procedure`. |
| Exclusion criteria | Procedure records excluded by dashboard filters or future documented service-line grouping rules. |
| SQL source objects | `silver.procedure`; `gold.fact_procedure`; `gold.dim_procedure`; `gold.mart_service_utilization`; `gold.dim_date`; `gold.dim_encounter_class`. |
| Power BI measure name | `Procedure Volume` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | On gold-layer refresh. |
| Validation query | Reconcile `SUM(procedure_count)` from `gold.fact_procedure` to `SUM(procedure_volume)` from `gold.mart_service_utilization`. |
| Data quality dependencies | Procedure patient linkage, procedure encounter linkage, procedure code completeness, procedure datetime validity, procedure grouping logic. |
| Known limitations | Procedure grouping depends on the derived `procedure_category` field and may be refined for dashboard presentation. |
| Related dashboard page | Conditions & Procedures; Service Utilization |
| Related FHIR resources | Procedure; Patient; Encounter |
| Status | Defined |

### 5.8 Data Quality Pass Rate

| Field | Definition |
|---|---|
| KPI name | Data Quality Pass Rate |
| Business question | How reliable are the reporting assets based on defined quality checks? |
| Plain-English definition | Percentage of quality checks that passed in the selected reporting scope. |
| Formal formula | `SUM(gold.mart_reporting_trust.passed_check_count) / SUM(gold.mart_reporting_trust.quality_check_count)`. |
| Grain | Quality rule, target object, quality dimension, severity, or dashboard filter context. |
| Inclusion criteria | Implemented quality checks represented in `gold.fact_data_quality_issue` and `gold.mart_reporting_trust`. |
| Exclusion criteria | Quality checks not yet implemented or explicitly out of scope. |
| SQL source objects | `governance.quality_rule`; `governance.quality_check_result`; `gold.fact_data_quality_issue`; `gold.mart_reporting_trust`. |
| Power BI measure name | `Data Quality Pass Rate` |
| Owner | Data Governance Owner |
| Steward | Data Steward |
| Refresh frequency | On quality-check run and gold-layer refresh. |
| Validation query | Reconcile passed and total check counts from `gold.mart_reporting_trust` to `gold.fact_data_quality_issue`. |
| Data quality dependencies | Completeness of quality-rule implementation, consistency of severity/status values, latest-run tagging, quality result persistence. |
| Known limitations | This KPI is check-count based by default. Record-level pass rate is available separately as `record_pass_rate` and may tell a different story when one failed rule affects many rows. |
| Related dashboard page | Executive Overview; Data Quality & Governance |
| Related FHIR resources | Not applicable |
| Status | Defined |

### 5.9 API Resource Coverage

| Field | Definition |
|---|---|
| KPI name | API Resource Coverage |
| Business question | Which selected ClinicalPulse entities are mapped to FHIR-style API resources? |
| Plain-English definition | Percentage of selected entities with documented FHIR-style mappings and API-ready views or endpoints. |
| Formal formula | Count of selected entities with complete API/FHIR mapping divided by count of selected entities in API scope. |
| Grain | Entity or FHIR-style resource. |
| Inclusion criteria | Entities selected for the ClinicalPulse FHIR/API demonstration. |
| Exclusion criteria | Entities not included in the API demonstration scope. |
| SQL source objects | Planned governance object: `governance.fhir_mapping`; planned API views: `api.vw_fhir_patient`, `api.vw_fhir_encounter`, `api.vw_fhir_observation`, `api.vw_fhir_condition`. |
| Power BI measure name | `API Resource Coverage` |
| Owner | Data Platform Owner |
| Steward | Data Steward |
| Refresh frequency | On API/FHIR mapping update. |
| Validation query | Count selected entities with completed mapping records and API-ready outputs once FHIR mapping and API views are implemented. |
| Data quality dependencies | Mapping completeness, API view readiness, required identifier availability, JSON-ready field availability. |
| Known limitations | This KPI demonstrates interoperability coverage only and does not imply full FHIR server compliance. |
| Related dashboard page | FHIR API Demonstration; Data Quality & Governance |
| Related FHIR resources | Patient; Encounter; Observation; Condition; Procedure; Organization; Practitioner |
| Status | Defined |

## 6. Current Implementation Notes

- Gold-layer encounter, readmission, condition, observation, procedure, data quality issue facts, and reporting marts are now the primary SQL reporting sources for implemented operational KPIs.
- Power BI measures have not yet been implemented in this document. The listed measure names are governed targets for the Power BI semantic model.
- API Resource Coverage is defined now but depends on later FHIR mapping, API views, and endpoint work.
- KPI validation should reconcile Power BI values back to SQL outputs before dashboard screenshots are treated as final.

## 7. Synthetic Data Caveat

ClinicalPulse uses synthetic Synthea data and does not represent real patients, real hospital performance, or clinical decision-support evidence. KPI outputs demonstrate data modeling, BI logic, governance, and validation practices only.
