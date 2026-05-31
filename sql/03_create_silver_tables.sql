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
