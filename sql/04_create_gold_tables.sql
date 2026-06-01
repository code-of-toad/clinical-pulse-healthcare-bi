/*
ClinicalPulse

Purpose: Create gold-layer dimension tables for reporting-ready Power BI models.

Notes:
- Gold dimensions are sourced from the current silver layer.
- Patient direct identifiers are not included in gold dimensions.
- Organization and provider dimensions are lightweight reference dimensions built from silver.encounter until dedicated silver organization/provider tables exist.
*/

USE ClinicalPulse;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    EXEC('CREATE SCHEMA gold');
END;
GO

DROP TABLE IF EXISTS gold.fact_readmission;
DROP TABLE IF EXISTS gold.fact_encounter;
GO

DROP TABLE IF EXISTS [gold].[dim_procedure];
DROP TABLE IF EXISTS [gold].[dim_observation];
DROP TABLE IF EXISTS [gold].[dim_condition];
DROP TABLE IF EXISTS [gold].[dim_encounter_class];
DROP TABLE IF EXISTS [gold].[dim_provider];
DROP TABLE IF EXISTS [gold].[dim_organization];
DROP TABLE IF EXISTS [gold].[dim_patient];
DROP TABLE IF EXISTS [gold].[dim_date];
GO

CREATE TABLE [gold].[dim_patient] (
    patient_key INT IDENTITY(1,1) NOT NULL CONSTRAINT [pk_dim_patient] PRIMARY KEY,
    patient_id NVARCHAR(100) NOT NULL,
    birth_date DATE NULL,
    death_date DATE NULL,
    is_deceased BIT NOT NULL,
    age_reference_date DATE NOT NULL,
    age_reference_type NVARCHAR(30) NOT NULL,
    age_years INT NULL,
    age_band NVARCHAR(20) NULL,
    age_band_sort_order INT NULL,
    gender NVARCHAR(50) NULL,
    race NVARCHAR(100) NULL,
    ethnicity NVARCHAR(100) NULL,
    marital_status NVARCHAR(50) NULL,
    city NVARCHAR(100) NULL,
    state NVARCHAR(100) NULL,
    county NVARCHAR(100) NULL,
    fips NVARCHAR(50) NULL,
    zip NVARCHAR(20) NULL,
    patient_date_quality_status NVARCHAR(50) NOT NULL,
    source_system NVARCHAR(100) NOT NULL,
    source_entity NVARCHAR(100) NOT NULL,
    bronze_ingestion_batch_id BIGINT NULL,
    bronze_source_file NVARCHAR(255) NULL,
    silver_load_datetime DATETIME2 NOT NULL,
    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT [df_dim_patient_gold_load_datetime] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [uq_dim_patient_patient_id] UNIQUE (patient_id)
);
GO

CREATE TABLE [gold].[dim_date] (
    date_key INT NOT NULL CONSTRAINT [pk_dim_date] PRIMARY KEY,
    full_date DATE NOT NULL,
    calendar_year INT NOT NULL,
    calendar_quarter INT NOT NULL,
    calendar_month INT NOT NULL,
    calendar_month_name NVARCHAR(20) NOT NULL,
    year_month NVARCHAR(7) NOT NULL,
    month_start_date DATE NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name NVARCHAR(20) NOT NULL,
    week_of_year INT NOT NULL,
    is_weekend BIT NOT NULL,

    CONSTRAINT [uq_dim_date_full_date] UNIQUE (full_date)
);
GO

CREATE TABLE [gold].[dim_organization] (
    organization_key INT IDENTITY(1,1) NOT NULL CONSTRAINT [pk_dim_organization] PRIMARY KEY,
    organization_id NVARCHAR(100) NOT NULL,
    organization_name NVARCHAR(255) NULL,
    organization_source_status NVARCHAR(50) NOT NULL,
    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT [df_dim_organization_gold_load_datetime] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [uq_dim_organization_organization_id] UNIQUE (organization_id)
);
GO

CREATE TABLE [gold].[dim_provider] (
    provider_key INT IDENTITY(1,1) NOT NULL CONSTRAINT [pk_dim_provider] PRIMARY KEY,
    provider_id NVARCHAR(100) NOT NULL,
    provider_name NVARCHAR(255) NULL,
    provider_source_status NVARCHAR(50) NOT NULL,
    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT [df_dim_provider_gold_load_datetime] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [uq_dim_provider_provider_id] UNIQUE (provider_id)
);
GO

CREATE TABLE [gold].[dim_encounter_class] (
    encounter_class_key INT IDENTITY(1,1) NOT NULL CONSTRAINT [pk_dim_encounter_class] PRIMARY KEY,
    encounter_class NVARCHAR(100) NOT NULL,
    encounter_class_display NVARCHAR(100) NOT NULL,
    encounter_class_group NVARCHAR(100) NOT NULL,
    is_inpatient BIT NOT NULL,
    is_emergency BIT NOT NULL,
    is_ambulatory BIT NOT NULL,
    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT [df_dim_encounter_class_gold_load_datetime] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [uq_dim_encounter_class] UNIQUE (encounter_class)
);
GO

CREATE TABLE [gold].[dim_condition] (
    condition_key INT IDENTITY(1,1) NOT NULL CONSTRAINT [pk_dim_condition] PRIMARY KEY,
    condition_natural_key NVARCHAR(1000) NOT NULL,
    condition_natural_key_hash VARBINARY(32) NOT NULL,
    condition_system NVARCHAR(255) NULL,
    condition_code NVARCHAR(100) NULL,
    condition_description NVARCHAR(255) NULL,
    condition_category NVARCHAR(100) NULL,
    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT [df_dim_condition_gold_load_datetime] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [uq_dim_condition_natural_key_hash] UNIQUE (condition_natural_key_hash)
);
GO

CREATE TABLE [gold].[dim_observation] (
    observation_key INT IDENTITY(1,1) NOT NULL CONSTRAINT [pk_dim_observation] PRIMARY KEY,
    observation_natural_key NVARCHAR(1200) NOT NULL,
    observation_natural_key_hash VARBINARY(32) NOT NULL,
    observation_category NVARCHAR(100) NULL,
    observation_code NVARCHAR(100) NULL,
    observation_description NVARCHAR(255) NULL,
    observation_units NVARCHAR(100) NULL,
    observation_type NVARCHAR(100) NULL,
    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT [df_dim_observation_gold_load_datetime] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [uq_dim_observation_natural_key_hash] UNIQUE (observation_natural_key_hash)
);
GO

CREATE TABLE [gold].[dim_procedure] (
    procedure_key INT IDENTITY(1,1) NOT NULL CONSTRAINT [pk_dim_procedure] PRIMARY KEY,
    procedure_natural_key NVARCHAR(1000) NOT NULL,
    procedure_natural_key_hash VARBINARY(32) NOT NULL,
    procedure_system NVARCHAR(255) NULL,
    procedure_code NVARCHAR(100) NULL,
    procedure_description NVARCHAR(255) NULL,
    procedure_category NVARCHAR(100) NULL,
    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT [df_dim_procedure_gold_load_datetime] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [uq_dim_procedure_natural_key_hash] UNIQUE (procedure_natural_key_hash)
);
GO

CREATE TABLE gold.fact_encounter (
    encounter_fact_key INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_fact_encounter PRIMARY KEY,

    encounter_id NVARCHAR(100) NOT NULL,

    patient_key INT NULL,
    encounter_start_date_key INT NULL,
    encounter_stop_date_key INT NULL,
    organization_key INT NULL,
    provider_key INT NULL,
    encounter_class_key INT NULL,

    patient_id NVARCHAR(100) NULL,
    organization_id NVARCHAR(100) NULL,
    provider_id NVARCHAR(100) NULL,
    payer_id NVARCHAR(100) NULL,

    encounter_start_datetime_utc DATETIME2 NULL,
    encounter_stop_datetime_utc DATETIME2 NULL,
    encounter_duration_minutes BIGINT NULL,
    encounter_duration_hours DECIMAL(18,2) NULL,
    length_of_stay_days DECIMAL(18,4) NULL,

    encounter_class NVARCHAR(100) NULL,
    encounter_code NVARCHAR(100) NULL,
    encounter_description NVARCHAR(255) NULL,

    base_encounter_cost DECIMAL(18,2) NULL,
    total_claim_cost DECIMAL(18,2) NULL,
    payer_coverage DECIMAL(18,2) NULL,

    reason_code NVARCHAR(100) NULL,
    reason_description NVARCHAR(255) NULL,

    encounter_count INT NOT NULL,
    valid_encounter_count INT NOT NULL,

    is_missing_start_datetime BIT NOT NULL,
    is_missing_stop_datetime BIT NOT NULL,
    is_invalid_start_datetime BIT NOT NULL,
    is_invalid_stop_datetime BIT NOT NULL,
    is_stop_before_start BIT NOT NULL,
    encounter_datetime_quality_status NVARCHAR(50) NOT NULL,

    source_system NVARCHAR(100) NOT NULL,
    source_entity NVARCHAR(100) NOT NULL,
    bronze_ingestion_batch_id BIGINT NULL,
    bronze_source_file NVARCHAR(255) NULL,
    silver_load_datetime DATETIME2 NOT NULL,
    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT df_fact_encounter_gold_load_datetime DEFAULT SYSUTCDATETIME(),

    CONSTRAINT uq_fact_encounter_encounter_id UNIQUE (encounter_id)
);
GO

CREATE TABLE gold.fact_readmission (
    readmission_fact_key INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_fact_readmission PRIMARY KEY,

    index_encounter_fact_key INT NOT NULL,
    index_encounter_id NVARCHAR(100) NOT NULL,

    patient_key INT NULL,
    patient_id NVARCHAR(100) NULL,

    index_encounter_start_datetime_utc DATETIME2 NULL,
    index_encounter_stop_datetime_utc DATETIME2 NULL,
    index_start_date_key INT NULL,
    index_stop_date_key INT NULL,
    index_organization_key INT NULL,
    index_provider_key INT NULL,
    index_encounter_class_key INT NULL,

    readmission_encounter_fact_key INT NULL,
    readmission_encounter_id NVARCHAR(100) NULL,
    readmission_start_datetime_utc DATETIME2 NULL,
    readmission_start_date_key INT NULL,

    days_to_readmission INT NULL,
    hours_to_readmission DECIMAL(18,2) NULL,

    eligible_encounter_count INT NOT NULL,
    readmission_30_day_count INT NOT NULL,
    is_30_day_readmission BIT NOT NULL,
    readmission_window_days INT NOT NULL,
    readmission_logic_status NVARCHAR(100) NOT NULL,

    gold_load_datetime DATETIME2 NOT NULL CONSTRAINT df_fact_readmission_gold_load_datetime DEFAULT SYSUTCDATETIME()
);
GO
