USE ClinicalPulse;
GO

DROP TABLE IF EXISTS silver.patient;
GO

CREATE TABLE silver.patient (
    patient_id  NVARCHAR(100) NOT NULL,

    birth_date  DATE NULL,
    death_date  DATE NULL,
    is_deceased BIT  NOT NULL,

    age_reference_date DATE         NOT NULL,
    age_reference_type NVARCHAR(30) NOT NULL,
    age_years          INT          NULL,
    age_band           NVARCHAR(20) NULL,

    gender         NVARCHAR(50)  NULL,
    race           NVARCHAR(100) NULL,
    ethnicity      NVARCHAR(100) NULL,
    marital_status NVARCHAR(50)  NULL,

    city      NVARCHAR(100)   NULL,
    [state]   NVARCHAR(100)   NULL,
    county    NVARCHAR(100)   NULL,
    fips      NVARCHAR(50)    NULL,
    zip       NVARCHAR(20)    NULL,
    latitude  DECIMAL(18, 12) NULL,
    longitude DECIMAL(18, 12) NULL,

    healthcare_expenses DECIMAL(18, 2) NULL,
    healthcare_coverage DECIMAL(18, 2) NULL,
    income INT NULL,

    patient_date_quality_status NVARCHAR(50) NOT NULL,

    source_system             NVARCHAR(100) NOT NULL,
    source_entity             NVARCHAR(100) NOT NULL,
    bronze_ingestion_batch_id BIGINT        NULL,
    bronze_ingestion_datetime DATETIME2     NULL,
    bronze_source_file        NVARCHAR(255) NULL,
    bronze_row_hash           VARBINARY(32) NULL,
    bronze_load_status        NVARCHAR(30)  NULL,

    silver_load_datetime DATETIME2 NOT NULL
        CONSTRAINT DF_silver_patient_silver_load_datetime
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_silver_patient
        PRIMARY KEY (patient_id),

    CONSTRAINT CK_silver_patient_is_deceased
        CHECK (is_deceased IN (0, 1)),

    CONSTRAINT CK_silver_patient_age_years
        CHECK (age_years IS NULL OR age_years >= 0)
);
GO


DROP TABLE IF EXISTS silver.encounter;
GO

CREATE TABLE silver.encounter (
    encounter_id NVARCHAR(100) NOT NULL,

    patient_id      NVARCHAR(100) NULL,
    organization_id NVARCHAR(100) NULL,
    provider_id     NVARCHAR(100) NULL,
    payer_id        NVARCHAR(100) NULL,

    encounter_start_datetime_utc DATETIME2(0) NULL,
    encounter_stop_datetime_utc  DATETIME2(0) NULL,
    encounter_start_date         DATE         NULL,
    encounter_stop_date          DATE         NULL,

    encounter_duration_minutes BIGINT         NULL,
    encounter_duration_hours   DECIMAL(18, 2) NULL,
    length_of_stay_days        DECIMAL(18, 4) NULL,

    encounter_class       NVARCHAR(100) NULL,
    encounter_code        NVARCHAR(100) NULL,
    encounter_description NVARCHAR(255) NULL,
 
    base_encounter_cost DECIMAL(18, 2) NULL,
    total_claim_cost    DECIMAL(18, 2) NULL,
    payer_coverage      DECIMAL(18, 2) NULL,

    reason_code        NVARCHAR(100) NULL,
    reason_description NVARCHAR(255) NULL,

    is_missing_start_datetime BIT NOT NULL,
    is_missing_stop_datetime  BIT NOT NULL,
    is_invalid_start_datetime BIT NOT NULL,
    is_invalid_stop_datetime  BIT NOT NULL,
    is_stop_before_start      BIT NOT NULL,
    encounter_datetime_quality_status NVARCHAR(50) NOT NULL,

    source_system             NVARCHAR(100) NOT NULL,
    source_entity             NVARCHAR(100) NOT NULL,
    bronze_ingestion_batch_id BIGINT        NULL,
    bronze_ingestion_datetime DATETIME2     NULL,
    bronze_source_file        NVARCHAR(255) NULL,
    bronze_row_hash           VARBINARY(32) NULL,
    bronze_load_status        NVARCHAR(30)  NULL,

    silver_load_datetime DATETIME2 NOT NULL
        CONSTRAINT DF_silver_encounter_silver_load_datetime
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_silver_encounter
        PRIMARY KEY (encounter_id),

    CONSTRAINT CK_silver_encounter_datetime_flags
        CHECK (
            is_missing_start_datetime IN (0, 1)
            AND is_missing_stop_datetime IN (0, 1)
            AND is_invalid_start_datetime IN (0, 1)
            AND is_invalid_stop_datetime IN (0, 1)
            AND is_stop_before_start IN (0, 1)
        ),

    CONSTRAINT CK_silver_encounter_duration_minutes
        CHECK (encounter_duration_minutes IS NULL OR encounter_duration_minutes >= 0),

    CONSTRAINT CK_silver_encounter_duration_hours
        CHECK (encounter_duration_hours IS NULL OR encounter_duration_hours >= 0),

    CONSTRAINT CK_silver_encounter_los_days
        CHECK (length_of_stay_days IS NULL OR length_of_stay_days >= 0)
);
GO


DROP TABLE IF EXISTS silver.condition;
GO

CREATE TABLE silver.condition (
    condition_record_id BIGINT IDENTITY(1,1) NOT NULL,
    patient_id NVARCHAR(100) NULL,
    encounter_id NVARCHAR(100) NULL,

    condition_start_date DATE NULL,
    condition_stop_date DATE NULL,
    condition_duration_days INT NULL,

    condition_system NVARCHAR(255) NULL,
    condition_code NVARCHAR(100) NULL,
    condition_description NVARCHAR(255) NULL,
    condition_category NVARCHAR(100) NULL,
    condition_status NVARCHAR(30) NOT NULL,

    is_missing_start_date BIT NOT NULL,
    is_invalid_start_date BIT NOT NULL,
    is_invalid_stop_date BIT NOT NULL,
    is_stop_before_start BIT NOT NULL,
    condition_date_quality_status NVARCHAR(50) NOT NULL,

    source_system NVARCHAR(100) NOT NULL,
    source_entity NVARCHAR(100) NOT NULL,
    bronze_ingestion_batch_id BIGINT NULL,
    bronze_ingestion_datetime DATETIME2 NULL,
    bronze_source_file NVARCHAR(255) NULL,
    bronze_row_hash VARBINARY(32) NULL,
    bronze_load_status NVARCHAR(30) NULL,

    silver_load_datetime DATETIME2 NOT NULL
        CONSTRAINT DF_silver_condition_silver_load_datetime
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_silver_condition
        PRIMARY KEY (condition_record_id),

    CONSTRAINT CK_silver_condition_flags
        CHECK (
            is_missing_start_date IN (0, 1)
            AND is_invalid_start_date IN (0, 1)
            AND is_invalid_stop_date IN (0, 1)
            AND is_stop_before_start IN (0, 1)
        ),

    CONSTRAINT CK_silver_condition_duration_days
        CHECK (condition_duration_days IS NULL OR condition_duration_days >= 0)
);
GO


DROP TABLE IF EXISTS silver.[procedure];
GO

CREATE TABLE silver.[procedure] (
    procedure_record_id BIGINT IDENTITY(1,1) NOT NULL,
    patient_id NVARCHAR(100) NULL,
    encounter_id NVARCHAR(100) NULL,

    procedure_start_datetime_utc DATETIME2(0) NULL,
    procedure_stop_datetime_utc DATETIME2(0) NULL,
    procedure_start_date DATE NULL,
    procedure_stop_date DATE NULL,

    procedure_duration_minutes BIGINT NULL,
    procedure_duration_hours DECIMAL(18, 2) NULL,

    procedure_system NVARCHAR(255) NULL,
    procedure_code NVARCHAR(100) NULL,
    procedure_description NVARCHAR(255) NULL,
    procedure_category NVARCHAR(100) NULL,
    base_procedure_cost DECIMAL(18, 2) NULL,

    reason_code NVARCHAR(100) NULL,
    reason_description NVARCHAR(255) NULL,

    is_missing_start_datetime BIT NOT NULL,
    is_missing_stop_datetime BIT NOT NULL,
    is_invalid_start_datetime BIT NOT NULL,
    is_invalid_stop_datetime BIT NOT NULL,
    is_stop_before_start BIT NOT NULL,
    procedure_datetime_quality_status NVARCHAR(50) NOT NULL,

    source_system NVARCHAR(100) NOT NULL,
    source_entity NVARCHAR(100) NOT NULL,
    bronze_ingestion_batch_id BIGINT NULL,
    bronze_ingestion_datetime DATETIME2 NULL,
    bronze_source_file NVARCHAR(255) NULL,
    bronze_row_hash VARBINARY(32) NULL,
    bronze_load_status NVARCHAR(30) NULL,

    silver_load_datetime DATETIME2 NOT NULL
        CONSTRAINT DF_silver_procedure_silver_load_datetime
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_silver_procedure
        PRIMARY KEY (procedure_record_id),

    CONSTRAINT CK_silver_procedure_flags
        CHECK (
            is_missing_start_datetime IN (0, 1)
            AND is_missing_stop_datetime IN (0, 1)
            AND is_invalid_start_datetime IN (0, 1)
            AND is_invalid_stop_datetime IN (0, 1)
            AND is_stop_before_start IN (0, 1)
        ),

    CONSTRAINT CK_silver_procedure_duration_minutes
        CHECK (procedure_duration_minutes IS NULL OR procedure_duration_minutes >= 0),

    CONSTRAINT CK_silver_procedure_duration_hours
        CHECK (procedure_duration_hours IS NULL OR procedure_duration_hours >= 0)
);
GO


DROP TABLE IF EXISTS silver.observation;
GO

CREATE TABLE silver.observation (
    observation_record_id BIGINT IDENTITY(1,1) NOT NULL,
    patient_id NVARCHAR(100) NULL,
    encounter_id NVARCHAR(100) NULL,

    observation_datetime_utc DATETIME2(0) NULL,
    observation_date DATE NULL,

    observation_category NVARCHAR(100) NULL,
    observation_code NVARCHAR(100) NULL,
    observation_description NVARCHAR(255) NULL,
    observation_value_raw NVARCHAR(255) NULL,
    observation_value_numeric DECIMAL(18, 6) NULL,
    observation_units NVARCHAR(100) NULL,
    observation_type NVARCHAR(100) NULL,

    is_missing_observation_datetime BIT NOT NULL,
    is_invalid_observation_datetime BIT NOT NULL,
    is_missing_patient_id BIT NOT NULL,
    is_missing_observation_code BIT NOT NULL,
    observation_quality_status NVARCHAR(50) NOT NULL,

    source_system NVARCHAR(100) NOT NULL,
    source_entity NVARCHAR(100) NOT NULL,
    bronze_ingestion_batch_id BIGINT NULL,
    bronze_ingestion_datetime DATETIME2 NULL,
    bronze_source_file NVARCHAR(255) NULL,
    bronze_row_hash VARBINARY(32) NULL,
    bronze_load_status NVARCHAR(30) NULL,

    silver_load_datetime DATETIME2 NOT NULL
        CONSTRAINT DF_silver_observation_silver_load_datetime
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_silver_observation
        PRIMARY KEY (observation_record_id),

    CONSTRAINT CK_silver_observation_flags
        CHECK (
            is_missing_observation_datetime IN (0, 1)
            AND is_invalid_observation_datetime IN (0, 1)
            AND is_missing_patient_id IN (0, 1)
            AND is_missing_observation_code IN (0, 1)
        )
);
GO
