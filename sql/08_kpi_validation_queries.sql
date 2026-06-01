/*
ClinicalPulse

Purpose: Independent SQL validation queries for governed core KPIs.

Notes:
- This script is read-only against project tables.
- Results are written only to a temporary table for reporting.
- Power BI measures should reconcile to these SQL outputs once dashboards are implemented.
- API Resource Coverage is included even though API/FHIR objects may be implemented later.
*/

USE ClinicalPulse;
GO

SET NOCOUNT ON;

DROP TABLE IF EXISTS #kpi_validation_results;

CREATE TABLE #kpi_validation_results (
    kpi_name NVARCHAR(150) NOT NULL,
    validation_query_name NVARCHAR(250) NOT NULL,
    source_value DECIMAL(38,6) NULL,
    comparison_value DECIMAL(38,6) NULL,
    variance_value DECIMAL(38,6) NULL,
    validation_status NVARCHAR(30) NOT NULL,
    validation_detail NVARCHAR(1000) NULL
);

--------------------------------------------------------------------------------
-- KPI: Total Encounters
--------------------------------------------------------------------------------

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'Total Encounters',
    'Reconcile gold.fact_encounter to gold.mart_patient_flow',
    fact_result.total_encounters,
    mart_result.total_encounters,
    fact_result.total_encounters - mart_result.total_encounters,
    CASE
        WHEN fact_result.total_encounters = mart_result.total_encounters THEN 'passed'
        ELSE 'failed'
    END,
    'Validates Total Encounters as SUM(encounter_count) from gold.fact_encounter against SUM(total_encounters) from gold.mart_patient_flow.'
FROM (
    SELECT CAST(SUM(encounter_count) AS DECIMAL(38,6)) AS total_encounters
    FROM gold.fact_encounter
) fact_result
CROSS JOIN (
    SELECT CAST(SUM(total_encounters) AS DECIMAL(38,6)) AS total_encounters
    FROM gold.mart_patient_flow
) mart_result;

--------------------------------------------------------------------------------
-- KPI: Unique Patients
--------------------------------------------------------------------------------

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'Unique Patients',
    'Reconcile distinct patient keys from encounter fact to LOS mart',
    fact_result.unique_patients,
    mart_result.unique_patients,
    fact_result.unique_patients - mart_result.unique_patients,
    CASE
        WHEN fact_result.unique_patients = mart_result.unique_patients THEN 'passed'
        ELSE 'failed'
    END,
    'Validates Unique Patients as COUNT(DISTINCT patient_key) from encounter-grain gold objects. Do not sum unique_patients_in_group across marts.'
FROM (
    SELECT CAST(COUNT(DISTINCT patient_key) AS DECIMAL(38,6)) AS unique_patients
    FROM gold.fact_encounter
    WHERE patient_key IS NOT NULL
) fact_result
CROSS JOIN (
    SELECT CAST(COUNT(DISTINCT patient_key) AS DECIMAL(38,6)) AS unique_patients
    FROM gold.mart_length_of_stay
    WHERE patient_key IS NOT NULL
) mart_result;

--------------------------------------------------------------------------------
-- KPI: Average Length of Stay
--------------------------------------------------------------------------------

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'Average Length of Stay',
    'Reconcile average LOS from fact_encounter to mart_length_of_stay',
    fact_result.average_los_days,
    mart_result.average_los_days,
    fact_result.average_los_days - mart_result.average_los_days,
    CASE
        WHEN ABS(fact_result.average_los_days - mart_result.average_los_days) < 0.0001 THEN 'passed'
        ELSE 'failed'
    END,
    'Validates Average LOS as total LOS days divided by LOS-eligible encounters.'
FROM (
    SELECT
        CAST(
            SUM(CASE WHEN valid_encounter_count = 1 AND length_of_stay_days IS NOT NULL THEN length_of_stay_days ELSE 0 END)
            / NULLIF(SUM(CASE WHEN valid_encounter_count = 1 AND length_of_stay_days IS NOT NULL THEN 1 ELSE 0 END), 0)
            AS DECIMAL(38,6)
        ) AS average_los_days
    FROM gold.fact_encounter
) fact_result
CROSS JOIN (
    SELECT
        CAST(
            SUM(los_days_numerator)
            / NULLIF(SUM(los_eligible_encounter_count), 0)
            AS DECIMAL(38,6)
        ) AS average_los_days
    FROM gold.mart_length_of_stay
) mart_result;

--------------------------------------------------------------------------------
-- KPI: Median Length of Stay
--------------------------------------------------------------------------------

WITH fact_median AS (
    SELECT DISTINCT
        CAST(
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY length_of_stay_days)
            OVER () AS DECIMAL(38,6)
        ) AS median_los_days
    FROM gold.fact_encounter
    WHERE valid_encounter_count = 1
      AND length_of_stay_days IS NOT NULL
),
mart_median AS (
    SELECT DISTINCT
        CAST(
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY length_of_stay_days)
            OVER () AS DECIMAL(38,6)
        ) AS median_los_days
    FROM gold.mart_length_of_stay
    WHERE los_eligible_encounter_count = 1
      AND length_of_stay_days IS NOT NULL
)
INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'Median Length of Stay',
    'Reconcile median LOS from fact_encounter to mart_length_of_stay',
    fact_median.median_los_days,
    mart_median.median_los_days,
    fact_median.median_los_days - mart_median.median_los_days,
    CASE
        WHEN ABS(fact_median.median_los_days - mart_median.median_los_days) < 0.0001 THEN 'passed'
        ELSE 'failed'
    END,
    'Validates Median LOS over LOS-eligible encounter rows.'
FROM fact_median
CROSS JOIN mart_median;

--------------------------------------------------------------------------------
-- KPI: 30-Day Readmission Rate
--------------------------------------------------------------------------------

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    '30-Day Readmission Rate',
    'Reconcile readmission rate from fact_readmission to mart_readmissions',
    fact_result.readmission_rate,
    mart_result.readmission_rate,
    fact_result.readmission_rate - mart_result.readmission_rate,
    CASE
        WHEN ABS(fact_result.readmission_rate - mart_result.readmission_rate) < 0.0001 THEN 'passed'
        ELSE 'failed'
    END,
    'Validates 30-day readmission rate as numerator divided by denominator. Current logic is demonstration-grade and does not distinguish planned versus unplanned readmissions.'
FROM (
    SELECT
        CAST(SUM(readmission_30_day_count) * 1.0 / NULLIF(SUM(eligible_encounter_count), 0) AS DECIMAL(38,6)) AS readmission_rate
    FROM gold.fact_readmission
) fact_result
CROSS JOIN (
    SELECT
        CAST(SUM(readmission_rate_numerator) * 1.0 / NULLIF(SUM(readmission_rate_denominator), 0) AS DECIMAL(38,6)) AS readmission_rate
    FROM gold.mart_readmissions
) mart_result;

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    '30-Day Readmission Rate',
    'Reconcile readmission numerator and denominator',
    fact_result.readmission_numerator,
    mart_result.readmission_numerator,
    fact_result.readmission_numerator - mart_result.readmission_numerator,
    CASE
        WHEN fact_result.readmission_numerator = mart_result.readmission_numerator
         AND fact_result.readmission_denominator = mart_result.readmission_denominator
        THEN 'passed'
        ELSE 'failed'
    END,
    CONCAT(
        'Numerator fact=', fact_result.readmission_numerator,
        '; numerator mart=', mart_result.readmission_numerator,
        '; denominator fact=', fact_result.readmission_denominator,
        '; denominator mart=', mart_result.readmission_denominator,
        '.'
    )
FROM (
    SELECT
        CAST(SUM(readmission_30_day_count) AS DECIMAL(38,6)) AS readmission_numerator,
        CAST(SUM(eligible_encounter_count) AS DECIMAL(38,6)) AS readmission_denominator
    FROM gold.fact_readmission
) fact_result
CROSS JOIN (
    SELECT
        CAST(SUM(readmission_rate_numerator) AS DECIMAL(38,6)) AS readmission_numerator,
        CAST(SUM(readmission_rate_denominator) AS DECIMAL(38,6)) AS readmission_denominator
    FROM gold.mart_readmissions
) mart_result;

--------------------------------------------------------------------------------
-- KPI: Observation Volume
--------------------------------------------------------------------------------

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'Observation Volume',
    'Reconcile observation volume from fact_observation to mart_lab_operations',
    fact_result.observation_volume,
    mart_result.observation_volume,
    fact_result.observation_volume - mart_result.observation_volume,
    CASE
        WHEN fact_result.observation_volume = mart_result.observation_volume THEN 'passed'
        ELSE 'failed'
    END,
    'Validates Observation Volume as SUM(observation_count) from gold.fact_observation against SUM(observation_volume) from gold.mart_lab_operations.'
FROM (
    SELECT CAST(SUM(observation_count) AS DECIMAL(38,6)) AS observation_volume
    FROM gold.fact_observation
) fact_result
CROSS JOIN (
    SELECT CAST(SUM(observation_volume) AS DECIMAL(38,6)) AS observation_volume
    FROM gold.mart_lab_operations
) mart_result;

--------------------------------------------------------------------------------
-- KPI: Procedure Volume
--------------------------------------------------------------------------------

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'Procedure Volume',
    'Reconcile procedure volume from fact_procedure to mart_service_utilization',
    fact_result.procedure_volume,
    mart_result.procedure_volume,
    fact_result.procedure_volume - mart_result.procedure_volume,
    CASE
        WHEN fact_result.procedure_volume = mart_result.procedure_volume THEN 'passed'
        ELSE 'failed'
    END,
    'Validates Procedure Volume as SUM(procedure_count) from gold.fact_procedure against SUM(procedure_volume) from gold.mart_service_utilization.'
FROM (
    SELECT CAST(SUM(procedure_count) AS DECIMAL(38,6)) AS procedure_volume
    FROM gold.fact_procedure
) fact_result
CROSS JOIN (
    SELECT CAST(SUM(procedure_volume) AS DECIMAL(38,6)) AS procedure_volume
    FROM gold.mart_service_utilization
) mart_result;

--------------------------------------------------------------------------------
-- KPI: Data Quality Pass Rate
--------------------------------------------------------------------------------

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'Data Quality Pass Rate',
    'Reconcile data quality pass rate from fact_data_quality_issue to mart_reporting_trust',
    fact_result.data_quality_pass_rate,
    mart_result.data_quality_pass_rate,
    fact_result.data_quality_pass_rate - mart_result.data_quality_pass_rate,
    CASE
        WHEN ABS(fact_result.data_quality_pass_rate - mart_result.data_quality_pass_rate) < 0.0001 THEN 'passed'
        ELSE 'failed'
    END,
    'Validates check-count-based Data Quality Pass Rate as passed checks divided by total quality checks.'
FROM (
    SELECT
        CAST(SUM(passed_check_count) * 1.0 / NULLIF(SUM(quality_check_count), 0) AS DECIMAL(38,6)) AS data_quality_pass_rate
    FROM gold.fact_data_quality_issue
) fact_result
CROSS JOIN (
    SELECT
        CAST(SUM(passed_check_count) * 1.0 / NULLIF(SUM(quality_check_count), 0) AS DECIMAL(38,6)) AS data_quality_pass_rate
    FROM gold.mart_reporting_trust
) mart_result;

INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'Data Quality Pass Rate',
    'Reconcile passed and failed quality-check counts',
    fact_result.passed_checks,
    mart_result.passed_checks,
    fact_result.passed_checks - mart_result.passed_checks,
    CASE
        WHEN fact_result.passed_checks = mart_result.passed_checks
         AND fact_result.failed_checks = mart_result.failed_checks
         AND fact_result.quality_checks = mart_result.quality_checks
        THEN 'passed'
        ELSE 'failed'
    END,
    CONCAT(
        'Passed fact=', fact_result.passed_checks,
        '; passed mart=', mart_result.passed_checks,
        '; failed fact=', fact_result.failed_checks,
        '; failed mart=', mart_result.failed_checks,
        '; checks fact=', fact_result.quality_checks,
        '; checks mart=', mart_result.quality_checks,
        '.'
    )
FROM (
    SELECT
        CAST(SUM(quality_check_count) AS DECIMAL(38,6)) AS quality_checks,
        CAST(SUM(passed_check_count) AS DECIMAL(38,6)) AS passed_checks,
        CAST(SUM(failed_check_count) AS DECIMAL(38,6)) AS failed_checks
    FROM gold.fact_data_quality_issue
) fact_result
CROSS JOIN (
    SELECT
        CAST(SUM(quality_check_count) AS DECIMAL(38,6)) AS quality_checks,
        CAST(SUM(passed_check_count) AS DECIMAL(38,6)) AS passed_checks,
        CAST(SUM(failed_check_count) AS DECIMAL(38,6)) AS failed_checks
    FROM gold.mart_reporting_trust
) mart_result;

--------------------------------------------------------------------------------
-- KPI: API Resource Coverage
--------------------------------------------------------------------------------

WITH api_scope AS (
    SELECT 'Patient' AS resource_name, 'api.vw_fhir_patient' AS object_name
    UNION ALL
    SELECT 'Encounter', 'api.vw_fhir_encounter'
    UNION ALL
    SELECT 'Observation', 'api.vw_fhir_observation'
    UNION ALL
    SELECT 'Condition', 'api.vw_fhir_condition'
),
api_coverage AS (
    SELECT
        COUNT(*) AS selected_resource_count,
        SUM(CASE WHEN OBJECT_ID(object_name, 'V') IS NOT NULL THEN 1 ELSE 0 END) AS implemented_resource_count
    FROM api_scope
)
INSERT INTO #kpi_validation_results (
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
)
SELECT
    'API Resource Coverage',
    'Calculate API/FHIR view coverage for selected resources',
    CAST(implemented_resource_count AS DECIMAL(38,6)) / NULLIF(CAST(selected_resource_count AS DECIMAL(38,6)), 0),
    CAST(1.000000 AS DECIMAL(38,6)),
    CAST(implemented_resource_count AS DECIMAL(38,6)) - CAST(selected_resource_count AS DECIMAL(38,6)),
    CASE
        WHEN implemented_resource_count = selected_resource_count THEN 'passed'
        WHEN implemented_resource_count = 0 THEN 'not_implemented'
        ELSE 'partial'
    END,
    CONCAT(
        'Implemented API/FHIR views=', implemented_resource_count,
        ' of selected resources=', selected_resource_count,
        '. This validates coverage only and does not imply full FHIR server compliance.'
    )
FROM api_coverage;

--------------------------------------------------------------------------------
-- Output
--------------------------------------------------------------------------------

SELECT
    kpi_name,
    validation_query_name,
    source_value,
    comparison_value,
    variance_value,
    validation_status,
    validation_detail
FROM #kpi_validation_results
ORDER BY
    CASE
        WHEN validation_status = 'failed' THEN 0
        WHEN validation_status IN ('partial', 'not_implemented') THEN 1
        ELSE 2
    END,
    kpi_name,
    validation_query_name;

SELECT
    validation_status,
    COUNT(*) AS validation_count
FROM #kpi_validation_results
GROUP BY validation_status
ORDER BY validation_status;

SELECT
    kpi_name,
    COUNT(*) AS validation_query_count,
    SUM(CASE WHEN validation_status = 'passed' THEN 1 ELSE 0 END) AS passed_query_count,
    SUM(CASE WHEN validation_status = 'failed' THEN 1 ELSE 0 END) AS failed_query_count,
    SUM(CASE WHEN validation_status IN ('partial', 'not_implemented') THEN 1 ELSE 0 END) AS implementation_pending_query_count
FROM #kpi_validation_results
GROUP BY kpi_name
ORDER BY kpi_name;
GO
