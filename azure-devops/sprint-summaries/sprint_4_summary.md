# Sprint 4 Summary: Silver Layer and Validation

**Project:** ClinicalPulse  
**Sprint:** Sprint 4 - Silver Layer and Validation  
**Primary focus:** Build standardized silver entities, preserve bronze-to-silver lineage, and implement governed data quality checks with persisted results.

## Sprint Outcome

Sprint 4 established the core silver layer and the first governed validation framework for ClinicalPulse. Bronze source records are now transformed into standardized, typed, analytics-ready silver entities, while quality rules and quality-check results are stored under the governance schema for auditability and future reporting trust.

## Completed User Stories

| User Story | Title | Outcome |
|---:|---|---|
| 1487 | Build `silver.patient` | Created and populated standardized patient demographics with typed dates, age logic, age bands, deceased status, patient date quality status, and bronze lineage fields. |
| 1491 | Build `silver.encounter` with LOS fields | Created and populated standardized encounters with typed UTC start/stop timestamps, dates, duration fields, length of stay, datetime quality flags, and bronze lineage fields. |
| 1495 | Build silver condition, procedure, and observation entities | Created and populated standardized clinical context entities for conditions, procedures, and observations, including typed dates/timestamps, derived categories/statuses, quality flags, numeric parsing, and lineage fields. |
| 1499 | Preserve lineage from bronze to silver | Documented and validated the bronze-to-silver lineage contract using ingestion batch ID, ingestion datetime, source file, row hash, load status, and silver load timestamp. |
| 1539 | Create governance quality rule metadata table | Created `governance.quality_rule` and seeded active metadata rules covering completeness, uniqueness, referential integrity, validity, consistency, freshness, and lineage. |
| 1543 | Implement completeness, uniqueness, and referential integrity checks | Created executable current-state quality checks through `governance.vw_quality_check_current` and `src/run_quality_checks.py`. |
| 1546 | Implement validity, consistency, and freshness checks | Expanded the quality framework to validate date logic, standardized categories, and freshness between bronze ingestion and silver load timestamps. |
| 1549 | Persist quality check results | Created `governance.quality_check_result` and updated the Python runner to persist each quality-check run with a unique run ID and audit-ready result rows. |

## Main Deliverables

### SQL Deliverables

| File | Purpose |
|---|---|
| `sql/03_create_silver_tables.sql` | Defines silver-layer tables for patient, encounter, condition, procedure, and observation entities. |
| `sql/05_transform_bronze_to_silver.sql` | Transforms bronze source tables into standardized silver tables while preserving lineage metadata. |
| `sql/07_data_quality_checks.sql` | Defines quality rule metadata, current-state quality checks, and persisted quality-check result storage. |

### Python Deliverable

| File | Purpose |
|---|---|
| `src/run_quality_checks.py` | Executes quality checks from `governance.vw_quality_check_current`, prints results, and persists run results to `governance.quality_check_result` by default. |

## Silver Layer Entities Built

| Silver Table | Source Table | Current Row Count | Key Additions |
|---|---|---:|---|
| `silver.patient` | `bronze.patients` | 1,145 | Typed birth/death dates, deceased flag, age reference logic, `age_years`, `age_band`, demographic standardization, date quality status, lineage. |
| `silver.encounter` | `bronze.encounters` | 71,663 | Typed UTC start/stop timestamps, start/stop dates, duration minutes/hours, LOS days, datetime quality status, lineage. |
| `silver.condition` | `bronze.conditions` | 43,758 | Typed condition dates, condition duration, category/status fields, date quality status, lineage. |
| `silver.procedure` | `bronze.procedures` | 196,207 | Typed UTC procedure timestamps, duration minutes/hours, procedure category, datetime quality status, lineage. |
| `silver.observation` | `bronze.observations` | 945,531 | Typed UTC observation timestamp, observation date, parsed numeric value, standardized category, observation quality status, lineage. |

## Data Quality Framework

### Implemented Rule Dimensions

| Dimension | Checks Executed |
|---|---:|
| Completeness | 3 |
| Uniqueness | 3 |
| Referential integrity | 7 |
| Validity | 4 |
| Consistency | 2 |
| Freshness | 1 |
| **Total executable checks** | **20** |

### Latest Quality Check Run

| Field | Value |
|---|---|
| Quality check run ID | `ceeea4ad-e424-4b69-a693-2816f7631768` |
| Persisted result rows | 20 |
| Passed checks | 19 |
| Failed checks | 1 |
| Persisted datetime | `2026-05-31 19:22:37` |

### Known Data Quality Finding

| Rule | Status | Failed Records | Pass Rate | Notes |
|---|---|---:|---:|---|
| `DQ_OBSERVATION_ROW_UNIQUE` | Failed | 256 | 0.9997 | Detected 256 excess duplicate observation records under the current natural-grain definition. This is retained as a visible quality finding rather than suppressed. |

All other completeness, uniqueness, referential integrity, validity, consistency, and freshness checks passed.

## Validation Evidence

Sprint 4 validation confirmed:

- Bronze-to-silver row counts reconcile for all current silver entities.
- Patient and encounter identifiers are complete and unique.
- Observation required fields are complete.
- Patient, encounter, condition, procedure, and observation references are intact where required.
- Observations with null encounter references are allowed when patient-linked, because the source contains patient-level observations without encounter links.
- Patient age logic, encounter LOS logic, condition date logic, and procedure timestamp logic pass validity checks.
- Encounter class and observation category standardization pass consistency checks.
- Silver load timestamps are not older than the latest bronze ingestion timestamps.
- Quality check results persist successfully to `governance.quality_check_result` with a run ID and audit metadata.

## Key Assumptions and Limitations

- The source data is synthetic Synthea CSV data and does not represent real patients or real hospital operations.
- The current row counts are based on the active source run used during Sprint 4.
- Bronze is source-preserving; silver is where business-friendly naming, typing, validation flags, and derived fields are introduced.
- Patient direct-identifier-style fields from bronze are intentionally excluded from silver reporting entities.
- Observation duplicate detection currently uses a natural-grain definition based on patient, encounter, observation timestamp, observation code, value, and units.
- The known observation duplicate finding is not resolved in Sprint 4; it is preserved for governance visibility and possible later remediation.
- Persisted quality results are append-only run results. Historical runs should be retained unless there is a documented cleanup policy.

## Recommended Commit Messages Used or Ready to Use

```bash
git commit -m "Build silver patient entity AB#1487"
git commit -m "Build silver encounter with LOS fields AB#1491"
git commit -m "Build silver clinical context entities AB#1495"
git commit -m "Preserve bronze to silver lineage AB#1499"
git commit -m "Create governance quality rule metadata AB#1539"
git commit -m "Implement silver completeness uniqueness and referential checks AB#1543"
git commit -m "Implement silver validity consistency and freshness checks AB#1546"
git commit -m "Persist quality check results AB#1549"
```

## Sprint 4 Completion Summary

Sprint 4 is complete. ClinicalPulse now has a functional silver layer for the core patient, encounter, condition, procedure, and observation entities, plus a governed quality framework that can execute, display, and persist quality-check results. The project is ready to proceed toward gold-layer modeling and reporting marts using validated silver entities and persisted data quality results as trust signals.
