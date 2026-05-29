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
