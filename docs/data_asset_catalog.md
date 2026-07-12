# ClinicalPulse Data Asset Catalog

## 1. Purpose

This catalog identifies the major ClinicalPulse data assets used to support governed healthcare BI reporting.

It is intended to help data stewards, BI developers, and reviewers understand which tables, views, marts, dashboards, and API-facing assets exist, what each asset is used for, who owns or stewards it, how it is validated, and what assumptions or limitations apply.

ClinicalPulse uses synthetic Synthea data. Assets documented here are not real patient records and should not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. This catalog is not intended for clinical-decision support.

## 2. Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1566 - Create data asset catalog |
| Parent area | ClinicalPulse\Data Quality & Governance |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Primary deliverable | `docs/data_asset_catalog.md` |
| Validation support | `src/validate_data_asset_catalog_ab1568.py` |
| Related task | AB#1567 - Draft/build artifact for Create data asset catalog |
| Validation task | AB#1568 - Validate and document Create data asset catalog |

## 3. Catalog Scope

This catalog covers the major assets currently relevant to governed reporting and portfolio review:

- SQL Server bronze source-preserving tables
- SQL Server silver standardized entity tables
- SQL Server gold dimensions, facts, and reporting marts
- governance and audit support assets
- planned Power BI semantic model and dashboard pages
- planned FHIR/API demonstration views

The catalog focuses on data-product meaning and governance readiness. It is not a full column-level data dictionary.

## 4. Standard Catalog Fields

| Field | Description |
|---|---|
| Asset name | Schema-qualified table/view name, dashboard page name, or logical asset name. |
| Asset type | Table, view, mart, dashboard page, semantic model, or planned API view. |
| Layer / domain | Bronze, silver, gold, governance, audit, Power BI, or API. |
| Grain / purpose | The business or technical grain of the asset. |
| Current status | Implemented, in progress, planned, or not implemented. |
| Owner role | Accountable project or business role. |
| Steward role | Role responsible for definition quality, documentation, and review. |
| Upstream assets | Source assets used to create or support the asset. |
| Downstream usage | Reporting, validation, dashboard, or API usage. |
| Validation / trust notes | How the asset is validated or what trust caveats apply. |
| Usage notes | Important assumptions, limits, or safe-use guidance. |

## 5. Ownership and Stewardship Roles

| Role | Responsibility |
|---|---|
| Data Platform Owner | Accountable for SQL Server schemas, data-layer structure, and API-facing data assets. |
| BI Developer | Responsible for Power BI semantic model, DAX measures, dashboard pages, and SQL-to-Power BI reconciliation. |
| Data Steward | Responsible for metric definitions, quality rules, lineage notes, catalog quality, and readiness review. |
| Operational Reporting Owner | Accountable for business interpretation of operational KPIs and dashboard usefulness. |
| Portfolio Reviewer | Uses the catalog to understand implementation scope, governance maturity, and project safety. |

## 6. Bronze Layer Assets

Bronze assets preserve source-like Synthea structures with ingestion metadata. They are not intended for direct Power BI reporting.

| Asset name | Asset type | Grain / purpose | Current status | Owner role | Steward role | Upstream assets | Downstream usage | Validation / trust notes | Usage notes |
|---|---|---|---|---|---|---|---|---|---|
| `bronze.patients` | Table | One row per source patient record. | Implemented | Data Platform Owner | Data Steward | `patients.csv` | `silver.patient` | Loaded through governed ingestion process. | Contains direct-identifier-style synthetic fields in bronze; do not expose in reporting outputs. |
| `bronze.encounters` | Table | One row per source encounter record. | Implemented | Data Platform Owner | Data Steward | `encounters.csv` | `silver.encounter` | Row counts reconciled through ingestion and transformation workflow. | Source timestamps are parsed and standardized in silver. |
| `bronze.conditions` | Table | One row per source condition record. | Implemented | Data Platform Owner | Data Steward | `conditions.csv` | `silver.condition` | Validated downstream through silver referential and date checks. | Date fields are source strings in bronze. |
| `bronze.observations` | Table | One row per source observation record. | Implemented | Data Platform Owner | Data Steward | `observations.csv` | `silver.observation` | Observation duplicate finding is retained transparently downstream. | Some observations may not have encounter links. |
| `bronze.procedures` | Table | One row per source procedure record. | Implemented | Data Platform Owner | Data Steward | `procedures.csv` | `silver.procedure` | Validated downstream through silver referential and timestamp checks. | Source procedure timestamps are parsed in silver. |
| `bronze.organizations` | Table | One row per source organization record. | Implemented | Data Platform Owner | Data Steward | `organizations.csv` | Future richer organization dimension work | Loaded as source-preserving reference data. | Current gold organization dimension is sourced from encounter organization references. |
| `bronze.providers` | Table | One row per source provider record. | Implemented | Data Platform Owner | Data Steward | `providers.csv` | Future richer provider dimension work | Loaded as source-preserving reference data. | Source field `speciality` may be standardized later if a silver provider table is implemented. |

## 7. Silver Layer Assets

Silver assets standardize types, naming, derived fields, quality flags, and lineage. They are transformation-ready but not the primary Power BI reporting layer.

| Asset name | Asset type | Grain / purpose | Current status | Owner role | Steward role | Upstream assets | Downstream usage | Validation / trust notes | Usage notes |
|---|---|---|---|---|---|---|---|---|---|
| `silver.patient` | Table | One row per standardized synthetic patient. | Implemented | Data Platform Owner | Data Steward | `bronze.patients` | `gold.dim_patient` | Patient ID completeness and uniqueness validated. | Direct identifiers are excluded from reporting-facing gold dimension. |
| `silver.encounter` | Table | One row per standardized encounter. | Implemented | Data Platform Owner | Data Steward | `bronze.encounters` | `gold.fact_encounter`, `gold.fact_readmission`, LOS and patient-flow marts | Encounter ID, patient reference, and datetime validity validated. | Contains derived duration and LOS fields used by gold. |
| `silver.condition` | Table | One row per standardized condition record. | Implemented | Data Platform Owner | Data Steward | `bronze.conditions` | `gold.dim_condition`, `gold.fact_condition` | Patient and encounter references validated. | Condition categorization supports case-mix reporting. |
| `silver.observation` | Table | One row per standardized observation record. | Implemented | Data Platform Owner | Data Steward | `bronze.observations` | `gold.dim_observation`, `gold.fact_observation`, lab operations mart | Required fields and references validated; duplicate observation finding retained. | Observation categories may include lab-like and vital-sign-like activity. |
| `silver.procedure` | Table | One row per standardized procedure record. | Implemented | Data Platform Owner | Data Steward | `bronze.procedures` | `gold.dim_procedure`, `gold.fact_procedure`, service utilization mart | Patient and encounter references validated. | Procedure grouping affects utilization interpretation. |

## 8. Gold Dimension Assets

Gold dimensions are Power BI-ready reference tables used to filter and describe fact records.

| Asset name | Asset type | Grain / purpose | Current row count | Current status | Owner role | Steward role | Upstream assets | Downstream usage | Validation / trust notes | Usage notes |
|---|---|---|---:|---|---|---|---|---|---|---|
| `gold.dim_patient` | Table | One row per synthetic patient; reporting-safe demographic dimension. | 1,145 | Implemented | Data Platform Owner | Data Steward | `silver.patient` | Executive Overview, Patient Flow, Readmissions | Gold validation passed. | Excludes names, SSN, passport, drivers, street address, and birthplace. |
| `gold.dim_date` | Table | One row per calendar date across reporting date range. | 40,365 | Implemented | Data Platform Owner | BI Developer | Generated calendar logic | All dashboard pages | Gold validation passed. | Use consistently for date filtering in Power BI. |
| `gold.dim_organization` | Table | One row per organization identifier sourced from encounters. | 727 | Implemented | Data Platform Owner | Data Steward | `silver.encounter` | Operational slicing by organization | Gold validation passed. | Lightweight organization dimension until richer organization modeling is implemented. |
| `gold.dim_provider` | Table | One row per provider identifier sourced from encounters. | 727 | Implemented | Data Platform Owner | Data Steward | `silver.encounter` | Optional provider-level analysis | Gold validation passed. | Lightweight provider dimension only. |
| `gold.dim_encounter_class` | Table | One row per encounter class with reporting group flags. | 10 | Implemented | Data Platform Owner | Data Steward | `silver.encounter` | Encounter class slicers and patient-flow analysis | Gold validation passed. | Used for grouping encounter volume and LOS patterns. |
| `gold.dim_condition` | Table | One row per distinct condition definition. | 268 | Implemented | Data Platform Owner | Data Steward | `silver.condition` | Conditions & Procedures, Readmissions | Gold validation passed. | Condition categories are synthetic-data reporting groupings. |
| `gold.dim_observation` | Table | One row per distinct observation definition. | 296 | Implemented | Data Platform Owner | Data Steward | `silver.observation` | Lab / Observation Operations | Gold validation passed. | Supports observation-code and category analysis. |
| `gold.dim_procedure` | Table | One row per distinct procedure definition. | 363 | Implemented | Data Platform Owner | Data Steward | `silver.procedure` | Conditions & Procedures, Service Utilization | Gold validation passed. | Procedure grouping logic should remain documented. |

## 9. Gold Fact Assets

Gold facts are the core reporting tables for encounter, clinical activity, readmission, and data-quality analysis.

| Asset name | Asset type | Grain / purpose | Current row count | Current status | Owner role | Steward role | Upstream assets | Downstream usage | Validation / trust notes | Usage notes |
|---|---|---|---:|---|---|---|---|---|---|---|
| `gold.fact_encounter` | Table | One row per encounter. | 71,663 | Implemented | Data Platform Owner | Data Steward | `silver.encounter`, gold dimensions | Executive Overview, Patient Flow, LOS, Readmissions | Gold fact validation passed; KPI reconciliation passed. | Main fact table for encounter volume and LOS measures. |
| `gold.fact_readmission` | Table | One row per eligible index encounter for 30-day readmission logic. | 71,663 | Implemented | Data Platform Owner | Data Steward | `silver.encounter`, `gold.fact_encounter` | Readmissions dashboard, Executive Overview | Readmission validation and KPI reconciliation passed. | Planned versus unplanned readmission distinction is not fully available in synthetic data. |
| `gold.fact_condition` | Table | One row per silver condition record. | 43,758 | Implemented | Data Platform Owner | Data Steward | `silver.condition`, `gold.dim_condition` | Conditions & Procedures, Readmissions | Gold fact validation passed. | Use for case-mix context, not clinical diagnosis conclusions. |
| `gold.fact_observation` | Table | One row per silver observation record. | 945,531 | Implemented | Data Platform Owner | Data Steward | `silver.observation`, `gold.dim_observation` | Lab / Observation Operations | Gold fact validation passed; duplicate observation finding retained. | Observation counts should acknowledge governed duplicate finding where relevant. |
| `gold.fact_procedure` | Table | One row per silver procedure record. | 196,207 | Implemented | Data Platform Owner | Data Steward | `silver.procedure`, `gold.dim_procedure` | Conditions & Procedures, Service Utilization | Gold fact validation passed. | Supports utilization reporting by procedure grouping. |
| `gold.fact_data_quality_issue` | Table | One row per persisted governance quality-check result. | 20 | Implemented | Data Platform Owner | Data Steward | `governance.quality_check_result`, `governance.quality_rule` | Data Quality & Governance dashboard | Data quality issue fact validation passed. | Reflects current persisted validation scope, not all possible quality rules. |

## 10. Gold Mart and View Assets

Gold marts are the preferred Power BI source layer for dashboard-ready reporting.

| Asset name | Asset type | Grain / purpose | Current row count | Current status | Owner role | Steward role | Upstream assets | Downstream usage | Validation / trust notes | Usage notes |
|---|---|---|---:|---|---|---|---|---|---|---|
| `gold.mart_patient_flow` | View | Aggregated patient-flow reporting rows. | 68,981 | Implemented | BI Developer | Data Steward | `gold.fact_encounter`, dimensions | Patient Flow dashboard | Mart validation passed. | Use for encounter trends and operational volume views. |
| `gold.mart_length_of_stay` | View | Encounter-grain LOS reporting mart. | 71,663 | Implemented | BI Developer | Data Steward | `gold.fact_encounter`, dimensions | Executive Overview, Patient Flow | LOS mart validation passed; average and median LOS reconciled. | Exclude invalid or unusable durations according to KPI definitions. |
| `gold.mart_readmissions` | View | Index-encounter-grain readmission reporting mart. | 71,663 | Implemented | BI Developer | Data Steward | `gold.fact_readmission`, `gold.fact_encounter`, dimensions | Readmissions dashboard | Readmission mart validation passed; 30-day readmission KPI reconciled. | Synthetic data limits planned/unplanned readmission interpretation. |
| `gold.mart_lab_operations` | View | Observation/lab activity reporting rows. | 935,704 | Implemented | BI Developer | Data Steward | `gold.fact_observation`, dimensions | Lab / Observation Operations dashboard | Lab operations mart validation passed. | Row count may differ from raw observation fact due to mart inclusion rules. |
| `gold.mart_service_utilization` | View | Procedure/service utilization reporting rows. | 186,119 | Implemented | BI Developer | Data Steward | `gold.fact_procedure`, dimensions | Conditions & Procedures dashboard | Service utilization mart validation passed. | Row count may differ from procedure fact due to mart inclusion rules. |
| `gold.mart_reporting_trust` | View | Data-quality and governance-readiness reporting rows. | 20 | Implemented | BI Developer | Data Steward | `gold.fact_data_quality_issue`, governance quality assets | Data Quality & Governance dashboard | Reporting trust mart validation passed. | Used to communicate validation status and reporting trust. |

## 11. Governance and Audit Assets

Governance and audit assets support trust, validation, traceability, and reproducibility.

| Asset name | Asset type | Layer / domain | Grain / purpose | Current status | Owner role | Steward role | Upstream assets | Downstream usage | Validation / trust notes | Usage notes |
|---|---|---|---|---|---|---|---|---|---|---|
| `governance.quality_rule` | Table | Governance | One row per defined quality rule. | Implemented | Data Platform Owner | Data Steward | Governance rule definitions | Quality checks, reporting trust | Rule catalog contains active quality rules. | Defines expected data quality behavior. |
| `governance.quality_check_result` | Table | Governance | One row per persisted quality-check result. | Implemented | Data Platform Owner | Data Steward | `governance.vw_quality_check_current`, Python validation | `gold.fact_data_quality_issue`, reporting trust | Latest persisted results include one governed observation duplicate finding. | Preserves quality-check history. |
| `governance.vw_quality_check_current` | View | Governance | Current executable quality-check result set. | Implemented | Data Platform Owner | Data Steward | Silver tables and quality rules | `src/run_quality_checks.py`, persisted results | Used to evaluate current data quality state. | Lineage rule is documented separately from executable checks. |
| `audit.ingestion_batch` | Table | Audit | One row per ingestion batch. | Implemented | Data Platform Owner | Data Steward | Python ingestion process | Reconciliation and lineage review | Supports reproducibility and batch traceability. | Contains local ingestion metadata, not business reporting metrics. |
| `audit.ingestion_file_log` | Table | Audit | One row per loaded source file per batch. | Implemented | Data Platform Owner | Data Steward | Python ingestion process | Row-count reconciliation | Supports source-file load validation. | Used for operational audit, not dashboard-level reporting. |
| `docs/kpi_dictionary.md` | Document | Governance | One governed definition per KPI. | Implemented | Operational Reporting Owner | Data Steward | Business requirements, gold assets | DAX measures, SQL validation, dashboard design | KPI entries define formulas, source objects, validation methods, and limitations. | KPI definitions should be updated before measure logic changes. |
| `docs/kpi_validation_log.md` | Document | Governance | Reconciled KPI output record. | Implemented | BI Developer | Data Steward | SQL KPI validation queries, gold marts | Power BI measure validation | Records reconciled KPI outputs before dashboard work. | Use as SQL baseline when validating DAX measures. |

## 12. Power BI Reporting Assets

Power BI assets are the stakeholder-facing reporting layer. Power BI should connect to gold tables/views, not raw CSV files or bronze tables.

| Asset name | Asset type | Layer / domain | Grain / purpose | Current status | Owner role | Steward role | Upstream assets | Downstream usage | Validation / trust notes | Usage notes |
|---|---|---|---|---|---|---|---|---|---|---|
| ClinicalPulse Power BI semantic model | Semantic model | Power BI | Star-schema-style model built from gold dimensions, facts, and marts. | Planned / in progress | BI Developer | Data Steward | Gold tables and marts | All dashboard pages | Must be validated against SQL KPI validation outputs. | Keep relationships clean and use `gold.dim_date` consistently. |
| Executive Overview | Dashboard page | Power BI | High-level operational KPIs and reporting trust indicators. | Planned | BI Developer | Operational Reporting Owner | Gold facts, marts, KPI measures | Stakeholder overview | Must reconcile KPI cards to SQL validation queries. | Include total encounters, unique patients, LOS, readmission rate, observation volume, and data quality score. |
| Patient Flow | Dashboard page | Power BI | Encounter trends, class breakdowns, and LOS patterns. | Planned | BI Developer | Operational Reporting Owner | `gold.mart_patient_flow`, `gold.mart_length_of_stay` | Operational flow analysis | Validate encounter counts and LOS against gold marts. | Use date, encounter class, organization, and age-band slicers. |
| Readmissions | Dashboard page | Power BI | 30-day readmission count/rate and return patterns. | Planned | BI Developer | Operational Reporting Owner | `gold.mart_readmissions` | Readmission monitoring | Validate numerator, denominator, and rate against SQL outputs. | Planned/unplanned distinction is documented as a synthetic-data limitation. |
| Conditions & Procedures | Dashboard page | Power BI | Case mix and procedure utilization. | Planned | BI Developer | Operational Reporting Owner | `gold.fact_condition`, `gold.fact_procedure`, `gold.mart_service_utilization` | Utilization analysis | Validate procedure volume against SQL outputs. | Avoid presenting synthetic condition patterns as clinical evidence. |
| Lab / Observation Operations | Dashboard page | Power BI | Observation volume and lab-like operational activity. | Planned | BI Developer | Operational Reporting Owner | `gold.fact_observation`, `gold.mart_lab_operations` | Observation activity analysis | Validate observation volume against SQL outputs. | Surface duplicate-observation caveat where relevant. |
| Data Quality & Governance | Dashboard page | Power BI | Quality rule status, pass rate, and reporting trust. | Planned | BI Developer | Data Steward | `gold.mart_reporting_trust`, governance quality tables | Governance reporting | Validate pass/fail counts against governance results. | Use this page to show reporting trust, not only failures. |
| FHIR API Demonstration | Dashboard page | Power BI | Interoperability coverage and sample API status. | Planned | BI Developer | Data Steward | Planned API views and FHIR mapping docs | Portfolio demonstration | API coverage currently not implemented. | Should clearly state FHIR-aligned demonstration scope, not certified FHIR server compliance. |

## 13. Planned API / FHIR Demonstration Assets

API/FHIR assets are planned for the interoperability component. They are included here so reviewers can distinguish planned assets from missing or failed reporting assets.

| Asset name | Asset type | Layer / domain | Grain / purpose | Current status | Owner role | Steward role | Upstream assets | Downstream usage | Validation / trust notes | Usage notes |
|---|---|---|---|---|---|---|---|---|---|---|
| `api.vw_fhir_patient` | Planned API view | API | One FHIR-style Patient resource row per selected synthetic patient. | Not implemented | Data Platform Owner | Data Steward | `silver.patient` / `gold.dim_patient` | Future FastAPI endpoint | Expected pending asset. | Must exclude unnecessary direct identifiers and label outputs as synthetic. |
| `api.vw_fhir_encounter` | Planned API view | API | One FHIR-style Encounter resource row per selected encounter. | Not implemented | Data Platform Owner | Data Steward | `silver.encounter` / `gold.fact_encounter` | Future FastAPI endpoint | Expected pending asset. | Should include patient and organization references where available. |
| `api.vw_fhir_observation` | Planned API view | API | FHIR-style Observation rows for selected synthetic patients. | Not implemented | Data Platform Owner | Data Steward | `silver.observation` / `gold.fact_observation` | Future FastAPI endpoint | Expected pending asset. | Observation examples should be limited and portfolio-safe. |
| `api.vw_fhir_condition` | Planned API view | API | FHIR-style Condition rows for selected synthetic patients. | Not implemented | Data Platform Owner | Data Steward | `silver.condition` / `gold.fact_condition` | Future FastAPI endpoint | Expected pending asset. | Demonstrates mapping literacy, not production clinical interoperability. |

## 14. Dashboard-to-Asset Mapping

| Dashboard page | Primary supporting assets |
|---|---|
| Executive Overview | `gold.fact_encounter`, `gold.fact_readmission`, `gold.fact_observation`, `gold.mart_length_of_stay`, `gold.mart_reporting_trust`, `docs/kpi_dictionary.md`, `docs/kpi_validation_log.md` |
| Patient Flow | `gold.mart_patient_flow`, `gold.mart_length_of_stay`, `gold.dim_date`, `gold.dim_encounter_class`, `gold.dim_organization`, `gold.dim_patient` |
| Readmissions | `gold.mart_readmissions`, `gold.fact_readmission`, `gold.dim_patient`, `gold.dim_condition`, `gold.dim_organization`, `gold.dim_date` |
| Conditions & Procedures | `gold.fact_condition`, `gold.fact_procedure`, `gold.dim_condition`, `gold.dim_procedure`, `gold.mart_service_utilization` |
| Lab / Observation Operations | `gold.fact_observation`, `gold.dim_observation`, `gold.mart_lab_operations`, `gold.dim_date`, `gold.dim_encounter_class` |
| Data Quality & Governance | `gold.fact_data_quality_issue`, `gold.mart_reporting_trust`, `governance.quality_rule`, `governance.quality_check_result`, `governance.vw_quality_check_current` |
| FHIR API Demonstration | Planned `api.vw_fhir_patient`, `api.vw_fhir_encounter`, `api.vw_fhir_observation`, `api.vw_fhir_condition`, future API documentation and sample responses |

## 15. Validation and Readiness Summary

| Asset group | Readiness status | Evidence / note |
|---|---|---|
| Bronze ingestion assets | Ready | Source files loaded into bronze with ingestion metadata and audit logs. |
| Silver standardized assets | Ready | Silver quality checks are implemented and persisted. |
| Gold dimensions | Ready | Gold dimension validation passed. |
| Gold facts | Ready | Gold fact validation passed. |
| Gold marts/views | Ready for Power BI | Mart validation passed and KPI outputs reconciled. |
| KPI definitions | Ready for Power BI implementation | Core KPI dictionary entries exist and are tied to source objects and validation expectations. |
| Power BI semantic model | Planned / in progress | Should connect to gold layer only. |
| Dashboard pages | Planned | Dashboard build begins after semantic model and measures are defined. |
| API/FHIR views | Not implemented | Expected future scope; not a current reporting-layer defect. |

## 16. Assumptions

- ClinicalPulse uses synthetic Synthea data only.
- SQL Server remains the analytical backbone for reporting assets.
- Power BI should connect to gold schema tables/views, not raw CSV files or bronze tables.
- Gold marts are the preferred source for dashboard-ready reporting where available.
- KPI definitions and SQL validation outputs should guide Power BI measure implementation.
- API/FHIR assets are cataloged as planned because they are part of the broader ClinicalPulse architecture, but they are not required to be complete before Sprint 6 dashboard work begins.
- Ownership and stewardship roles are modeled for portfolio demonstration and governance clarity.

## 17. Limitations

- This catalog is asset-level documentation, not a complete column-level data dictionary.
- Row counts reflect the documented current project state and may change after regeneration, reload, or transformation reruns.
- Synthetic data patterns should not be interpreted as real patient outcomes, real hospital performance, or clinical recommendations.
- Some gold dimensions, such as organization and provider, are intentionally lightweight until richer silver organization/provider transformations are implemented.
- The known observation duplicate finding is retained as a governed data-quality issue and should be considered when interpreting observation volume.
- API/FHIR views are planned and should not be treated as missing Sprint 6 reporting deliverables.
