# Database Schema Inventory

This document records the current SQL Server table structures and representative sample values for the ClinicalPulse bronze and audit schemas. It is intended to support reliable bronze-to-silver transformation work, data quality rule design, lineage documentation, and future assistant/project-source context.

ClinicalPulse uses synthetic Synthea data. The sample values below are not real patient data and should not be described as clinical evidence or production hospital records.

## Portfolio-Safety Note

The current `bronze.patients` table contains direct-identifier-style Synthea fields such as `ssn`, `drivers`, `passport`, `first_name`, `middle_name`, `last_name`, `maiden`, `birthplace`, and `street_address`.

Those fields are documented in the schema inventory because they exist in bronze, but patient sample rows below intentionally exclude or redact them. They should generally not be carried into silver/gold reporting tables unless there is a specific documented reason.

## Current Scope

The current database inventory covers:

| Schema | Table |
|---|---|
| `audit` | `ingestion_batch` |
| `audit` | `ingestion_file_log` |
| `bronze` | `patients` |
| `bronze` | `encounters` |
| `bronze` | `conditions` |
| `bronze` | `observations` |
| `bronze` | `procedures` |
| `bronze` | `organizations` |
| `bronze` | `providers` |

The current bronze model is source-preserving. Most source business fields are stored as `nvarchar` in bronze and should be typed, standardized, and validated in silver.

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
