/*
ClinicalPulse
Script: 06_transform_silver_to_gold.sql
Purpose: Populate gold-layer dimension tables from silver-layer entities.
User Story: AB#1504 Create gold dimensions

Assumptions:
- Current silver scope includes patient, encounter, condition, observation, and procedure.
- Organization and provider dimensions are built from distinct IDs in silver.encounter until dedicated silver organization/provider tables exist.
- Gold dimensions use Type 1/current-state logic for this portfolio version.
*/

USE ClinicalPulse;
GO

SET NOCOUNT ON;
SET DATEFIRST 7;

DECLARE @gold_load_datetime DATETIME2 = SYSUTCDATETIME();

TRUNCATE TABLE gold.fact_readmission;
TRUNCATE TABLE gold.fact_encounter;
TRUNCATE TABLE [gold].[dim_patient];
TRUNCATE TABLE [gold].[dim_date];
TRUNCATE TABLE [gold].[dim_organization];
TRUNCATE TABLE [gold].[dim_provider];
TRUNCATE TABLE [gold].[dim_encounter_class];
TRUNCATE TABLE [gold].[dim_condition];
TRUNCATE TABLE [gold].[dim_observation];
TRUNCATE TABLE [gold].[dim_procedure];

INSERT INTO [gold].[dim_patient] (
    patient_id,
    birth_date,
    death_date,
    is_deceased,
    age_reference_date,
    age_reference_type,
    age_years,
    age_band,
    age_band_sort_order,
    gender,
    race,
    ethnicity,
    marital_status,
    city,
    state,
    county,
    fips,
    zip,
    patient_date_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_source_file,
    silver_load_datetime,
    gold_load_datetime
)
SELECT
    patient_id,
    birth_date,
    death_date,
    is_deceased,
    age_reference_date,
    age_reference_type,
    age_years,
    age_band,
    CASE age_band
        WHEN '0-17' THEN 1
        WHEN '18-34' THEN 2
        WHEN '35-49' THEN 3
        WHEN '50-64' THEN 4
        WHEN '65+' THEN 5
        ELSE 99
    END AS age_band_sort_order,
    gender,
    race,
    ethnicity,
    marital_status,
    city,
    state,
    county,
    fips,
    zip,
    patient_date_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_source_file,
    silver_load_datetime,
    @gold_load_datetime
FROM [silver].[patient];

DECLARE @min_date DATE;
DECLARE @max_date DATE;

SELECT
    @min_date = MIN(candidate_date),
    @max_date = MAX(candidate_date)
FROM (
    SELECT birth_date AS candidate_date FROM [silver].[patient] WHERE birth_date IS NOT NULL
    UNION ALL
    SELECT death_date FROM [silver].[patient] WHERE death_date IS NOT NULL
    UNION ALL
    SELECT encounter_start_date FROM [silver].[encounter] WHERE encounter_start_date IS NOT NULL
    UNION ALL
    SELECT encounter_stop_date FROM [silver].[encounter] WHERE encounter_stop_date IS NOT NULL
    UNION ALL
    SELECT condition_start_date FROM [silver].[condition] WHERE condition_start_date IS NOT NULL
    UNION ALL
    SELECT condition_stop_date FROM [silver].[condition] WHERE condition_stop_date IS NOT NULL
    UNION ALL
    SELECT observation_date FROM [silver].[observation] WHERE observation_date IS NOT NULL
    UNION ALL
    SELECT procedure_start_date FROM [silver].[procedure] WHERE procedure_start_date IS NOT NULL
    UNION ALL
    SELECT procedure_stop_date FROM [silver].[procedure] WHERE procedure_stop_date IS NOT NULL
) AS date_candidates;

IF @min_date IS NOT NULL AND @max_date IS NOT NULL
BEGIN
    ;WITH date_series AS (
        SELECT @min_date AS full_date

        UNION ALL

        SELECT DATEADD(DAY, 1, full_date)
        FROM date_series
        WHERE full_date < @max_date
    )
    INSERT INTO [gold].[dim_date] (
        date_key,
        full_date,
        calendar_year,
        calendar_quarter,
        calendar_month,
        calendar_month_name,
        year_month,
        month_start_date,
        day_of_month,
        day_of_week,
        day_name,
        week_of_year,
        is_weekend
    )
    SELECT
        CONVERT(INT, CONVERT(CHAR(8), full_date, 112)) AS date_key,
        full_date,
        YEAR(full_date) AS calendar_year,
        DATEPART(QUARTER, full_date) AS calendar_quarter,
        MONTH(full_date) AS calendar_month,
        DATENAME(MONTH, full_date) AS calendar_month_name,
        CONVERT(CHAR(7), full_date, 120) AS year_month,
        DATEFROMPARTS(YEAR(full_date), MONTH(full_date), 1) AS month_start_date,
        DAY(full_date) AS day_of_month,
        DATEPART(WEEKDAY, full_date) AS day_of_week,
        DATENAME(WEEKDAY, full_date) AS day_name,
        DATEPART(WEEK, full_date) AS week_of_year,
        CASE
            WHEN DATEPART(WEEKDAY, full_date) IN (1, 7) THEN 1
            ELSE 0
        END AS is_weekend
    FROM date_series
    OPTION (MAXRECURSION 0);
END;

INSERT INTO [gold].[dim_organization] (
    organization_id,
    organization_name,
    organization_source_status,
    gold_load_datetime
)
SELECT DISTINCT
    COALESCE(NULLIF(LTRIM(RTRIM(organization_id)), ''), 'UNKNOWN') AS organization_id,
    CASE
        WHEN NULLIF(LTRIM(RTRIM(organization_id)), '') IS NULL THEN 'Unknown Organization'
        ELSE NULL
    END AS organization_name,
    CASE
        WHEN NULLIF(LTRIM(RTRIM(organization_id)), '') IS NULL THEN 'unknown_from_silver_encounter'
        ELSE 'sourced_from_silver_encounter'
    END AS organization_source_status,
    @gold_load_datetime
FROM [silver].[encounter];

INSERT INTO [gold].[dim_provider] (
    provider_id,
    provider_name,
    provider_source_status,
    gold_load_datetime
)
SELECT DISTINCT
    COALESCE(NULLIF(LTRIM(RTRIM(provider_id)), ''), 'UNKNOWN') AS provider_id,
    CASE
        WHEN NULLIF(LTRIM(RTRIM(provider_id)), '') IS NULL THEN 'Unknown Provider'
        ELSE NULL
    END AS provider_name,
    CASE
        WHEN NULLIF(LTRIM(RTRIM(provider_id)), '') IS NULL THEN 'unknown_from_silver_encounter'
        ELSE 'sourced_from_silver_encounter'
    END AS provider_source_status,
    @gold_load_datetime
FROM [silver].[encounter];

;WITH encounter_class_source AS (
    SELECT DISTINCT
        COALESCE(NULLIF(LTRIM(RTRIM(encounter_class)), ''), 'unknown') AS encounter_class
    FROM [silver].[encounter]
)
INSERT INTO [gold].[dim_encounter_class] (
    encounter_class,
    encounter_class_display,
    encounter_class_group,
    is_inpatient,
    is_emergency,
    is_ambulatory,
    gold_load_datetime
)
SELECT
    encounter_class,
    UPPER(LEFT(encounter_class, 1)) + SUBSTRING(encounter_class, 2, LEN(encounter_class)) AS encounter_class_display,
    CASE
        WHEN encounter_class = 'inpatient' THEN 'Inpatient'
        WHEN encounter_class = 'emergency' THEN 'Emergency'
        WHEN encounter_class IN ('ambulatory', 'outpatient', 'wellness', 'urgentcare') THEN 'Ambulatory / Outpatient'
        WHEN encounter_class = 'unknown' THEN 'Unknown'
        ELSE 'Other'
    END AS encounter_class_group,
    CASE WHEN encounter_class = 'inpatient' THEN 1 ELSE 0 END AS is_inpatient,
    CASE WHEN encounter_class = 'emergency' THEN 1 ELSE 0 END AS is_emergency,
    CASE WHEN encounter_class IN ('ambulatory', 'outpatient', 'wellness', 'urgentcare') THEN 1 ELSE 0 END AS is_ambulatory,
    @gold_load_datetime
FROM encounter_class_source;

;WITH condition_source AS (
    SELECT DISTINCT
        condition_system,
        condition_code,
        condition_description,
        condition_category
    FROM [silver].[condition]
), condition_keys AS (
    SELECT
        CONCAT(
            COALESCE(NULLIF(LTRIM(RTRIM(condition_system)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(condition_code)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(condition_description)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(condition_category)), ''), 'UNKNOWN')
        ) AS condition_natural_key,
        condition_system,
        condition_code,
        condition_description,
        condition_category
    FROM condition_source
)
INSERT INTO [gold].[dim_condition] (
    condition_natural_key,
    condition_natural_key_hash,
    condition_system,
    condition_code,
    condition_description,
    condition_category,
    gold_load_datetime
)
SELECT
    condition_natural_key,
    HASHBYTES('SHA2_256', condition_natural_key) AS condition_natural_key_hash,
    condition_system,
    condition_code,
    condition_description,
    condition_category,
    @gold_load_datetime
FROM condition_keys;

;WITH observation_source AS (
    SELECT DISTINCT
        observation_category,
        observation_code,
        observation_description,
        observation_units,
        observation_type
    FROM [silver].[observation]
), observation_keys AS (
    SELECT
        CONCAT(
            COALESCE(NULLIF(LTRIM(RTRIM(observation_category)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(observation_code)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(observation_description)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(observation_units)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(observation_type)), ''), 'UNKNOWN')
        ) AS observation_natural_key,
        observation_category,
        observation_code,
        observation_description,
        observation_units,
        observation_type
    FROM observation_source
)
INSERT INTO [gold].[dim_observation] (
    observation_natural_key,
    observation_natural_key_hash,
    observation_category,
    observation_code,
    observation_description,
    observation_units,
    observation_type,
    gold_load_datetime
)
SELECT
    observation_natural_key,
    HASHBYTES('SHA2_256', observation_natural_key) AS observation_natural_key_hash,
    observation_category,
    observation_code,
    observation_description,
    observation_units,
    observation_type,
    @gold_load_datetime
FROM observation_keys;

;WITH procedure_source AS (
    SELECT DISTINCT
        procedure_system,
        procedure_code,
        procedure_description,
        procedure_category
    FROM [silver].[procedure]
), procedure_keys AS (
    SELECT
        CONCAT(
            COALESCE(NULLIF(LTRIM(RTRIM(procedure_system)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(procedure_code)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(procedure_description)), ''), 'UNKNOWN'), '|',
            COALESCE(NULLIF(LTRIM(RTRIM(procedure_category)), ''), 'UNKNOWN')
        ) AS procedure_natural_key,
        procedure_system,
        procedure_code,
        procedure_description,
        procedure_category
    FROM procedure_source
)
INSERT INTO [gold].[dim_procedure] (
    procedure_natural_key,
    procedure_natural_key_hash,
    procedure_system,
    procedure_code,
    procedure_description,
    procedure_category,
    gold_load_datetime
)
SELECT
    procedure_natural_key,
    HASHBYTES('SHA2_256', procedure_natural_key) AS procedure_natural_key_hash,
    procedure_system,
    procedure_code,
    procedure_description,
    procedure_category,
    @gold_load_datetime
FROM procedure_keys;
GO

DECLARE @gold_load_datetime DATETIME2 = SYSUTCDATETIME();

INSERT INTO gold.fact_encounter (
    encounter_id,
    patient_key,
    encounter_start_date_key,
    encounter_stop_date_key,
    organization_key,
    provider_key,
    encounter_class_key,
    patient_id,
    organization_id,
    provider_id,
    payer_id,
    encounter_start_datetime_utc,
    encounter_stop_datetime_utc,
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
    encounter_count,
    valid_encounter_count,
    is_missing_start_datetime,
    is_missing_stop_datetime,
    is_invalid_start_datetime,
    is_invalid_stop_datetime,
    is_stop_before_start,
    encounter_datetime_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_source_file,
    silver_load_datetime,
    gold_load_datetime
)
SELECT
    e.encounter_id,
    dp.patient_key,
    d_start.date_key,
    d_stop.date_key,
    do.organization_key,
    dpr.provider_key,
    dec.encounter_class_key,
    e.patient_id,
    COALESCE(e.organization_id, 'UNKNOWN') AS organization_id,
    COALESCE(e.provider_id, 'UNKNOWN') AS provider_id,
    e.payer_id,
    e.encounter_start_datetime_utc,
    e.encounter_stop_datetime_utc,
    e.encounter_duration_minutes,
    e.encounter_duration_hours,
    e.length_of_stay_days,
    COALESCE(e.encounter_class, 'unknown') AS encounter_class,
    e.encounter_code,
    e.encounter_description,
    e.base_encounter_cost,
    e.total_claim_cost,
    e.payer_coverage,
    e.reason_code,
    e.reason_description,
    1 AS encounter_count,
    CASE
        WHEN e.encounter_datetime_quality_status = 'valid' THEN 1
        ELSE 0
    END AS valid_encounter_count,
    e.is_missing_start_datetime,
    e.is_missing_stop_datetime,
    e.is_invalid_start_datetime,
    e.is_invalid_stop_datetime,
    e.is_stop_before_start,
    e.encounter_datetime_quality_status,
    e.source_system,
    e.source_entity,
    e.bronze_ingestion_batch_id,
    e.bronze_source_file,
    e.silver_load_datetime,
    @gold_load_datetime
FROM silver.encounter e
LEFT JOIN gold.dim_patient dp
    ON e.patient_id = dp.patient_id
LEFT JOIN gold.dim_date d_start
    ON e.encounter_start_date = d_start.full_date
LEFT JOIN gold.dim_date d_stop
    ON e.encounter_stop_date = d_stop.full_date
LEFT JOIN gold.dim_organization do
    ON COALESCE(e.organization_id, 'UNKNOWN') = do.organization_id
LEFT JOIN gold.dim_provider dpr
    ON COALESCE(e.provider_id, 'UNKNOWN') = dpr.provider_id
LEFT JOIN gold.dim_encounter_class dec
    ON COALESCE(e.encounter_class, 'unknown') = dec.encounter_class;
GO

DECLARE @gold_load_datetime DATETIME2 = SYSUTCDATETIME();

INSERT INTO gold.fact_readmission (
    index_encounter_fact_key,
    index_encounter_id,
    patient_key,
    patient_id,
    index_encounter_start_datetime_utc,
    index_encounter_stop_datetime_utc,
    index_start_date_key,
    index_stop_date_key,
    index_organization_key,
    index_provider_key,
    index_encounter_class_key,
    readmission_encounter_fact_key,
    readmission_encounter_id,
    readmission_start_datetime_utc,
    readmission_start_date_key,
    days_to_readmission,
    hours_to_readmission,
    eligible_encounter_count,
    readmission_30_day_count,
    is_30_day_readmission,
    readmission_window_days,
    readmission_logic_status,
    gold_load_datetime
)
SELECT
    index_encounter.encounter_fact_key AS index_encounter_fact_key,
    index_encounter.encounter_id AS index_encounter_id,
    index_encounter.patient_key,
    index_encounter.patient_id,
    index_encounter.encounter_start_datetime_utc AS index_encounter_start_datetime_utc,
    index_encounter.encounter_stop_datetime_utc AS index_encounter_stop_datetime_utc,
    index_encounter.encounter_start_date_key AS index_start_date_key,
    index_encounter.encounter_stop_date_key AS index_stop_date_key,
    index_encounter.organization_key AS index_organization_key,
    index_encounter.provider_key AS index_provider_key,
    index_encounter.encounter_class_key AS index_encounter_class_key,
    next_encounter.encounter_fact_key AS readmission_encounter_fact_key,
    next_encounter.encounter_id AS readmission_encounter_id,
    next_encounter.encounter_start_datetime_utc AS readmission_start_datetime_utc,
    next_encounter.encounter_start_date_key AS readmission_start_date_key,
    CASE
        WHEN next_encounter.encounter_id IS NULL THEN NULL
        ELSE DATEDIFF(DAY, index_encounter.encounter_stop_datetime_utc, next_encounter.encounter_start_datetime_utc)
    END AS days_to_readmission,
    CASE
        WHEN next_encounter.encounter_id IS NULL THEN NULL
        ELSE CAST(DATEDIFF_BIG(MINUTE, index_encounter.encounter_stop_datetime_utc, next_encounter.encounter_start_datetime_utc) / 60.0 AS DECIMAL(18,2))
    END AS hours_to_readmission,
    1 AS eligible_encounter_count,
    CASE
        WHEN next_encounter.encounter_start_datetime_utc <= DATEADD(DAY, 30, index_encounter.encounter_stop_datetime_utc) THEN 1
        ELSE 0
    END AS readmission_30_day_count,
    CASE
        WHEN next_encounter.encounter_start_datetime_utc <= DATEADD(DAY, 30, index_encounter.encounter_stop_datetime_utc) THEN 1
        ELSE 0
    END AS is_30_day_readmission,
    30 AS readmission_window_days,
    CASE
        WHEN next_encounter.encounter_id IS NULL THEN 'no_subsequent_encounter'
        WHEN next_encounter.encounter_start_datetime_utc <= DATEADD(DAY, 30, index_encounter.encounter_stop_datetime_utc) THEN 'readmitted_within_30_days'
        ELSE 'subsequent_encounter_after_30_days'
    END AS readmission_logic_status,
    @gold_load_datetime
FROM gold.fact_encounter index_encounter
OUTER APPLY (
    SELECT TOP (1)
        candidate.encounter_fact_key,
        candidate.encounter_id,
        candidate.encounter_start_datetime_utc,
        candidate.encounter_start_date_key
    FROM gold.fact_encounter candidate
    WHERE candidate.patient_id = index_encounter.patient_id
      AND candidate.encounter_start_datetime_utc > index_encounter.encounter_stop_datetime_utc
      AND candidate.encounter_id <> index_encounter.encounter_id
    ORDER BY
        candidate.encounter_start_datetime_utc,
        candidate.encounter_id
) next_encounter
WHERE index_encounter.patient_id IS NOT NULL
  AND index_encounter.encounter_start_datetime_utc IS NOT NULL
  AND index_encounter.encounter_stop_datetime_utc IS NOT NULL
  AND index_encounter.encounter_stop_datetime_utc >= index_encounter.encounter_start_datetime_utc;
GO
