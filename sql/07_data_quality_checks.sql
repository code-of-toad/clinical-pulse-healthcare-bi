USE ClinicalPulse;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'governance'
)
BEGIN
    EXEC('CREATE SCHEMA governance');
END;
GO

IF OBJECT_ID('governance.quality_rule', 'U') IS NULL
BEGIN
    CREATE TABLE governance.quality_rule (
        quality_rule_id NVARCHAR(80) NOT NULL,
        rule_name NVARCHAR(200) NOT NULL,
        quality_dimension NVARCHAR(50) NOT NULL,

        target_schema NVARCHAR(128) NOT NULL,
        target_table NVARCHAR(128) NOT NULL,
        target_column NVARCHAR(128) NULL,
        rule_scope NVARCHAR(50) NOT NULL,

        severity NVARCHAR(20) NOT NULL,
        owner_role NVARCHAR(100) NOT NULL,
        steward_role NVARCHAR(100) NOT NULL,

        business_description NVARCHAR(1000) NOT NULL,
        technical_description NVARCHAR(2000) NOT NULL,
        expected_outcome NVARCHAR(1000) NOT NULL,

        is_active BIT NOT NULL
            CONSTRAINT DF_quality_rule_is_active DEFAULT 1,

        created_datetime DATETIME2(0) NOT NULL
            CONSTRAINT DF_quality_rule_created_datetime DEFAULT SYSUTCDATETIME(),

        updated_datetime DATETIME2(0) NOT NULL
            CONSTRAINT DF_quality_rule_updated_datetime DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_quality_rule
            PRIMARY KEY (quality_rule_id),

        CONSTRAINT CK_quality_rule_quality_dimension
            CHECK (
                quality_dimension IN (
                    'completeness',
                    'uniqueness',
                    'referential_integrity',
                    'validity',
                    'consistency',
                    'freshness',
                    'lineage'
                )
            ),

        CONSTRAINT CK_quality_rule_severity
            CHECK (severity IN ('critical', 'high', 'medium', 'low')),

        CONSTRAINT CK_quality_rule_is_active
            CHECK (is_active IN (0, 1))
    );
END;
GO

MERGE governance.quality_rule AS target
USING (
    VALUES
        (
            'DQ_LINEAGE_COMPLETE',
            'Silver lineage fields are populated',
            'lineage',
            'silver',
            'all_current_silver',
            NULL,
            'table',
            'critical',
            'BI Developer',
            'Data Steward',
            'Silver records must remain traceable to bronze source records.',
            'Validate that silver rows retain bronze ingestion batch ID, ingestion datetime, source file, row hash, and load status.',
            'No active silver record is missing required bronze lineage metadata.'
        ),
        (
            'DQ_SILVER_LOAD_FRESHNESS',
            'Silver layer has a current load timestamp',
            'freshness',
            'silver',
            'all_current_silver',
            'silver_load_datetime',
            'pipeline',
            'high',
            'BI Developer',
            'Data Steward',
            'Dashboard users need confidence that silver data was recently transformed.',
            'Validate that silver tables contain non-null silver_load_datetime values from the latest transform run.',
            'Silver load timestamps are present and usable for freshness reporting.'
        ),
        (
            'DQ_PATIENT_ID_COMPLETE',
            'Patient identifier is populated',
            'completeness',
            'silver',
            'patient',
            'patient_id',
            'row',
            'critical',
            'BI Developer',
            'Data Steward',
            'Patient records require stable identifiers for joining and reporting.',
            'Validate that silver.patient.patient_id is not null.',
            'No silver.patient row has a missing patient_id.'
        ),
        (
            'DQ_PATIENT_ID_UNIQUE',
            'Patient identifier is unique',
            'uniqueness',
            'silver',
            'patient',
            'patient_id',
            'table',
            'critical',
            'BI Developer',
            'Data Steward',
            'Patient identifiers must not duplicate across the patient dimension.',
            'Validate that silver.patient.patient_id has no duplicates.',
            'Each patient_id appears once in silver.patient.'
        ),
        (
            'DQ_PATIENT_AGE_VALID',
            'Patient age is valid',
            'validity',
            'silver',
            'patient',
            'age_years',
            'row',
            'high',
            'BI Developer',
            'Data Steward',
            'Age bands and demographic reporting depend on valid age calculations.',
            'Validate that age_years is null only when date quality prevents calculation and is never negative.',
            'No patient has a negative age_years value.'
        ),
        (
            'DQ_ENCOUNTER_ID_COMPLETE',
            'Encounter identifier is populated',
            'completeness',
            'silver',
            'encounter',
            'encounter_id',
            'row',
            'critical',
            'BI Developer',
            'Data Steward',
            'Encounter reporting requires stable encounter identifiers.',
            'Validate that silver.encounter.encounter_id is not null.',
            'No silver.encounter row has a missing encounter_id.'
        ),
        (
            'DQ_ENCOUNTER_ID_UNIQUE',
            'Encounter identifier is unique',
            'uniqueness',
            'silver',
            'encounter',
            'encounter_id',
            'table',
            'critical',
            'BI Developer',
            'Data Steward',
            'Encounter identifiers must not duplicate across the encounter entity.',
            'Validate that silver.encounter.encounter_id has no duplicates.',
            'Each encounter_id appears once in silver.encounter.'
        ),
        (
            'DQ_ENCOUNTER_PATIENT_REF',
            'Encounter patient reference exists',
            'referential_integrity',
            'silver',
            'encounter',
            'patient_id',
            'cross_table',
            'critical',
            'BI Developer',
            'Data Steward',
            'Encounter metrics must link back to valid patients.',
            'Validate that non-null silver.encounter.patient_id values exist in silver.patient.patient_id.',
            'No encounter references a missing silver patient.'
        ),
        (
            'DQ_ENCOUNTER_DATES_VALID',
            'Encounter start and stop timestamps are valid',
            'validity',
            'silver',
            'encounter',
            NULL,
            'row',
            'high',
            'BI Developer',
            'Data Steward',
            'Length of stay and encounter duration depend on valid start and stop timestamps.',
            'Validate that encounter datetime quality flags identify missing, invalid, or stop-before-start records.',
            'No valid encounter has negative duration or negative length of stay.'
        ),
        (
            'DQ_ENCOUNTER_CLASS_CONSISTENT',
            'Encounter class is standardized',
            'consistency',
            'silver',
            'encounter',
            'encounter_class',
            'row',
            'medium',
            'BI Developer',
            'Data Steward',
            'Encounter class grouping should be consistent for reporting filters.',
            'Validate that encounter_class is standardized to a consistent casing and known grouping pattern.',
            'Encounter class values are consistently formatted for reporting.'
        ),
        (
            'DQ_CONDITION_PATIENT_REF',
            'Condition patient reference exists',
            'referential_integrity',
            'silver',
            'condition',
            'patient_id',
            'cross_table',
            'critical',
            'BI Developer',
            'Data Steward',
            'Condition records must link back to valid patients for cohorting and diagnosis context.',
            'Validate that non-null silver.condition.patient_id values exist in silver.patient.patient_id.',
            'No condition references a missing silver patient.'
        ),
        (
            'DQ_CONDITION_ENCOUNTER_REF',
            'Condition encounter reference exists',
            'referential_integrity',
            'silver',
            'condition',
            'encounter_id',
            'cross_table',
            'medium',
            'BI Developer',
            'Data Steward',
            'Condition records should link to encounters where encounter references are present.',
            'Validate that non-null silver.condition.encounter_id values exist in silver.encounter.encounter_id.',
            'No populated condition encounter reference points to a missing silver encounter.'
        ),
        (
            'DQ_CONDITION_DATES_VALID',
            'Condition dates are valid',
            'validity',
            'silver',
            'condition',
            NULL,
            'row',
            'high',
            'BI Developer',
            'Data Steward',
            'Condition duration and status depend on valid condition dates.',
            'Validate that condition_date_quality_status identifies missing, invalid, or stop-before-start dates.',
            'No valid condition has negative condition duration.'
        ),
        (
            'DQ_PROCEDURE_PATIENT_REF',
            'Procedure patient reference exists',
            'referential_integrity',
            'silver',
            'procedure',
            'patient_id',
            'cross_table',
            'critical',
            'BI Developer',
            'Data Steward',
            'Procedure records must link back to valid patients for utilization reporting.',
            'Validate that non-null silver.procedure.patient_id values exist in silver.patient.patient_id.',
            'No procedure references a missing silver patient.'
        ),
        (
            'DQ_PROCEDURE_ENCOUNTER_REF',
            'Procedure encounter reference exists',
            'referential_integrity',
            'silver',
            'procedure',
            'encounter_id',
            'cross_table',
            'medium',
            'BI Developer',
            'Data Steward',
            'Procedure records should link to encounters for encounter-level utilization analysis.',
            'Validate that non-null silver.procedure.encounter_id values exist in silver.encounter.encounter_id.',
            'No populated procedure encounter reference points to a missing silver encounter.'
        ),
        (
            'DQ_PROCEDURE_DATES_VALID',
            'Procedure timestamps are valid',
            'validity',
            'silver',
            'procedure',
            NULL,
            'row',
            'high',
            'BI Developer',
            'Data Steward',
            'Procedure duration depends on valid start and stop timestamps.',
            'Validate that procedure datetime quality flags identify missing, invalid, or stop-before-start records.',
            'No valid procedure has negative duration.'
        ),
        (
            'DQ_OBSERVATION_PATIENT_REF',
            'Observation patient reference exists',
            'referential_integrity',
            'silver',
            'observation',
            'patient_id',
            'cross_table',
            'critical',
            'BI Developer',
            'Data Steward',
            'Observation records must link back to valid patients for lab and observation reporting.',
            'Validate that non-null silver.observation.patient_id values exist in silver.patient.patient_id.',
            'No observation references a missing silver patient.'
        ),
        (
            'DQ_OBSERVATION_REQUIRED_FIELDS_COMPLETE',
            'Observation required fields are populated',
            'completeness',
            'silver',
            'observation',
            NULL,
            'row',
            'high',
            'BI Developer',
            'Data Steward',
            'Observation reporting requires patient, timestamp, and observation code fields.',
            'Validate that observation_quality_status flags missing patient IDs, timestamps, and observation codes.',
            'Required observation fields are populated or explicitly flagged.'
        ),
        (
            'DQ_OBSERVATION_ENCOUNTER_REF_WHEN_PRESENT',
            'Observation encounter reference exists when present',
            'referential_integrity',
            'silver',
            'observation',
            'encounter_id',
            'cross_table',
            'medium',
            'BI Developer',
            'Data Steward',
            'Some observations are patient-level and not encounter-linked, but populated encounter references should be valid.',
            'Validate only non-null silver.observation.encounter_id values against silver.encounter.encounter_id.',
            'No populated observation encounter reference points to a missing silver encounter.'
        ),
        (
            'DQ_OBSERVATION_CATEGORY_CONSISTENT',
            'Observation category is standardized',
            'consistency',
            'silver',
            'observation',
            'observation_category',
            'row',
            'medium',
            'BI Developer',
            'Data Steward',
            'Observation categories should be standardized for reporting and quality grouping.',
            'Validate that null source categories are standardized to uncategorized and retained consistently.',
            'Observation category values are consistently populated for reporting.'
        )
) AS source (
    quality_rule_id,
    rule_name,
    quality_dimension,
    target_schema,
    target_table,
    target_column,
    rule_scope,
    severity,
    owner_role,
    steward_role,
    business_description,
    technical_description,
    expected_outcome
)
ON target.quality_rule_id = source.quality_rule_id
WHEN MATCHED THEN
    UPDATE SET
        rule_name = source.rule_name,
        quality_dimension = source.quality_dimension,
        target_schema = source.target_schema,
        target_table = source.target_table,
        target_column = source.target_column,
        rule_scope = source.rule_scope,
        severity = source.severity,
        owner_role = source.owner_role,
        steward_role = source.steward_role,
        business_description = source.business_description,
        technical_description = source.technical_description,
        expected_outcome = source.expected_outcome,
        is_active = 1,
        updated_datetime = SYSUTCDATETIME()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        quality_rule_id,
        rule_name,
        quality_dimension,
        target_schema,
        target_table,
        target_column,
        rule_scope,
        severity,
        owner_role,
        steward_role,
        business_description,
        technical_description,
        expected_outcome,
        is_active
    )
    VALUES (
        source.quality_rule_id,
        source.rule_name,
        source.quality_dimension,
        source.target_schema,
        source.target_table,
        source.target_column,
        source.rule_scope,
        source.severity,
        source.owner_role,
        source.steward_role,
        source.business_description,
        source.technical_description,
        source.expected_outcome,
        1
    );
GO


USE ClinicalPulse;
GO

MERGE governance.quality_rule AS target
USING (
    VALUES (
        'DQ_OBSERVATION_ROW_UNIQUE',
        'Observation rows are unique',
        'uniqueness',
        'silver',
        'observation',
        NULL,
        'table',
        'medium',
        'BI Developer',
        'Data Steward',
        'Duplicate observation rows can inflate lab and observation volume metrics.',
        'Validate that silver.observation has no duplicate rows by patient, encounter, observation datetime, code, value, and units.',
        'No duplicate observation rows exist at the selected natural-grain check.'
    )
) AS source (
    quality_rule_id,
    rule_name,
    quality_dimension,
    target_schema,
    target_table,
    target_column,
    rule_scope,
    severity,
    owner_role,
    steward_role,
    business_description,
    technical_description,
    expected_outcome
)
ON target.quality_rule_id = source.quality_rule_id
WHEN MATCHED THEN
    UPDATE SET
        rule_name = source.rule_name,
        quality_dimension = source.quality_dimension,
        target_schema = source.target_schema,
        target_table = source.target_table,
        target_column = source.target_column,
        rule_scope = source.rule_scope,
        severity = source.severity,
        owner_role = source.owner_role,
        steward_role = source.steward_role,
        business_description = source.business_description,
        technical_description = source.technical_description,
        expected_outcome = source.expected_outcome,
        is_active = 1,
        updated_datetime = SYSUTCDATETIME()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        quality_rule_id,
        rule_name,
        quality_dimension,
        target_schema,
        target_table,
        target_column,
        rule_scope,
        severity,
        owner_role,
        steward_role,
        business_description,
        technical_description,
        expected_outcome,
        is_active
    )
    VALUES (
        source.quality_rule_id,
        source.rule_name,
        source.quality_dimension,
        source.target_schema,
        source.target_table,
        source.target_column,
        source.rule_scope,
        source.severity,
        source.owner_role,
        source.steward_role,
        source.business_description,
        source.technical_description,
        source.expected_outcome,
        1
    );
GO


IF OBJECT_ID('governance.quality_check_result', 'U') IS NULL
BEGIN
    CREATE TABLE governance.quality_check_result (
        quality_check_result_id BIGINT IDENTITY(1,1) NOT NULL,
        quality_check_run_id UNIQUEIDENTIFIER NOT NULL,

        quality_rule_id NVARCHAR(80) NOT NULL,
        rule_name NVARCHAR(200) NOT NULL,
        quality_dimension NVARCHAR(50) NOT NULL,

        target_schema NVARCHAR(128) NOT NULL,
        target_table NVARCHAR(128) NOT NULL,
        target_column NVARCHAR(128) NULL,
        rule_scope NVARCHAR(50) NOT NULL,
        severity NVARCHAR(20) NOT NULL,

        total_records BIGINT NOT NULL,
        failed_records BIGINT NOT NULL,
        passed_records BIGINT NOT NULL,
        pass_rate DECIMAL(9, 4) NOT NULL,
        check_status NVARCHAR(20) NOT NULL,

        checked_datetime DATETIME2(0) NOT NULL,
        persisted_datetime DATETIME2(0) NOT NULL
            CONSTRAINT DF_quality_check_result_persisted_datetime
            DEFAULT SYSUTCDATETIME(),

        run_source NVARCHAR(100) NOT NULL
            CONSTRAINT DF_quality_check_result_run_source
            DEFAULT 'src/run_quality_checks.py',

        CONSTRAINT PK_quality_check_result
            PRIMARY KEY (quality_check_result_id),

        CONSTRAINT FK_quality_check_result_quality_rule
            FOREIGN KEY (quality_rule_id)
            REFERENCES governance.quality_rule (quality_rule_id),

        CONSTRAINT CK_quality_check_result_check_status
            CHECK (check_status IN ('passed', 'failed')),

        CONSTRAINT CK_quality_check_result_counts
            CHECK (
                total_records >= 0
                AND failed_records >= 0
                AND passed_records >= 0
                AND failed_records + passed_records = total_records
            )
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_quality_check_result_run_id'
      AND object_id = OBJECT_ID('governance.quality_check_result')
)
BEGIN
    CREATE INDEX IX_quality_check_result_run_id
    ON governance.quality_check_result (
        quality_check_run_id,
        quality_rule_id
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_quality_check_result_persisted_datetime'
      AND object_id = OBJECT_ID('governance.quality_check_result')
)
BEGIN
    CREATE INDEX IX_quality_check_result_persisted_datetime
    ON governance.quality_check_result (
        persisted_datetime DESC,
        check_status,
        severity
    );
END;
GO


CREATE OR ALTER VIEW governance.vw_quality_check_current AS
WITH check_result AS (
    SELECT
        'DQ_PATIENT_ID_COMPLETE' AS quality_rule_id,
        COUNT_BIG(*) AS total_records,
        SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS failed_records
    FROM silver.patient

    UNION ALL

    SELECT
        'DQ_ENCOUNTER_ID_COMPLETE',
        COUNT_BIG(*),
        SUM(CASE WHEN encounter_id IS NULL THEN 1 ELSE 0 END)
    FROM silver.encounter

    UNION ALL

    SELECT
        'DQ_OBSERVATION_REQUIRED_FIELDS_COMPLETE',
        COUNT_BIG(*),
        SUM(
            CASE
                WHEN patient_id IS NULL
                  OR observation_datetime_utc IS NULL
                  OR observation_code IS NULL
                THEN 1
                ELSE 0
            END
        )
    FROM silver.observation

    UNION ALL

    SELECT
        'DQ_PATIENT_ID_UNIQUE',
        COUNT_BIG(*),
        (
            SELECT COUNT_BIG(*)
            FROM silver.patient p
            INNER JOIN (
                SELECT patient_id
                FROM silver.patient
                WHERE patient_id IS NOT NULL
                GROUP BY patient_id
                HAVING COUNT_BIG(*) > 1
            ) d
                ON p.patient_id = d.patient_id
        )
    FROM silver.patient

    UNION ALL

    SELECT
        'DQ_ENCOUNTER_ID_UNIQUE',
        COUNT_BIG(*),
        (
            SELECT COUNT_BIG(*)
            FROM silver.encounter e
            INNER JOIN (
                SELECT encounter_id
                FROM silver.encounter
                WHERE encounter_id IS NOT NULL
                GROUP BY encounter_id
                HAVING COUNT_BIG(*) > 1
            ) d
                ON e.encounter_id = d.encounter_id
        )
    FROM silver.encounter

    UNION ALL

    SELECT
        'DQ_OBSERVATION_ROW_UNIQUE',
        COUNT_BIG(*),
        (
            SELECT COALESCE(SUM(duplicate_record_count - 1), 0)
            FROM (
                SELECT COUNT_BIG(*) AS duplicate_record_count
                FROM silver.observation
                GROUP BY
                    patient_id,
                    encounter_id,
                    observation_datetime_utc,
                    observation_code,
                    observation_value_raw,
                    observation_units
                HAVING COUNT_BIG(*) > 1
            ) d
        )
    FROM silver.observation

    UNION ALL

    SELECT
        'DQ_ENCOUNTER_PATIENT_REF',
        COUNT_BIG(*),
        SUM(CASE WHEN e.patient_id IS NOT NULL AND p.patient_id IS NULL THEN 1 ELSE 0 END)
    FROM silver.encounter e
    LEFT JOIN silver.patient p
        ON e.patient_id = p.patient_id

    UNION ALL

    SELECT
        'DQ_CONDITION_PATIENT_REF',
        COUNT_BIG(*),
        SUM(CASE WHEN c.patient_id IS NOT NULL AND p.patient_id IS NULL THEN 1 ELSE 0 END)
    FROM silver.condition c
    LEFT JOIN silver.patient p
        ON c.patient_id = p.patient_id

    UNION ALL

    SELECT
        'DQ_CONDITION_ENCOUNTER_REF',
        COUNT_BIG(*),
        SUM(CASE WHEN c.encounter_id IS NOT NULL AND e.encounter_id IS NULL THEN 1 ELSE 0 END)
    FROM silver.condition c
    LEFT JOIN silver.encounter e
        ON c.encounter_id = e.encounter_id

    UNION ALL

    SELECT
        'DQ_PROCEDURE_PATIENT_REF',
        COUNT_BIG(*),
        SUM(CASE WHEN pr.patient_id IS NOT NULL AND p.patient_id IS NULL THEN 1 ELSE 0 END)
    FROM silver.[procedure] pr
    LEFT JOIN silver.patient p
        ON pr.patient_id = p.patient_id

    UNION ALL

    SELECT
        'DQ_PROCEDURE_ENCOUNTER_REF',
        COUNT_BIG(*),
        SUM(CASE WHEN pr.encounter_id IS NOT NULL AND e.encounter_id IS NULL THEN 1 ELSE 0 END)
    FROM silver.[procedure] pr
    LEFT JOIN silver.encounter e
        ON pr.encounter_id = e.encounter_id

    UNION ALL

    SELECT
        'DQ_OBSERVATION_PATIENT_REF',
        COUNT_BIG(*),
        SUM(CASE WHEN o.patient_id IS NOT NULL AND p.patient_id IS NULL THEN 1 ELSE 0 END)
    FROM silver.observation o
    LEFT JOIN silver.patient p
        ON o.patient_id = p.patient_id

    UNION ALL

    SELECT
        'DQ_OBSERVATION_ENCOUNTER_REF_WHEN_PRESENT',
        COUNT_BIG(*),
        SUM(CASE WHEN o.encounter_id IS NOT NULL AND e.encounter_id IS NULL THEN 1 ELSE 0 END)
    FROM silver.observation o
    LEFT JOIN silver.encounter e
        ON o.encounter_id = e.encounter_id
    
    UNION ALL

    SELECT
        'DQ_PATIENT_AGE_VALID',
        COUNT_BIG(*),
        SUM(
            CASE
                WHEN age_years < 0 THEN 1
                WHEN patient_date_quality_status = 'valid' AND age_years IS NULL THEN 1
                ELSE 0
            END
        )
    FROM silver.patient

    UNION ALL

    SELECT
        'DQ_ENCOUNTER_DATES_VALID',
        COUNT_BIG(*),
        SUM(
            CASE
                WHEN encounter_datetime_quality_status <> 'valid' THEN 1
                WHEN encounter_duration_minutes < 0 THEN 1
                WHEN encounter_duration_hours < 0 THEN 1
                WHEN length_of_stay_days < 0 THEN 1
                ELSE 0
            END
        )
    FROM silver.encounter

    UNION ALL

    SELECT
        'DQ_CONDITION_DATES_VALID',
        COUNT_BIG(*),
        SUM(
            CASE
                WHEN condition_date_quality_status <> 'valid' THEN 1
                WHEN condition_duration_days < 0 THEN 1
                ELSE 0
            END
        )
    FROM silver.condition

    UNION ALL

    SELECT
        'DQ_PROCEDURE_DATES_VALID',
        COUNT_BIG(*),
        SUM(
            CASE
                WHEN procedure_datetime_quality_status <> 'valid' THEN 1
                WHEN procedure_duration_minutes < 0 THEN 1
                WHEN procedure_duration_hours < 0 THEN 1
                ELSE 0
            END
        )
    FROM silver.[procedure]

    UNION ALL

    SELECT
        'DQ_ENCOUNTER_CLASS_CONSISTENT',
        COUNT_BIG(*),
        SUM(
            CASE
                WHEN encounter_class IS NULL THEN 1
                WHEN encounter_class <> LOWER(encounter_class) THEN 1
                ELSE 0
            END
        )
    FROM silver.encounter

    UNION ALL

    SELECT
        'DQ_OBSERVATION_CATEGORY_CONSISTENT',
        COUNT_BIG(*),
        SUM(
            CASE
                WHEN observation_category IS NULL THEN 1
                WHEN observation_category <> LOWER(observation_category) THEN 1
                ELSE 0
            END
        )
    FROM silver.observation

    UNION ALL

    SELECT
        'DQ_SILVER_LOAD_FRESHNESS',
        COUNT_BIG(*),
        SUM(
            CASE
                WHEN latest_silver_load_datetime IS NULL THEN 1
                WHEN latest_bronze_ingestion_datetime IS NULL THEN 1
                WHEN latest_silver_load_datetime < latest_bronze_ingestion_datetime THEN 1
                ELSE 0
            END
        )
    FROM (
        SELECT
            'patient' AS table_name,
            (SELECT MAX(silver_load_datetime) FROM silver.patient) AS latest_silver_load_datetime,
            (SELECT MAX(ingestion_datetime) FROM bronze.patients) AS latest_bronze_ingestion_datetime

        UNION ALL

        SELECT
            'encounter',
            (SELECT MAX(silver_load_datetime) FROM silver.encounter),
            (SELECT MAX(ingestion_datetime) FROM bronze.encounters)

        UNION ALL

        SELECT
            'condition',
            (SELECT MAX(silver_load_datetime) FROM silver.condition),
            (SELECT MAX(ingestion_datetime) FROM bronze.conditions)

        UNION ALL

        SELECT
            'procedure',
            (SELECT MAX(silver_load_datetime) FROM silver.[procedure]),
            (SELECT MAX(ingestion_datetime) FROM bronze.procedures)

        UNION ALL

        SELECT
            'observation',
            (SELECT MAX(silver_load_datetime) FROM silver.observation),
            (SELECT MAX(ingestion_datetime) FROM bronze.observations)
    ) freshness_check
)
SELECT
    qr.quality_rule_id,
    qr.rule_name,
    qr.quality_dimension,
    qr.target_schema,
    qr.target_table,
    qr.target_column,
    qr.rule_scope,
    qr.severity,
    qr.owner_role,
    qr.steward_role,
    cr.total_records,
    cr.failed_records,
    cr.total_records - cr.failed_records AS passed_records,
    CAST(
        CASE
            WHEN cr.total_records = 0 THEN 1.0000
            ELSE
                1.0 - (
                    CAST(cr.failed_records AS DECIMAL(19, 4))
                    / NULLIF(CAST(cr.total_records AS DECIMAL(19, 4)), 0)
                )
        END
        AS DECIMAL(9, 4)
    ) AS pass_rate,
    CASE
        WHEN cr.failed_records = 0 THEN 'passed'
        ELSE 'failed'
    END AS check_status,
    CAST(SYSUTCDATETIME() AS DATETIME2(0)) AS checked_datetime
FROM check_result cr
INNER JOIN governance.quality_rule qr
    ON cr.quality_rule_id = qr.quality_rule_id
WHERE qr.is_active = 1;
GO
