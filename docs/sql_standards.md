# SQL Naming and Scripting Standards

## Purpose

This document defines SQL Server naming and scripting standards for ClinicalPulse. The goal is to keep SQL objects consistent, readable, traceable, and safe to recreate as the platform grows from Synthea source ingestion into bronze, silver, gold, governance, audit, and API-facing assets.

## Scope

These standards apply to SQL Server scripts and objects created for ClinicalPulse, including schemas, tables, columns, constraints, indexes, views, stored procedures, validation queries, and API-facing SQL views.

## Core Schemas

| Schema | Purpose |
|---|---|
| `bronze` | Source-preserving ingestion tables with load metadata |
| `silver` | Cleaned, standardized, validated business entities |
| `gold` | Reporting-ready dimensions, facts, marts, and KPI-ready views |
| `governance` | KPI, quality, lineage, scorecard, ownership, and mapping objects |
| `audit` | Ingestion, reconciliation, transformation, and run-history logging |
| `api` | FHIR-aligned/API-facing SQL views |

Schema names are fixed project architecture names. Do not rename them without documenting the architecture decision.

## General Naming Rules

Use these rules for all SQL Server objects:

- Use lowercase `snake_case`.
- Use clear business names instead of unclear abbreviations.
- Avoid spaces, punctuation, and special characters.
- Avoid reserved SQL keywords as object names.
- Fully qualify objects with their schema name.
- Do not include environment names such as `dev`, `test`, or `prod` in object names.
- Do not use Hungarian-style data type prefixes such as `str_`, `int_`, or `dt_`.

Good examples:

```sql
bronze.patients
silver.patient
gold.dim_patient
gold.fact_encounter
governance.quality_check_result
audit.ingestion_batch
api.vw_fhir_patient
```

Avoid:

```sql
Patient Table
tblPatient
dimPatient
patient_dev
GoldPatientDimension
```

## Table Naming Standards

### Bronze Tables

Bronze tables should preserve the Synthea source entity names as closely as practical. Use plural source-style names.

Examples:

```sql
bronze.patients
bronze.encounters
bronze.conditions
bronze.observations
bronze.procedures
bronze.organizations
bronze.providers
```

### Silver Tables

Silver tables should use singular business-entity names because they represent cleaned and standardized entities.

Examples:

```sql
silver.patient
silver.encounter
silver.condition
silver.observation
silver.procedure
silver.organization
silver.provider
```

### Gold Tables

Gold tables should use dimensional modeling prefixes.

| Object Type | Prefix | Example |
|---|---|---|
| Dimension | `dim_` | `gold.dim_patient` |
| Fact | `fact_` | `gold.fact_encounter` |
| Mart | `mart_` | `gold.mart_patient_flow` |

Examples:

```sql
gold.dim_patient
gold.dim_date
gold.dim_organization
gold.fact_encounter
gold.fact_observation
gold.fact_readmission
gold.mart_patient_flow
gold.mart_length_of_stay
gold.mart_readmissions
gold.mart_lab_operations
gold.mart_service_utilization
gold.mart_reporting_trust
```

### Governance Tables

Governance table names should describe the governed asset, rule, mapping, or control process.

Examples:

```sql
governance.kpi_dictionary
governance.data_asset_catalog
governance.data_asset_scorecard
governance.data_lineage
governance.quality_rule
governance.quality_check_result
governance.fhir_mapping
```

### Audit Tables

Audit table names should describe the logged process.

Examples:

```sql
audit.ingestion_batch
audit.ingestion_file_log
audit.transformation_run_log
audit.row_count_reconciliation
audit.api_request_log
```

### API Views

API-facing views should use the prefix `vw_fhir_` when preparing FHIR-aligned resource outputs.

Examples:

```sql
api.vw_fhir_patient
api.vw_fhir_encounter
api.vw_fhir_observation
api.vw_fhir_condition
api.vw_fhir_procedure
```

## Column Naming Standards

Use lowercase `snake_case` for all column names.

Good examples:

```sql
patient_id
encounter_id
birth_date
encounter_start_datetime
encounter_stop_datetime
source_file
ingestion_batch_id
```

Avoid:

```sql
PatientID
Encounter Start
birthDate
DOB
```

### Identifier Columns

Use the pattern `<entity>_id`.

Examples:

```sql
patient_id
encounter_id
condition_id
observation_id
procedure_id
organization_id
provider_id
```

### Date and Time Columns

Use descriptive suffixes.

| Suffix | Use |
|---|---|
| `_date` | Date-only values |
| `_datetime` | Date and time values |
| `_year` | Four-digit year values |
| `_month` | Month number or month label, depending on context |

Examples:

```sql
birth_date
death_date
encounter_start_datetime
encounter_stop_datetime
ingestion_datetime
```

### Boolean and Flag Columns

Use `is_`, `has_`, or `_flag`.

Examples:

```sql
is_deceased
has_valid_encounter_dates
invalid_date_flag
readmission_flag
```

### Count and Measure Columns

Use clear measure names and units where relevant.

Examples:

```sql
encounter_count
patient_count
observation_count
length_of_stay_hours
length_of_stay_days
```

## Key and Constraint Naming Standards

| Object | Pattern | Example |
|---|---|---|
| Primary key | `pk_<table_name>` | `pk_patient` |
| Foreign key | `fk_<child_table>_<parent_table>` | `fk_encounter_patient` |
| Unique constraint | `uq_<table_name>_<column_or_business_key>` | `uq_patient_source_patient_id` |
| Check constraint | `ck_<table_name>_<rule_description>` | `ck_encounter_stop_after_start` |
| Default constraint | `df_<table_name>_<column_name>` | `df_patients_ingestion_datetime` |

Examples:

```sql
pk_patient
pk_encounter
pk_dim_patient
pk_fact_encounter
fk_encounter_patient
fk_condition_patient
fk_observation_encounter
fk_fact_encounter_dim_patient
uq_patient_source_patient_id
ck_encounter_stop_after_start
ck_patient_birth_date_not_future
df_patients_ingestion_datetime
```

## Index Naming Standards

| Index Type | Pattern | Example |
|---|---|---|
| Non-unique index | `ix_<table_name>_<column_list>` | `ix_encounter_patient_id` |
| Unique index | `ux_<table_name>_<column_list>` | `ux_patient_source_patient_id` |

Examples:

```sql
ix_encounter_patient_id
ix_encounter_start_datetime
ix_observation_encounter_id_observation_code
ux_patient_source_patient_id
ux_encounter_source_encounter_id
```

## View and Stored Procedure Naming Standards

Views should use the prefix `vw_`.

Examples:

```sql
gold.vw_patient_flow_summary
gold.vw_readmission_summary
api.vw_fhir_patient
api.vw_fhir_encounter
```

Stored procedures should use the prefix `usp_`.

Examples:

```sql
audit.usp_start_ingestion_batch
audit.usp_complete_ingestion_batch
governance.usp_record_quality_check_result
```

Stored procedures should be used only when procedural execution provides clear value. Prefer readable SQL scripts when a script is easier to review and maintain.

## Script Naming Standards

SQL scripts should use a numeric prefix to make execution order clear.

Pattern:

```text
<number>_<purpose>.sql
```

Examples:

```text
00_create_database.sql
01_create_schemas.sql
02_create_bronze_tables.sql
03_create_silver_tables.sql
04_create_gold_tables.sql
05_transform_bronze_to_silver.sql
06_transform_silver_to_gold.sql
07_data_quality_checks.sql
08_kpi_validation_queries.sql
09_create_api_views.sql
```

Script names should be stable. Do not create duplicate version names such as:

```text
02_create_bronze_tables_new.sql
02_create_bronze_tables_final.sql
```

Update the existing script and rely on Git history to track changes.

## Scripting Standards

SQL scripts should follow these rules:

- Start with a short comment block explaining the script purpose.
- Use `USE [ClinicalPulse];` when the script targets the project database.
- Use `GO` to separate logical batches where appropriate.
- Prefer idempotent scripts where practical.
- Check whether schemas, tables, constraints, and indexes exist before creating them.
- Use explicit schema qualification for database objects.
- Avoid `SELECT *` in reporting-facing views, validation queries, and transformations.
- Avoid hard-coded local paths in committed SQL scripts.
- Never store credentials, secrets, or connection strings in SQL files.
- Use clear `PRINT` statements when they improve setup feedback.
- Keep transformation and validation logic readable for portfolio review.

Example:

```sql
USE [ClinicalPulse];
GO

IF OBJECT_ID(N'bronze.patients', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.patients (
        patient_id NVARCHAR(100) NOT NULL,
        source_file NVARCHAR(255) NOT NULL,
        ingestion_datetime DATETIME2(0) NOT NULL
    );

    PRINT 'Created bronze.patients.';
END
ELSE
BEGIN
    PRINT 'bronze.patients already exists.';
END;
GO
```

## Data Type Standards

Use SQL Server data types intentionally and consistently.

| Data Type | Use |
|---|---|
| `INT` | Counts, small whole-number identifiers, sequence values |
| `BIGINT` | Large row counts or high-volume generated identifiers |
| `DECIMAL(p, s)` | Exact numeric values where precision matters |
| `FLOAT` | Approximate source measurement values |
| `NVARCHAR(n)` | Text values with known maximum length |
| `NVARCHAR(MAX)` | Long text only when necessary |
| `DATE` | Date-only fields |
| `DATETIME2(0)` | Standard datetime fields where seconds precision is enough |
| `DATETIME2(7)` | High-precision timestamps only when needed |
| `BIT` | Boolean flags |

Use `NVARCHAR` instead of `VARCHAR` unless there is a specific reason not to support Unicode.

## Bronze Ingestion Metadata Standards

Bronze source tables should include ingestion metadata columns.

| Column | Recommended Type | Purpose |
|---|---|---|
| `ingestion_batch_id` | `INT NOT NULL` | Identifies the load batch |
| `ingestion_datetime` | `DATETIME2(0) NOT NULL` | Records when the row was loaded |
| `source_file` | `NVARCHAR(255) NOT NULL` | Identifies the source file |
| `row_hash` | `VARBINARY(32) NULL` | Supports duplicate/change detection |
| `load_status` | `NVARCHAR(30) NOT NULL` | Records load status for auditability |

These columns support traceability, reconciliation, and data quality validation.

## Lineage Standards

Curated silver and gold objects should preserve traceability to source records where practical.

Recommended lineage fields:

```sql
source_patient_id
source_encounter_id
source_condition_id
source_observation_id
source_procedure_id
ingestion_batch_id
source_file
```

Gold objects should retain enough lineage to support KPI validation and reviewer traceability without exposing unnecessary raw detail.

## Validation Query Standards

Validation queries should be readable and tied to a clear rule.

Good example:

```sql
SELECT
    COUNT(*) AS invalid_encounter_date_count
FROM silver.encounter
WHERE encounter_stop_datetime < encounter_start_datetime;
```

Avoid unclear aliases:

```sql
SELECT COUNT(*) AS cnt
FROM silver.encounter
WHERE stop < start;
```

## Documentation Standards

When a SQL object supports a governed KPI, dashboard, scorecard, lineage record, or API view, document its purpose in the relevant project artifact.

| SQL Object | Related Documentation |
|---|---|
| `gold.fact_encounter` | Data asset catalog, data lineage, KPI dictionary |
| `gold.mart_readmissions` | KPI dictionary, Power BI measure documentation |
| `governance.quality_check_result` | Data quality framework, data asset scorecard |
| `api.vw_fhir_patient` | FHIR mapping document, API reference |

## Assumptions and Limitations

- These standards are designed for the SQL Server implementation of ClinicalPulse.
- Bronze tables may use plural source-style names to stay close to Synthea CSV source files.
- Silver tables use singular business-entity names to represent cleaned entities.
- Gold tables follow dimensional modeling conventions and may evolve as reporting needs become clearer.
- These standards prioritize clarity, traceability, and portfolio readability over advanced enterprise automation.
- Naming conventions may be revised later, but meaningful changes should be documented.
