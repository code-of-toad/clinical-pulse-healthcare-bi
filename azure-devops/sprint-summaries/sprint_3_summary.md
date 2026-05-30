# Sprint 3 Summary: SQL Server Ingestion

## Sprint Objective

Sprint 3 established the SQL Server ingestion foundation for ClinicalPulse. The sprint created the project database and schemas, defined SQL standards, configured safe local database access, built bronze tables for selected Synthea entities, loaded source CSVs into SQL Server, added ingestion metadata and audit logging support, and reconciled source-to-bronze row counts.

## Completed User Stories

| User Story | Title | Outcome |
|---:|---|---|
| 1440 | Create database and schema scripts | Created SQL Server database setup and core schemas: `bronze`, `silver`, `gold`, `governance`, `audit`, and `api`. |
| 1444 | Define SQL naming and scripting standards | Documented naming, scripting, table, column, constraint, index, and layer conventions. |
| 1448 | Set up local SQL Server connection configuration | Documented safe local SQL Server connection configuration using environment variables and no committed secrets. |
| 1453 | Create bronze patient and organization/provider tables | Created bronze tables for `patients`, `organizations`, and `providers`. |
| 1457 | Create bronze encounter and condition tables | Created bronze tables for `encounters` and `conditions`. |
| 1461 | Create bronze observation and procedure tables | Created bronze tables for `observations` and `procedures`. |
| 1465 | Add ingestion metadata columns to bronze tables | Added standard metadata columns for batch ID, load timestamp, source file, row hash, and load status. |
| 1470 | Build database configuration utilities | Built Python database configuration utilities for centralized SQL Server connection handling. |
| 1473 | Build Synthea CSV ingestion script | Built Python ingestion script to load selected Synthea CSV files into bronze tables. |
| 1477 | Write ingestion logs to audit tables | Added audit table structures and ingestion logging hooks for batch-level and file-level load tracking. |
| 1481 | Run initial load and verify row counts | Built and ran row count reconciliation between source CSV files and bronze SQL tables. |

## Deliverables Created or Updated

| Path | Purpose |
|---|---|
| `sql/00_create_database.sql` | Creates the `ClinicalPulse` database. |
| `sql/01_create_schemas.sql` | Creates required SQL Server schemas. |
| `docs/sql_standards.md` | Defines SQL naming and scripting conventions. |
| `src/config.md` | Documents safe local SQL Server connection configuration. |
| `sql/2_create_bronze_tables.sql` | Creates selected bronze tables and adds ingestion metadata columns. |
| `src/db_config.py` | Centralizes Python SQL Server connection configuration. |
| `src/ingest_synthea_csv_to_sqlserver.py` | Loads selected Synthea CSV files into bronze tables. |
| `sql/audit_tables.sql` | Creates ingestion audit tables. |
| `src/row_count_reconciliation.py` | Reconciles source CSV row counts against bronze table row counts. |

## Initial Load Validation

The initial source-to-bronze load was validated successfully. All configured source CSV row counts matched their corresponding bronze table row counts.

| Entity | Source File | Bronze Table | Source Rows | Bronze Rows | Status |
|---|---|---|---:|---:|---|
| Conditions | `conditions.csv` | `bronze.conditions` | 43,758 | 43,758 | Matched |
| Encounters | `encounters.csv` | `bronze.encounters` | 71,663 | 71,663 | Matched |
| Observations | `observations.csv` | `bronze.observations` | 945,531 | 945,531 | Matched |
| Organizations | `organizations.csv` | `bronze.organizations` | 826 | 826 | Matched |
| Patients | `patients.csv` | `bronze.patients` | 1,145 | 1,145 | Matched |
| Procedures | `procedures.csv` | `bronze.procedures` | 196,207 | 196,207 | Matched |
| Providers | `providers.csv` | `bronze.providers` | 826 | 826 | Matched |

**Total source rows:** 1,259,956  
**Total bronze rows:** 1,259,956  
**Overall reconciliation status:** Passed

## Technical Notes

Bronze tables intentionally store source values primarily as `NVARCHAR` to avoid irreversible parsing decisions during raw ingestion. Type conversion, date standardization, categorization, quality flags, and business-rule enforcement are deferred to later silver-layer work.

The ingestion script uses configured source-to-bronze mappings instead of relying on automatic column matching. This keeps the load process explicit and reviewable while still allowing the bronze layer to use project-standard column names.

The Python database configuration utility centralizes SQL Server connection settings and reads connection values from environment variables, supporting safer local development without committed credentials.

## Assumptions and Limitations

- The source data is Synthea-generated synthetic EHR-style data, not real patient data.
- Raw generated CSV files remain local and are not committed to Git.
- Sprint 3 focuses on ingestion into bronze only; silver cleaning, validation rules, and gold reporting models are handled in later sprints.
- Bronze columns preserve source values but use readable project-standard column names rather than exact raw CSV header names.
- Ingestion audit logging captures batch-level and file-level load status; broader transformation and quality logging will be expanded later.
- Python package dependencies are installed locally during development; the final project dependency file can be frozen near final delivery.

## Sprint Outcome

Sprint 3 successfully established the ClinicalPulse SQL Server ingestion foundation. The project now has a working local database, standardized SQL structure, bronze source tables, centralized Python database configuration, repeatable Synthea CSV ingestion, audit logging support, and verified source-to-bronze row count reconciliation.

ClinicalPulse is now ready to move from source ingestion into the next layer of the medallion pipeline: silver-layer cleaning, standardization, validation, and business entity modeling.
