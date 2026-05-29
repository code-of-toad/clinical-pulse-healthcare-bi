/*
    ClinicalPulse

    Purpose:
    Create the core SQL Server schemas used by the ClinicalPulse platform.

    Schemas:
    - bronze: source-preserving ingestion tables
    - silver: cleaned and standardized business entities
    - gold: reporting-ready facts, dimensions, and marts
    - governance: KPI, quality, lineage, and asset governance objects
    - audit: ingestion, reconciliation, and run-history logging
    - api: FHIR-aligned/API-facing SQL views
*/

USE [ClinicalPulse];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'bronze'
)
BEGIN
    EXEC(N'CREATE SCHEMA [bronze] AUTHORIZATION [dbo];');
    PRINT 'Schema bronze created.';
END
ELSE
BEGIN
    PRINT 'Schema bronze already exists.';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'silver'
)
BEGIN
    EXEC(N'CREATE SCHEMA [silver] AUTHORIZATION [dbo];');
    PRINT 'Schema silver created.';
END
ELSE
BEGIN
    PRINT 'Schema silver already exists.';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'gold'
)
BEGIN
    EXEC(N'CREATE SCHEMA [gold] AUTHORIZATION [dbo];');
    PRINT 'Schema gold created.';
END
ELSE
BEGIN
    PRINT 'Schema gold already exists.';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'governance'
)
BEGIN
    EXEC(N'CREATE SCHEMA [governance] AUTHORIZATION [dbo];');
    PRINT 'Schema governance created.';
END
ELSE
BEGIN
    PRINT 'Schema governance already exists.';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'audit'
)
BEGIN
    EXEC(N'CREATE SCHEMA [audit] AUTHORIZATION [dbo];');
    PRINT 'Schema audit created.';
END
ELSE
BEGIN
    PRINT 'Schema audit already exists.';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'api'
)
BEGIN
    EXEC(N'CREATE SCHEMA [api] AUTHORIZATION [dbo];');
    PRINT 'Schema api created.';
END
ELSE
BEGIN
    PRINT 'Schema api already exists.';
END;
GO

/*---------------------------------------------------------------------------*/
SELECT name
FROM sys.databases
WHERE name = N'ClinicalPulse'

USE [ClinicalPulse];

SELECT name AS schema_name
FROM sys.schemas
WHERE name IN (
    N'bronze',
    N'silver',
    N'gold',
    N'governance',
    N'audit',
    N'api'
)
ORDER BY name;
