/*
ClinicalPulse bronze-to-silver lineage contract

Every silver table produced by this script must preserve enough metadata
to trace each silver record back to its bronze source record.

Required silver lineage fields:
    source_system
    source_entity
    bronze_ingestion_batch_id
    bronze_ingestion_datetime
    bronze_source_file
    bronze_row_hash
    bronze_load_status
    silver_load_datetime

Primary trace pattern:
    silver.bronze_ingestion_batch_id = bronze.ingestion_batch_id
    silver.bronze_source_file = bronze.source_file
    silver.bronze_row_hash = bronze.row_hash

Where natural source identifiers exist, they are also standardized:
    bronze.patients.source_patient_id -> silver.patient.patient_id
    bronze.encounters.source_encounter_id -> silver.encounter.encounter_id
    bronze source_patient_id -> patient_id references
    bronze source_encounter_id -> encounter_id references

Notes:
    - row_hash is VARBINARY(32), matching bronze.
    - load_status is retained for traceability but is not a business-quality status.
    - silver_load_datetime records when the silver transform was run.
*/

USE ClinicalPulse;
GO

DECLARE @silver_load_datetime DATETIME2 = SYSUTCDATETIME();
DECLARE @current_date DATE = CAST(@silver_load_datetime AS DATE);

TRUNCATE TABLE silver.patient;

WITH typed_patient AS (
    SELECT
        NULLIF(TRIM(source_patient_id), '') AS patient_id,

        TRY_CONVERT(DATE, NULLIF(TRIM(birthdate), ''), 23) AS birth_date,
        TRY_CONVERT(DATE, NULLIF(TRIM(deathdate), ''), 23) AS death_date,

        UPPER(NULLIF(TRIM(gender), '')) AS gender,
        LOWER(NULLIF(TRIM(race), '')) AS race,
        LOWER(NULLIF(TRIM(ethnicity), '')) AS ethnicity,
        NULLIF(TRIM(marital), '') AS marital_status,

        NULLIF(TRIM(city), '') AS city,
        NULLIF(TRIM(state), '') AS state,
        NULLIF(TRIM(county), '') AS county,
        NULLIF(TRIM(fips), '') AS fips,
        NULLIF(TRIM(zip), '') AS zip,

        TRY_CONVERT(DECIMAL(18, 12), NULLIF(TRIM(lat), '')) AS latitude,
        TRY_CONVERT(DECIMAL(18, 12), NULLIF(TRIM(lon), '')) AS longitude,

        TRY_CONVERT(DECIMAL(18, 2), NULLIF(TRIM(healthcare_expenses), '')) AS healthcare_expenses,
        TRY_CONVERT(DECIMAL(18, 2), NULLIF(TRIM(healthcare_coverage), '')) AS healthcare_coverage,
        TRY_CONVERT(INT, NULLIF(TRIM(income), '')) AS income,

        ingestion_batch_id,
        ingestion_datetime,
        source_file,
        row_hash,
        load_status
    FROM bronze.patients
),
patient_with_reference_date AS (
    SELECT
        *,
        CASE
            WHEN death_date IS NOT NULL THEN death_date
            ELSE @current_date
        END AS age_reference_date,

        CASE
            WHEN death_date IS NOT NULL THEN 'death_date'
            ELSE 'silver_load_date'
        END AS age_reference_type
    FROM typed_patient
),
patient_with_age AS (
    SELECT
        *,
        CASE
            WHEN birth_date IS NULL THEN NULL
            WHEN birth_date > age_reference_date THEN NULL
            WHEN death_date IS NOT NULL AND death_date < birth_date THEN NULL
            ELSE
                DATEDIFF(YEAR, birth_date, age_reference_date)
                - CASE
                    WHEN DATEADD(
                        YEAR,
                        DATEDIFF(YEAR, birth_date, age_reference_date),
                        birth_date
                    ) > age_reference_date
                    THEN 1
                    ELSE 0
                  END
        END AS age_years
    FROM patient_with_reference_date
),
final_patient AS (
    SELECT
        *,
        CASE
            WHEN birth_date IS NULL THEN 'missing_birth_date'
            WHEN birth_date > age_reference_date THEN 'birth_date_after_reference_date'
            WHEN death_date IS NOT NULL AND death_date < birth_date THEN 'death_date_before_birth_date'
            ELSE 'valid'
        END AS patient_date_quality_status
    FROM patient_with_age
    WHERE patient_id IS NOT NULL
)
INSERT INTO silver.patient (
    patient_id,
    birth_date,
    death_date,
    is_deceased,
    age_reference_date,
    age_reference_type,
    age_years,
    age_band,
    gender,
    race,
    ethnicity,
    marital_status,
    city,
    [state],
    county,
    fips,
    zip,
    latitude,
    longitude,
    healthcare_expenses,
    healthcare_coverage,
    income,
    patient_date_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_ingestion_datetime,
    bronze_source_file,
    bronze_row_hash,
    bronze_load_status,
    silver_load_datetime
)
SELECT
    patient_id,
    birth_date,
    death_date,

    CASE
        WHEN death_date IS NOT NULL THEN 1
        ELSE 0
    END AS is_deceased,

    age_reference_date,
    age_reference_type,
    age_years,

    CASE
        WHEN age_years IS NULL THEN 'Unknown'
        WHEN age_years < 18 THEN '0-17'
        WHEN age_years BETWEEN 18 AND 34 THEN '18-34'
        WHEN age_years BETWEEN 35 AND 49 THEN '35-49'
        WHEN age_years BETWEEN 50 AND 64 THEN '50-64'
        WHEN age_years >= 65 THEN '65+'
    END AS age_band,

    gender,
    race,
    ethnicity,
    marital_status,
    city,
    [state],
    county,
    fips,
    zip,
    latitude,
    longitude,
    healthcare_expenses,
    healthcare_coverage,
    income,
    patient_date_quality_status,

    'Synthea CSV' AS source_system,
    'patients.csv' AS source_entity,
    ingestion_batch_id AS bronze_ingestion_batch_id,
    ingestion_datetime AS bronze_ingestion_datetime,
    source_file AS bronze_source_file,
    row_hash AS bronze_row_hash,
    load_status AS bronze_load_status,
    @silver_load_datetime AS silver_load_datetime
FROM final_patient;
GO


DECLARE @encounter_silver_load_datetime DATETIME2 = SYSUTCDATETIME();

TRUNCATE TABLE silver.encounter;

WITH typed_encounter AS (
    SELECT
        NULLIF(TRIM(source_encounter_id), '') AS encounter_id,

        NULLIF(TRIM(source_patient_id), '') AS patient_id,
        NULLIF(TRIM(source_organization_id), '') AS organization_id,
        NULLIF(TRIM(source_provider_id), '') AS provider_id,
        NULLIF(TRIM(source_payer_id), '') AS payer_id,

        NULLIF(TRIM(encounter_start_datetime), '') AS raw_start_datetime,
        NULLIF(TRIM(encounter_stop_datetime), '') AS raw_stop_datetime,

        TRY_CONVERT(
            DATETIMEOFFSET(0),
            NULLIF(TRIM(encounter_start_datetime), '')
        ) AS start_datetimeoffset,

        TRY_CONVERT(
            DATETIMEOFFSET(0),
            NULLIF(TRIM(encounter_stop_datetime), '')
        ) AS stop_datetimeoffset,

        LOWER(NULLIF(TRIM(encounter_class), '')) AS encounter_class,
        NULLIF(TRIM(encounter_code), '') AS encounter_code,
        NULLIF(TRIM(encounter_description), '') AS encounter_description,

        TRY_CONVERT(DECIMAL(18, 2), NULLIF(TRIM(base_encounter_cost), '')) AS base_encounter_cost,
        TRY_CONVERT(DECIMAL(18, 2), NULLIF(TRIM(total_claim_cost), '')) AS total_claim_cost,
        TRY_CONVERT(DECIMAL(18, 2), NULLIF(TRIM(payer_coverage), '')) AS payer_coverage,

        NULLIF(TRIM(reason_code), '') AS reason_code,
        NULLIF(TRIM(reason_description), '') AS reason_description,

        ingestion_batch_id,
        ingestion_datetime,
        source_file,
        row_hash,
        load_status
    FROM bronze.encounters
),
normalized_encounter AS (
    SELECT
        *,
        CAST(SWITCHOFFSET(start_datetimeoffset, '+00:00') AS DATETIME2(0)) AS encounter_start_datetime_utc,
        CAST(SWITCHOFFSET(stop_datetimeoffset, '+00:00') AS DATETIME2(0)) AS encounter_stop_datetime_utc
    FROM typed_encounter
),
final_encounter AS (
    SELECT
        *,

        CASE WHEN raw_start_datetime IS NULL THEN 1 ELSE 0 END AS is_missing_start_datetime,
        CASE WHEN raw_stop_datetime IS NULL THEN 1 ELSE 0 END AS is_missing_stop_datetime,

        CASE
            WHEN raw_start_datetime IS NOT NULL AND start_datetimeoffset IS NULL THEN 1
            ELSE 0
        END AS is_invalid_start_datetime,

        CASE
            WHEN raw_stop_datetime IS NOT NULL AND stop_datetimeoffset IS NULL THEN 1
            ELSE 0
        END AS is_invalid_stop_datetime,

        CASE
            WHEN encounter_start_datetime_utc IS NOT NULL
             AND encounter_stop_datetime_utc IS NOT NULL
             AND encounter_stop_datetime_utc < encounter_start_datetime_utc
            THEN 1
            ELSE 0
        END AS is_stop_before_start,

        CASE
            WHEN raw_start_datetime IS NULL THEN 'missing_start_datetime'
            WHEN start_datetimeoffset IS NULL THEN 'invalid_start_datetime'
            WHEN raw_stop_datetime IS NULL THEN 'missing_stop_datetime'
            WHEN stop_datetimeoffset IS NULL THEN 'invalid_stop_datetime'
            WHEN encounter_stop_datetime_utc < encounter_start_datetime_utc THEN 'stop_before_start'
            ELSE 'valid'
        END AS encounter_datetime_quality_status
    FROM normalized_encounter
    WHERE encounter_id IS NOT NULL
)
INSERT INTO silver.encounter (
    encounter_id,
    patient_id,
    organization_id,
    provider_id,
    payer_id,
    encounter_start_datetime_utc,
    encounter_stop_datetime_utc,
    encounter_start_date,
    encounter_stop_date,
    encounter_duration_minutes,
    encounter_duration_hours,
    length_of_stay_days,
    encounter_class,
    encounter_code,
    encounter_description,
    base_encounter_cost,
    total_claim_cost,
    payer_coverage,
    reason_code,
    reason_description,
    is_missing_start_datetime,
    is_missing_stop_datetime,
    is_invalid_start_datetime,
    is_invalid_stop_datetime,
    is_stop_before_start,
    encounter_datetime_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_ingestion_datetime,
    bronze_source_file,
    bronze_row_hash,
    bronze_load_status,
    silver_load_datetime
)
SELECT
    encounter_id,
    patient_id,
    organization_id,
    provider_id,
    payer_id,

    encounter_start_datetime_utc,
    encounter_stop_datetime_utc,

    CAST(encounter_start_datetime_utc AS DATE) AS encounter_start_date,
    CAST(encounter_stop_datetime_utc AS DATE) AS encounter_stop_date,

    CASE
        WHEN encounter_datetime_quality_status = 'valid'
        THEN DATEDIFF_BIG(MINUTE, encounter_start_datetime_utc, encounter_stop_datetime_utc)
        ELSE NULL
    END AS encounter_duration_minutes,

    CASE
        WHEN encounter_datetime_quality_status = 'valid'
        THEN CAST(DATEDIFF_BIG(SECOND, encounter_start_datetime_utc, encounter_stop_datetime_utc) / 3600.0 AS DECIMAL(18, 2))
        ELSE NULL
    END AS encounter_duration_hours,

    CASE
        WHEN encounter_datetime_quality_status = 'valid'
        THEN CAST(DATEDIFF_BIG(SECOND, encounter_start_datetime_utc, encounter_stop_datetime_utc) / 86400.0 AS DECIMAL(18, 4))
        ELSE NULL
    END AS length_of_stay_days,

    encounter_class,
    encounter_code,
    encounter_description,

    base_encounter_cost,
    total_claim_cost,
    payer_coverage,

    reason_code,
    reason_description,

    is_missing_start_datetime,
    is_missing_stop_datetime,
    is_invalid_start_datetime,
    is_invalid_stop_datetime,
    is_stop_before_start,
    encounter_datetime_quality_status,

    'Synthea CSV' AS source_system,
    'encounters.csv' AS source_entity,
    ingestion_batch_id AS bronze_ingestion_batch_id,
    ingestion_datetime AS bronze_ingestion_datetime,
    source_file AS bronze_source_file,
    row_hash AS bronze_row_hash,
    load_status AS bronze_load_status,
    @encounter_silver_load_datetime AS silver_load_datetime
FROM final_encounter;
GO


DECLARE @clinical_context_silver_load_datetime DATETIME2 = SYSUTCDATETIME();

TRUNCATE TABLE silver.condition;

WITH typed_condition AS (
    SELECT
        NULLIF(TRIM(source_patient_id), '') AS patient_id,
        NULLIF(TRIM(source_encounter_id), '') AS encounter_id,

        NULLIF(TRIM(condition_start_date), '') AS raw_start_date,
        NULLIF(TRIM(condition_stop_date), '') AS raw_stop_date,

        TRY_CONVERT(DATE, NULLIF(TRIM(condition_start_date), ''), 23) AS condition_start_date,
        TRY_CONVERT(DATE, NULLIF(TRIM(condition_stop_date), ''), 23) AS condition_stop_date,

        NULLIF(TRIM(condition_system), '') AS condition_system,
        NULLIF(TRIM(condition_code), '') AS condition_code,
        NULLIF(TRIM(condition_description), '') AS condition_description,

        ingestion_batch_id,
        ingestion_datetime,
        source_file,
        row_hash,
        load_status
    FROM bronze.conditions
),
final_condition AS (
    SELECT
        *,
        CASE WHEN raw_start_date IS NULL THEN 1 ELSE 0 END AS is_missing_start_date,

        CASE
            WHEN raw_start_date IS NOT NULL AND condition_start_date IS NULL THEN 1
            ELSE 0
        END AS is_invalid_start_date,

        CASE
            WHEN raw_stop_date IS NOT NULL AND condition_stop_date IS NULL THEN 1
            ELSE 0
        END AS is_invalid_stop_date,

        CASE
            WHEN condition_start_date IS NOT NULL
             AND condition_stop_date IS NOT NULL
             AND condition_stop_date < condition_start_date
            THEN 1
            ELSE 0
        END AS is_stop_before_start,

        CASE
            WHEN raw_start_date IS NULL THEN 'missing_start_date'
            WHEN condition_start_date IS NULL THEN 'invalid_start_date'
            WHEN raw_stop_date IS NOT NULL AND condition_stop_date IS NULL THEN 'invalid_stop_date'
            WHEN condition_stop_date < condition_start_date THEN 'stop_before_start'
            ELSE 'valid'
        END AS condition_date_quality_status
    FROM typed_condition
)
INSERT INTO silver.condition (
    patient_id,
    encounter_id,
    condition_start_date,
    condition_stop_date,
    condition_duration_days,
    condition_system,
    condition_code,
    condition_description,
    condition_category,
    condition_status,
    is_missing_start_date,
    is_invalid_start_date,
    is_invalid_stop_date,
    is_stop_before_start,
    condition_date_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_ingestion_datetime,
    bronze_source_file,
    bronze_row_hash,
    bronze_load_status,
    silver_load_datetime
)
SELECT
    patient_id,
    encounter_id,
    condition_start_date,
    condition_stop_date,

    CASE
        WHEN condition_date_quality_status = 'valid'
         AND condition_stop_date IS NOT NULL
        THEN DATEDIFF(DAY, condition_start_date, condition_stop_date)
        ELSE NULL
    END AS condition_duration_days,

    condition_system,
    condition_code,
    condition_description,

    CASE
        WHEN LOWER(condition_description) LIKE '%(finding)%' THEN 'finding'
        WHEN LOWER(condition_description) LIKE '%(disorder)%' THEN 'disorder'
        WHEN LOWER(condition_description) LIKE '%(procedure)%' THEN 'procedure'
        WHEN LOWER(condition_description) LIKE '%(situation)%' THEN 'situation'
        ELSE 'uncategorized'
    END AS condition_category,

    CASE
        WHEN condition_stop_date IS NULL THEN 'active_or_open'
        ELSE 'resolved_or_closed'
    END AS condition_status,

    is_missing_start_date,
    is_invalid_start_date,
    is_invalid_stop_date,
    is_stop_before_start,
    condition_date_quality_status,

    'Synthea CSV' AS source_system,
    'conditions.csv' AS source_entity,
    ingestion_batch_id AS bronze_ingestion_batch_id,
    ingestion_datetime AS bronze_ingestion_datetime,
    source_file AS bronze_source_file,
    row_hash AS bronze_row_hash,
    load_status AS bronze_load_status,
    @clinical_context_silver_load_datetime AS silver_load_datetime
FROM final_condition;
GO


DECLARE @procedure_silver_load_datetime DATETIME2 = SYSUTCDATETIME();

TRUNCATE TABLE silver.[procedure];

WITH typed_procedure AS (
    SELECT
        NULLIF(TRIM(source_patient_id), '') AS patient_id,
        NULLIF(TRIM(source_encounter_id), '') AS encounter_id,

        NULLIF(TRIM(procedure_start_datetime), '') AS raw_start_datetime,
        NULLIF(TRIM(procedure_stop_datetime), '') AS raw_stop_datetime,

        TRY_CONVERT(DATETIMEOFFSET(0), NULLIF(TRIM(procedure_start_datetime), '')) AS start_datetimeoffset,
        TRY_CONVERT(DATETIMEOFFSET(0), NULLIF(TRIM(procedure_stop_datetime), '')) AS stop_datetimeoffset,

        NULLIF(TRIM(procedure_system), '') AS procedure_system,
        NULLIF(TRIM(procedure_code), '') AS procedure_code,
        NULLIF(TRIM(procedure_description), '') AS procedure_description,
        TRY_CONVERT(DECIMAL(18, 2), NULLIF(TRIM(base_procedure_cost), '')) AS base_procedure_cost,

        NULLIF(TRIM(reason_code), '') AS reason_code,
        NULLIF(TRIM(reason_description), '') AS reason_description,

        ingestion_batch_id,
        ingestion_datetime,
        source_file,
        row_hash,
        load_status
    FROM bronze.procedures
),
normalized_procedure AS (
    SELECT
        *,
        CAST(SWITCHOFFSET(start_datetimeoffset, '+00:00') AS DATETIME2(0)) AS procedure_start_datetime_utc,
        CAST(SWITCHOFFSET(stop_datetimeoffset, '+00:00') AS DATETIME2(0)) AS procedure_stop_datetime_utc
    FROM typed_procedure
),
final_procedure AS (
    SELECT
        *,
        CASE WHEN raw_start_datetime IS NULL THEN 1 ELSE 0 END AS is_missing_start_datetime,
        CASE WHEN raw_stop_datetime IS NULL THEN 1 ELSE 0 END AS is_missing_stop_datetime,

        CASE
            WHEN raw_start_datetime IS NOT NULL AND start_datetimeoffset IS NULL THEN 1
            ELSE 0
        END AS is_invalid_start_datetime,

        CASE
            WHEN raw_stop_datetime IS NOT NULL AND stop_datetimeoffset IS NULL THEN 1
            ELSE 0
        END AS is_invalid_stop_datetime,

        CASE
            WHEN procedure_start_datetime_utc IS NOT NULL
             AND procedure_stop_datetime_utc IS NOT NULL
             AND procedure_stop_datetime_utc < procedure_start_datetime_utc
            THEN 1
            ELSE 0
        END AS is_stop_before_start,

        CASE
            WHEN raw_start_datetime IS NULL THEN 'missing_start_datetime'
            WHEN start_datetimeoffset IS NULL THEN 'invalid_start_datetime'
            WHEN raw_stop_datetime IS NULL THEN 'missing_stop_datetime'
            WHEN stop_datetimeoffset IS NULL THEN 'invalid_stop_datetime'
            WHEN procedure_stop_datetime_utc < procedure_start_datetime_utc THEN 'stop_before_start'
            ELSE 'valid'
        END AS procedure_datetime_quality_status
    FROM normalized_procedure
)
INSERT INTO silver.[procedure] (
    patient_id,
    encounter_id,
    procedure_start_datetime_utc,
    procedure_stop_datetime_utc,
    procedure_start_date,
    procedure_stop_date,
    procedure_duration_minutes,
    procedure_duration_hours,
    procedure_system,
    procedure_code,
    procedure_description,
    procedure_category,
    base_procedure_cost,
    reason_code,
    reason_description,
    is_missing_start_datetime,
    is_missing_stop_datetime,
    is_invalid_start_datetime,
    is_invalid_stop_datetime,
    is_stop_before_start,
    procedure_datetime_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_ingestion_datetime,
    bronze_source_file,
    bronze_row_hash,
    bronze_load_status,
    silver_load_datetime
)
SELECT
    patient_id,
    encounter_id,
    procedure_start_datetime_utc,
    procedure_stop_datetime_utc,
    CAST(procedure_start_datetime_utc AS DATE) AS procedure_start_date,
    CAST(procedure_stop_datetime_utc AS DATE) AS procedure_stop_date,

    CASE
        WHEN procedure_datetime_quality_status = 'valid'
        THEN DATEDIFF_BIG(MINUTE, procedure_start_datetime_utc, procedure_stop_datetime_utc)
        ELSE NULL
    END AS procedure_duration_minutes,

    CASE
        WHEN procedure_datetime_quality_status = 'valid'
        THEN CAST(DATEDIFF_BIG(SECOND, procedure_start_datetime_utc, procedure_stop_datetime_utc) / 3600.0 AS DECIMAL(18, 2))
        ELSE NULL
    END AS procedure_duration_hours,

    procedure_system,
    procedure_code,
    procedure_description,

    CASE
        WHEN LOWER(procedure_description) LIKE '%dental%' THEN 'dental'
        WHEN LOWER(procedure_description) LIKE '%therapy%' THEN 'therapy'
        WHEN LOWER(procedure_description) LIKE '%assessment%' THEN 'assessment'
        WHEN LOWER(procedure_description) LIKE '%examination%' THEN 'assessment'
        WHEN LOWER(procedure_description) LIKE '%surgery%' THEN 'surgical'
        WHEN LOWER(procedure_description) LIKE '%surgical%' THEN 'surgical'
        ELSE 'other'
    END AS procedure_category,

    base_procedure_cost,
    reason_code,
    reason_description,

    is_missing_start_datetime,
    is_missing_stop_datetime,
    is_invalid_start_datetime,
    is_invalid_stop_datetime,
    is_stop_before_start,
    procedure_datetime_quality_status,

    'Synthea CSV' AS source_system,
    'procedures.csv' AS source_entity,
    ingestion_batch_id AS bronze_ingestion_batch_id,
    ingestion_datetime AS bronze_ingestion_datetime,
    source_file AS bronze_source_file,
    row_hash AS bronze_row_hash,
    load_status AS bronze_load_status,
    @procedure_silver_load_datetime AS silver_load_datetime
FROM final_procedure;
GO


DECLARE @observation_silver_load_datetime DATETIME2 = SYSUTCDATETIME();

TRUNCATE TABLE silver.observation;

WITH typed_observation AS (
    SELECT
        NULLIF(TRIM(source_patient_id), '') AS patient_id,
        NULLIF(TRIM(source_encounter_id), '') AS encounter_id,

        NULLIF(TRIM(observation_datetime), '') AS raw_observation_datetime,
        TRY_CONVERT(DATETIMEOFFSET(0), NULLIF(TRIM(observation_datetime), '')) AS observation_datetimeoffset,

        LOWER(NULLIF(TRIM(observation_category), '')) AS raw_observation_category,
        NULLIF(TRIM(observation_code), '') AS observation_code,
        NULLIF(TRIM(observation_description), '') AS observation_description,
        NULLIF(TRIM(observation_value), '') AS observation_value_raw,
        TRY_CONVERT(DECIMAL(18, 6), NULLIF(TRIM(observation_value), '')) AS observation_value_numeric,
        NULLIF(TRIM(observation_units), '') AS observation_units,
        LOWER(NULLIF(TRIM(observation_type), '')) AS observation_type,

        ingestion_batch_id,
        ingestion_datetime,
        source_file,
        row_hash,
        load_status
    FROM bronze.observations
),
normalized_observation AS (
    SELECT
        *,
        CAST(SWITCHOFFSET(observation_datetimeoffset, '+00:00') AS DATETIME2(0)) AS observation_datetime_utc
    FROM typed_observation
),
final_observation AS (
    SELECT
        *,
        CASE WHEN raw_observation_datetime IS NULL THEN 1 ELSE 0 END AS is_missing_observation_datetime,

        CASE
            WHEN raw_observation_datetime IS NOT NULL AND observation_datetimeoffset IS NULL THEN 1
            ELSE 0
        END AS is_invalid_observation_datetime,

        CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END AS is_missing_patient_id,
        CASE WHEN observation_code IS NULL THEN 1 ELSE 0 END AS is_missing_observation_code,

        CASE
            WHEN patient_id IS NULL THEN 'missing_patient_id'
            WHEN raw_observation_datetime IS NULL THEN 'missing_observation_datetime'
            WHEN observation_datetimeoffset IS NULL THEN 'invalid_observation_datetime'
            WHEN observation_code IS NULL THEN 'missing_observation_code'
            ELSE 'valid'
        END AS observation_quality_status
    FROM normalized_observation
)
INSERT INTO silver.observation (
    patient_id,
    encounter_id,
    observation_datetime_utc,
    observation_date,
    observation_category,
    observation_code,
    observation_description,
    observation_value_raw,
    observation_value_numeric,
    observation_units,
    observation_type,
    is_missing_observation_datetime,
    is_invalid_observation_datetime,
    is_missing_patient_id,
    is_missing_observation_code,
    observation_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_ingestion_datetime,
    bronze_source_file,
    bronze_row_hash,
    bronze_load_status,
    silver_load_datetime
)
SELECT
    patient_id,
    encounter_id,
    observation_datetime_utc,
    CAST(observation_datetime_utc AS DATE) AS observation_date,

    COALESCE(raw_observation_category, 'uncategorized') AS observation_category,
    observation_code,
    observation_description,
    observation_value_raw,
    observation_value_numeric,
    observation_units,
    observation_type,

    is_missing_observation_datetime,
    is_invalid_observation_datetime,
    is_missing_patient_id,
    is_missing_observation_code,
    observation_quality_status,

    'Synthea CSV' AS source_system,
    'observations.csv' AS source_entity,
    ingestion_batch_id AS bronze_ingestion_batch_id,
    ingestion_datetime AS bronze_ingestion_datetime,
    source_file AS bronze_source_file,
    row_hash AS bronze_row_hash,
    load_status AS bronze_load_status,
    @observation_silver_load_datetime AS silver_load_datetime
FROM final_observation;
GO
