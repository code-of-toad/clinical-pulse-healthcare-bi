/*
    ClinicalPulse

    Purpose:
    Create audit tables for Synthea CSV ingestion runs.

    Tables:
    - audit.ingestion_batch
    - audit.ingestion_file_log

    Assumptions:
    - One ingestion batch represents one execution of the ingestion script.
    - One ingestion file log row represents one source CSV loaded during a batch.
    - Bronze rows store ingestion_batch_id for row-level traceability.
*/

USE [ClinicalPulse];
GO

IF OBJECT_ID(N'audit.ingestion_batch', N'U') IS NULL
BEGIN
    CREATE TABLE audit.ingestion_batch (
        ingestion_batch_id BIGINT IDENTITY(1,1) NOT NULL,
        source_system NVARCHAR(100) NOT NULL,
        raw_directory NVARCHAR(500) NULL,
        ingestion_mode NVARCHAR(20) NOT NULL,
        entity_count INT NOT NULL,
        started_at DATETIME2(0) NOT NULL
            CONSTRAINT df_ingestion_batch_started_at
            DEFAULT SYSUTCDATETIME(),
        completed_at DATETIME2(0) NULL,
        load_status NVARCHAR(30) NOT NULL
            CONSTRAINT df_ingestion_batch_load_status
            DEFAULT N'running',
        total_rows_loaded BIGINT NOT NULL
            CONSTRAINT df_ingestion_batch_total_rows_loaded
            DEFAULT (0),
        error_message NVARCHAR(MAX) NULL,

        CONSTRAINT pk_ingestion_batch
            PRIMARY KEY (ingestion_batch_id),

        CONSTRAINT ck_ingestion_batch_load_status
            CHECK (load_status IN (N'running', N'succeeded', N'failed'))
    );

    PRINT 'Created audit.ingestion_batch.';
END
ELSE
BEGIN
    PRINT 'audit.ingestion_batch already exists.';
END;
GO

IF OBJECT_ID(N'audit.ingestion_file_log', N'U') IS NULL
BEGIN
    CREATE TABLE audit.ingestion_file_log (
        ingestion_file_log_id BIGINT IDENTITY(1,1) NOT NULL,
        ingestion_batch_id BIGINT NOT NULL,
        source_file NVARCHAR(255) NOT NULL,
        target_schema SYSNAME NOT NULL
            CONSTRAINT df_ingestion_file_log_target_schema
            DEFAULT N'bronze',
        target_table SYSNAME NOT NULL,
        started_at DATETIME2(0) NOT NULL
            CONSTRAINT df_ingestion_file_log_started_at
            DEFAULT SYSUTCDATETIME(),
        completed_at DATETIME2(0) NULL,
        load_status NVARCHAR(30) NOT NULL
            CONSTRAINT df_ingestion_file_log_load_status
            DEFAULT N'running',
        rows_loaded BIGINT NOT NULL
            CONSTRAINT df_ingestion_file_log_rows_loaded
            DEFAULT (0),
        error_message NVARCHAR(MAX) NULL,

        CONSTRAINT pk_ingestion_file_log
            PRIMARY KEY (ingestion_file_log_id),

        CONSTRAINT fk_ingestion_file_log_ingestion_batch
            FOREIGN KEY (ingestion_batch_id)
            REFERENCES audit.ingestion_batch (ingestion_batch_id),

        CONSTRAINT ck_ingestion_file_log_load_status
            CHECK (load_status IN (N'running', N'succeeded', N'failed'))
    );

    PRINT 'Created audit.ingestion_file_log.';
END
ELSE
BEGIN
    PRINT 'audit.ingestion_file_log already exists.';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'ix_ingestion_file_log_ingestion_batch_id'
      AND object_id = OBJECT_ID(N'audit.ingestion_file_log')
)
BEGIN
    CREATE INDEX ix_ingestion_file_log_ingestion_batch_id
    ON audit.ingestion_file_log (ingestion_batch_id);

    PRINT 'Created ix_ingestion_file_log_ingestion_batch_id.';
END
ELSE
BEGIN
    PRINT 'ix_ingestion_file_log_ingestion_batch_id already exists.';
END;
GO
