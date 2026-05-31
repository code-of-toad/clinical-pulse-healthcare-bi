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
