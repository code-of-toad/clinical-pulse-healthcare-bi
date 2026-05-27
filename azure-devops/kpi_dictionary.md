# KPI Dictionary

## 1. Purpose

This document defines the standard structure for ClinicalPulse KPI definitions.

The KPI dictionary exists to prevent conflicting interpretations of dashboard metrics. Each metric used in ClinicalPulse should have a documented business question, plain-language definition, formal calculation approach, source objects, validation expectation, ownership, and known limitations before it is treated as reporting-ready.

## 2. Intended Audience

This document is intended for:

- data stewards who review metric meaning, ownership, and governance readiness
- BI developers who implement SQL logic, Power BI measures, and validation queries
- operational stakeholders who need to understand what each metric means
- technical reviewers who need to trace dashboard numbers back to source and transformation logic

## 3. How the KPI Dictionary Will Be Used

ClinicalPulse will use this document as the standard reference for metric definitions across SQL Server, Power BI, governance documentation, and FHIR/API demonstrations where relevant.

A KPI should not be considered final until its dictionary entry defines:

- what business question the metric answers
- what records are included or excluded
- what grain the metric is measured at
- which SQL objects support the metric
- which Power BI measure represents the metric
- how the metric can be validated
- what limitations or data quality dependencies affect interpretation

## 4. Required KPI Definition Fields

| Field | Purpose |
|---|---|
| KPI name | The business-facing name of the metric. |
| Business question | The operational question the KPI helps answer. |
| Plain-English definition | A concise explanation of what the KPI means. |
| Formal formula | The calculation logic expressed in precise terms. |
| Grain | The level at which the metric is calculated, such as encounter, patient, organization, date, or dashboard filter context. |
| Inclusion criteria | Records that should be included in the calculation. |
| Exclusion criteria | Records that should be excluded from the calculation. |
| SQL source objects | Bronze, silver, gold, mart, or view objects used to calculate the KPI. |
| Power BI measure name | The planned or implemented DAX measure name. |
| Owner | The accountable business or project role for the KPI. |
| Steward | The role responsible for definition quality, documentation, and review. |
| Refresh frequency | Expected refresh cadence once the reporting layer is implemented. |
| Validation query | SQL query or validation method used to reconcile the KPI. |
| Data quality dependencies | Data quality checks that affect whether the KPI can be trusted. |
| Known limitations | Interpretation limits, assumptions, or caveats. |
| Related dashboard page | Dashboard page where the KPI is expected to appear. |
| Related FHIR resources | FHIR-style resources related to the KPI, where applicable. |
| Status | Draft, defined, implemented, validated, or retired. |

## 5. Standard KPI Entry Template

```text
KPI name:
Business question:
Plain-English definition:
Formal formula:
Grain:
Inclusion criteria:
Exclusion criteria:
SQL source objects:
Power BI measure name:
Owner:
Steward:
Refresh frequency:
Validation query:
Data quality dependencies:
Known limitations:
Related dashboard page:
Related FHIR resources:
Status:
```

## 6. Initial KPI Skeleton

The following KPI entries define the starting structure for ClinicalPulse. Calculation logic will be refined as the SQL Server model, gold reporting layer, and Power BI semantic model are implemented.

### 6.1 Total Encounters

| Field | Definition |
|---|---|
| KPI name | Total Encounters |
| Business question | How many healthcare encounters occurred in the selected reporting period? |
| Plain-English definition | Count of encounters that meet the selected reporting filters. |
| Formal formula | Count of eligible encounter records. |
| Grain | Encounter. |
| Inclusion criteria | Encounters within the selected date range and reporting scope. |
| Exclusion criteria | Encounters with invalid or unusable encounter identifiers; additional exclusions to be defined during implementation. |
| SQL source objects | `silver.encounter`; planned gold object: `gold.fact_encounter`; planned mart: `gold.mart_patient_flow`. |
| Power BI measure name | `Total Encounters` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | To be defined during reporting implementation. |
| Validation query | Count eligible records from the gold encounter fact or patient flow mart and reconcile against the Power BI measure. |
| Data quality dependencies | Encounter identifier completeness, encounter date validity, source-to-silver row reconciliation. |
| Known limitations | Encounter class and reporting date logic must be clearly defined before final use. |
| Related dashboard page | Executive Overview; Patient Flow |
| Related FHIR resources | Encounter |
| Status | Draft |

### 6.2 Unique Patients

| Field | Definition |
|---|---|
| KPI name | Unique Patients |
| Business question | How many distinct synthetic patients had at least one encounter in the selected reporting scope? |
| Plain-English definition | Count of distinct patients represented in eligible encounters. |
| Formal formula | Distinct count of patient identifiers among eligible encounter records. |
| Grain | Patient within reporting filter context. |
| Inclusion criteria | Patients with at least one eligible encounter in scope. |
| Exclusion criteria | Patient records not linked to an eligible encounter; records with invalid patient identifiers. |
| SQL source objects | `silver.patient`, `silver.encounter`; planned gold objects: `gold.dim_patient`, `gold.fact_encounter`. |
| Power BI measure name | `Unique Patients` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | To be defined during reporting implementation. |
| Validation query | Distinct count patient keys from eligible encounter records in the gold layer. |
| Data quality dependencies | Patient identifier completeness, encounter-to-patient referential integrity. |
| Known limitations | Synthetic population does not represent a real hospital catchment area. |
| Related dashboard page | Executive Overview; Patient Flow |
| Related FHIR resources | Patient; Encounter |
| Status | Draft |

### 6.3 Average Length of Stay

| Field | Definition |
|---|---|
| KPI name | Average Length of Stay |
| Business question | How long do patients remain in care, on average, for selected encounter classes or reporting groups? |
| Plain-English definition | Average duration between encounter start and stop timestamps for eligible encounters. |
| Formal formula | Sum of eligible encounter durations divided by count of eligible encounters. |
| Grain | Encounter, aggregated by dashboard filter context. |
| Inclusion criteria | Encounters with valid start and stop timestamps. Encounter class scope to be defined during implementation. |
| Exclusion criteria | Encounters with missing stop time, missing start time, stop before start, or negative duration. |
| SQL source objects | `silver.encounter`; planned gold object: `gold.fact_encounter`; planned mart: `gold.mart_length_of_stay`. |
| Power BI measure name | `Average LOS` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | To be defined during reporting implementation. |
| Validation query | Recalculate average encounter duration from the gold length-of-stay mart and reconcile against the Power BI measure. |
| Data quality dependencies | Encounter timestamp validity, duration derivation logic, invalid-date flags. |
| Known limitations | Average LOS can be affected by long-stay outliers and synthetic data patterns. |
| Related dashboard page | Executive Overview; Patient Flow |
| Related FHIR resources | Encounter |
| Status | Draft |

### 6.4 Median Length of Stay

| Field | Definition |
|---|---|
| KPI name | Median Length of Stay |
| Business question | What is the typical encounter duration after reducing the influence of long-stay outliers? |
| Plain-English definition | Median duration between encounter start and stop timestamps for eligible encounters. |
| Formal formula | Median of eligible encounter durations. |
| Grain | Encounter, aggregated by dashboard filter context. |
| Inclusion criteria | Encounters with valid start and stop timestamps. Encounter class scope to be defined during implementation. |
| Exclusion criteria | Encounters with missing stop time, missing start time, stop before start, or negative duration. |
| SQL source objects | `silver.encounter`; planned gold object: `gold.fact_encounter`; planned mart: `gold.mart_length_of_stay`. |
| Power BI measure name | `Median LOS` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | To be defined during reporting implementation. |
| Validation query | Recalculate median encounter duration from the gold length-of-stay mart and reconcile against the Power BI measure. |
| Data quality dependencies | Encounter timestamp validity, duration derivation logic, invalid-date flags. |
| Known limitations | Median LOS requires a clearly defined duration unit and encounter inclusion scope. |
| Related dashboard page | Executive Overview; Patient Flow |
| Related FHIR resources | Encounter |
| Status | Draft |

### 6.5 30-Day Readmission Rate

| Field | Definition |
|---|---|
| KPI name | 30-Day Readmission Rate |
| Business question | What percentage of eligible encounters are followed by another encounter for the same patient within 30 days? |
| Plain-English definition | Percentage of eligible index encounters with a subsequent encounter for the same patient within 30 days. |
| Formal formula | Eligible index encounters followed by a subsequent encounter within 30 days divided by total eligible index encounters. |
| Grain | Index encounter. |
| Inclusion criteria | Eligible completed encounters with patient identifier and valid encounter end date. |
| Exclusion criteria | Encounters without valid patient linkage or valid timing fields; planned versus unplanned logic to be defined as an assumption. |
| SQL source objects | `silver.encounter`, `silver.condition`; planned gold objects: `gold.fact_encounter`, `gold.fact_readmission`; planned mart: `gold.mart_readmissions`. |
| Power BI measure name | `30-Day Readmission Rate` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | To be defined during reporting implementation. |
| Validation query | Recalculate readmission numerator and denominator from the gold readmission fact or mart. |
| Data quality dependencies | Patient linkage, encounter date validity, encounter sequencing, duplicate encounter checks. |
| Known limitations | Planned versus unplanned readmission logic may not be fully available in synthetic data and must be documented. |
| Related dashboard page | Executive Overview; Readmissions |
| Related FHIR resources | Patient; Encounter; Condition |
| Status | Draft |

### 6.6 Observation Volume

| Field | Definition |
|---|---|
| KPI name | Observation Volume |
| Business question | How much lab or clinical observation activity occurred in the selected reporting scope? |
| Plain-English definition | Count of observation records by reporting period, observation type, encounter, patient group, or organization. |
| Formal formula | Count of eligible observation records. |
| Grain | Observation. |
| Inclusion criteria | Observation records linked to valid patients and, where required, valid encounters. |
| Exclusion criteria | Observations with missing required identifiers or invalid source linkage. |
| SQL source objects | `silver.observation`; planned gold object: `gold.fact_observation`; planned mart: `gold.mart_lab_operations`. |
| Power BI measure name | `Observation Volume` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | To be defined during reporting implementation. |
| Validation query | Count eligible observation records from the gold observation fact or lab operations mart. |
| Data quality dependencies | Observation identifier completeness, patient and encounter linkage, observation code completeness. |
| Known limitations | Synthea observations may include both lab-like and vital-sign-like records; category logic must be documented. |
| Related dashboard page | Executive Overview; Lab / Observation Operations |
| Related FHIR resources | Observation; Patient; Encounter |
| Status | Draft |

### 6.7 Procedure Volume

| Field | Definition |
|---|---|
| KPI name | Procedure Volume |
| Business question | Which procedures or procedure groups contribute the greatest operational volume? |
| Plain-English definition | Count of procedure records by reporting period, procedure category, encounter class, or organization. |
| Formal formula | Count of eligible procedure records. |
| Grain | Procedure. |
| Inclusion criteria | Procedure records linked to valid patients and encounters where required. |
| Exclusion criteria | Procedure records with missing required identifiers or invalid source linkage. |
| SQL source objects | `silver.procedure`; planned gold object: `gold.fact_procedure`; planned mart: `gold.mart_service_utilization`. |
| Power BI measure name | `Procedure Volume` |
| Owner | Operational Reporting Owner |
| Steward | Data Steward |
| Refresh frequency | To be defined during reporting implementation. |
| Validation query | Count eligible procedure records from the gold procedure fact or service utilization mart. |
| Data quality dependencies | Procedure code completeness, patient linkage, encounter linkage, procedure grouping logic. |
| Known limitations | Procedure grouping logic will determine how useful this KPI is for business interpretation. |
| Related dashboard page | Conditions & Procedures |
| Related FHIR resources | Procedure; Patient; Encounter |
| Status | Draft |

### 6.8 Data Quality Pass Rate

| Field | Definition |
|---|---|
| KPI name | Data Quality Pass Rate |
| Business question | How reliable are the reporting assets based on defined data quality checks? |
| Plain-English definition | Percentage of evaluated checks or records that pass defined validation rules. |
| Formal formula | Passed checks or records divided by total evaluated checks or records. |
| Grain | Quality rule, data asset, or reporting domain. |
| Inclusion criteria | Defined quality checks included in the reporting trust framework. |
| Exclusion criteria | Checks not yet implemented or explicitly marked out of scope. |
| SQL source objects | Planned governance objects: `governance.quality_rule`, `governance.quality_check_result`; planned mart: `gold.mart_reporting_trust`. |
| Power BI measure name | `Data Quality Pass Rate` |
| Owner | Data Governance Owner |
| Steward | Data Steward |
| Refresh frequency | To be defined during validation implementation. |
| Validation query | Recalculate pass and fail counts from governance quality result tables. |
| Data quality dependencies | Completeness of quality rule implementation and consistency of severity/status values. |
| Known limitations | Pass rate depends on rule coverage, rule severity, and whether the metric is calculated by checks or by records. |
| Related dashboard page | Executive Overview; Data Quality & Governance |
| Related FHIR resources | Not applicable |
| Status | Draft |

### 6.9 API Resource Coverage

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
| Refresh frequency | To be defined during API implementation. |
| Validation query | Count selected entities with completed mapping records and API-ready outputs. |
| Data quality dependencies | Mapping completeness, API view readiness, required identifier availability. |
| Known limitations | This KPI demonstrates interoperability coverage only and does not imply full FHIR server compliance. |
| Related dashboard page | FHIR API Demonstration; Data Quality & Governance |
| Related FHIR resources | Patient; Encounter; Observation; Condition; Procedure; Organization; Practitioner |
| Status | Draft |

## 7. Governance Notes

- KPI names should remain stable once used in dashboards.
- Any change to a KPI definition should be documented before dashboard values are refreshed or presented.
- KPI definitions should be reviewed before implementation in Power BI.
- Power BI measures should reconcile to SQL validation queries.
- Known limitations should remain visible to users and reviewers.
- Synthetic-data caveats must be preserved where they affect interpretation.

## 8. Assumptions

- ClinicalPulse uses synthetic Synthea data and does not represent real patients or real hospital performance.
- KPI definitions are initially drafted before all SQL Server and Power BI objects exist.
- Final formulas, source objects, and validation queries may be refined during implementation.
- Gold-layer tables, marts, and Power BI measures will become the authoritative reporting layer once implemented.
- KPI ownership and stewardship roles are modeled for portfolio demonstration and governance clarity.

## 9. Limitations

- This document is a skeleton and does not prove that each KPI has been implemented.
- Some source object names may be updated as the SQL Server model is built.
- Some KPIs depend on derived logic that will be finalized later, such as readmission eligibility, encounter class grouping, procedure grouping, and observation categorization.
- Synthetic EHR data may not support the same operational interpretation as real hospital data.
- API-related KPI fields describe FHIR-aligned demonstration scope, not certified production FHIR compliance.
