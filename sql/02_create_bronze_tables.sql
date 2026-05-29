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

/*
    DECLARE creates variables.

    Here, @bronze_tables is a table variable.
    It behaves like a small temporary table that exists only while this script batch runs.

    SYSNAME is a SQL Server system data type used for object names.
    It is essentially NVARCHAR(128), commonly used for table names, schema names,
    column names, constraint names, and other identifiers.
*/
DECLARE @bronze_tables TABLE (
    table_name SYSNAME NOT NULL PRIMARY KEY
);

/*
    Store the bronze table names that should receive the metadata columns.

    This avoids copy-pasting the same ALTER TABLE logic seven times.
*/
INSERT INTO @bronze_tables (table_name)
VALUES
    (N'patients'),
    (N'organizations'),
    (N'providers'),
    (N'encounters'),
    (N'conditions'),
    (N'observations'),
    (N'procedures');

/*
    These scalar variables hold one table name at a time and one generated SQL command
    at a time while the cursor loops through the bronze table list.
*/
DECLARE @table_name SYSNAME;
DECLARE @sql NVARCHAR(MAX);

/*
    A cursor lets SQL Server loop through a result set row by row.

    In this case, the cursor loops through the table names stored in @bronze_tables.

    LOCAL means the cursor only exists in this script scope.
    FAST_FORWARD means this is a simple read-only, forward-only cursor.
*/
DECLARE bronze_table_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT table_name
FROM @bronze_tables
ORDER BY table_name;

/*
    OPEN activates the cursor so rows can be fetched from it.
*/
OPEN bronze_table_cursor;

/*
    FETCH NEXT gets the first table name from the cursor and stores it in @table_name.
*/
FETCH NEXT FROM bronze_table_cursor INTO @table_name;

/*
    @@FETCH_STATUS tells us whether the previous FETCH succeeded.

    0 means the fetch was successful.
    So this loop continues until there are no more table names to process.
*/
WHILE @@FETCH_STATUS = 0
BEGIN
    /*
        COL_LENGTH checks whether a column exists on a table.

        Syntax:
            COL_LENGTH('schema.table', 'column_name')

        If the column exists, SQL Server returns its length.
        If the column does not exist, it returns NULL.

        So this condition means:
            If bronze.<current_table>.ingestion_batch_id does not exist, add it.
    */
    IF COL_LENGTH(N'bronze.' + @table_name, N'ingestion_batch_id') IS NULL
    BEGIN
        /*
            Dynamic SQL means building a SQL command as text, then executing it.

            We need dynamic SQL here because ALTER TABLE needs a table name,
            and the table name changes on each loop iteration.

            QUOTENAME safely wraps the table name in brackets.
            Example:
                patients becomes [patients]

            This protects against invalid object names and is a good habit when
            dynamically generating SQL object references.
        */
        SET @sql = N'
            ALTER TABLE bronze.' + QUOTENAME(@table_name) + N'
            ADD ingestion_batch_id BIGINT NULL;
        ';

        /*
            sys.sp_executesql executes the SQL text stored in @sql.
        */
        EXEC sys.sp_executesql @sql;

        PRINT 'Added ingestion_batch_id to bronze.' + @table_name + '.';
    END;

    /*
        Add ingestion_datetime if it does not already exist.

        DATETIME2(0) stores date and time with seconds precision.
        NOT NULL means every row must have a value.

        DEFAULT SYSUTCDATETIME() automatically fills the column with the current
        UTC date/time when a new row is inserted and no explicit value is provided.
    */
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

    /*
        Add source_file if it does not already exist.

        This column stores the CSV file name/path used for the loaded row.
    */
    IF COL_LENGTH(N'bronze.' + @table_name, N'source_file') IS NULL
    BEGIN
        SET @sql = N'
            ALTER TABLE bronze.' + QUOTENAME(@table_name) + N'
            ADD source_file NVARCHAR(255) NULL;
        ';

        EXEC sys.sp_executesql @sql;

        PRINT 'Added source_file to bronze.' + @table_name + '.';
    END;

    /*
        Add row_hash if it does not already exist.

        VARBINARY(32) is appropriate for a 256-bit hash value, such as SHA2_256.
        This can later help detect row-level changes or duplicates.
    */
    IF COL_LENGTH(N'bronze.' + @table_name, N'row_hash') IS NULL
    BEGIN
        SET @sql = N'
            ALTER TABLE bronze.' + QUOTENAME(@table_name) + N'
            ADD row_hash VARBINARY(32) NULL;
        ';

        EXEC sys.sp_executesql @sql;

        PRINT 'Added row_hash to bronze.' + @table_name + '.';
    END;

    /*
        Add load_status if it does not already exist.

        This records the ingestion status for the row.

        The default constraint automatically sets load_status to 'loaded'
        unless the ingestion script provides a different value.
    */
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

    /*
        Move to the next table name in the cursor.
        Without this FETCH NEXT, the loop would never advance.
    */
    FETCH NEXT FROM bronze_table_cursor INTO @table_name;
END;

/*
    CLOSE releases the cursor's active result set.
*/
CLOSE bronze_table_cursor;

/*
    DEALLOCATE removes the cursor definition from memory.
*/
DEALLOCATE bronze_table_cursor;
GO
