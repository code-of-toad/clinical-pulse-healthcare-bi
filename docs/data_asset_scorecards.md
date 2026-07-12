# ClinicalPulse Data Asset Scorecards

## 1. Purpose

This document provides governance scorecards for key ClinicalPulse data assets.

The scorecards rate each asset across reliability, documentation, validation coverage, security / portfolio safety, and adoption readiness. The goal is to help data stewards, BI developers, and reviewers understand which assets are ready for Power BI reporting, which assets need follow-up, and which assumptions should remain visible.

ClinicalPulse uses synthetic Synthea data. Assets documented here are not real patient records and should not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. This document is not intended for clinical-decision support.

## 2. Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1572 - Create data asset scorecards |
| Parent area | ClinicalPulse\Data Quality & Governance |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Primary deliverable | `docs/data_asset_scorecards.md` |
| Validation support | `src/validate_data_asset_scorecards_ab1574.py` |
| Related task | AB#1573 - Draft/build artifact for Create data asset scorecards |
| Validation task | AB#1574 - Validate and document Create data asset scorecards |

## 3. Scope

These scorecards cover the assets most important to the Sprint 6 Power BI reporting layer:

- gold fact tables
- gold reporting marts/views
- governance reporting assets
- planned Power BI reporting assets
- planned API/FHIR demonstration assets where relevant to dashboard traceability

The scorecards are intended for asset-level governance review, not full column-level certification.

## 4. Rating Scale

| Rating | Label | Meaning |
|---:|---|---|
| 5 | Strong | Ready for intended use with strong validation, documentation, and low known risk. |
| 4 | Good | Ready for intended use with minor limitations or follow-up items. |
| 3 | Moderate | Usable for limited or internal use, but important caveats remain. |
| 2 | Limited | Not yet ready for broad reporting use; material gaps remain. |
| 1 | Not ready | Not implemented or not suitable for current use. |

## 5. Scorecard Dimensions

| Dimension | What it evaluates |
|---|---|
| Reliability | Whether the asset is structurally stable, consistently produced, and suitable for its intended reporting purpose. |
| Documentation | Whether the asset is described in supporting documentation, lineage, catalog, KPI definitions, or usage notes. |
| Validation coverage | Whether the asset has SQL, Python, reconciliation, or KPI validation evidence. |
| Security / portfolio safety | Whether the asset avoids unnecessary exposure of direct identifiers, secrets, raw data, or misleading clinical claims. |
| Adoption readiness | Whether the asset can be used by Power BI or reviewers with clear purpose, caveats, and expected downstream usage. |

## 6. Overall Score Calculation

Overall readiness is assigned by qualitative governance judgment using the five scorecard dimensions.

| Overall score | Readiness status | Interpretation |
|---:|---|---|
| 5.0 | Ready | Strong candidate for stakeholder-facing reporting or portfolio demonstration. |
| 4.0 - 4.9 | Ready with minor caveats | Usable, with documented assumptions or follow-up items. |
| 3.0 - 3.9 | Internal use / needs review | Useful for development or internal validation, but not fully adoption-ready. |
| 2.0 - 2.9 | Limited readiness | Material gaps exist. |
| 1.0 - 1.9 | Not ready | Not implemented or not appropriate for current use. |

## 7. Summary Scorecard Register

| Asset | Asset type | Primary use | Reliability | Documentation | Validation coverage | Security / portfolio safety | Adoption readiness | Overall score | Readiness status |
|---|---|---|---:|---:|---:|---:|---:|---:|---|
| `gold.fact_encounter` | Gold fact table | Encounter volume, LOS, patient flow, readmissions | 5 | 5 | 5 | 5 | 5 | 5.0 | Ready |
| `gold.fact_readmission` | Gold fact table | 30-day readmission reporting | 4 | 5 | 5 | 5 | 4 | 4.6 | Ready with minor caveats |
| `gold.fact_observation` | Gold fact table | Observation and lab-like activity reporting | 4 | 5 | 4 | 5 | 4 | 4.4 | Ready with minor caveats |
| `gold.fact_procedure` | Gold fact table | Procedure and utilization reporting | 5 | 5 | 5 | 5 | 4 | 4.8 | Ready with minor caveats |
| `gold.fact_data_quality_issue` | Gold fact table | Reporting trust and quality status | 5 | 5 | 5 | 5 | 5 | 5.0 | Ready |
| `gold.mart_patient_flow` | Gold reporting mart/view | Patient flow dashboard | 5 | 5 | 5 | 5 | 5 | 5.0 | Ready |
| `gold.mart_length_of_stay` | Gold reporting mart/view | LOS metrics and trends | 5 | 5 | 5 | 5 | 5 | 5.0 | Ready |
| `gold.mart_readmissions` | Gold reporting mart/view | Readmission dashboard | 4 | 5 | 5 | 5 | 4 | 4.6 | Ready with minor caveats |
| `gold.mart_lab_operations` | Gold reporting mart/view | Lab / observation operations dashboard | 4 | 5 | 4 | 5 | 4 | 4.4 | Ready with minor caveats |
| `gold.mart_service_utilization` | Gold reporting mart/view | Conditions & Procedures dashboard | 5 | 5 | 5 | 5 | 4 | 4.8 | Ready with minor caveats |
| `gold.mart_reporting_trust` | Gold reporting mart/view | Data Quality & Governance dashboard | 5 | 5 | 5 | 5 | 5 | 5.0 | Ready |
| ClinicalPulse Power BI semantic model | Power BI asset | Shared model for dashboard pages | 3 | 4 | 3 | 5 | 3 | 3.6 | Internal use / needs review |
| Executive Overview dashboard page | Power BI asset | High-level operational overview | 3 | 4 | 3 | 5 | 3 | 3.6 | Internal use / needs review |
| FHIR API Demonstration assets | Planned API assets | Interoperability demonstration | 1 | 4 | 1 | 5 | 1 | 2.4 | Limited readiness |

## 8. Detailed Asset Scorecards

### 8.1 `gold.fact_encounter`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold fact table |
| Primary purpose | Encounter-grain reporting for volume, LOS, patient flow, organization, provider, encounter class, and date analysis. |
| Reliability | 5 - Built as the central encounter fact and reconciled to the documented encounter population. |
| Documentation | 5 - Referenced in schema inventory, KPI dictionary, data asset catalog, and lineage documentation. |
| Validation coverage | 5 - Covered by gold-layer validation and KPI validation for total encounters and LOS-related measures. |
| Security / portfolio safety | 5 - Reporting-facing asset avoids direct patient identifiers and supports aggregate reporting. |
| Adoption readiness | 5 - Ready as a primary Power BI source asset. |
| Overall score | 5.0 |
| Readiness status | Ready |
| Key downstream use | Executive Overview, Patient Flow, LOS analysis, Readmissions context. |
| Assumptions / limitations | Synthetic encounter patterns do not represent real hospital operations. |

### 8.2 `gold.fact_readmission`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold fact table |
| Primary purpose | Index-encounter-level 30-day readmission logic. |
| Reliability | 4 - Readmission sequencing is implemented, but planned versus unplanned readmission distinction is limited by synthetic source data. |
| Documentation | 5 - Covered in KPI definitions, lineage, and data asset catalog. |
| Validation coverage | 5 - Covered by SQL validation for readmission numerator, denominator, and rate. |
| Security / portfolio safety | 5 - Uses synthetic identifiers and is intended for aggregate dashboard interpretation. |
| Adoption readiness | 4 - Ready for Power BI with explicit caveat about planned/unplanned readmission assumptions. |
| Overall score | 4.6 |
| Readiness status | Ready with minor caveats |
| Key downstream use | Executive Overview and Readmissions dashboard page. |
| Assumptions / limitations | 30-day readmission rate demonstrates BI logic and governance, not clinical readmission performance. |

### 8.3 `gold.fact_observation`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold fact table |
| Primary purpose | Observation-grain reporting for lab-like and clinical observation activity. |
| Reliability | 4 - Main observation fact is implemented, but known duplicate observation finding affects interpretation of raw observation counts. |
| Documentation | 5 - Covered in catalog and lineage, with observation duplicate caveat documented. |
| Validation coverage | 4 - Validation exists, but governed duplicate finding should remain visible. |
| Security / portfolio safety | 5 - Uses synthetic observation records and should be reported in aggregate. |
| Adoption readiness | 4 - Ready for reporting with observation-volume caveat. |
| Overall score | 4.4 |
| Readiness status | Ready with minor caveats |
| Key downstream use | Executive Overview and Lab / Observation Operations dashboard page. |
| Assumptions / limitations | Observations may include both lab-like and vital-sign-like records. |

### 8.4 `gold.fact_procedure`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold fact table |
| Primary purpose | Procedure-grain reporting for service utilization and procedure grouping. |
| Reliability | 5 - Procedure fact is implemented and sourced from standardized procedure records. |
| Documentation | 5 - Covered in catalog, lineage, and KPI definitions. |
| Validation coverage | 5 - Procedure volume is reconciled through SQL KPI validation. |
| Security / portfolio safety | 5 - Uses synthetic procedure activity and aggregate reporting context. |
| Adoption readiness | 4 - Ready, with procedure grouping interpretation caveats. |
| Overall score | 4.8 |
| Readiness status | Ready with minor caveats |
| Key downstream use | Conditions & Procedures dashboard page and service utilization reporting. |
| Assumptions / limitations | Procedure categories are useful for reporting but should not be treated as clinical evidence. |

### 8.5 `gold.fact_data_quality_issue`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold fact table |
| Primary purpose | Reporting fact for persisted quality-check results and reporting trust indicators. |
| Reliability | 5 - Sourced from governance quality result assets. |
| Documentation | 5 - Covered in governance, catalog, and lineage artifacts. |
| Validation coverage | 5 - Directly represents persisted validation output. |
| Security / portfolio safety | 5 - Contains governance metrics, not patient-level clinical details. |
| Adoption readiness | 5 - Ready for Data Quality & Governance dashboard page. |
| Overall score | 5.0 |
| Readiness status | Ready |
| Key downstream use | `gold.mart_reporting_trust`, Data Quality & Governance dashboard page. |
| Assumptions / limitations | Reflects implemented validation scope, not every possible enterprise data quality rule. |

### 8.6 `gold.mart_patient_flow`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold reporting mart/view |
| Primary purpose | Dashboard-ready patient-flow and encounter trend reporting. |
| Reliability | 5 - Built from gold encounter assets and validated for dashboard readiness. |
| Documentation | 5 - Covered in data asset catalog and lineage. |
| Validation coverage | 5 - Mart validation passed and supports total encounter reporting. |
| Security / portfolio safety | 5 - Designed for aggregate operational reporting. |
| Adoption readiness | 5 - Ready for Patient Flow dashboard development. |
| Overall score | 5.0 |
| Readiness status | Ready |
| Key downstream use | Patient Flow dashboard page. |
| Assumptions / limitations | Synthetic encounter volume should not be treated as real hospital activity. |

### 8.7 `gold.mart_length_of_stay`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold reporting mart/view |
| Primary purpose | Dashboard-ready length-of-stay reporting. |
| Reliability | 5 - Built from standardized encounter duration and LOS fields. |
| Documentation | 5 - Covered in KPI dictionary, catalog, and lineage. |
| Validation coverage | 5 - Average and median LOS are reconciled through SQL KPI validation. |
| Security / portfolio safety | 5 - Supports aggregate duration reporting without direct identifiers. |
| Adoption readiness | 5 - Ready for Executive Overview and Patient Flow dashboard pages. |
| Overall score | 5.0 |
| Readiness status | Ready |
| Key downstream use | Average LOS, Median LOS, LOS distributions and trends. |
| Assumptions / limitations | Average LOS can be influenced by long-stay outliers and synthetic data patterns. |

### 8.8 `gold.mart_readmissions`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold reporting mart/view |
| Primary purpose | Dashboard-ready readmission reporting. |
| Reliability | 4 - Readmission logic is implemented, but planned/unplanned distinction remains an assumption. |
| Documentation | 5 - Covered in KPI dictionary, catalog, and lineage. |
| Validation coverage | 5 - Readmission KPI validation passed. |
| Security / portfolio safety | 5 - Intended for aggregate demonstration reporting. |
| Adoption readiness | 4 - Ready for dashboard use with visible caveat. |
| Overall score | 4.6 |
| Readiness status | Ready with minor caveats |
| Key downstream use | Readmissions dashboard page. |
| Assumptions / limitations | Synthetic data does not fully support production-style clinical readmission interpretation. |

### 8.9 `gold.mart_lab_operations`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold reporting mart/view |
| Primary purpose | Dashboard-ready observation and lab-like activity reporting. |
| Reliability | 4 - Ready for reporting, with known observation duplicate caveat. |
| Documentation | 5 - Covered in catalog and lineage documentation. |
| Validation coverage | 4 - Observation volume validation exists, but duplicate finding should remain visible. |
| Security / portfolio safety | 5 - Uses synthetic observation data in aggregate reporting context. |
| Adoption readiness | 4 - Ready for Lab / Observation Operations dashboard with caveats. |
| Overall score | 4.4 |
| Readiness status | Ready with minor caveats |
| Key downstream use | Lab / Observation Operations dashboard page. |
| Assumptions / limitations | Observation categories may mix lab-like results and vital-sign-like results. |

### 8.10 `gold.mart_service_utilization`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold reporting mart/view |
| Primary purpose | Dashboard-ready procedure and service utilization reporting. |
| Reliability | 5 - Built from gold procedure fact and procedure dimension assets. |
| Documentation | 5 - Covered in catalog, lineage, and KPI definitions. |
| Validation coverage | 5 - Procedure volume KPI validation passed. |
| Security / portfolio safety | 5 - Uses synthetic procedure records and aggregate reporting. |
| Adoption readiness | 4 - Ready with procedure-category interpretation caveats. |
| Overall score | 4.8 |
| Readiness status | Ready with minor caveats |
| Key downstream use | Conditions & Procedures dashboard page. |
| Assumptions / limitations | Procedure grouping logic should remain documented when used in visuals. |

### 8.11 `gold.mart_reporting_trust`

| Field | Scorecard detail |
|---|---|
| Asset type | Gold reporting mart/view |
| Primary purpose | Dashboard-ready quality-rule status and reporting trust summary. |
| Reliability | 5 - Sourced from persisted quality-check results. |
| Documentation | 5 - Covered in governance documentation, catalog, and lineage. |
| Validation coverage | 5 - Quality-check results are produced by the governed validation framework. |
| Security / portfolio safety | 5 - Does not expose direct patient-level clinical details. |
| Adoption readiness | 5 - Ready for Data Quality & Governance dashboard page. |
| Overall score | 5.0 |
| Readiness status | Ready |
| Key downstream use | Data Quality & Governance dashboard page and Executive Overview trust indicator. |
| Assumptions / limitations | Pass rate depends on implemented rule coverage and current validation scope. |

### 8.12 ClinicalPulse Power BI Semantic Model

| Field | Scorecard detail |
|---|---|
| Asset type | Power BI semantic model |
| Primary purpose | Shared model for dashboard pages using gold schema tables/views. |
| Reliability | 3 - Planned / in progress until relationships, date table usage, and measures are built. |
| Documentation | 4 - Intended model approach is documented in catalog, lineage, and project specification. |
| Validation coverage | 3 - SQL baselines exist, but DAX measures still need reconciliation after implementation. |
| Security / portfolio safety | 5 - Should connect to aggregate/reporting-ready gold assets and avoid raw data exposure. |
| Adoption readiness | 3 - Not fully ready until relationships, DAX measures, and validation evidence are complete. |
| Overall score | 3.6 |
| Readiness status | Internal use / needs review |
| Key downstream use | All dashboard pages. |
| Assumptions / limitations | Power BI should connect to gold schema tables/views, not raw CSV files or bronze tables. |

### 8.13 Executive Overview Dashboard Page

| Field | Scorecard detail |
|---|---|
| Asset type | Power BI dashboard page |
| Primary purpose | High-level operational KPI and reporting trust overview. |
| Reliability | 3 - Planned until visuals and measures are built. |
| Documentation | 4 - Dashboard purpose and KPI lineage are documented. |
| Validation coverage | 3 - SQL KPI outputs exist but must be reconciled after Power BI measures are implemented. |
| Security / portfolio safety | 5 - Should use aggregate values and avoid row-level patient detail. |
| Adoption readiness | 3 - Not ready until dashboard page is built and screenshots are documented. |
| Overall score | 3.6 |
| Readiness status | Internal use / needs review |
| Key downstream use | Stakeholder-facing project overview. |
| Assumptions / limitations | Must present synthetic-data caveats and avoid production hospital claims. |

### 8.14 FHIR API Demonstration Assets

| Field | Scorecard detail |
|---|---|
| Asset type | Planned API / interoperability assets |
| Primary purpose | Demonstrate FHIR-aligned mapping and future FastAPI output. |
| Reliability | 1 - API/FHIR views and endpoints are planned but not implemented. |
| Documentation | 4 - Planned scope is documented in catalog and lineage. |
| Validation coverage | 1 - API-specific validation will occur in the FHIR/API implementation phase. |
| Security / portfolio safety | 5 - Planned scope emphasizes synthetic examples, limited exposure, and non-production FHIR alignment. |
| Adoption readiness | 1 - Not ready for dashboard/API demonstration until views, endpoints, and examples are built. |
| Overall score | 2.4 |
| Readiness status | Limited readiness |
| Key downstream use | FHIR API Demonstration dashboard page and future API documentation. |
| Assumptions / limitations | This is a FHIR-aligned demonstration target, not a certified production FHIR server. |

## 9. Asset Readiness by Dashboard Page

| Dashboard page | Supporting scored assets | Current readiness interpretation |
|---|---|---|
| Executive Overview | `gold.fact_encounter`, `gold.fact_readmission`, `gold.fact_observation`, `gold.mart_length_of_stay`, `gold.mart_reporting_trust`, Executive Overview dashboard page | SQL assets are ready; dashboard page still requires Power BI implementation and reconciliation. |
| Patient Flow | `gold.mart_patient_flow`, `gold.mart_length_of_stay`, Power BI semantic model | Gold marts are ready; Power BI model and visuals still need build/validation. |
| Readmissions | `gold.fact_readmission`, `gold.mart_readmissions`, Power BI semantic model | SQL readmission assets are ready with planned/unplanned caveat. |
| Conditions & Procedures | `gold.fact_condition`, `gold.fact_procedure`, `gold.mart_service_utilization`, Power BI semantic model | Procedure/service utilization assets are ready with grouping caveats. |
| Lab / Observation Operations | `gold.fact_observation`, `gold.mart_lab_operations`, Power BI semantic model | Reporting is ready with duplicate-observation and category-mix caveats. |
| Data Quality & Governance | `gold.fact_data_quality_issue`, `gold.mart_reporting_trust`, governance results | Reporting trust assets are ready. |
| FHIR API Demonstration | Planned API/FHIR demonstration assets | Planned future work, not yet ready for API demonstration. |

## 10. Governance Follow-Up Items

| Follow-up item | Related asset(s) | Priority | Rationale |
|---|---|---|---|
| Reconcile Power BI DAX measures to SQL KPI validation outputs. | Power BI semantic model, all dashboard pages | High | Required before dashboard values are considered reporting-ready. |
| Keep observation duplicate caveat visible where observation volume is presented. | `gold.fact_observation`, `gold.mart_lab_operations` | Medium | Prevents hidden quality assumptions in lab/observation reporting. |
| Keep planned/unplanned readmission limitation visible. | `gold.fact_readmission`, `gold.mart_readmissions` | Medium | Synthetic data does not fully support production readmission classification. |
| Document screenshots after dashboard pages are built. | Power BI dashboard pages | High | Required for portfolio review and implementation evidence. |
| Re-score API/FHIR assets after implementation. | Planned API/FHIR assets | Medium | Current score reflects planned, not implemented, state. |

## 11. Assumptions

- ClinicalPulse uses synthetic Synthea data only.
- Gold tables and marts are the authoritative reporting source for Power BI.
- Scorecards reflect the documented current state at the start of Sprint 6 Power BI reporting work.
- Ratings are governance-readiness indicators, not automated production certification.
- Power BI assets are scored lower until the semantic model, DAX measures, dashboards, and screenshot evidence are implemented.
- API/FHIR assets are included because they are part of the broader ClinicalPulse architecture, but they are not required to be complete for current Power BI dashboard development.

## 12. Limitations

- These scorecards are asset-level summaries and do not replace detailed column-level profiling.
- Scores may change after additional validation, Power BI implementation, or API development.
- Synthetic data should not be interpreted as real hospital operations, patient outcomes, clinical trends, or care-quality evidence.
- Some scores use qualitative judgment based on documentation, validation coverage, and known limitations.
- The known observation duplicate finding is retained as a governed caveat rather than hidden or suppressed.
- Planned API/FHIR assets have limited readiness because they are not yet implemented.
