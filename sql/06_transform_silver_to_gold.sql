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
