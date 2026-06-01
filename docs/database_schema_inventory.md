# Database Schema Inventory

This document records the current SQL Server table structures, view structures, and representative sample values for the ClinicalPulse bronze, silver, gold, audit, and governance schemas. It is intended to support reliable transformation work, data quality rule design, lineage documentation, and future assistant/project-source context.

ClinicalPulse uses synthetic Synthea data. The sample values below are not real patient data and should not be described as clinical evidence or production hospital records.

## Portfolio-Safety Note

The current `bronze.patients` table contains direct-identifier-style Synthea fields such as `ssn`, `drivers`, `passport`, `first_name`, `middle_name`, `last_name`, `maiden`, `birthplace`, and `street_address`.

Those fields are documented in the schema inventory because they exist in bronze, but patient sample rows below intentionally exclude or redact them. They should generally not be carried into silver/gold reporting tables unless there is a specific documented reason.

## Current Scope

The current database inventory covers:

| Schema | Object Group | Type |
|---|---|---|
| `audit` | ingestion batch and ingestion file log | Tables |
| `bronze` | patients, encounters, conditions, observations, procedures, organizations, providers | Tables |
| `silver` | patient, encounter, condition, procedure, observation | Tables |
| `gold` | dimensions, facts, and reporting marts | Tables and views |
| `governance` | quality rules, persisted quality-check results, current quality-check view | Tables and view |
| `api` | FHIR/API demonstration views | Planned, not yet implemented |

The current bronze model is source-preserving. Most source business fields are stored as `nvarchar` in bronze and are typed, standardized, and validated in silver. The gold layer contains reporting-ready dimensions, facts, and marts. The governance layer stores quality rule metadata and persisted quality-check results.

## Audit Load Snapshot

Latest visible ingestion batch:

| ingestion_batch_id | source_system | raw_directory | ingestion_mode | entity_count | started_at | completed_at | load_status | total_rows_loaded |
|---:|---|---|---|---:|---|---|---|---:|
| 2 | Synthea CSV | `data\raw\synthea` | replace | 7 | 2026-05-31 04:15:49 | 2026-05-31 04:17:26 | succeeded | 1,259,956 |
| 1 | Synthea CSV | `data\raw\synthea` | replace | 7 | 2026-05-30 00:36:25 | 2026-05-30 00:37:55 | succeeded | 1,259,956 |

Visible file-log sample from batch 2:

| source_file | target_table | rows_loaded | load_status |
|---|---|---:|---|
| `providers.csv` | `bronze.providers` | 826 | succeeded |
| `procedures.csv` | `bronze.procedures` | 196,207 | succeeded |
| `patients.csv` | `bronze.patients` | 1,145 | succeeded |
| `organizations.csv` | `bronze.organizations` | 826 | succeeded |
| `observations.csv` | `bronze.observations` | 945,531 | succeeded |

## Column Inventory

### `audit.ingestion_batch`

| Ordinal | Column | Data Type | Length | Nullable |
|---:|---|---|---:|---|
| 1 | `ingestion_batch_id` | `bigint` | NULL | NO |
| 2 | `source_system` | `nvarchar` | 100 | NO |
| 3 | `raw_directory` | `nvarchar` | 500 | YES |
| 4 | `ingestion_mode` | `nvarchar` | 20 | NO |
| 5 | `entity_count` | `int` | NULL | NO |
| 6 | `started_at` | `datetime2` | NULL | NO |
| 7 | `completed_at` | `datetime2` | NULL | YES |
| 8 | `load_status` | `nvarchar` | 30 | NO |
| 9 | `total_rows_loaded` | `bigint` | NULL | NO |
| 10 | `error_message` | `nvarchar` | -1 | YES |

### `audit.ingestion_file_log`

| Ordinal | Column | Data Type | Length | Nullable |
|---:|---|---|---:|---|
| 1 | `ingestion_file_log_id` | `bigint` | NULL | NO |
| 2 | `ingestion_batch_id` | `bigint` | NULL | NO |
| 3 | `source_file` | `nvarchar` | 255 | NO |
| 4 | `target_schema` | `nvarchar` | 128 | NO |
| 5 | `target_table` | `nvarchar` | 128 | NO |
| 6 | `started_at` | `datetime2` | NULL | NO |
| 7 | `completed_at` | `datetime2` | NULL | YES |
| 8 | `load_status` | `nvarchar` | 30 | NO |
| 9 | `rows_loaded` | `bigint` | NULL | NO |
| 10 | `error_message` | `nvarchar` | -1 | YES |

### `bronze.patients`

| Ordinal | Column | Data Type | Length | Nullable | Notes |
|---:|---|---|---:|---|---|
| 1 | `source_patient_id` | `nvarchar` | 100 | YES | Source patient identifier; maps to `silver.patient.patient_id`. |
| 2 | `birthdate` | `nvarchar` | 50 | YES | Date-like string; maps to `birth_date`. |
| 3 | `deathdate` | `nvarchar` | 50 | YES | Date-like string; maps to `death_date`. |
| 4 | `ssn` | `nvarchar` | 50 | YES | Direct-identifier-style field; document but exclude from reporting layers. |
| 5 | `drivers` | `nvarchar` | 50 | YES | Direct-identifier-style field; document but exclude from reporting layers. |
| 6 | `passport` | `nvarchar` | 50 | YES | Direct-identifier-style field; document but exclude from reporting layers. |
| 7 | `prefix` | `nvarchar` | 50 | YES | Name-related field. |
| 8 | `first_name` | `nvarchar` | 100 | YES | Name-related field; exclude from public reporting samples. |
| 9 | `middle_name` | `nvarchar` | 100 | YES | Name-related field; exclude from public reporting samples. |
| 10 | `last_name` | `nvarchar` | 100 | YES | Name-related field; exclude from public reporting samples. |
| 11 | `suffix` | `nvarchar` | 50 | YES | Name-related field. |
| 12 | `maiden` | `nvarchar` | 100 | YES | Name-related field. |
| 13 | `marital` | `nvarchar` | 50 | YES | Maps to `silver.patient.marital_status`. |
| 14 | `race` | `nvarchar` | 100 | YES | Demographic field. |
| 15 | `ethnicity` | `nvarchar` | 100 | YES | Demographic field. |
| 16 | `gender` | `nvarchar` | 50 | YES | Demographic field. |
| 17 | `birthplace` | `nvarchar` | 255 | YES | Sensitive-ish location context; generally exclude from reporting. |
| 18 | `street_address` | `nvarchar` | 255 | YES | Address field; generally exclude from reporting. |
| 19 | `city` | `nvarchar` | 100 | YES | Geographic field. |
| 20 | `state` | `nvarchar` | 100 | YES | Geographic field. |
| 21 | `county` | `nvarchar` | 100 | YES | Geographic field. |
| 22 | `fips` | `nvarchar` | 50 | YES | Geographic code. |
| 23 | `zip` | `nvarchar` | 20 | YES | Postal code. |
| 24 | `lat` | `nvarchar` | 50 | YES | Convert to decimal latitude in silver. |
| 25 | `lon` | `nvarchar` | 50 | YES | Convert to decimal longitude in silver. |
| 26 | `healthcare_expenses` | `nvarchar` | 50 | YES | Convert to decimal in silver. |
| 27 | `healthcare_coverage` | `nvarchar` | 50 | YES | Convert to decimal in silver. |
| 28 | `income` | `nvarchar` | 50 | YES | Convert to decimal/integer in silver. |
| 29 | `ingestion_batch_id` | `bigint` | NULL | YES | Bronze lineage field. |
| 30 | `ingestion_datetime` | `datetime2` | NULL | NO | Bronze lineage field. |
| 31 | `source_file` | `nvarchar` | 255 | YES | Bronze lineage field. |
| 32 | `row_hash` | `varbinary` | 32 | YES | Bronze lineage hash. |
| 33 | `load_status` | `nvarchar` | 30 | NO | Bronze load status. |

### `bronze.encounters`

| Ordinal | Column | Data Type | Length | Nullable | Notes |
|---:|---|---|---:|---|---|
| 1 | `source_encounter_id` | `nvarchar` | 100 | YES | Source encounter identifier; maps to silver encounter key. |
| 2 | `encounter_start_datetime` | `nvarchar` | 50 | YES | ISO timestamp string with `Z`; convert in silver. |
| 3 | `encounter_stop_datetime` | `nvarchar` | 50 | YES | ISO timestamp string with `Z`; convert in silver. |
| 4 | `source_patient_id` | `nvarchar` | 100 | YES | Patient reference. |
| 5 | `source_organization_id` | `nvarchar` | 100 | YES | Organization reference. |
| 6 | `source_provider_id` | `nvarchar` | 100 | YES | Provider reference. |
| 7 | `source_payer_id` | `nvarchar` | 100 | YES | Payer reference; payer table not currently in bronze scope. |
| 8 | `encounter_class` | `nvarchar` | 100 | YES | Encounter grouping field. |
| 9 | `encounter_code` | `nvarchar` | 100 | YES | Clinical/administrative code. |
| 10 | `encounter_description` | `nvarchar` | 255 | YES | Encounter description. |
| 11 | `base_encounter_cost` | `nvarchar` | 50 | YES | Convert to decimal in silver. |
| 12 | `total_claim_cost` | `nvarchar` | 50 | YES | Convert to decimal in silver. |
| 13 | `payer_coverage` | `nvarchar` | 50 | YES | Convert to decimal in silver. |
| 14 | `reason_code` | `nvarchar` | 100 | YES | Reason code. |
| 15 | `reason_description` | `nvarchar` | 255 | YES | Reason description. |
| 16 | `ingestion_batch_id` | `bigint` | NULL | YES | Bronze lineage field. |
| 17 | `ingestion_datetime` | `datetime2` | NULL | NO | Bronze lineage field. |
| 18 | `source_file` | `nvarchar` | 255 | YES | Bronze lineage field. |
| 19 | `row_hash` | `varbinary` | 32 | YES | Bronze lineage hash. |
| 20 | `load_status` | `nvarchar` | 30 | NO | Bronze load status. |

### `bronze.conditions`

| Ordinal | Column | Data Type | Length | Nullable | Notes |
|---:|---|---|---:|---|---|
| 1 | `condition_start_date` | `nvarchar` | 50 | YES | Date-like string; convert to date. |
| 2 | `condition_stop_date` | `nvarchar` | 50 | YES | Date-like string; convert to date. |
| 3 | `source_patient_id` | `nvarchar` | 100 | YES | Patient reference. |
| 4 | `source_encounter_id` | `nvarchar` | 100 | YES | Encounter reference. |
| 5 | `condition_system` | `nvarchar` | 255 | YES | Coding system, e.g. SNOMED-CT. |
| 6 | `condition_code` | `nvarchar` | 100 | YES | Condition code. |
| 7 | `condition_description` | `nvarchar` | 255 | YES | Condition description. |
| 8 | `ingestion_batch_id` | `bigint` | NULL | YES | Bronze lineage field. |
| 9 | `ingestion_datetime` | `datetime2` | NULL | NO | Bronze lineage field. |
| 10 | `source_file` | `nvarchar` | 255 | YES | Bronze lineage field. |
| 11 | `row_hash` | `varbinary` | 32 | YES | Bronze lineage hash. |
| 12 | `load_status` | `nvarchar` | 30 | NO | Bronze load status. |

### `bronze.observations`

| Ordinal | Column | Data Type | Length | Nullable | Notes |
|---:|---|---|---:|---|---|
| 1 | `observation_datetime` | `nvarchar` | 50 | YES | ISO timestamp string with `Z`; convert in silver. |
| 2 | `source_patient_id` | `nvarchar` | 100 | YES | Patient reference. |
| 3 | `source_encounter_id` | `nvarchar` | 100 | YES | Encounter reference; may be NULL for some observations. |
| 4 | `observation_category` | `nvarchar` | 100 | YES | May be NULL for some records. |
| 5 | `observation_code` | `nvarchar` | 100 | YES | Observation code; sample includes QALY/QOLS. |
| 6 | `observation_description` | `nvarchar` | 255 | YES | Observation description. |
| 7 | `observation_value` | `nvarchar` | 255 | YES | Value as string; may require numeric parsing by `observation_type`. |
| 8 | `observation_units` | `nvarchar` | 100 | YES | Unit string. |
| 9 | `observation_type` | `nvarchar` | 100 | YES | Sample includes `numeric`. |
| 10 | `ingestion_batch_id` | `bigint` | NULL | YES | Bronze lineage field. |
| 11 | `ingestion_datetime` | `datetime2` | NULL | NO | Bronze lineage field. |
| 12 | `source_file` | `nvarchar` | 255 | YES | Bronze lineage field. |
| 13 | `row_hash` | `varbinary` | 32 | YES | Bronze lineage hash. |
| 14 | `load_status` | `nvarchar` | 30 | NO | Bronze load status. |

### `bronze.procedures`

| Ordinal | Column | Data Type | Length | Nullable | Notes |
|---:|---|---|---:|---|---|
| 1 | `procedure_start_datetime` | `nvarchar` | 50 | YES | ISO timestamp string with `Z`; convert in silver. |
| 2 | `procedure_stop_datetime` | `nvarchar` | 50 | YES | ISO timestamp string with `Z`; convert in silver. |
| 3 | `source_patient_id` | `nvarchar` | 100 | YES | Patient reference. |
| 4 | `source_encounter_id` | `nvarchar` | 100 | YES | Encounter reference. |
| 5 | `procedure_system` | `nvarchar` | 255 | YES | Coding system, e.g. SNOMED-CT. |
| 6 | `procedure_code` | `nvarchar` | 100 | YES | Procedure code. |
| 7 | `procedure_description` | `nvarchar` | 255 | YES | Procedure description. |
| 8 | `base_procedure_cost` | `nvarchar` | 50 | YES | Convert to decimal in silver. |
| 9 | `reason_code` | `nvarchar` | 100 | YES | Reason code. |
| 10 | `reason_description` | `nvarchar` | 255 | YES | Reason description. |
| 11 | `ingestion_batch_id` | `bigint` | NULL | YES | Bronze lineage field. |
| 12 | `ingestion_datetime` | `datetime2` | NULL | NO | Bronze lineage field. |
| 13 | `source_file` | `nvarchar` | 255 | YES | Bronze lineage field. |
| 14 | `row_hash` | `varbinary` | 32 | YES | Bronze lineage hash. |
| 15 | `load_status` | `nvarchar` | 30 | NO | Bronze load status. |

### `bronze.organizations`

| Ordinal | Column | Data Type | Length | Nullable | Notes |
|---:|---|---|---:|---|---|
| 1 | `source_organization_id` | `nvarchar` | 100 | YES | Source organization identifier. |
| 2 | `organization_name` | `nvarchar` | 255 | YES | Organization name. |
| 3 | `street_address` | `nvarchar` | 255 | YES | Organization address. |
| 4 | `city` | `nvarchar` | 100 | YES | City. |
| 5 | `state_code` | `nvarchar` | 100 | YES | State code; maps to standardized organization state in silver. |
| 6 | `zip` | `nvarchar` | 20 | YES | Postal code. |
| 7 | `lat` | `nvarchar` | 50 | YES | Convert to decimal latitude in silver. |
| 8 | `lon` | `nvarchar` | 50 | YES | Convert to decimal longitude in silver. |
| 9 | `phone` | `nvarchar` | 50 | YES | Organization phone. |
| 10 | `revenue` | `nvarchar` | 50 | YES | Convert to decimal in silver if retained. |
| 11 | `utilization` | `nvarchar` | 50 | YES | Convert to numeric/integer in silver if retained. |
| 12 | `ingestion_batch_id` | `bigint` | NULL | YES | Bronze lineage field. |
| 13 | `ingestion_datetime` | `datetime2` | NULL | NO | Bronze lineage field. |
| 14 | `source_file` | `nvarchar` | 255 | YES | Bronze lineage field. |
| 15 | `row_hash` | `varbinary` | 32 | YES | Bronze lineage hash. |
| 16 | `load_status` | `nvarchar` | 30 | NO | Bronze load status. |

### `bronze.providers`

| Ordinal | Column | Data Type | Length | Nullable | Notes |
|---:|---|---|---:|---|---|
| 1 | `source_provider_id` | `nvarchar` | 100 | YES | Source provider identifier. |
| 2 | `source_organization_id` | `nvarchar` | 100 | YES | Organization reference. |
| 3 | `provider_name` | `nvarchar` | 255 | YES | Provider name. |
| 4 | `gender` | `nvarchar` | 50 | YES | Provider gender. |
| 5 | `speciality` | `nvarchar` | 255 | YES | Source spelling is `speciality`; may standardize to `specialty` in silver. |
| 6 | `street_address` | `nvarchar` | 255 | YES | Provider address. |
| 7 | `city` | `nvarchar` | 100 | YES | City. |
| 8 | `state_code` | `nvarchar` | 100 | YES | State code. |
| 9 | `zip` | `nvarchar` | 20 | YES | Postal code. |
| 10 | `lat` | `nvarchar` | 50 | YES | Convert to decimal latitude in silver. |
| 11 | `lon` | `nvarchar` | 50 | YES | Convert to decimal longitude in silver. |
| 12 | `encounter_count` | `nvarchar` | 50 | YES | Convert to integer in silver if retained. |
| 13 | `procedure_count` | `nvarchar` | 50 | YES | Convert to integer in silver if retained. |
| 14 | `ingestion_batch_id` | `bigint` | NULL | YES | Bronze lineage field. |
| 15 | `ingestion_datetime` | `datetime2` | NULL | NO | Bronze lineage field. |
| 16 | `source_file` | `nvarchar` | 255 | YES | Bronze lineage field. |
| 17 | `row_hash` | `varbinary` | 32 | YES | Bronze lineage hash. |
| 18 | `load_status` | `nvarchar` | 30 | NO | Bronze load status. |

## Representative Sample Values

### `bronze.patients` sample

Patient direct identifiers and name/address fields are excluded from this sample section.

| source_patient_id | birthdate | deathdate | marital | race | ethnicity | gender | city | state | county | fips | zip | lat | lon | healthcare_expenses | healthcare_coverage | income | ingestion_batch_id | ingestion_datetime | source_file | load_status |
|---|---|---|---|---|---|---|---|---|---|---|---|---:|---:|---:|---:|---:|---:|---|---|---|
| 00710f47-36de-4d24-1e15-d9b77f5096b8 | 1966-04-11 | NULL | M | black | nonhispanic | M | Boston | Massachusetts | Suffolk County | 25025 | 02152 | 42.33306117060206 | -71.13533020752708 | 225058.27 | 185971.24 | 27898 | 2 | 2026-05-31 04:17:13 | patients.csv | loaded |
| 00b64473-9de5-cfac-1ece-16fffba92ac8 | 2014-12-08 | NULL | NULL | hawaiian | nonhispanic | F | Boston | Massachusetts | Suffolk County | 25025 | 02129 | 42.258954158238026 | -71.1961663496271 | 28618.96 | 2578.45 | 83517 | 2 | 2026-05-31 04:17:13 | patients.csv | loaded |
| 0103d5dd-3dd6-e4ee-f79d-e84db4035eaf | 1962-03-20 | NULL | M | asian | nonhispanic | M | Somerville | Massachusetts | Middlesex County | 25017 | 02155 | 42.411253593786306 | -71.05696166240823 | 115216.58 | 1042761.41 | 6362 | 2 | 2026-05-31 04:17:13 | patients.csv | loaded |

### `bronze.encounters` sample

| source_encounter_id | encounter_start_datetime | encounter_stop_datetime | source_patient_id | encounter_class | encounter_code | encounter_description | base_encounter_cost | total_claim_cost | payer_coverage | reason_code | reason_description | source_file | load_status |
|---|---|---|---|---|---|---|---:|---:|---:|---|---|---|---|
| 00710f47-36de-4d24-015a-79647aba53a3 | 2017-03-20T20:28:05Z | 2017-03-21T00:12:30Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | ambulatory | 185349003 | Encounter for check up (procedure) | 85.55 | 3536.75 | 2122.05 | 103697008 | Patient referral for dental care (procedure) | encounters.csv | loaded |
| 00710f47-36de-4d24-14f6-9e776bd43aad | 2020-04-27T05:28:05Z | 2020-04-27T05:43:05Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | ambulatory | 185345009 | Encounter for symptom (procedure) | 85.55 | 85.55 | 0.00 | 36971009 | Sinusitis (disorder) | encounters.csv | loaded |
| 00710f47-36de-4d24-1b3d-9488710345f5 | 2020-05-04T05:28:05Z | 2020-05-04T05:43:05Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | ambulatory | 185345009 | Encounter for symptom (procedure) | 85.55 | 85.55 | 0.00 | 36971009 | Sinusitis (disorder) | encounters.csv | loaded |

### `bronze.conditions` sample

| condition_start_date | condition_stop_date | source_patient_id | source_encounter_id | condition_system | condition_code | condition_description | source_file | load_status |
|---|---|---|---|---|---|---|---|---|
| 2018-03-12 | 2019-03-18 | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 00710f47-36de-4d24-2d5a-4033bb72eb49 | SNOMED-CT | 741062008 | Not in labor force (finding) | conditions.csv | loaded |
| 2018-03-12 | 2018-03-26 | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 00710f47-36de-4d24-2d5a-4033bb72eb49 | SNOMED-CT | 66383009 | Gingivitis (disorder) | conditions.csv | loaded |
| 2025-04-21 | 2026-04-27 | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 00710f47-36de-4d24-2e05-22ca0cfc8bbb | SNOMED-CT | 422650009 | Social isolation (finding) | conditions.csv | loaded |

### `bronze.observations` sample

| observation_datetime | source_patient_id | source_encounter_id | observation_category | observation_code | observation_description | observation_value | observation_units | observation_type | source_file | load_status |
|---|---|---|---|---|---|---:|---|---|---|---|
| 2024-04-11T19:28:05Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | NULL | NULL | QALY | QALY | 56.1 | a | numeric | observations.csv | loaded |
| 2020-04-11T19:28:05Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | NULL | NULL | QOLS | QOLS | 0.9 | `{score}` | numeric | observations.csv | loaded |
| 2016-04-11T19:28:05Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | NULL | NULL | QALY | QALY | 48.8 | a | numeric | observations.csv | loaded |

### `bronze.procedures` sample

| procedure_start_datetime | procedure_stop_datetime | source_patient_id | source_encounter_id | procedure_system | procedure_code | procedure_description | base_procedure_cost | reason_code | reason_description | source_file | load_status |
|---|---|---|---|---|---|---|---:|---|---|---|---|
| 2017-03-20T20:28:05Z | 2017-03-20T21:04:26Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 00710f47-36de-4d24-015a-79647aba53a3 | SNOMED-CT | 34043003 | Dental consultation and report (procedure) | 431.40 | 103697008 | Patient referral for dental care (procedure) | procedures.csv | loaded |
| 2017-03-20T21:04:26Z | 2017-03-20T21:20:11Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 00710f47-36de-4d24-015a-79647aba53a3 | SNOMED-CT | 225362009 | Dental care (regime/therapy) | 431.40 | 103697008 | Patient referral for dental care (procedure) | procedures.csv | loaded |
| 2017-03-20T21:20:11Z | 2017-03-20T22:00:05Z | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 00710f47-36de-4d24-015a-79647aba53a3 | SNOMED-CT | 1260009003 | Removal of supragingival plaque and calculus from all teeth using dental instrument (procedure) | 431.40 | 103697008 | Patient referral for dental care (procedure) | procedures.csv | loaded |

### `bronze.organizations` sample

| source_organization_id | organization_name | city | state_code | zip | lat | lon | revenue | utilization | source_file | load_status |
|---|---|---|---|---|---:|---:|---:|---:|---|---|
| 004554b4-3068-3938-832d-fa7cbe1cd1fb | DWYER HOME | WEYMOUTH | MA | 021903951 | 42.1589443 | -70.94970431672323 | 0.0 | 20 | organizations.csv | loaded |
| 009f87f0-4bb6-350c-ba41-0b3235a7ca43 | STONE INSTITUTE AND NEWTON HOME FOR AGED PEOPLE | NEWTON UPPER FALLS | MA | 024641201 | 42.3134306 | -71.2206105 | 0.0 | 1 | organizations.csv | loaded |
| 00ffb204-07b4-3c72-a678-fa252e6cf86c | BEDFORD-LEXINGTON INTERNAL MEDICINE PC | LEXINGTON | MA | 02420 | 42.47370735 | -71.25090005 | 0.0 | 358 | organizations.csv | loaded |

### `bronze.providers` sample

| source_provider_id | source_organization_id | gender | speciality | city | state_code | zip | lat | lon | encounter_count | procedure_count | source_file | load_status |
|---|---|---|---|---|---|---|---:|---:|---:|---:|---|---|
| 000f1e7a-7209-384d-9780-36dfbc4082d1 | 37111f41-8bc5-35d3-9cd9-5b447a11ffd1 | M | GENERAL PRACTICE | METHUEN | MA | 018443712 | 42.7262016 | -71.1908924 | 56 | 0 | providers.csv | loaded |
| 004bf0f2-f64b-3a48-aa75-9949cc7a6cbb | dd9914b0-9491-3330-a890-d34e95e497ea | M | GENERAL PRACTICE | NEW BEDFORD | MA | 027406728 | 41.64280275 | -70.92865004309593 | 100 | 0 | providers.csv | loaded |
| 0152d0cf-c741-3f05-a3c6-29d95c985ef8 | a43fd704-ddbc-3f63-b3a0-e97c5d42ab5e | M | GENERAL PRACTICE | WHITINSVILLE | MA | 015881016 | 42.1216837 | -71.6715608 | 3 | 0 | providers.csv | loaded |

## Transformation-Relevant Notes for Sprint 4

### Global bronze-to-silver rules

- Bronze source business columns are mostly `nvarchar`; silver should convert dates, timestamps, decimals, integers, and booleans into proper SQL Server types.
- Preserve lineage fields from bronze to silver:
  - `ingestion_batch_id`
  - `ingestion_datetime`
  - `source_file`
  - `row_hash`
  - optionally `load_status`
- `row_hash` is `varbinary(32)` in bronze. If copied into silver, use `VARBINARY(32)` unless intentionally converting it to hex text.
- Timestamp strings such as `2017-03-20T20:28:05Z` should be treated as UTC-style source timestamps. In SQL Server, parse consistently, for example with `datetimeoffset` or by removing the trailing `Z` before converting to `datetime2`.
- Date-only strings such as `birthdate`, `deathdate`, `condition_start_date`, and `condition_stop_date` should convert to `date`.

### `silver.patient` mapping notes

| Bronze column | Silver target concept |
|---|---|
| `source_patient_id` | `patient_id` |
| `birthdate` | `birth_date` |
| `deathdate` | `death_date` |
| `marital` | `marital_status` |
| `race` | `race` |
| `ethnicity` | `ethnicity` |
| `gender` | `gender` |
| `city` | `city` |
| `state` | `state` |
| `county` | `county` |
| `fips` | `fips` |
| `zip` | `zip` |
| `lat` | `latitude` |
| `lon` | `longitude` |
| `healthcare_expenses` | `healthcare_expenses` |
| `healthcare_coverage` | `healthcare_coverage` |
| `income` | `income` |
| `ingestion_batch_id`, `ingestion_datetime`, `source_file`, `row_hash` | bronze lineage fields |

Do not assume `bronze.patients` has `patient_id`, `birth_date`, `death_date`, `marital_status`, `latitude`, or `longitude`; those are silver-friendly names that should be produced during transformation.

### `silver.encounter` mapping notes

| Bronze column | Silver target concept |
|---|---|
| `source_encounter_id` | `encounter_id` |
| `encounter_start_datetime` | `encounter_start_datetime` |
| `encounter_stop_datetime` | `encounter_stop_datetime` |
| `source_patient_id` | `patient_id` / patient reference |
| `source_organization_id` | organization reference |
| `source_provider_id` | provider reference |
| `source_payer_id` | payer reference, retained as source reference if no payer table exists |
| `encounter_class` | encounter class |
| `encounter_code` | encounter code |
| `encounter_description` | encounter description |
| `base_encounter_cost`, `total_claim_cost`, `payer_coverage` | decimal cost fields |
| `reason_code`, `reason_description` | reason fields |

Length-of-stay logic should be derived from typed start/stop datetimes and should flag missing stop times or stop-before-start records.

### `silver.condition` mapping notes

| Bronze column | Silver target concept |
|---|---|
| `condition_start_date` | `condition_start_date` |
| `condition_stop_date` | `condition_stop_date` |
| `source_patient_id` | patient reference |
| `source_encounter_id` | encounter reference |
| `condition_system` | coding system |
| `condition_code` | condition code |
| `condition_description` | condition description |

Condition dates are date-only strings, not full datetimes.

### `silver.observation` mapping notes

| Bronze column | Silver target concept |
|---|---|
| `observation_datetime` | observation timestamp |
| `source_patient_id` | patient reference |
| `source_encounter_id` | encounter reference |
| `observation_category` | observation category |
| `observation_code` | observation code |
| `observation_description` | observation description |
| `observation_value` | raw value and/or parsed numeric value |
| `observation_units` | units |
| `observation_type` | source value type |

Sample observations show `source_encounter_id` and `observation_category` can be NULL. Referential integrity checks should distinguish observations missing patients from observations legitimately lacking encounter links.

### `silver.procedure` mapping notes

| Bronze column | Silver target concept |
|---|---|
| `procedure_start_datetime` | procedure start timestamp |
| `procedure_stop_datetime` | procedure stop timestamp |
| `source_patient_id` | patient reference |
| `source_encounter_id` | encounter reference |
| `procedure_system` | coding system |
| `procedure_code` | procedure code |
| `procedure_description` | procedure description |
| `base_procedure_cost` | decimal cost field |
| `reason_code`, `reason_description` | reason fields |

### `silver.organization` mapping notes

| Bronze column | Silver target concept |
|---|---|
| `source_organization_id` | organization ID |
| `organization_name` | organization name |
| `street_address` | address |
| `city` | city |
| `state_code` | state |
| `zip` | postal code |
| `lat`, `lon` | decimal coordinates |
| `phone` | phone |
| `revenue` | decimal revenue |
| `utilization` | numeric utilization |

Organizations use `state_code`, while patients use `state`.

### `silver.provider` mapping notes

| Bronze column | Silver target concept |
|---|---|
| `source_provider_id` | provider ID |
| `source_organization_id` | organization reference |
| `provider_name` | provider name |
| `gender` | gender |
| `speciality` | specialty |
| `street_address`, `city`, `state_code`, `zip` | address/location fields |
| `lat`, `lon` | decimal coordinates |
| `encounter_count`, `procedure_count` | integer counts |

The bronze column is spelled `speciality`; standardize to `specialty` in silver only if explicitly documented.

## Known Modeling Cautions

- Do not build Power BI directly on bronze tables.
- Do not assume all observation records are encounter-linked.
- Do not assume every `nvarchar` numeric-looking field is valid; silver transformations should use `TRY_CONVERT`.
- Do not enforce patient direct identifiers into analytics-facing outputs.
- Do not treat synthetic data as real patient data.
- Keep bronze as source-preserving as practical; perform business-friendly naming and typing in silver.
- Keep lineage columns through silver so gold, KPI validation, Power BI, and FHIR-style outputs can be traced back to source files and ingestion batches.

---

## Sprint 4 Update: Silver and Governance Inventory

This section records the database state after Sprint 4 silver-layer and validation work. Silver tables now contain standardized, typed, lineage-preserving entities for patient, encounter, condition, procedure, and observation. Governance objects now define quality-rule metadata, expose current quality-check results, and persist quality-check run history.

### Current Row Counts

| Object | Row Count |
|---|---:|
| `silver.patient` | 1,145 |
| `silver.encounter` | 71,663 |
| `silver.condition` | 43,758 |
| `silver.procedure` | 196,207 |
| `silver.observation` | 945,531 |
| `governance.quality_rule` | 21 |
| `governance.quality_check_result` | 20 |
| `governance.vw_quality_check_current` | 20 |

### Silver Layer Design Notes

- Silver tables use business-friendly singular table names: `silver.patient`, `silver.encounter`, `silver.condition`, `silver.procedure`, and `silver.observation`.
- Silver fields convert bronze `nvarchar` values into typed SQL Server values where appropriate, including `date`, `datetime2`, `decimal`, `int`, `bigint`, and `bit`.
- Silver entities retain bronze lineage fields: `bronze_ingestion_batch_id`, `bronze_ingestion_datetime`, `bronze_source_file`, `bronze_row_hash`, and `bronze_load_status`.
- `bronze_row_hash` remains `varbinary(32)` in silver, matching the bronze source lineage hash.
- Quality status columns are included in silver tables to make validity and completeness issues visible without destroying source traceability.

## Silver Column Inventory

### `silver.patient`

| Ordinal | Column | Data Type | Nullable | Notes |
|---:|---|---|---|---|
| 1 | `patient_id` | `nvarchar(100)` | NO | Standardized from `bronze.patients.source_patient_id`. |
| 2 | `birth_date` | `date` | YES | Typed from bronze `birthdate`. |
| 3 | `death_date` | `date` | YES | Typed from bronze `deathdate`. |
| 4 | `is_deceased` | `bit` | NO | Derived from `death_date`. |
| 5 | `age_reference_date` | `date` | NO | Death date for deceased patients; silver load date otherwise. |
| 6 | `age_reference_type` | `nvarchar(30)` | NO | Indicates whether age uses `death_date` or `silver_load_date`. |
| 7 | `age_years` | `int` | YES | Derived age calculation. |
| 8 | `age_band` | `nvarchar(20)` | YES | Derived reporting band. |
| 9 | `gender` | `nvarchar(50)` | YES | Standardized demographic field. |
| 10 | `race` | `nvarchar(100)` | YES | Standardized demographic field. |
| 11 | `ethnicity` | `nvarchar(100)` | YES | Standardized demographic field. |
| 12 | `marital_status` | `nvarchar(50)` | YES | Standardized from bronze `marital`. |
| 13 | `city` | `nvarchar(100)` | YES | Geographic field. |
| 14 | `state` | `nvarchar(100)` | YES | Geographic field. |
| 15 | `county` | `nvarchar(100)` | YES | Geographic field. |
| 16 | `fips` | `nvarchar(50)` | YES | Geographic code. |
| 17 | `zip` | `nvarchar(20)` | YES | Postal code. |
| 18 | `latitude` | `decimal(18,12)` | YES | Typed from bronze `lat`. |
| 19 | `longitude` | `decimal(18,12)` | YES | Typed from bronze `lon`. |
| 20 | `healthcare_expenses` | `decimal(18,2)` | YES | Typed financial field. |
| 21 | `healthcare_coverage` | `decimal(18,2)` | YES | Typed financial field. |
| 22 | `income` | `int` | YES | Typed income field. |
| 23 | `patient_date_quality_status` | `nvarchar(50)` | NO | Date-quality status, e.g. `valid`. |
| 24 | `source_system` | `nvarchar(100)` | NO | Source system label. |
| 25 | `source_entity` | `nvarchar(100)` | NO | Source entity/file label. |
| 26 | `bronze_ingestion_batch_id` | `bigint` | YES | Lineage to bronze ingestion batch. |
| 27 | `bronze_ingestion_datetime` | `datetime2` | YES | Lineage to bronze ingestion timestamp. |
| 28 | `bronze_source_file` | `nvarchar(255)` | YES | Lineage to source CSV file. |
| 29 | `bronze_row_hash` | `varbinary(32)` | YES | Lineage hash copied from bronze. |
| 30 | `bronze_load_status` | `nvarchar(30)` | YES | Bronze load status. |
| 31 | `silver_load_datetime` | `datetime2` | NO | Silver transform timestamp. |

### `silver.encounter`

| Ordinal | Column | Data Type | Nullable | Notes |
|---:|---|---|---|---|
| 1 | `encounter_id` | `nvarchar(100)` | NO | Standardized from `bronze.encounters.source_encounter_id`. |
| 2 | `patient_id` | `nvarchar(100)` | YES | Patient reference. |
| 3 | `organization_id` | `nvarchar(100)` | YES | Organization reference. |
| 4 | `provider_id` | `nvarchar(100)` | YES | Provider reference. |
| 5 | `payer_id` | `nvarchar(100)` | YES | Payer reference retained from source. |
| 6 | `encounter_start_datetime_utc` | `datetime2` | YES | Parsed UTC encounter start. |
| 7 | `encounter_stop_datetime_utc` | `datetime2` | YES | Parsed UTC encounter stop. |
| 8 | `encounter_start_date` | `date` | YES | Derived from start timestamp. |
| 9 | `encounter_stop_date` | `date` | YES | Derived from stop timestamp. |
| 10 | `encounter_duration_minutes` | `bigint` | YES | Derived duration in minutes. |
| 11 | `encounter_duration_hours` | `decimal(18,2)` | YES | Derived duration in hours. |
| 12 | `length_of_stay_days` | `decimal(18,4)` | YES | Derived length of stay in days. |
| 13 | `encounter_class` | `nvarchar(100)` | YES | Standardized to lower-case grouping value. |
| 14 | `encounter_code` | `nvarchar(100)` | YES | Encounter code. |
| 15 | `encounter_description` | `nvarchar(255)` | YES | Encounter description. |
| 16 | `base_encounter_cost` | `decimal(18,2)` | YES | Typed cost field. |
| 17 | `total_claim_cost` | `decimal(18,2)` | YES | Typed cost field. |
| 18 | `payer_coverage` | `decimal(18,2)` | YES | Typed coverage field. |
| 19 | `reason_code` | `nvarchar(100)` | YES | Reason code. |
| 20 | `reason_description` | `nvarchar(255)` | YES | Reason description. |
| 21 | `is_missing_start_datetime` | `bit` | NO | Quality flag. |
| 22 | `is_missing_stop_datetime` | `bit` | NO | Quality flag. |
| 23 | `is_invalid_start_datetime` | `bit` | NO | Quality flag. |
| 24 | `is_invalid_stop_datetime` | `bit` | NO | Quality flag. |
| 25 | `is_stop_before_start` | `bit` | NO | Quality flag. |
| 26 | `encounter_datetime_quality_status` | `nvarchar(50)` | NO | Date-quality status. |
| 27 | `source_system` | `nvarchar(100)` | NO | Source system label. |
| 28 | `source_entity` | `nvarchar(100)` | NO | Source entity/file label. |
| 29 | `bronze_ingestion_batch_id` | `bigint` | YES | Lineage to bronze ingestion batch. |
| 30 | `bronze_ingestion_datetime` | `datetime2` | YES | Lineage to bronze ingestion timestamp. |
| 31 | `bronze_source_file` | `nvarchar(255)` | YES | Lineage to source CSV file. |
| 32 | `bronze_row_hash` | `varbinary(32)` | YES | Lineage hash copied from bronze. |
| 33 | `bronze_load_status` | `nvarchar(30)` | YES | Bronze load status. |
| 34 | `silver_load_datetime` | `datetime2` | NO | Silver transform timestamp. |

### `silver.condition`

| Ordinal | Column | Data Type | Nullable | Notes |
|---:|---|---|---|---|
| 1 | `condition_record_id` | `bigint` | NO | Surrogate silver record key. |
| 2 | `patient_id` | `nvarchar(100)` | YES | Patient reference. |
| 3 | `encounter_id` | `nvarchar(100)` | YES | Encounter reference. |
| 4 | `condition_start_date` | `date` | YES | Typed condition start date. |
| 5 | `condition_stop_date` | `date` | YES | Typed condition stop date. |
| 6 | `condition_duration_days` | `int` | YES | Derived duration for closed conditions. |
| 7 | `condition_system` | `nvarchar(255)` | YES | Coding system, e.g. SNOMED-CT. |
| 8 | `condition_code` | `nvarchar(100)` | YES | Condition code. |
| 9 | `condition_description` | `nvarchar(255)` | YES | Condition description. |
| 10 | `condition_category` | `nvarchar(100)` | YES | Derived category from description. |
| 11 | `condition_status` | `nvarchar(30)` | NO | `active_or_open` or `resolved_or_closed`. |
| 12 | `is_missing_start_date` | `bit` | NO | Quality flag. |
| 13 | `is_invalid_start_date` | `bit` | NO | Quality flag. |
| 14 | `is_invalid_stop_date` | `bit` | NO | Quality flag. |
| 15 | `is_stop_before_start` | `bit` | NO | Quality flag. |
| 16 | `condition_date_quality_status` | `nvarchar(50)` | NO | Date-quality status. |
| 17 | `source_system` | `nvarchar(100)` | NO | Source system label. |
| 18 | `source_entity` | `nvarchar(100)` | NO | Source entity/file label. |
| 19 | `bronze_ingestion_batch_id` | `bigint` | YES | Lineage to bronze ingestion batch. |
| 20 | `bronze_ingestion_datetime` | `datetime2` | YES | Lineage to bronze ingestion timestamp. |
| 21 | `bronze_source_file` | `nvarchar(255)` | YES | Lineage to source CSV file. |
| 22 | `bronze_row_hash` | `varbinary(32)` | YES | Lineage hash copied from bronze. |
| 23 | `bronze_load_status` | `nvarchar(30)` | YES | Bronze load status. |
| 24 | `silver_load_datetime` | `datetime2` | NO | Silver transform timestamp. |

### `silver.procedure`

| Ordinal | Column | Data Type | Nullable | Notes |
|---:|---|---|---|---|
| 1 | `procedure_record_id` | `bigint` | NO | Surrogate silver record key. |
| 2 | `patient_id` | `nvarchar(100)` | YES | Patient reference. |
| 3 | `encounter_id` | `nvarchar(100)` | YES | Encounter reference. |
| 4 | `procedure_start_datetime_utc` | `datetime2` | YES | Parsed UTC procedure start. |
| 5 | `procedure_stop_datetime_utc` | `datetime2` | YES | Parsed UTC procedure stop. |
| 6 | `procedure_start_date` | `date` | YES | Derived start date. |
| 7 | `procedure_stop_date` | `date` | YES | Derived stop date. |
| 8 | `procedure_duration_minutes` | `bigint` | YES | Derived duration in minutes. |
| 9 | `procedure_duration_hours` | `decimal(18,2)` | YES | Derived duration in hours. |
| 10 | `procedure_system` | `nvarchar(255)` | YES | Coding system, e.g. SNOMED-CT. |
| 11 | `procedure_code` | `nvarchar(100)` | YES | Procedure code. |
| 12 | `procedure_description` | `nvarchar(255)` | YES | Procedure description. |
| 13 | `procedure_category` | `nvarchar(100)` | YES | Derived broad category. |
| 14 | `base_procedure_cost` | `decimal(18,2)` | YES | Typed cost field. |
| 15 | `reason_code` | `nvarchar(100)` | YES | Reason code. |
| 16 | `reason_description` | `nvarchar(255)` | YES | Reason description. |
| 17 | `is_missing_start_datetime` | `bit` | NO | Quality flag. |
| 18 | `is_missing_stop_datetime` | `bit` | NO | Quality flag. |
| 19 | `is_invalid_start_datetime` | `bit` | NO | Quality flag. |
| 20 | `is_invalid_stop_datetime` | `bit` | NO | Quality flag. |
| 21 | `is_stop_before_start` | `bit` | NO | Quality flag. |
| 22 | `procedure_datetime_quality_status` | `nvarchar(50)` | NO | Datetime-quality status. |
| 23 | `source_system` | `nvarchar(100)` | NO | Source system label. |
| 24 | `source_entity` | `nvarchar(100)` | NO | Source entity/file label. |
| 25 | `bronze_ingestion_batch_id` | `bigint` | YES | Lineage to bronze ingestion batch. |
| 26 | `bronze_ingestion_datetime` | `datetime2` | YES | Lineage to bronze ingestion timestamp. |
| 27 | `bronze_source_file` | `nvarchar(255)` | YES | Lineage to source CSV file. |
| 28 | `bronze_row_hash` | `varbinary(32)` | YES | Lineage hash copied from bronze. |
| 29 | `bronze_load_status` | `nvarchar(30)` | YES | Bronze load status. |
| 30 | `silver_load_datetime` | `datetime2` | NO | Silver transform timestamp. |

### `silver.observation`

| Ordinal | Column | Data Type | Nullable | Notes |
|---:|---|---|---|---|
| 1 | `observation_record_id` | `bigint` | NO | Surrogate silver record key. |
| 2 | `patient_id` | `nvarchar(100)` | YES | Patient reference. |
| 3 | `encounter_id` | `nvarchar(100)` | YES | Encounter reference; may be NULL for patient-level observations. |
| 4 | `observation_datetime_utc` | `datetime2` | YES | Parsed UTC observation timestamp. |
| 5 | `observation_date` | `date` | YES | Derived observation date. |
| 6 | `observation_category` | `nvarchar(100)` | YES | Standardized category; null source categories become `uncategorized`. |
| 7 | `observation_code` | `nvarchar(100)` | YES | Observation code. |
| 8 | `observation_description` | `nvarchar(255)` | YES | Observation description. |
| 9 | `observation_value_raw` | `nvarchar(255)` | YES | Raw observation value. |
| 10 | `observation_value_numeric` | `decimal(18,6)` | YES | Numeric parse where possible. |
| 11 | `observation_units` | `nvarchar(100)` | YES | Unit string. |
| 12 | `observation_type` | `nvarchar(100)` | YES | Source value type. |
| 13 | `is_missing_observation_datetime` | `bit` | NO | Quality flag. |
| 14 | `is_invalid_observation_datetime` | `bit` | NO | Quality flag. |
| 15 | `is_missing_patient_id` | `bit` | NO | Quality flag. |
| 16 | `is_missing_observation_code` | `bit` | NO | Quality flag. |
| 17 | `observation_quality_status` | `nvarchar(50)` | NO | Observation quality status. |
| 18 | `source_system` | `nvarchar(100)` | NO | Source system label. |
| 19 | `source_entity` | `nvarchar(100)` | NO | Source entity/file label. |
| 20 | `bronze_ingestion_batch_id` | `bigint` | YES | Lineage to bronze ingestion batch. |
| 21 | `bronze_ingestion_datetime` | `datetime2` | YES | Lineage to bronze ingestion timestamp. |
| 22 | `bronze_source_file` | `nvarchar(255)` | YES | Lineage to source CSV file. |
| 23 | `bronze_row_hash` | `varbinary(32)` | YES | Lineage hash copied from bronze. |
| 24 | `bronze_load_status` | `nvarchar(30)` | YES | Bronze load status. |
| 25 | `silver_load_datetime` | `datetime2` | NO | Silver transform timestamp. |

## Governance Column Inventory

### `governance.quality_rule`

| Ordinal | Column | Data Type | Nullable | Notes |
|---:|---|---|---|---|
| 1 | `quality_rule_id` | `nvarchar(80)` | NO | Stable rule identifier. |
| 2 | `rule_name` | `nvarchar(200)` | NO | Human-readable rule name. |
| 3 | `quality_dimension` | `nvarchar(50)` | NO | Completeness, uniqueness, referential integrity, validity, consistency, freshness, or lineage. |
| 4 | `target_schema` | `nvarchar(128)` | NO | Target schema. |
| 5 | `target_table` | `nvarchar(128)` | NO | Target table or logical table group. |
| 6 | `target_column` | `nvarchar(128)` | YES | Target column when applicable. |
| 7 | `rule_scope` | `nvarchar(50)` | NO | Row, table, cross-table, or pipeline scope. |
| 8 | `severity` | `nvarchar(20)` | NO | Critical, high, medium, or low. |
| 9 | `owner_role` | `nvarchar(100)` | NO | Rule owner role. |
| 10 | `steward_role` | `nvarchar(100)` | NO | Steward role. |
| 11 | `business_description` | `nvarchar(1000)` | NO | Business explanation. |
| 12 | `technical_description` | `nvarchar(2000)` | NO | Technical check explanation. |
| 13 | `expected_outcome` | `nvarchar(1000)` | NO | Expected result. |
| 14 | `is_active` | `bit` | NO | Active-rule flag. |
| 15 | `created_datetime` | `datetime2` | NO | Creation timestamp. |
| 16 | `updated_datetime` | `datetime2` | NO | Last update timestamp. |

### `governance.quality_check_result`

| Ordinal | Column | Data Type | Nullable | Notes |
|---:|---|---|---|---|
| 1 | `quality_check_result_id` | `bigint` | NO | Result row surrogate key. |
| 2 | `quality_check_run_id` | `uniqueidentifier` | NO | Run-level identifier grouping one execution. |
| 3 | `quality_rule_id` | `nvarchar(80)` | NO | Foreign key to `governance.quality_rule`. |
| 4 | `rule_name` | `nvarchar(200)` | NO | Rule name captured at execution time. |
| 5 | `quality_dimension` | `nvarchar(50)` | NO | Quality dimension. |
| 6 | `target_schema` | `nvarchar(128)` | NO | Target schema. |
| 7 | `target_table` | `nvarchar(128)` | NO | Target table or logical group. |
| 8 | `target_column` | `nvarchar(128)` | YES | Target column when applicable. |
| 9 | `rule_scope` | `nvarchar(50)` | NO | Rule scope. |
| 10 | `severity` | `nvarchar(20)` | NO | Rule severity. |
| 11 | `total_records` | `bigint` | NO | Records evaluated. |
| 12 | `failed_records` | `bigint` | NO | Records or checks failing the rule. |
| 13 | `passed_records` | `bigint` | NO | Records passing the rule. |
| 14 | `pass_rate` | `decimal(9,4)` | NO | Pass-rate ratio. |
| 15 | `check_status` | `nvarchar(20)` | NO | `passed` or `failed`. |
| 16 | `checked_datetime` | `datetime2` | NO | Time the view result was produced. |
| 17 | `persisted_datetime` | `datetime2` | NO | Time the result was inserted. |
| 18 | `run_source` | `nvarchar(100)` | NO | Script/source that persisted the run. |

### `governance.vw_quality_check_current`

The current-state quality-check view exposes 20 executable quality checks. It includes rule metadata, target scope, evaluated record counts, failure counts, pass rates, check status, and checked timestamp. It is read by `src/run_quality_checks.py`, and persisted runs are inserted into `governance.quality_check_result`.

## Representative Silver Sample Values

### `silver.patient` sample

| patient_id | birth_date | death_date | is_deceased | age_reference_date | age_reference_type | age_years | age_band | gender | race | ethnicity | marital_status | city | state | county | healthcare_expenses | healthcare_coverage | income | patient_date_quality_status | source_entity | bronze_ingestion_batch_id | bronze_source_file | bronze_load_status |
|---|---|---|---:|---|---|---:|---|---|---|---|---|---|---|---|---:|---:|---:|---|---|---:|---|---|
| 00710f47-36de-4d24-1e15-d9b77f5096b8 | 1966-04-11 | NULL | 0 | 2026-05-31 | silver_load_date | 60 | 50-64 | M | black | nonhispanic | M | Boston | Massachusetts | Suffolk County | 225058.27 | 185971.24 | 27898 | valid | patients.csv | 2 | patients.csv | loaded |
| 00b64473-9de5-cfac-1ece-16fffba92ac8 | 2014-12-08 | NULL | 0 | 2026-05-31 | silver_load_date | 11 | 0-17 | F | hawaiian | nonhispanic | NULL | Boston | Massachusetts | Suffolk County | 28618.96 | 2578.45 | 83517 | valid | patients.csv | 2 | patients.csv | loaded |
| 0103d5dd-3dd6-e4ee-f79d-e84db4035eaf | 1962-03-20 | NULL | 0 | 2026-05-31 | silver_load_date | 64 | 50-64 | M | asian | nonhispanic | M | Somerville | Massachusetts | Middlesex County | 115216.58 | 1042761.41 | 6362 | valid | patients.csv | 2 | patients.csv | loaded |

### `silver.encounter` sample

| encounter_id | patient_id | encounter_start_datetime_utc | encounter_stop_datetime_utc | encounter_duration_minutes | encounter_duration_hours | length_of_stay_days | encounter_class | encounter_code | encounter_description | encounter_datetime_quality_status | source_entity | bronze_ingestion_batch_id |
|---|---|---|---|---:|---:|---:|---|---|---|---|---|---:|
| 00710f47-36de-4d24-015a-79647aba53a3 | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 2017-03-20 20:28:05 | 2017-03-21 00:12:30 | 224 | 3.74 | 0.1558 | ambulatory | 185349003 | Encounter for check up (procedure) | valid | encounters.csv | 2 |
| 00710f47-36de-4d24-14f6-9e776bd43aad | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 2020-04-27 05:28:05 | 2020-04-27 05:43:05 | 15 | 0.25 | 0.0104 | ambulatory | 185345009 | Encounter for symptom (procedure) | valid | encounters.csv | 2 |
| 00710f47-36de-4d24-1b3d-9488710345f5 | 00710f47-36de-4d24-1e15-d9b77f5096b8 | 2020-05-04 05:28:05 | 2020-05-04 05:43:05 | 15 | 0.25 | 0.0104 | ambulatory | 185345009 | Encounter for symptom (procedure) | valid | encounters.csv | 2 |

### `silver.condition` sample

| condition_record_id | patient_id | encounter_id | condition_start_date | condition_stop_date | condition_duration_days | condition_system | condition_code | condition_description | condition_category | condition_status | condition_date_quality_status | source_entity | bronze_ingestion_batch_id |
|---:|---|---|---|---|---:|---|---|---|---|---|---|---|---:|
| 1 | e70dd4d4-66e5-7a84-d346-25f6b1e4de2f | e70dd4d4-66e5-7a84-ff33-c63646037ed5 | 2026-05-18 | NULL | NULL | SNOMED-CT | 314529007 | Medication review due (situation) | situation | active_or_open | valid | conditions.csv | 2 |
| 2 | eb227384-1ba4-0aa4-9d0e-0cc4682d5133 | eb227384-1ba4-0aa4-25a3-942466621b92 | 2016-05-04 | 2018-05-16 | 742 | SNOMED-CT | 314529007 | Medication review due (situation) | situation | resolved_or_closed | valid | conditions.csv | 2 |
| 3 | a94d9782-208d-2a0a-50f8-8a89fc65ef36 | a94d9782-208d-2a0a-61de-9c65601b45e8 | 2024-02-14 | 2024-03-20 | 35 | SNOMED-CT | 314529007 | Medication review due (situation) | situation | resolved_or_closed | valid | conditions.csv | 2 |

### `silver.procedure` sample

| procedure_record_id | patient_id | encounter_id | procedure_start_datetime_utc | procedure_stop_datetime_utc | procedure_duration_minutes | procedure_duration_hours | procedure_system | procedure_code | procedure_description | procedure_category | base_procedure_cost | procedure_datetime_quality_status | source_entity | bronze_ingestion_batch_id |
|---:|---|---|---|---|---:|---:|---|---|---|---|---:|---|---|---:|
| 1 | a94d9782-208d-2a0a-50f8-8a89fc65ef36 | a94d9782-208d-2a0a-07ff-32d3007915e6 | 2024-03-20 09:52:13 | 2024-03-20 10:07:13 | 15 | 0.25 | SNOMED-CT | 430193006 | Medication reconciliation (procedure) | other | 515.68 | valid | procedures.csv | 2 |
| 2 | eb227384-1ba4-0aa4-9d0e-0cc4682d5133 | eb227384-1ba4-0aa4-c0d5-c4661918204b | 2018-05-16 06:19:09 | 2018-05-16 06:34:09 | 15 | 0.25 | SNOMED-CT | 430193006 | Medication reconciliation (procedure) | other | 215.70 | valid | procedures.csv | 2 |
| 3 | a94d9782-208d-2a0a-50f8-8a89fc65ef36 | a94d9782-208d-2a0a-9adf-b5cdf9fe93d6 | 2024-05-22 09:52:13 | 2024-05-22 10:07:13 | 15 | 0.25 | SNOMED-CT | 430193006 | Medication reconciliation (procedure) | other | 761.55 | valid | procedures.csv | 2 |

### `silver.observation` sample

| observation_record_id | patient_id | encounter_id | observation_datetime_utc | observation_date | observation_category | observation_code | observation_description | observation_value_raw | observation_value_numeric | observation_units | observation_type | observation_quality_status | source_entity | bronze_ingestion_batch_id |
|---:|---|---|---|---|---|---|---|---:|---:|---|---|---|---|---:|
| 1 | 32b45c9c-6f3c-80cc-45e1-d93c2dd99161 | 32b45c9c-6f3c-80cc-5db4-a55c0d9b6eca | 2018-01-18 21:56:26 | 2018-01-18 | vital-signs | 74006-8 | Weight difference [Mass difference] --pre dialysis - post dialysis | 4.6 | 4.600000 | kg | numeric | valid | observations.csv | 2 |
| 2 | 32b45c9c-6f3c-80cc-45e1-d93c2dd99161 | 32b45c9c-6f3c-80cc-5db4-a55c0d9b6eca | 2018-01-18 21:56:26 | 2018-01-18 | vital-signs | 72514-3 | Pain severity - 0-10 verbal numeric rating [Score] - Reported | 5.0 | 5.000000 | `{score}` | numeric | valid | observations.csv | 2 |
| 3 | 32b45c9c-6f3c-80cc-45e1-d93c2dd99161 | 32b45c9c-6f3c-80cc-fc8d-d8f45790823c | 2018-01-22 01:38:26 | 2018-01-22 | vital-signs | 74006-8 | Weight difference [Mass difference] --pre dialysis - post dialysis | 1.1 | 1.100000 | kg | numeric | valid | observations.csv | 2 |

## Silver Lineage Coverage Summary

| Silver Table | Total Rows | Missing Batch ID | Missing Ingestion Datetime | Missing Source File | Missing Row Hash | Missing Load Status |
|---|---:|---:|---:|---:|---:|---:|
| `silver.patient` | 1,145 | 0 | 0 | 0 | 0 | 0 |
| `silver.encounter` | 71,663 | 0 | 0 | 0 | 0 | 0 |
| `silver.condition` | 43,758 | 0 | 0 | 0 | 0 | 0 |
| `silver.procedure` | 196,207 | 0 | 0 | 0 | 0 | 0 |
| `silver.observation` | 945,531 | 0 | 0 | 0 | 0 | 0 |

Lineage coverage is complete across all current silver entities. Each silver row preserves the required bronze ingestion metadata and source-record hash.

## Governance Quality Rule Summary

| Quality Dimension | Severity | Rule Count |
|---|---|---:|
| completeness | critical | 2 |
| completeness | high | 1 |
| consistency | medium | 2 |
| freshness | high | 1 |
| lineage | critical | 1 |
| referential_integrity | critical | 4 |
| referential_integrity | medium | 3 |
| uniqueness | critical | 2 |
| uniqueness | medium | 1 |
| validity | high | 4 |

The governance rule catalog currently contains 21 active quality rules. Twenty rules are executable in `governance.vw_quality_check_current`; the lineage rule is documented in metadata and validated separately through lineage coverage checks.

## Latest Persisted Quality Check Run

| quality_check_run_id | persisted_result_rows | passed_checks | failed_checks | persisted_datetime |
|---|---:|---:|---:|---|
| ceeea4ad-e424-4b69-a693-2816f7631768 | 20 | 19 | 1 | 2026-05-31 19:22:37 |

### Latest Run Result Summary

| Quality Rule | Dimension | Target Table | Severity | Total Records | Failed Records | Pass Rate | Status |
|---|---|---|---|---:|---:|---:|---|
| DQ_ENCOUNTER_ID_COMPLETE | completeness | encounter | critical | 71,663 | 0 | 1.0000 | passed |
| DQ_OBSERVATION_REQUIRED_FIELDS_COMPLETE | completeness | observation | high | 945,531 | 0 | 1.0000 | passed |
| DQ_PATIENT_ID_COMPLETE | completeness | patient | critical | 1,145 | 0 | 1.0000 | passed |
| DQ_ENCOUNTER_ID_UNIQUE | uniqueness | encounter | critical | 71,663 | 0 | 1.0000 | passed |
| DQ_OBSERVATION_ROW_UNIQUE | uniqueness | observation | medium | 945,531 | 256 | 0.9997 | failed |
| DQ_PATIENT_ID_UNIQUE | uniqueness | patient | critical | 1,145 | 0 | 1.0000 | passed |
| DQ_CONDITION_ENCOUNTER_REF | referential_integrity | condition | medium | 43,758 | 0 | 1.0000 | passed |
| DQ_CONDITION_PATIENT_REF | referential_integrity | condition | critical | 43,758 | 0 | 1.0000 | passed |
| DQ_ENCOUNTER_PATIENT_REF | referential_integrity | encounter | critical | 71,663 | 0 | 1.0000 | passed |
| DQ_OBSERVATION_ENCOUNTER_REF_WHEN_PRESENT | referential_integrity | observation | medium | 945,531 | 0 | 1.0000 | passed |
| DQ_OBSERVATION_PATIENT_REF | referential_integrity | observation | critical | 945,531 | 0 | 1.0000 | passed |
| DQ_PROCEDURE_ENCOUNTER_REF | referential_integrity | procedure | medium | 196,207 | 0 | 1.0000 | passed |
| DQ_PROCEDURE_PATIENT_REF | referential_integrity | procedure | critical | 196,207 | 0 | 1.0000 | passed |
| DQ_CONDITION_DATES_VALID | validity | condition | high | 43,758 | 0 | 1.0000 | passed |
| DQ_ENCOUNTER_DATES_VALID | validity | encounter | high | 71,663 | 0 | 1.0000 | passed |
| DQ_PATIENT_AGE_VALID | validity | patient | high | 1,145 | 0 | 1.0000 | passed |
| DQ_PROCEDURE_DATES_VALID | validity | procedure | high | 196,207 | 0 | 1.0000 | passed |
| DQ_ENCOUNTER_CLASS_CONSISTENT | consistency | encounter | medium | 71,663 | 0 | 1.0000 | passed |
| DQ_OBSERVATION_CATEGORY_CONSISTENT | consistency | observation | medium | 945,531 | 0 | 1.0000 | passed |
| DQ_SILVER_LOAD_FRESHNESS | freshness | all_current_silver | high | 5 | 0 | 1.0000 | passed |

### Known Data Quality Finding

`DQ_OBSERVATION_ROW_UNIQUE` detected 256 excess duplicate observation records under the current natural-grain definition: patient, encounter, observation datetime, observation code, raw observation value, and units. This is retained as a governed data-quality finding rather than hidden or suppressed. It should be reviewed before gold-layer lab/observation marts rely on observation counts.


## Sprint 5 Update: Gold Layer, Marts, and KPI Reconciliation

Sprint 5 added the governed gold reporting layer used for Power BI-ready operational analytics. The gold layer now includes dimensions, facts, marts/views, KPI validation queries, and KPI reconciliation documentation.

### Sprint 5 Deliverable Files

| File | Purpose |
|---|---|
| `sql/04_create_gold_tables.sql` | Creates gold dimensions and gold fact tables. |
| `sql/06_transform_silver_to_gold.sql` | Populates gold dimensions/facts and creates gold mart views. |
| `sql/08_kpi_validation_queries.sql` | Provides independent SQL reconciliation queries for governed core KPIs. |
| `docs/kpi_dictionary.md` | Defines governed KPI entries and source objects. |
| `docs/kpi_validation_log.md` | Records KPI outputs reconciled to gold marts before Power BI work begins. |

### Gold Object Inventory

| Schema | Object | Type | Grain / Purpose | Current Row Count |
|---|---|---|---|---:|
| `gold` | `dim_patient` | Table | One row per synthetic patient; direct name/address identifiers excluded. | 1,145 |
| `gold` | `dim_date` | Table | One row per calendar date across source date range. | 40,365 |
| `gold` | `dim_organization` | Table | One row per organization identifier currently sourced from encounters. | 727 |
| `gold` | `dim_provider` | Table | One row per provider identifier currently sourced from encounters. | 727 |
| `gold` | `dim_encounter_class` | Table | One row per encounter class with reporting group flags. | 10 |
| `gold` | `dim_condition` | Table | One row per distinct condition definition. | 268 |
| `gold` | `dim_observation` | Table | One row per distinct observation definition. | 296 |
| `gold` | `dim_procedure` | Table | One row per distinct procedure definition. | 363 |
| `gold` | `fact_encounter` | Table | One row per encounter. | 71,663 |
| `gold` | `fact_readmission` | Table | One row per eligible index encounter for 30-day readmission logic. | 71,663 |
| `gold` | `fact_condition` | Table | One row per silver condition record. | 43,758 |
| `gold` | `fact_observation` | Table | One row per silver observation record, including governed duplicate findings. | 945,531 |
| `gold` | `fact_procedure` | Table | One row per silver procedure record. | 196,207 |
| `gold` | `fact_data_quality_issue` | Table | One row per persisted governance quality-check result. | 20 |
| `gold` | `mart_patient_flow` | View | Aggregated patient-flow reporting rows. | 68,981 |
| `gold` | `mart_length_of_stay` | View | Encounter-grain LOS reporting mart. | 71,663 |
| `gold` | `mart_readmissions` | View | Index-encounter-grain readmission reporting mart. | 71,663 |
| `gold` | `mart_lab_operations` | View | Observation/lab activity reporting rows. | 935,704 |
| `gold` | `mart_service_utilization` | View | Procedure/service utilization reporting rows. | 186,119 |
| `gold` | `mart_reporting_trust` | View | Data-quality and governance-readiness reporting rows. | 20 |

The gold marts are implemented as SQL views, so they appear under the database `Views` folder rather than the `Tables` folder.

### Gold Dimension Summary

#### `gold.dim_patient`

Purpose: reporting-safe patient dimension. Direct identifiers such as names, SSN, passport, drivers, street address, and birthplace are excluded.

Key columns:

| Column Group | Columns |
|---|---|
| Key fields | `patient_key`, `patient_id` |
| Demographics | `birth_date`, `death_date`, `is_deceased`, `age_reference_date`, `age_reference_type`, `age_years`, `age_band`, `gender`, `race`, `ethnicity`, `marital_status` |
| Geography | `city`, `state`, `county`, `fips`, `zip`, `latitude`, `longitude` |
| Quality and lineage | `patient_date_quality_status`, `source_system`, `source_entity`, `bronze_ingestion_batch_id`, `bronze_source_file`, `silver_load_datetime`, `gold_load_datetime` |

#### `gold.dim_date`

Purpose: standard reporting calendar dimension used by facts and marts.

Columns: `date_key`, `full_date`, `calendar_year`, `calendar_quarter`, `calendar_month`, `calendar_month_name`, `day_of_month`, `day_of_week`, `day_name`, `week_of_year`, `is_weekend`.

#### `gold.dim_organization`

Purpose: lightweight organization reference dimension sourced from distinct `silver.encounter.organization_id` values until richer organization/provider silver dimensions are implemented.

Columns: `organization_key`, `organization_id`, `organization_name`, `organization_source_status`, `gold_load_datetime`.

#### `gold.dim_provider`

Purpose: lightweight provider reference dimension sourced from distinct `silver.encounter.provider_id` values until richer provider silver dimensions are implemented.

Columns: `provider_key`, `provider_id`, `provider_name`, `provider_source_status`, `gold_load_datetime`.

#### `gold.dim_encounter_class`

Purpose: standardized encounter-class slicer dimension.

Columns: `encounter_class_key`, `encounter_class`, `encounter_class_display`, `encounter_class_group`, `is_inpatient`, `is_emergency`, `is_ambulatory`, `gold_load_datetime`.

#### `gold.dim_condition`

Purpose: condition definition dimension for case-mix reporting.

Columns: `condition_key`, `condition_natural_key`, `condition_system`, `condition_code`, `condition_description`, `condition_category`, `gold_load_datetime`.

#### `gold.dim_observation`

Purpose: observation definition dimension for lab/observation reporting.

Columns: `observation_key`, `observation_natural_key`, `observation_category`, `observation_code`, `observation_description`, `observation_units`, `observation_type`, `gold_load_datetime`.

#### `gold.dim_procedure`

Purpose: procedure definition dimension for service utilization reporting.

Columns: `procedure_key`, `procedure_natural_key`, `procedure_system`, `procedure_code`, `procedure_description`, `procedure_category`, `gold_load_datetime`.

### Gold Fact Summary

#### `gold.fact_encounter`

Purpose: encounter-grain fact supporting encounter volume, LOS, patient-flow, and encounter-class reporting.

| Column Group | Columns |
|---|---|
| Fact key and natural key | `encounter_fact_key`, `encounter_id` |
| Dimension keys | `patient_key`, `encounter_start_date_key`, `encounter_stop_date_key`, `organization_key`, `provider_key`, `encounter_class_key` |
| Source references | `patient_id`, `organization_id`, `provider_id`, `payer_id` |
| Timing and LOS | `encounter_start_datetime_utc`, `encounter_stop_datetime_utc`, `encounter_duration_minutes`, `encounter_duration_hours`, `length_of_stay_days` |
| Encounter descriptors | `encounter_class`, `encounter_code`, `encounter_description`, `reason_code`, `reason_description` |
| Cost fields | `base_encounter_cost`, `total_claim_cost`, `payer_coverage` |
| Measures | `encounter_count`, `valid_encounter_count` |
| Quality flags | `is_missing_start_datetime`, `is_missing_stop_datetime`, `is_invalid_start_datetime`, `is_invalid_stop_datetime`, `is_stop_before_start`, `encounter_datetime_quality_status` |
| Lineage | `source_system`, `source_entity`, `bronze_ingestion_batch_id`, `bronze_source_file`, `silver_load_datetime`, `gold_load_datetime` |

#### `gold.fact_readmission`

Purpose: index-encounter-grain fact supporting 30-day readmission rate logic.

| Column Group | Columns |
|---|---|
| Fact key | `readmission_fact_key` |
| Index encounter | `index_encounter_fact_key`, `index_encounter_id`, `index_encounter_start_datetime_utc`, `index_encounter_stop_datetime_utc`, `index_start_date_key`, `index_stop_date_key`, `index_organization_key`, `index_provider_key`, `index_encounter_class_key` |
| Patient reference | `patient_key`, `patient_id` |
| Readmission encounter | `readmission_encounter_fact_key`, `readmission_encounter_id`, `readmission_start_datetime_utc`, `readmission_start_date_key` |
| Interval fields | `days_to_readmission`, `hours_to_readmission`, `readmission_window_days` |
| Measures and flags | `eligible_encounter_count`, `readmission_30_day_count`, `is_30_day_readmission`, `readmission_logic_status` |
| Lineage | `gold_load_datetime` |

Current readmission logic identifies the next encounter for the same patient after the index encounter stop time and flags it when it starts within 30 days. It does not distinguish planned versus unplanned readmissions.

#### `gold.fact_condition`

Purpose: condition-record-grain fact for case-mix reporting and condition context.

Key columns: `condition_fact_key`, `condition_record_id`, `patient_key`, `encounter_fact_key`, `condition_key`, `condition_start_date_key`, `condition_stop_date_key`, `patient_id`, `encounter_id`, `condition_start_date`, `condition_stop_date`, `condition_duration_days`, `condition_system`, `condition_code`, `condition_description`, `condition_category`, `condition_status`, `condition_count`, `active_condition_count`, `resolved_condition_count`, `condition_date_quality_status`, lineage/load metadata.

#### `gold.fact_observation`

Purpose: observation-record-grain fact for lab/observation operations reporting.

Key columns: `observation_fact_key`, `observation_record_id`, `patient_key`, `encounter_fact_key`, `observation_key`, `observation_date_key`, `organization_key`, `provider_key`, `encounter_class_key`, `patient_id`, `encounter_id`, `observation_datetime_utc`, `observation_date`, `observation_category`, `observation_code`, `observation_description`, `observation_value_raw`, `observation_value_numeric`, `observation_units`, `observation_type`, `observation_count`, `numeric_observation_count`, `encounter_linked_observation_count`, `patient_level_observation_count`, `observation_quality_status`, lineage/load metadata.

Observation facts preserve governed duplicate records already identified by `DQ_OBSERVATION_ROW_UNIQUE`; they are not silently suppressed.

#### `gold.fact_procedure`

Purpose: procedure-record-grain fact for procedure volume and service utilization reporting.

Key columns: `procedure_fact_key`, `procedure_record_id`, `patient_key`, `encounter_fact_key`, `procedure_key`, `procedure_start_date_key`, `procedure_stop_date_key`, `organization_key`, `provider_key`, `encounter_class_key`, `patient_id`, `encounter_id`, `procedure_start_datetime_utc`, `procedure_stop_datetime_utc`, `procedure_duration_minutes`, `procedure_duration_hours`, `procedure_system`, `procedure_code`, `procedure_description`, `procedure_category`, `base_procedure_cost`, `reason_code`, `reason_description`, `procedure_count`, `valid_procedure_count`, `procedure_datetime_quality_status`, lineage/load metadata.

#### `gold.fact_data_quality_issue`

Purpose: data-quality-result-grain fact for reporting trust and governance dashboards.

Key columns: `data_quality_issue_fact_key`, `quality_check_result_id`, `quality_check_run_id`, `quality_rule_id`, `rule_name`, `quality_dimension`, `target_schema`, `target_table`, `target_column`, `target_object_name`, `rule_scope`, `severity`, `owner_role`, `steward_role`, `total_records`, `passed_records`, `failed_records`, `pass_rate`, `check_status`, `quality_check_count`, `passed_check_count`, `failed_check_count`, `issue_count`, `has_quality_issue`, `critical_issue_count`, `high_issue_count`, `medium_issue_count`, `low_issue_count`, `checked_datetime`, `persisted_datetime`, `run_source`, `is_latest_run`, `source_system`, `source_entity`, `gold_load_datetime`.

### Gold Mart / View Summary

#### `gold.mart_patient_flow`

Purpose: aggregated patient-flow reporting by encounter start date, organization, provider, encounter class, patient demographic grouping, and encounter quality status.

Core measures: `total_encounters`, `valid_encounters`, `unique_patients_in_group`, `encounters_with_los`, `encounters_without_los`, `average_los_days`, `total_los_days`, `total_encounter_duration_minutes`, `same_day_encounters`, `multi_day_encounters`, quality indicator counts.

Caution: `unique_patients_in_group` is distinct within the mart row grain and should not be summed across rows.

#### `gold.mart_length_of_stay`

Purpose: encounter-grain LOS mart used for average and median LOS calculations.

Core measures and fields: `encounter_fact_key`, `patient_key`, date keys, organization/provider/class keys, patient demographic grouping, condition/procedure summary counts, `length_of_stay_days`, `total_encounters`, `valid_encounters`, `los_eligible_encounter_count`, `los_days_numerator`, `same_day_encounter_count`, `multi_day_encounter_count`, `long_stay_encounter_count`, `los_bucket`, quality flags.

#### `gold.mart_readmissions`

Purpose: index-encounter-grain readmission mart used for 30-day readmission rate.

Core measures and fields: `readmission_fact_key`, `index_encounter_fact_key`, `patient_key`, index encounter date keys, organization/provider/class keys, demographic grouping, condition summary fields, readmission encounter fields, `days_to_readmission`, `hours_to_readmission`, `readmission_rate_denominator`, `readmission_rate_numerator`, `is_30_day_readmission`, `no_subsequent_encounter_count`, `subsequent_encounter_after_30_days_count`, `readmission_logic_status`.

#### `gold.mart_lab_operations`

Purpose: observation/lab activity mart for dashboarding observation volume, numeric observation volume, encounter-linked observations, patient-level observations, and observation quality indicators.

Core measures: `observation_volume`, `numeric_observation_count`, `encounter_linked_observation_count`, `patient_level_observation_count`, `unique_patients_in_group`, `unique_encounters_in_group`, `average_numeric_observation_value`, `minimum_numeric_observation_value`, `maximum_numeric_observation_value`, observation quality counts.

Caution: Current lab operations scope includes all Synthea observation records. Synthea observations include both lab-like and vital-sign-like records, so stricter lab-only grouping may be refined later.

#### `gold.mart_service_utilization`

Purpose: procedure/service utilization mart for dashboarding procedure volume, procedure duration, procedure cost, and procedure quality indicators.

Core measures: `procedure_volume`, `valid_procedure_count`, `unique_patients_in_group`, `unique_encounters_in_group`, `total_procedure_duration_minutes`, `total_procedure_duration_hours`, `average_procedure_duration_hours`, `total_base_procedure_cost`, `average_base_procedure_cost`, procedure quality counts.

#### `gold.mart_reporting_trust`

Purpose: data quality and governance readiness mart for reporting pass/fail status, issue severity, and reporting trust score.

Core measures and fields: `quality_check_count`, `passed_check_count`, `failed_check_count`, `total_records_evaluated`, `passed_records`, `failed_records`, `issue_count`, `quality_issue_rule_count`, severity issue counts, `check_pass_rate`, `record_pass_rate`, `reporting_trust_score`, `reporting_readiness_status`, `is_reporting_ready`, `has_failed_checks`, `has_record_level_issues`, `distinct_quality_rule_count`.

### Sprint 5 Validation Summary

| User Story | Deliverable Area | Validation Result |
|---|---|---|
| AB#1504 | Gold dimensions | 30 checks passed, 0 failed |
| AB#1508 | Encounter and readmission facts | 26 checks passed, 0 failed |
| AB#1512 | Condition, observation, and procedure facts | 48 checks passed, 0 failed |
| AB#1516 | Data quality issue fact | 20 checks passed, 0 failed |
| AB#1521 | Patient flow mart | 22 checks passed, 0 failed |
| AB#1525 | LOS and readmission marts | 32 checks passed, 0 failed |
| AB#1529 | Lab operations and service utilization marts | 33 checks passed, 0 failed |
| AB#1533 | Reporting trust mart | 23 checks passed, 0 failed |
| AB#1554 | KPI dictionary entries | 202 checks passed, 0 failed |
| AB#1557 | SQL KPI validation queries | 42 file-level checks passed, 0 failed; SQL KPI validation returned 10 passed, 0 failed, 1 expected not-implemented API coverage item |
| AB#1561 | KPI validation log | Documents reconciled KPI outputs to gold marts |

### Reconciled KPI Outputs

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

API Resource Coverage is expected to remain `not_implemented` until the API/FHIR views are built. This is not a failure of the current gold layer.

### Portfolio-Safety Notes for Gold

- Gold dimensions and marts are reporting-facing assets and should avoid direct patient identifiers.
- `gold.dim_patient` excludes names, SSN, passport, drivers, street address, and birthplace.
- Aggregated marts exclude direct patient/source identifier columns such as `patient_id`, `encounter_id`, `observation_record_id`, `procedure_record_id`, and direct name/address identifiers.
- Some gold fact tables retain source IDs such as `patient_id` and `encounter_id` for lineage, reconciliation, and fact-to-fact joining. These are technical/reporting-layer keys and should not be exposed casually in public screenshots.
- ClinicalPulse uses synthetic Synthea data and does not represent real patients, real hospital performance, or clinical decision-support evidence.

### Pending Database Objects

The following API/FHIR objects are defined in KPI documentation but are not yet implemented:

| Planned Object | Current Status |
|---|---|
| `api.vw_fhir_patient` | Not implemented |
| `api.vw_fhir_encounter` | Not implemented |
| `api.vw_fhir_observation` | Not implemented |
| `api.vw_fhir_condition` | Not implemented |

These planned objects support the later FHIR/API demonstration scope and should not be counted as missing gold-layer assets.
