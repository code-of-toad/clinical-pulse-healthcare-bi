# ClinicalPulse Power BI Semantic Model Notes

## 1. Purpose

This document records the Power BI connection approach for ClinicalPulse.

Power BI should connect to SQL Server gold schema tables/views rather than raw files, unmanaged CSV extracts, bronze tables, or silver transformation tables. The gold layer is the governed reporting source for dashboard development, DAX measure definitions, and SQL-to-Power-BI validation.

ClinicalPulse uses synthetic Synthea data. Assets documented here are not real patient records and should not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. This document is not intended for clinical-decision support.

## 2. Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1580 - Connect Power BI to SQL Server gold schema |
| Parent area | ClinicalPulse\Power BI |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Primary deliverable | `powerbi/semantic_model_notes.md` |
| Validation support | `src/validate_powerbi_gold_connection_ab1582.py` |
| Related task | AB#1581 - Draft/build artifact for Connect Power BI to SQL Server gold schema |
| Validation task | AB#1582 - Validate and document Connect Power BI to SQL Server gold schema |
| Evidence task | AB#1583 - Commit and link implementation evidence for Connect Power BI to SQL Server gold schema |

## 3. Connection Decision

| Setting | Decision |
|---|---|
| BI tool | Power BI Desktop |
| Data source type | SQL Server |
| Database | ClinicalPulse SQL Server database |
| Source schema | `gold` |
| Connection mode | Import mode for the portfolio semantic model |
| Credential handling | Use local Windows or SQL Server credentials; do not commit credentials or connection strings. |
| Committed Power BI file policy | Do not commit `.pbix` files by default. Commit documentation and safe screenshots instead. |
| Reporting source rule | Use gold schema tables/views only for Power BI reporting. |

## 4. Why the Gold Schema Is the Power BI Source

| Reason | Explanation |
|---|---|
| Governance | Gold assets are the reporting-ready layer aligned to KPI definitions, lineage, cataloging, and scorecards. |
| Stability | Gold dimensions, facts, and marts provide stable reporting grains for dashboard pages. |
| Validation | Gold outputs reconcile to SQL KPI validation queries. |
| Safety | Gold assets avoid unnecessary source-like direct identifiers and raw generated file handling. |
| Maintainability | Power BI measures can be documented against known gold source objects instead of raw source files or bronze staging tables. |

## 5. Explicitly Excluded Sources

Power BI should not use the following as reporting sources:

| Excluded source | Reason |
|---|---|
| Raw Synthea CSV files | Raw files are source inputs, not governed reporting assets. |
| Local unmanaged CSV exports | They bypass SQL Server lineage, validation, and governance controls. |
| `bronze` schema tables | Bronze preserves source-like structures and may contain direct-identifier-style synthetic fields. |
| `silver` schema tables | Silver is a standardized transformation layer, but gold is the reporting-ready layer. |
| Manual spreadsheet copies | Manual extracts create reconciliation risk and weaken source-to-report traceability. |

## 6. Gold Tables and Views Available for Power BI

### 6.1 Core Dimensions

| Gold object | Expected role in Power BI | Current row count |
|---|---|---:|
| `gold.dim_patient` | Patient demographics, age bands, sex, geography-style reporting attributes | 1,145 |
| `gold.dim_date` | Date filtering, time intelligence, calendar attributes | 40,365 |
| `gold.dim_organization` | Organization filtering and breakdowns | 727 |
| `gold.dim_provider` | Provider filtering and breakdowns | 727 |
| `gold.dim_encounter_class` | Encounter class/category filtering | 10 |
| `gold.dim_condition` | Condition grouping and condition descriptions | 268 |
| `gold.dim_observation` | Observation/lab grouping and descriptions | 296 |
| `gold.dim_procedure` | Procedure grouping and descriptions | 363 |

### 6.2 Core Facts

| Gold object | Expected role in Power BI | Current row count |
|---|---|---:|
| `gold.fact_encounter` | Encounter volume, patient flow, LOS, organization/provider/class analysis | 71,663 |
| `gold.fact_readmission` | 30-day readmission numerator, denominator, and rate logic | 71,663 |
| `gold.fact_condition` | Condition occurrence analysis | 43,758 |
| `gold.fact_observation` | Observation and lab-like activity volume | 945,531 |
| `gold.fact_procedure` | Procedure and service utilization volume | 196,207 |
| `gold.fact_data_quality_issue` | Data quality rule status and reporting trust metrics | 20 |

### 6.3 Reporting Marts / Views

| Gold object | Expected role in Power BI | Current row count |
|---|---|---:|
| `gold.mart_patient_flow` | Patient Flow page support | 68,981 |
| `gold.mart_length_of_stay` | LOS trends and distribution support | 71,663 |
| `gold.mart_readmissions` | Readmissions page support | 71,663 |
| `gold.mart_lab_operations` | Lab / Observation Operations page support | 935,704 |
| `gold.mart_service_utilization` | Conditions & Procedures page support | 186,119 |
| `gold.mart_reporting_trust` | Data Quality & Governance page support | 20 |

## 7. Initial Import Plan

The initial Power BI connection should select gold schema assets only.

Recommended initial import:

| Include? | Asset group | Objects |
|---|---|---|
| Yes | Core dimensions | `gold.dim_patient`, `gold.dim_date`, `gold.dim_organization`, `gold.dim_provider`, `gold.dim_encounter_class`, `gold.dim_condition`, `gold.dim_observation`, `gold.dim_procedure` |
| Yes | Core facts | `gold.fact_encounter`, `gold.fact_readmission`, `gold.fact_condition`, `gold.fact_observation`, `gold.fact_procedure`, `gold.fact_data_quality_issue` |
| Optional / page-specific | Reporting marts | `gold.mart_patient_flow`, `gold.mart_length_of_stay`, `gold.mart_readmissions`, `gold.mart_lab_operations`, `gold.mart_service_utilization`, `gold.mart_reporting_trust` |

Recommended model discipline:

- Use facts and dimensions as the primary semantic model foundation.
- Use marts only when they simplify a specific dashboard page or provide reporting-trust support.
- Avoid duplicate measures from both facts and marts unless the measure purpose is clearly documented.
- Keep table names recognizable so they can be traced back to SQL Server gold objects.

## 8. Power BI Desktop Connection Steps

1. Open Power BI Desktop.
2. Select **Get data**.
3. Choose **SQL Server**.
4. Enter the local SQL Server name.
5. Enter the ClinicalPulse database name.
6. Choose **Import** as the initial connection mode.
7. Use credentials from the local environment only.
8. In Navigator, select only objects from the `gold` schema.
9. Load selected gold dimensions, facts, and any needed gold marts/views.
10. Save the working `.pbix` locally, but do not commit it to Git by default.
11. Document model decisions in this file and future measure logic in `powerbi/measure_definitions.md`.

## 9. Connection Validation Checklist

| Validation item | Expected result |
|---|---|
| Power BI source type | SQL Server |
| Source database | ClinicalPulse SQL Server database |
| Source schema | `gold` |
| Raw CSV files used? | No |
| `bronze` tables used? | No |
| `silver` tables used as reporting source? | No |
| Gold dimensions available | Yes |
| Gold facts available | Yes |
| Gold marts/views available where needed | Yes |
| Credentials committed? | No |
| `.pbix` committed? | No, unless intentionally reviewed and approved later |
| Synthetic-data caveat documented | Yes |

## 10. Evidence to Capture for AB#1583

Because `.pbix` files should not be committed by default, implementation evidence should be lightweight and safe.

Recommended evidence:

| Evidence type | Where to record |
|---|---|
| Validation script output | Azure Boards comment or pull request description |
| Screenshot of Navigator showing gold schema selection | Optional safe screenshot under a reviewed documentation path, if needed |
| Screenshot of Model view showing imported gold tables | Optional safe screenshot under a reviewed documentation path, if needed |
| Notes confirming no raw/bronze sources were selected | Azure Boards comment or PR description |
| Commit reference | Git commit linked to AB#1580 |

Do not include screenshots that reveal credentials, connection strings, local private paths, or unnecessary row-level patient-like detail.

## 11. Relationship to Future Power BI Stories

| Future work | Dependency on this story |
|---|---|
| Build relationships and date table | Requires gold dimensions and facts loaded from SQL Server. |
| Document DAX measure definitions | Requires stable semantic model source tables. |
| Validate DAX measures against SQL outputs | Requires DAX measures built on governed gold objects. |
| Build dashboard pages | Requires a trusted Power BI model connected to gold tables/views. |
| Create screenshot documentation | Requires dashboard pages built from the governed gold source layer. |

## 12. Assumptions

- SQL Server already contains the implemented ClinicalPulse gold schema.
- Power BI Desktop is installed locally.
- The local user has permission to read the ClinicalPulse SQL Server database.
- Import mode is appropriate for this portfolio-scale synthetic dataset.
- The Power BI semantic model will be built from gold tables/views, not raw files, bronze tables, or unmanaged extracts.
- `.pbix` files remain local by default because they can embed data and connection metadata.
- Future dashboard screenshots will use aggregate views and synthetic-data caveats.

## 13. Limitations

- Repository safety rule: do not commit `.pbix` files.

- This document does not include credentials, server names, passwords, or connection strings.
- This document does not commit a `.pbix` file.
- Actual Power BI Desktop connection must be performed manually in the local environment.
- This document confirms the intended governed connection pattern, not production workspace deployment.
- DirectQuery, gateway configuration, service refresh, Power BI workspace permissions, and deployment pipelines are outside this story.
- Synthetic data does not represent real patients, real hospital operations, or real clinical outcomes.
