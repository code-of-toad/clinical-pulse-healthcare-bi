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


---

# AB#1584 Semantic Model Relationships and Date Table

## 14. Purpose for AB#1584

This section documents the relationship and date-table design for the ClinicalPulse Power BI semantic model.

The goal is to support consistent filtering by date, encounter class, organization, age band, condition group, and procedure group while keeping Power BI connected to governed SQL Server gold schema assets.

## 15. AB#1584 Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1584 - Build relationships and date table |
| Parent area | ClinicalPulse\Power BI |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Updated deliverable | `powerbi/semantic_model_notes.md` |
| Validation support | `src/validate_powerbi_relationships_ab1586.py` |
| Related task | AB#1585 - Draft/build artifact for Build relationships and date table |
| Validation task | AB#1586 - Validate and document Build relationships and date table |
| Evidence task | AB#1587 - Commit and link implementation evidence for Build relationships and date table |

## 16. Actual Power BI Steps for AB#1584

Perform these steps in the local `.pbix` file saved outside the Git repository.

### 16.1 Open the Existing Local PBIX

1. Open Power BI Desktop.
2. Open the local file:

```text
clinicalpulse_powerbi_reporting.pbix
```

3. Confirm the file is connected to the SQL Server `ClinicalPulse` database and uses only gold schema objects.

The `.pbix` file should remain local and should not be committed.

### 16.2 Turn Off Auto Date/Time

In Power BI Desktop:

```text
File -> Options and settings -> Options -> Current File -> Data Load -> Time intelligence
```

Uncheck:

```text
Auto date/time
```

This ensures the model uses `gold.dim_date` as the governed date table instead of hidden Power BI-generated date tables.

### 16.3 Mark `gold.dim_date` as the Date Table

In Power BI Desktop:

1. Go to Data view or Model view.
2. Select the imported `gold.dim_date` table.
3. Choose:

```text
Table tools -> Mark as date table -> Mark as date table
```

4. Select the primary date column from `gold.dim_date`.

Use the actual date column in the imported table. The expected candidate is the column that stores one calendar date per row, such as `date`, `date_value`, `calendar_date`, or an equivalent date column.

The selected date column must contain unique, non-null date values.

### 16.4 Create Relationships in Model View

Go to:

```text
Model view -> Manage relationships -> New
```

Create relationships using this pattern:

- cardinality: many-to-one from fact to dimension / one-to-many from dimension to fact
- cross-filter direction: single
- active relationship: yes
- dimension side: the one side
- fact side: the many side

Recommended relationship plan:

| Dimension table | Dimension key / field | Fact table | Fact key / field | Filter supported |
|---|---|---|---|---|
| `gold.dim_patient` | patient key | `gold.fact_encounter` | patient key | Age band and patient attributes filter encounters |
| `gold.dim_patient` | patient key | `gold.fact_readmission` | patient key | Age band and patient attributes filter readmissions |
| `gold.dim_patient` | patient key | `gold.fact_condition` | patient key | Age band and patient attributes filter conditions |
| `gold.dim_patient` | patient key | `gold.fact_observation` | patient key | Age band and patient attributes filter observations |
| `gold.dim_patient` | patient key | `gold.fact_procedure` | patient key | Age band and patient attributes filter procedures |
| `gold.dim_date` | date key / date field | `gold.fact_encounter` | encounter start/admit date key | Date filtering for encounters and LOS |
| `gold.dim_date` | date key / date field | `gold.fact_readmission` | index encounter date key | Date filtering for readmissions |
| `gold.dim_date` | date key / date field | `gold.fact_condition` | condition start date key | Date filtering for conditions |
| `gold.dim_date` | date key / date field | `gold.fact_observation` | observation date key | Date filtering for observations |
| `gold.dim_date` | date key / date field | `gold.fact_procedure` | procedure start date key | Date filtering for procedures |
| `gold.dim_organization` | organization key | `gold.fact_encounter` | organization key | Organization filtering |
| `gold.dim_organization` | organization key | `gold.fact_readmission` | organization key | Organization filtering for readmissions |
| `gold.dim_provider` | provider key | `gold.fact_encounter` | provider key | Provider filtering |
| `gold.dim_encounter_class` | encounter class key | `gold.fact_encounter` | encounter class key | Encounter class filtering |
| `gold.dim_encounter_class` | encounter class key | `gold.fact_readmission` | encounter class key | Encounter class filtering for readmissions |
| `gold.dim_condition` | condition key / condition code | `gold.fact_condition` | condition key / condition code | Condition group filtering |
| `gold.dim_observation` | observation key / observation code | `gold.fact_observation` | observation key / observation code | Observation grouping |
| `gold.dim_procedure` | procedure key / procedure code | `gold.fact_procedure` | procedure key / procedure code | Procedure group filtering |
| `gold.fact_encounter` | encounter key / encounter id | `gold.fact_condition` | encounter key / encounter id | Encounter context for conditions |
| `gold.fact_encounter` | encounter key / encounter id | `gold.fact_observation` | encounter key / encounter id | Encounter context for observations |
| `gold.fact_encounter` | encounter key / encounter id | `gold.fact_procedure` | encounter key / encounter id | Encounter context for procedures |

Use the exact matching columns that exist in the imported gold tables. Prefer surrogate keys when available. If surrogate keys are not available for a relationship, use the governed natural identifier or code field documented in the gold table.

### 16.5 Do Not Force Ambiguous Relationships

Do not create a relationship if Power BI warns that it would create ambiguity or multiple active paths.

If a second date relationship is needed later, such as discharge date in addition to admission date, keep only the primary reporting date active and document inactive alternatives later when DAX measures are built.

For this story, prioritize the primary date path required for date slicers and dashboard filtering.

### 16.6 Validate Slicer Support

After relationships are created, add temporary test visuals locally. These visuals do not need to be committed.

Create simple table or card checks confirming that filters work from:

| Filter table | Field type to test | Expected behavior |
|---|---|---|
| `gold.dim_date` | year, month, date | Filters encounter, readmission, observation, procedure, and condition counts where relationships exist. |
| `gold.dim_encounter_class` | encounter class | Filters encounter and readmission facts. |
| `gold.dim_organization` | organization name / id | Filters encounter-based metrics. |
| `gold.dim_patient` | age band | Filters patient-linked fact tables. |
| `gold.dim_condition` | condition group / description | Filters condition facts. |
| `gold.dim_procedure` | procedure group / description | Filters procedure facts. |

Remove temporary test visuals or keep them on a local scratch page that is not treated as a finished dashboard page.

## 17. Model Relationship Standards

| Standard | Required setting |
|---|---|
| Date table | Use `gold.dim_date`, not Auto date/time hidden tables. |
| Relationship direction | Single direction from dimension to fact. |
| Cardinality | One-to-many from dimension to fact where keys support it. |
| Active relationships | Keep the primary relationship active. |
| Ambiguous paths | Avoid ambiguous or circular relationships. |
| Fact-to-fact relationships | Use sparingly; prefer dimensions for filtering. |
| Marts/views | Use cautiously; avoid duplicating relationship logic when facts and dimensions already support analysis. |

## 18. Evidence to Capture for AB#1587

Because the `.pbix` file is not committed, capture evidence in Azure Boards or PR notes.

Recommended evidence:

| Evidence type | Where to record |
|---|---|
| Confirmation that `gold.dim_date` is marked as the date table | Azure Boards comment |
| Confirmation that Auto date/time is disabled | Azure Boards comment |
| Relationship list or screenshot of Model view | Azure Boards comment or safe documentation screenshot if needed |
| Confirmation that relationships use single-direction filtering | Azure Boards comment |
| Confirmation that `.pbix` remains local and uncommitted | Azure Boards comment |
| Validation script output | Azure Boards comment or PR description |

Do not include screenshots containing credentials, local private paths, or row-level synthetic patient detail.

## 19. Assumptions for AB#1584

- The Power BI file is saved locally as `clinicalpulse_powerbi_reporting.pbix`.
- The file imports SQL Server gold schema tables/views only.
- `gold.dim_date` contains a unique date column suitable for marking as the model date table.
- Gold facts and dimensions contain matching key or identifier columns to support relationships.
- Date filtering is based on the primary business date for each fact table.
- Relationship work is completed manually in Power BI Desktop and documented in this file because `.pbix` is not committed.

## 20. Limitations for AB#1584

- This documentation does not prove relationships inside a committed `.pbix` because `.pbix` files are intentionally excluded from Git.
- Exact relationship column names must be confirmed in the local Power BI model.
- Some alternate date relationships may remain inactive until DAX measures are implemented.
- Dashboard visuals, DAX measures, and final screenshots are handled in later user stories.
- Synthetic data does not represent real patient records, real hospital operations, clinical evidence, or clinical recommendations.
