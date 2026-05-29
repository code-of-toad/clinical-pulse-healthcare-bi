/*
    ClinicalPulse

    Purpose:
    Create the first bronze-layer tables for core demographic and organizational
    Synthea source entities.

    Tables:
    - bronze.patients
    - bronze.organizations
    - bronze.providers
    - bronze.encounters
    - bronze.conditions
    - bronze.observations
    - bronze.procedures

    Assumptions:
    - These bronze tables are source-preserving staging tables for Synthea CSV data.
    - Source values are stored as NVARCHAR to avoid irreversible parsing decisions in bronze.
    - Datetime, numeric, category, and business-rule standardization will occur in silver.
*/

USE [ClinicalPulse];
GO

IF OBJECT_ID(N'bronze.patients', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.patients (
        source_patient_id NVARCHAR(100) NULL,
        birthdate NVARCHAR(50) NULL,
        deathdate NVARCHAR(50) NULL,
        ssn NVARCHAR(50) NULL,
        drivers NVARCHAR(50) NULL,
        passport NVARCHAR(50) NULL,
        prefix NVARCHAR(50) NULL,
        first_name NVARCHAR(100) NULL,
        last_name NVARCHAR(100) NULL,
        suffix NVARCHAR(50) NULL,
        maiden NVARCHAR(100) NULL,
        marital NVARCHAR(50) NULL,
        race NVARCHAR(100) NULL,
        ethnicity NVARCHAR(100) NULL,
        gender NVARCHAR(50) NULL,
        birthplace NVARCHAR(255) NULL,
        street_address NVARCHAR(255) NULL,
        city NVARCHAR(100) NULL,
        state_code NVARCHAR(100) NULL,
        county NVARCHAR(100) NULL,
        fips NVARCHAR(50) NULL,
        zip NVARCHAR(20) NULL,
        lat NVARCHAR(50) NULL,
        lon NVARCHAR(50) NULL,
        healthcare_expenses NVARCHAR(50) NULL,
        healthcare_coverage NVARCHAR(50) NULL,
        income NVARCHAR(50) NULL
    );

    PRINT 'Created bronze.patients.';
END
ELSE
BEGIN
    PRINT 'bronze.patients already exists.';
END;
GO

IF OBJECT_ID(N'bronze.organizations', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.organizations (
        source_organization_id NVARCHAR(100) NULL,
        organization_name NVARCHAR(255) NULL,
        street_address NVARCHAR(255) NULL,
        city NVARCHAR(100) NULL,
        state_code NVARCHAR(100) NULL,
        zip NVARCHAR(20) NULL,
        lat NVARCHAR(50) NULL,
        lon NVARCHAR(50) NULL,
        phone NVARCHAR(50) NULL,
        revenue NVARCHAR(50) NULL,
        utilization NVARCHAR(50) NULL
    );

    PRINT 'Created bronze.organizations.';
END
ELSE
BEGIN
    PRINT 'bronze.organizations already exists.';
END;
GO

IF OBJECT_ID(N'bronze.providers', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.providers (
        source_provider_id NVARCHAR(100) NULL,
        source_organization_id NVARCHAR(100) NULL,
        provider_name NVARCHAR(255) NULL,
        gender NVARCHAR(50) NULL,
        speciality NVARCHAR(255) NULL,
        street_address NVARCHAR(255) NULL,
        city NVARCHAR(100) NULL,
        state_code NVARCHAR(100) NULL,
        zip NVARCHAR(20) NULL,
        lat NVARCHAR(50) NULL,
        lon NVARCHAR(50) NULL,
        utilization NVARCHAR(50) NULL
    );

    PRINT 'Created bronze.providers.';
END
ELSE
BEGIN
    PRINT 'bronze.providers already exists.';
END;
GO

IF OBJECT_ID(N'bronze.encounters', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.encounters (
        source_encounter_id NVARCHAR(100) NULL,
        encounter_start_datetime NVARCHAR(50) NULL,
        encounter_stop_datetime NVARCHAR(50) NULL,
        source_patient_id NVARCHAR(100) NULL,
        source_organization_id NVARCHAR(100) NULL,
        source_provider_id NVARCHAR(100) NULL,
        source_payer_id NVARCHAR(100) NULL,
        encounter_class NVARCHAR(100) NULL,
        encounter_code NVARCHAR(100) NULL,
        encounter_description NVARCHAR(255) NULL,
        base_encounter_cost NVARCHAR(50) NULL,
        total_claim_cost NVARCHAR(50) NULL,
        payer_coverage NVARCHAR(50) NULL,
        reason_code NVARCHAR(100) NULL,
        reason_description NVARCHAR(255) NULL
    );

    PRINT 'Created bronze.encounters.';
END
ELSE
BEGIN
    PRINT 'bronze.encounters already exists.';
END;
GO

IF OBJECT_ID(N'bronze.conditions', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.conditions (
        condition_start_datetime NVARCHAR(50) NULL,
        condition_stop_datetime NVARCHAR(50) NULL,
        source_patient_id NVARCHAR(100) NULL,
        source_encounter_id NVARCHAR(100) NULL,
        condition_system NVARCHAR(255) NULL,
        condition_code NVARCHAR(100) NULL,
        condition_description NVARCHAR(255) NULL
    );

    PRINT 'Created bronze.conditions.';
END
ELSE
BEGIN
    PRINT 'bronze.conditions already exists.';
END;
GO

IF OBJECT_ID(N'bronze.observations', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.observations (
        observation_datetime NVARCHAR(50) NULL,
        source_patient_id NVARCHAR(100) NULL,
        source_encounter_id NVARCHAR(100) NULL,
        observation_category NVARCHAR(100) NULL,
        observation_code NVARCHAR(100) NULL,
        observation_description NVARCHAR(255) NULL,
        observation_value NVARCHAR(255) NULL,
        observation_units NVARCHAR(100) NULL,
        observation_type NVARCHAR(100) NULL
    );

    PRINT 'Created bronze.observations.';
END
ELSE
BEGIN
    PRINT 'bronze.observations already exists.';
END;
GO

IF OBJECT_ID(N'bronze.procedures', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.procedures (
        procedure_datetime NVARCHAR(50) NULL,
        source_patient_id NVARCHAR(100) NULL,
        source_encounter_id NVARCHAR(100) NULL,
        procedure_code NVARCHAR(100) NULL,
        procedure_description NVARCHAR(255) NULL,
        base_procedure_cost NVARCHAR(50) NULL,
        reason_code NVARCHAR(100) NULL,
        reason_description NVARCHAR(255) NULL
    );

    PRINT 'Created bronze.procedures.';
END
ELSE
BEGIN
    PRINT 'bronze.procedures already exists.';
END;
GO

/*
    Add ingestion metadata columns to bronze tables.

    Purpose:
    Add standard ingestion metadata columns to bronze tables so each loaded row
    can be traced to its source file, ingestion batch, load timestamp, row hash,
    and load status.

    Assumptions:
    - ingestion_batch_id will link to an audit batch table created in a later story.
    - source_file will be populated by the ingestion script.
    - row_hash will be populated by the ingestion script.
    - load_status defaults to 'loaded' unless the ingestion process sets another status.
*/

USE [ClinicalPulse];
GO

DECLARE @bronze_tables TABLE (
    table_name SYSNAME NOT NULL PRIMARY KEY
);

INSERT INTO @bronze_tables (table_name)
VALUES
    (N'patients'),
    (N'organizations'),
    (N'providers'),
    (N'encounters'),
    (N'conditions'),
    (N'observations'),
    (N'procedures');

DECLARE @table_name SYSNAME;
DECLARE @sql NVARCHAR(MAX);

DECLARE bronze_table_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT table_name
FROM @bronze_tables
ORDER BY table_name;

OPEN bronze_table_cursor;

FETCH NEXT FROM bronze_table_cursor INTO @table_name;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF COL_LENGTH(N'bronze.' + @table_name, N'ingestion_batch_id') IS NULL
    BEGIN
        SET @sql = N'
            ALTER TABLE bronze.' + QUOTENAME(@table_name) + N'
            ADD ingestion_batch_id BIGINT NULL;
        ';
        EXEC sys.sp_executesql @sql;
        PRINT 'Added ingestion_batch_id to bronze.' + @table_name + '.';
    END;

    IF COL_LENGTH(N'bronze.' + @table_name, N'ingestion_datetime') IS NULL
    BEGIN
        SET @sql = N'
            ALTER TABLE bronze.' + QUOTENAME(@table_name) + N'
            ADD ingestion_datetime DATETIME2(0) NOT NULL
                CONSTRAINT ' + QUOTENAME(N'df_' + @table_name + N'_ingestion_datetime') + N'
                DEFAULT SYSUTCDATETIME();
        ';
        EXEC sys.sp_executesql @sql;
        PRINT 'Added ingestion_datetime to bronze.' + @table_name + '.';
    END;

    IF COL_LENGTH(N'bronze.' + @table_name, N'source_file') IS NULL
    BEGIN
        SET @sql = N'
            ALTER TABLE bronze.' + QUOTENAME(@table_name) + N'
            ADD source_file NVARCHAR(255) NULL;
        ';
        EXEC sys.sp_executesql @sql;
        PRINT 'Added source_file to bronze.' + @table_name + '.';
    END;

    IF COL_LENGTH(N'bronze.' + @table_name, N'row_hash') IS NULL
    BEGIN
        SET @sql = N'
            ALTER TABLE bronze.' + QUOTENAME(@table_name) + N'
            ADD row_hash VARBINARY(32) NULL;
        ';
        EXEC sys.sp_executesql @sql;
        PRINT 'Added row_hash to bronze.' + @table_name + '.';
    END;

    IF COL_LENGTH(N'bronze.' + @table_name, N'load_status') IS NULL
    BEGIN
        SET @sql = N'
            ALTER TABLE bronze.' + QUOTENAME(@table_name) + N'
            ADD load_status NVARCHAR(30) NOT NULL
                CONSTRAINT ' + QUOTENAME(N'df_' + @table_name + N'_load_status') + N'
                DEFAULT N''loaded'';
        ';
        EXEC sys.sp_executesql @sql;
        PRINT 'Added load_status to bronze.' + @table_name + '.';
    END;

    FETCH NEXT FROM bronze_table_cursor INTO @table_name;
END;

CLOSE bronze_table_cursor;
DEALLOCATE bronze_table_cursor;
GO
