from pathlib import Path
import re
import sys


DOC_PATH = Path("docs/powerbi_validation_log.md")

REQUIRED_SECTIONS = [
    "# ClinicalPulse Power BI Validation Log",
    "## 2. Artifact Traceability",
    "## 3. Validation Scope",
    "## 4. Actual Power BI Steps for AB#1592",
    "## 5. SQL Baseline Queries",
    "## 6. DAX-to-SQL Reconciliation Results",
    "## 7. Validation Result Summary",
    "## 8. Evidence Notes",
    "## 9. Assumptions",
    "## 10. Limitations",
]

REQUIRED_TRACEABILITY = [
    "AB#1592 - Validate DAX measures against SQL outputs",
    "AB#1593 - Draft/build artifact for Validate DAX measures against SQL outputs",
    "AB#1594 - Validate and document Validate DAX measures against SQL outputs",
    "AB#1595 - Commit and link implementation evidence for Validate DAX measures against SQL outputs",
]

REQUIRED_MEASURES = [
    "Total Encounters",
    "Unique Patients",
    "Average LOS",
    "30-Day Readmission Rate",
    "Observation Volume",
    "Procedure Volume",
    "Data Quality Checks",
    "Data Quality Checks Passed",
    "Data Quality Pass Rate",
    "API Resource Coverage",
]

REQUIRED_BASELINE_VALUES = [
    "71,663",
    "1,145",
    "0.247679",
    "0.25 displayed",
    "64.37%",
    "945,531",
    "196,207",
    "20",
    "19",
    "95.00%",
    "Blank",
]

REQUIRED_SQL_TERMS = [
    "FROM gold.fact_encounter",
    "FROM gold.fact_readmission",
    "FROM gold.fact_observation",
    "FROM gold.fact_procedure",
    "FROM gold.fact_data_quality_issue",
    "SUM(encounter_count)",
    "COUNT(DISTINCT patient_key)",
    "length_of_stay_days",
    "is_30_day_readmission",
    "check_status",
]

REQUIRED_POWERBI_ACTIONS = [
    "clinicalpulse_powerbi_reporting.pbix",
    "Scratch - KPI Validation",
    "clear all slicers",
    "clear all visual filters",
    "clear all page filters",
    "clear all report filters",
    "_Measures",
    "Power BI source layer: SQL Server `gold` schema",
]

REQUIRED_STATUS_TERMS = [
    "Passed",
    "Exact match",
    "Rounded display match",
    "Expected placeholder behavior",
    "Overall",
    "10",
    "0",
]

REQUIRED_SAFETY_PHRASES = [
    "not real patient records",
    "not intended for clinical-decision support",
    "synthetic",
    ".pbix` file remains local",
    "not committed",
    "credentials",
    "row-level synthetic patient detail",
]

REQUIRED_LIMITATION_PHRASES = [
    "initial unfiltered KPI reconciliation only",
    "does not replace future dashboard-level visual validation",
    "Median LOS should be checked",
    "planned from unplanned readmissions",
    "known governed duplicate-observation caveat",
    "API Resource Coverage remains a placeholder",
]


def normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip().lower()


def check_contains(text: str, required_values: list[str], label: str) -> list[str]:
    failures = []
    for value in required_values:
        if value not in text:
            failures.append(f"Missing {label}: {value}")
    return failures


def check_normalized_contains(text: str, required_values: list[str], label: str) -> list[str]:
    normalized_text = normalize(text)
    failures = []
    for value in required_values:
        if normalize(value) not in normalized_text:
            failures.append(f"Missing {label}: {value}")
    return failures


def main() -> int:
    failures: list[str] = []

    if not DOC_PATH.exists():
        print(f"FAIL: Required deliverable not found: {DOC_PATH}")
        return 1

    text = DOC_PATH.read_text(encoding="utf-8")

    failures.extend(check_contains(text, REQUIRED_SECTIONS, "required section"))
    failures.extend(check_contains(text, REQUIRED_TRACEABILITY, "Azure Boards traceability"))
    failures.extend(check_contains(text, REQUIRED_MEASURES, "validated measure"))
    failures.extend(check_contains(text, REQUIRED_BASELINE_VALUES, "baseline/reconciliation value"))
    failures.extend(check_contains(text, REQUIRED_SQL_TERMS, "SQL validation term"))
    failures.extend(check_contains(text, REQUIRED_POWERBI_ACTIONS, "Power BI validation action/evidence"))
    failures.extend(check_contains(text, REQUIRED_STATUS_TERMS, "validation status term"))
    failures.extend(check_normalized_contains(text, REQUIRED_SAFETY_PHRASES, "portfolio-safety phrase"))
    failures.extend(check_normalized_contains(text, REQUIRED_LIMITATION_PHRASES, "limitation / scope phrase"))

    sql_block_count = text.count("```sql")
    if sql_block_count < 8:
        failures.append(f"Expected at least 8 SQL code blocks; found {sql_block_count}.")

    markdown_table_count = text.count("|---")
    if markdown_table_count < 6:
        failures.append(f"Expected at least 6 markdown tables; found {markdown_table_count}.")

    passed_count = len(re.findall(r"\|\s*`?[^|]+`?\s*\|[^|]+\|[^|]+\|[^|]+\|\s*Passed\s*\|", text))
    if passed_count < 8:
        failures.append(f"Expected at least 8 passed reconciliation rows; found {passed_count}.")

    if "Assumptions" not in text or "Limitations" not in text:
        failures.append("Missing assumptions and limitations coverage.")

    if failures:
        print("FAIL: Power BI validation log validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: docs/powerbi_validation_log.md exists and satisfies AB#1592 acceptance criteria.")
    print(f"Validated DAX-to-SQL measures documented: {len(REQUIRED_MEASURES)}")
    print(f"Validated SQL baseline query blocks: {sql_block_count}")
    print(f"Validated passed reconciliation rows: {passed_count}")
    print("Validated Power BI evidence notes, SQL baselines, reconciliation statuses, assumptions, and limitations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
