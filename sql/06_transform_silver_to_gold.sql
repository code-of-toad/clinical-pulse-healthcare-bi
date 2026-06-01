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

TRUNCATE TABLE gold.fact_data_quality_issue;
TRUNCATE TABLE gold.fact_observation;
TRUNCATE TABLE gold.fact_procedure;
TRUNCATE TABLE gold.fact_condition;
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

DECLARE @gold_load_datetime DATETIME2 = SYSUTCDATETIME();

INSERT INTO gold.fact_condition (
    condition_record_id,
    patient_key,
    encounter_fact_key,
    condition_key,
    condition_start_date_key,
    condition_stop_date_key,
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
    condition_count,
    active_condition_count,
    resolved_condition_count,
    is_missing_start_date,
    is_invalid_start_date,
    is_invalid_stop_date,
    is_stop_before_start,
    condition_date_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_source_file,
    silver_load_datetime,
    gold_load_datetime
)
SELECT
    c.condition_record_id,
    dp.patient_key,
    fe.encounter_fact_key,
    dc.condition_key,
    d_start.date_key,
    d_stop.date_key,
    c.patient_id,
    c.encounter_id,
    c.condition_start_date,
    c.condition_stop_date,
    c.condition_duration_days,
    c.condition_system,
    c.condition_code,
    c.condition_description,
    c.condition_category,
    c.condition_status,
    1 AS condition_count,
    CASE WHEN c.condition_status = 'active_or_open' THEN 1 ELSE 0 END AS active_condition_count,
    CASE WHEN c.condition_status = 'resolved_or_closed' THEN 1 ELSE 0 END AS resolved_condition_count,
    c.is_missing_start_date,
    c.is_invalid_start_date,
    c.is_invalid_stop_date,
    c.is_stop_before_start,
    c.condition_date_quality_status,
    c.source_system,
    c.source_entity,
    c.bronze_ingestion_batch_id,
    c.bronze_source_file,
    c.silver_load_datetime,
    @gold_load_datetime
FROM silver.[condition] c
LEFT JOIN gold.dim_patient dp
    ON c.patient_id = dp.patient_id
LEFT JOIN gold.fact_encounter fe
    ON c.encounter_id = fe.encounter_id
LEFT JOIN gold.dim_condition dc
    ON CONCAT(
        COALESCE(c.condition_system, 'UNKNOWN'), '|',
        COALESCE(c.condition_code, 'UNKNOWN'), '|',
        COALESCE(c.condition_description, 'UNKNOWN'), '|',
        COALESCE(c.condition_category, 'UNKNOWN')
    ) = dc.condition_natural_key
LEFT JOIN gold.dim_date d_start
    ON c.condition_start_date = d_start.full_date
LEFT JOIN gold.dim_date d_stop
    ON c.condition_stop_date = d_stop.full_date;
GO

DECLARE @gold_load_datetime DATETIME2 = SYSUTCDATETIME();

INSERT INTO gold.fact_observation (
    observation_record_id,
    patient_key,
    encounter_fact_key,
    observation_key,
    observation_date_key,
    organization_key,
    provider_key,
    encounter_class_key,
    patient_id,
    encounter_id,
    organization_id,
    provider_id,
    encounter_class,
    observation_datetime_utc,
    observation_date,
    observation_category,
    observation_code,
    observation_description,
    observation_value_raw,
    observation_value_numeric,
    observation_units,
    observation_type,
    observation_count,
    numeric_observation_count,
    encounter_linked_observation_count,
    patient_level_observation_count,
    is_missing_observation_datetime,
    is_invalid_observation_datetime,
    is_missing_patient_id,
    is_missing_observation_code,
    observation_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_source_file,
    silver_load_datetime,
    gold_load_datetime
)
SELECT
    o.observation_record_id,
    dp.patient_key,
    fe.encounter_fact_key,
    dob.observation_key,
    dd.date_key,
    fe.organization_key,
    fe.provider_key,
    fe.encounter_class_key,
    o.patient_id,
    o.encounter_id,
    fe.organization_id,
    fe.provider_id,
    fe.encounter_class,
    o.observation_datetime_utc,
    o.observation_date,
    o.observation_category,
    o.observation_code,
    o.observation_description,
    o.observation_value_raw,
    o.observation_value_numeric,
    o.observation_units,
    o.observation_type,
    1 AS observation_count,
    CASE WHEN o.observation_value_numeric IS NOT NULL THEN 1 ELSE 0 END AS numeric_observation_count,
    CASE WHEN o.encounter_id IS NOT NULL THEN 1 ELSE 0 END AS encounter_linked_observation_count,
    CASE WHEN o.encounter_id IS NULL THEN 1 ELSE 0 END AS patient_level_observation_count,
    o.is_missing_observation_datetime,
    o.is_invalid_observation_datetime,
    o.is_missing_patient_id,
    o.is_missing_observation_code,
    o.observation_quality_status,
    o.source_system,
    o.source_entity,
    o.bronze_ingestion_batch_id,
    o.bronze_source_file,
    o.silver_load_datetime,
    @gold_load_datetime
FROM silver.observation o
LEFT JOIN gold.dim_patient dp
    ON o.patient_id = dp.patient_id
LEFT JOIN gold.fact_encounter fe
    ON o.encounter_id = fe.encounter_id
LEFT JOIN gold.dim_observation dob
    ON CONCAT(
        COALESCE(o.observation_category, 'UNKNOWN'), '|',
        COALESCE(o.observation_code, 'UNKNOWN'), '|',
        COALESCE(o.observation_description, 'UNKNOWN'), '|',
        COALESCE(o.observation_units, 'UNKNOWN'), '|',
        COALESCE(o.observation_type, 'UNKNOWN')
    ) = dob.observation_natural_key
LEFT JOIN gold.dim_date dd
    ON o.observation_date = dd.full_date;
GO

DECLARE @gold_load_datetime DATETIME2 = SYSUTCDATETIME();

INSERT INTO gold.fact_procedure (
    procedure_record_id,
    patient_key,
    encounter_fact_key,
    procedure_key,
    procedure_start_date_key,
    procedure_stop_date_key,
    organization_key,
    provider_key,
    encounter_class_key,
    patient_id,
    encounter_id,
    organization_id,
    provider_id,
    encounter_class,
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
    procedure_count,
    valid_procedure_count,
    is_missing_start_datetime,
    is_missing_stop_datetime,
    is_invalid_start_datetime,
    is_invalid_stop_datetime,
    is_stop_before_start,
    procedure_datetime_quality_status,
    source_system,
    source_entity,
    bronze_ingestion_batch_id,
    bronze_source_file,
    silver_load_datetime,
    gold_load_datetime
)
SELECT
    p.procedure_record_id,
    dp.patient_key,
    fe.encounter_fact_key,
    dpr.procedure_key,
    d_start.date_key,
    d_stop.date_key,
    fe.organization_key,
    fe.provider_key,
    fe.encounter_class_key,
    p.patient_id,
    p.encounter_id,
    fe.organization_id,
    fe.provider_id,
    fe.encounter_class,
    p.procedure_start_datetime_utc,
    p.procedure_stop_datetime_utc,
    p.procedure_start_date,
    p.procedure_stop_date,
    p.procedure_duration_minutes,
    p.procedure_duration_hours,
    p.procedure_system,
    p.procedure_code,
    p.procedure_description,
    p.procedure_category,
    p.base_procedure_cost,
    p.reason_code,
    p.reason_description,
    1 AS procedure_count,
    CASE
        WHEN p.procedure_datetime_quality_status = 'valid' THEN 1
        ELSE 0
    END AS valid_procedure_count,
    p.is_missing_start_datetime,
    p.is_missing_stop_datetime,
    p.is_invalid_start_datetime,
    p.is_invalid_stop_datetime,
    p.is_stop_before_start,
    p.procedure_datetime_quality_status,
    p.source_system,
    p.source_entity,
    p.bronze_ingestion_batch_id,
    p.bronze_source_file,
    p.silver_load_datetime,
    @gold_load_datetime
FROM silver.[procedure] p
LEFT JOIN gold.dim_patient dp
    ON p.patient_id = dp.patient_id
LEFT JOIN gold.fact_encounter fe
    ON p.encounter_id = fe.encounter_id
LEFT JOIN gold.dim_procedure dpr
    ON CONCAT(
        COALESCE(p.procedure_system, 'UNKNOWN'), '|',
        COALESCE(p.procedure_code, 'UNKNOWN'), '|',
        COALESCE(p.procedure_description, 'UNKNOWN'), '|',
        COALESCE(p.procedure_category, 'UNKNOWN')
    ) = dpr.procedure_natural_key
LEFT JOIN gold.dim_date d_start
    ON p.procedure_start_date = d_start.full_date
LEFT JOIN gold.dim_date d_stop
    ON p.procedure_stop_date = d_stop.full_date;
GO

DECLARE @gold_load_datetime DATETIME2 = SYSUTCDATETIME();

;WITH latest_run AS (
    SELECT TOP (1)
        quality_check_run_id
    FROM governance.quality_check_result
    GROUP BY quality_check_run_id
    ORDER BY
        MAX(persisted_datetime) DESC,
        quality_check_run_id
)
INSERT INTO gold.fact_data_quality_issue (
    quality_check_result_id,
    quality_check_run_id,
    quality_rule_id,
    rule_name,
    quality_dimension,
    target_schema,
    target_table,
    target_column,
    target_object_name,
    rule_scope,
    severity,
    owner_role,
    steward_role,
    total_records,
    passed_records,
    failed_records,
    pass_rate,
    check_status,
    quality_check_count,
    passed_check_count,
    failed_check_count,
    issue_count,
    has_quality_issue,
    critical_issue_count,
    high_issue_count,
    medium_issue_count,
    low_issue_count,
    checked_datetime,
    persisted_datetime,
    run_source,
    is_latest_run,
    source_system,
    source_entity,
    gold_load_datetime
)
SELECT
    r.quality_check_result_id,
    r.quality_check_run_id,
    r.quality_rule_id,
    r.rule_name,
    r.quality_dimension,
    r.target_schema,
    r.target_table,
    r.target_column,
    CONCAT(r.target_schema, '.', r.target_table) AS target_object_name,
    r.rule_scope,
    r.severity,
    q.owner_role,
    q.steward_role,
    r.total_records,
    r.passed_records,
    r.failed_records,
    r.pass_rate,
    r.check_status,

    1 AS quality_check_count,

    CASE
        WHEN r.check_status = 'passed' THEN 1
        ELSE 0
    END AS passed_check_count,

    CASE
        WHEN r.check_status = 'failed' THEN 1
        ELSE 0
    END AS failed_check_count,

    r.failed_records AS issue_count,

    CASE
        WHEN r.failed_records > 0 OR r.check_status = 'failed' THEN 1
        ELSE 0
    END AS has_quality_issue,

    CASE
        WHEN LOWER(r.severity) = 'critical'
         AND (r.failed_records > 0 OR r.check_status = 'failed')
        THEN r.failed_records
        ELSE 0
    END AS critical_issue_count,

    CASE
        WHEN LOWER(r.severity) = 'high'
         AND (r.failed_records > 0 OR r.check_status = 'failed')
        THEN r.failed_records
        ELSE 0
    END AS high_issue_count,

    CASE
        WHEN LOWER(r.severity) = 'medium'
         AND (r.failed_records > 0 OR r.check_status = 'failed')
        THEN r.failed_records
        ELSE 0
    END AS medium_issue_count,

    CASE
        WHEN LOWER(r.severity) = 'low'
         AND (r.failed_records > 0 OR r.check_status = 'failed')
        THEN r.failed_records
        ELSE 0
    END AS low_issue_count,

    r.checked_datetime,
    r.persisted_datetime,
    r.run_source,

    CASE
        WHEN lr.quality_check_run_id IS NOT NULL THEN 1
        ELSE 0
    END AS is_latest_run,

    'ClinicalPulse Governance' AS source_system,
    'governance.quality_check_result' AS source_entity,
    @gold_load_datetime
FROM governance.quality_check_result r
LEFT JOIN governance.quality_rule q
    ON r.quality_rule_id = q.quality_rule_id
LEFT JOIN latest_run lr
    ON r.quality_check_run_id = lr.quality_check_run_id;
GO



/*
Purpose: Create a reporting-ready patient flow mart for encounter trends and flow indicators.

Assumptions:
- The mart is implemented as a gold-layer view because it summarizes existing gold facts/dimensions.
- The mart uses encounter start date as the primary reporting date.
- unique_patients_in_group is distinct within the mart row grain and should not be summed across groups.
*/

GO

CREATE OR ALTER VIEW gold.mart_patient_flow AS
SELECT
    dd.date_key AS encounter_start_date_key,
    dd.full_date AS encounter_start_date,
    dd.calendar_year,
    dd.calendar_quarter,
    dd.calendar_month,
    dd.calendar_month_name,
    dd.week_of_year,
    dd.day_of_week,
    dd.day_name,
    dd.is_weekend,

    dorg.organization_key,
    dorg.organization_id,
    COALESCE(dorg.organization_name, dorg.organization_id, 'Unknown Organization') AS organization_display_name,
    dorg.organization_source_status,

    dprov.provider_key,
    dprov.provider_id,
    COALESCE(dprov.provider_name, dprov.provider_id, 'Unknown Provider') AS provider_display_name,
    dprov.provider_source_status,

    dec.encounter_class_key,
    dec.encounter_class,
    dec.encounter_class_display,
    dec.encounter_class_group,
    dec.is_inpatient,
    dec.is_emergency,
    dec.is_ambulatory,

    dp.age_band AS patient_age_band,
    dp.gender AS patient_gender,
    dp.race AS patient_race,
    dp.ethnicity AS patient_ethnicity,
    dp.state AS patient_state,
    dp.county AS patient_county,

    fe.encounter_datetime_quality_status,

    SUM(fe.encounter_count) AS total_encounters,
    SUM(fe.valid_encounter_count) AS valid_encounters,
    COUNT(DISTINCT fe.patient_key) AS unique_patients_in_group,

    SUM(CASE WHEN fe.length_of_stay_days IS NOT NULL THEN 1 ELSE 0 END) AS encounters_with_los,
    SUM(CASE WHEN fe.length_of_stay_days IS NULL THEN 1 ELSE 0 END) AS encounters_without_los,

    CAST(AVG(CAST(fe.length_of_stay_days AS DECIMAL(18,4))) AS DECIMAL(18,4)) AS average_los_days,
    CAST(SUM(COALESCE(fe.length_of_stay_days, 0)) AS DECIMAL(18,4)) AS total_los_days,
    SUM(COALESCE(fe.encounter_duration_minutes, 0)) AS total_encounter_duration_minutes,

    SUM(CASE WHEN fe.length_of_stay_days < 1 THEN 1 ELSE 0 END) AS same_day_encounters,
    SUM(CASE WHEN fe.length_of_stay_days >= 1 THEN 1 ELSE 0 END) AS multi_day_encounters,

    SUM(CASE WHEN fe.is_missing_start_datetime = 1 THEN 1 ELSE 0 END) AS missing_start_datetime_encounters,
    SUM(CASE WHEN fe.is_missing_stop_datetime = 1 THEN 1 ELSE 0 END) AS missing_stop_datetime_encounters,
    SUM(CASE WHEN fe.is_stop_before_start = 1 THEN 1 ELSE 0 END) AS stop_before_start_encounters,

    MAX(fe.gold_load_datetime) AS latest_gold_load_datetime
FROM gold.fact_encounter fe
LEFT JOIN gold.dim_date dd
    ON fe.encounter_start_date_key = dd.date_key
LEFT JOIN gold.dim_patient dp
    ON fe.patient_key = dp.patient_key
LEFT JOIN gold.dim_organization dorg
    ON fe.organization_key = dorg.organization_key
LEFT JOIN gold.dim_provider dprov
    ON fe.provider_key = dprov.provider_key
LEFT JOIN gold.dim_encounter_class dec
    ON fe.encounter_class_key = dec.encounter_class_key
GROUP BY
    dd.date_key,
    dd.full_date,
    dd.calendar_year,
    dd.calendar_quarter,
    dd.calendar_month,
    dd.calendar_month_name,
    dd.week_of_year,
    dd.day_of_week,
    dd.day_name,
    dd.is_weekend,

    dorg.organization_key,
    dorg.organization_id,
    COALESCE(dorg.organization_name, dorg.organization_id, 'Unknown Organization'),
    dorg.organization_source_status,

    dprov.provider_key,
    dprov.provider_id,
    COALESCE(dprov.provider_name, dprov.provider_id, 'Unknown Provider'),
    dprov.provider_source_status,

    dec.encounter_class_key,
    dec.encounter_class,
    dec.encounter_class_display,
    dec.encounter_class_group,
    dec.is_inpatient,
    dec.is_emergency,
    dec.is_ambulatory,

    dp.age_band,
    dp.gender,
    dp.race,
    dp.ethnicity,
    dp.state,
    dp.county,

    fe.encounter_datetime_quality_status;
GO



/*
Purpose: Create reporting-ready marts for LOS and 30-day readmission reporting.

Assumptions:
- mart_length_of_stay is encounter-grain so Power BI can calculate average and median LOS correctly.
- mart_readmissions is index-encounter-grain so 30-day readmission numerator and denominator aggregate consistently.
- Readmission logic uses the next encounter for the same patient after index encounter stop time.
- Planned versus unplanned readmission classification is not available in the current model.
*/

GO

CREATE OR ALTER VIEW gold.mart_length_of_stay AS
WITH condition_summary AS (
    SELECT
        encounter_fact_key,
        COUNT(*) AS condition_record_count,
        COUNT(DISTINCT COALESCE(condition_category, 'Unknown')) AS distinct_condition_category_count,
        MIN(COALESCE(condition_category, 'Unknown')) AS representative_condition_category
    FROM gold.fact_condition
    WHERE encounter_fact_key IS NOT NULL
    GROUP BY encounter_fact_key
),
procedure_summary AS (
    SELECT
        encounter_fact_key,
        COUNT(*) AS procedure_record_count,
        COUNT(DISTINCT COALESCE(procedure_category, 'Unknown')) AS distinct_procedure_category_count,
        MIN(COALESCE(procedure_category, 'Unknown')) AS representative_procedure_category
    FROM gold.fact_procedure
    WHERE encounter_fact_key IS NOT NULL
    GROUP BY encounter_fact_key
)
SELECT
    fe.encounter_fact_key,
    fe.patient_key,

    fe.encounter_start_date_key,
    dstart.full_date AS encounter_start_date,
    dstart.calendar_year AS encounter_start_year,
    dstart.calendar_quarter AS encounter_start_quarter,
    dstart.calendar_month AS encounter_start_month,
    dstart.calendar_month_name AS encounter_start_month_name,
    dstart.week_of_year AS encounter_start_week_of_year,

    fe.encounter_stop_date_key,
    dstop.full_date AS encounter_stop_date,

    fe.organization_key,
    dorg.organization_id,
    COALESCE(dorg.organization_name, dorg.organization_id, 'Unknown Organization') AS organization_display_name,

    fe.provider_key,
    dprov.provider_id,
    COALESCE(dprov.provider_name, dprov.provider_id, 'Unknown Provider') AS provider_display_name,

    fe.encounter_class_key,
    dec.encounter_class,
    dec.encounter_class_display,
    dec.encounter_class_group,
    dec.is_inpatient,
    dec.is_emergency,
    dec.is_ambulatory,

    dp.age_band AS patient_age_band,
    dp.gender AS patient_gender,
    dp.race AS patient_race,
    dp.ethnicity AS patient_ethnicity,
    dp.state AS patient_state,
    dp.county AS patient_county,

    COALESCE(cs.condition_record_count, 0) AS condition_record_count,
    COALESCE(cs.distinct_condition_category_count, 0) AS distinct_condition_category_count,
    COALESCE(cs.representative_condition_category, 'No linked condition') AS representative_condition_category,

    COALESCE(ps.procedure_record_count, 0) AS procedure_record_count,
    COALESCE(ps.distinct_procedure_category_count, 0) AS distinct_procedure_category_count,
    COALESCE(ps.representative_procedure_category, 'No linked procedure') AS representative_procedure_category,

    fe.encounter_start_datetime_utc,
    fe.encounter_stop_datetime_utc,
    fe.encounter_duration_minutes,
    fe.encounter_duration_hours,
    fe.length_of_stay_days,

    fe.encounter_count AS total_encounters,
    fe.valid_encounter_count AS valid_encounters,

    CASE
        WHEN fe.valid_encounter_count = 1
         AND fe.length_of_stay_days IS NOT NULL
        THEN 1
        ELSE 0
    END AS los_eligible_encounter_count,

    CAST(
        CASE
            WHEN fe.valid_encounter_count = 1
             AND fe.length_of_stay_days IS NOT NULL
            THEN fe.length_of_stay_days
            ELSE 0
        END AS DECIMAL(18,4)
    ) AS los_days_numerator,

    CASE
        WHEN fe.valid_encounter_count = 1
         AND fe.length_of_stay_days IS NOT NULL
         AND fe.length_of_stay_days < 1
        THEN 1
        ELSE 0
    END AS same_day_encounter_count,

    CASE
        WHEN fe.valid_encounter_count = 1
         AND fe.length_of_stay_days IS NOT NULL
         AND fe.length_of_stay_days >= 1
        THEN 1
        ELSE 0
    END AS multi_day_encounter_count,

    CASE
        WHEN fe.valid_encounter_count = 1
         AND fe.length_of_stay_days >= 7
        THEN 1
        ELSE 0
    END AS long_stay_encounter_count,

    CASE
        WHEN fe.valid_encounter_count <> 1 OR fe.length_of_stay_days IS NULL THEN 'Not LOS eligible'
        WHEN fe.length_of_stay_days < 1 THEN '<1 day'
        WHEN fe.length_of_stay_days < 3 THEN '1-2 days'
        WHEN fe.length_of_stay_days < 8 THEN '3-7 days'
        WHEN fe.length_of_stay_days < 15 THEN '8-14 days'
        ELSE '15+ days'
    END AS los_bucket,

    fe.is_missing_start_datetime,
    fe.is_missing_stop_datetime,
    fe.is_stop_before_start,
    fe.encounter_datetime_quality_status,

    fe.gold_load_datetime AS latest_gold_load_datetime
FROM gold.fact_encounter fe
LEFT JOIN gold.dim_date dstart
    ON fe.encounter_start_date_key = dstart.date_key
LEFT JOIN gold.dim_date dstop
    ON fe.encounter_stop_date_key = dstop.date_key
LEFT JOIN gold.dim_patient dp
    ON fe.patient_key = dp.patient_key
LEFT JOIN gold.dim_organization dorg
    ON fe.organization_key = dorg.organization_key
LEFT JOIN gold.dim_provider dprov
    ON fe.provider_key = dprov.provider_key
LEFT JOIN gold.dim_encounter_class dec
    ON fe.encounter_class_key = dec.encounter_class_key
LEFT JOIN condition_summary cs
    ON fe.encounter_fact_key = cs.encounter_fact_key
LEFT JOIN procedure_summary ps
    ON fe.encounter_fact_key = ps.encounter_fact_key;
GO

CREATE OR ALTER VIEW gold.mart_readmissions AS
WITH condition_summary AS (
    SELECT
        encounter_fact_key,
        COUNT(*) AS index_condition_record_count,
        COUNT(DISTINCT COALESCE(condition_category, 'Unknown')) AS index_distinct_condition_category_count,
        MIN(COALESCE(condition_category, 'Unknown')) AS representative_index_condition_category
    FROM gold.fact_condition
    WHERE encounter_fact_key IS NOT NULL
    GROUP BY encounter_fact_key
)
SELECT
    r.readmission_fact_key,

    r.index_encounter_fact_key,
    r.patient_key,

    r.index_start_date_key,
    dindex_start.full_date AS index_encounter_start_date,
    dindex_start.calendar_year AS index_start_year,
    dindex_start.calendar_quarter AS index_start_quarter,
    dindex_start.calendar_month AS index_start_month,
    dindex_start.calendar_month_name AS index_start_month_name,

    r.index_stop_date_key,
    dindex_stop.full_date AS index_encounter_stop_date,

    r.index_organization_key AS organization_key,
    dorg.organization_id,
    COALESCE(dorg.organization_name, dorg.organization_id, 'Unknown Organization') AS organization_display_name,

    r.index_provider_key AS provider_key,
    dprov.provider_id,
    COALESCE(dprov.provider_name, dprov.provider_id, 'Unknown Provider') AS provider_display_name,

    r.index_encounter_class_key AS encounter_class_key,
    dec.encounter_class,
    dec.encounter_class_display,
    dec.encounter_class_group,
    dec.is_inpatient,
    dec.is_emergency,
    dec.is_ambulatory,

    dp.age_band AS patient_age_band,
    dp.gender AS patient_gender,
    dp.race AS patient_race,
    dp.ethnicity AS patient_ethnicity,
    dp.state AS patient_state,
    dp.county AS patient_county,

    COALESCE(cs.index_condition_record_count, 0) AS index_condition_record_count,
    COALESCE(cs.index_distinct_condition_category_count, 0) AS index_distinct_condition_category_count,
    COALESCE(cs.representative_index_condition_category, 'No linked condition') AS representative_index_condition_category,

    r.index_encounter_start_datetime_utc,
    r.index_encounter_stop_datetime_utc,

    r.readmission_encounter_fact_key,
    r.readmission_start_date_key,
    dreadmit_start.full_date AS readmission_start_date,
    r.readmission_start_datetime_utc,

    readmit_fe.encounter_class AS readmission_encounter_class,
    readmit_dec.encounter_class_group AS readmission_encounter_class_group,

    r.days_to_readmission,
    r.hours_to_readmission,

    r.eligible_encounter_count AS readmission_rate_denominator,
    r.readmission_30_day_count AS readmission_rate_numerator,
    r.is_30_day_readmission,
    r.readmission_window_days,

    CASE
        WHEN r.readmission_encounter_fact_key IS NULL THEN 1
        ELSE 0
    END AS no_subsequent_encounter_count,

    CASE
        WHEN r.readmission_encounter_fact_key IS NOT NULL
         AND r.is_30_day_readmission = 0
        THEN 1
        ELSE 0
    END AS subsequent_encounter_after_30_days_count,

    r.readmission_logic_status,

    r.gold_load_datetime AS latest_gold_load_datetime
FROM gold.fact_readmission r
LEFT JOIN gold.dim_date dindex_start
    ON r.index_start_date_key = dindex_start.date_key
LEFT JOIN gold.dim_date dindex_stop
    ON r.index_stop_date_key = dindex_stop.date_key
LEFT JOIN gold.dim_date dreadmit_start
    ON r.readmission_start_date_key = dreadmit_start.date_key
LEFT JOIN gold.dim_patient dp
    ON r.patient_key = dp.patient_key
LEFT JOIN gold.dim_organization dorg
    ON r.index_organization_key = dorg.organization_key
LEFT JOIN gold.dim_provider dprov
    ON r.index_provider_key = dprov.provider_key
LEFT JOIN gold.dim_encounter_class dec
    ON r.index_encounter_class_key = dec.encounter_class_key
LEFT JOIN gold.fact_encounter readmit_fe
    ON r.readmission_encounter_fact_key = readmit_fe.encounter_fact_key
LEFT JOIN gold.dim_encounter_class readmit_dec
    ON readmit_fe.encounter_class_key = readmit_dec.encounter_class_key
LEFT JOIN condition_summary cs
    ON r.index_encounter_fact_key = cs.encounter_fact_key;
GO
