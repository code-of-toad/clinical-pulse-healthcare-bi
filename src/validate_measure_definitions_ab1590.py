from pathlib import Path
import re
import sys


DOC_PATH = Path("powerbi/measure_definitions.md")

REQUIRED_SECTIONS = [
    "# ClinicalPulse Power BI Measure Definitions",
    "## 2. Artifact Traceability",
    "## 3. Power BI Implementation Steps for AB#1588",
    "## 4. Measure Summary",
    "## 5. Core Encounter Measures",
    "## 6. Readmission Measures",
    "## 7. Activity Volume Measures",
    "## 8. Data Quality Measures",
    "## 9. API/FHIR Demonstration Measure",
    "## 10. Formatting Standards",
    "## 11. Local Sanity Checks After Creating Measures",
    "## 12. Assumptions",
    "## 13. Limitations",
]

REQUIRED_TRACEABILITY = [
    "AB#1588 - Document DAX measure definitions",
    "AB#1589 - Draft/build artifact for Document DAX measure definitions",
    "AB#1590 - Validate and document Document DAX measure definitions",
    "AB#1591 - Commit and link implementation evidence for Document DAX measure definitions",
]

REQUIRED_MEASURES = [
    "Total Encounters",
    "Unique Patients",
    "Average LOS",
    "Median LOS",
    "30-Day Readmissions",
    "Readmission Eligible Encounters",
    "30-Day Readmission Rate",
    "Observation Volume",
    "Procedure Volume",
    "Data Quality Checks",
    "Data Quality Checks Passed",
    "Data Quality Pass Rate",
    "API Resource Coverage",
]

REQUIRED_DAX_TERMS = [
    "```DAX",
    "SUM ( 'gold fact_encounter'[encounter_count] )",
    "DISTINCTCOUNT",
    "AVERAGEX",
    "MEDIANX",
    "COUNTROWS ( 'gold fact_readmission' )",
    "DIVIDE ( [30-Day Readmissions], [Readmission Eligible Encounters] )",
    "COUNTROWS ( 'gold fact_observation' )",
    "COUNTROWS ( 'gold fact_procedure' )",
    "COUNTROWS ( 'gold fact_data_quality_issue' )",
    "BLANK ()",
]

REQUIRED_SOURCE_OBJECTS = [
    "gold.fact_encounter",
    "gold.fact_readmission",
    "gold.fact_observation",
    "gold.fact_procedure",
    "gold.fact_data_quality_issue",
]

REQUIRED_POWERBI_ACTIONS = [
    "clinicalpulse_powerbi_reporting.pbix",
    "_Measures",
    "Home -> Enter data",
    "Modeling -> New measure",
    "whole number",
    "decimal number",
    "percentage",
]

REQUIRED_EXPECTED_VALUES = [
    "71,663",
    "1,145",
    "0.247679",
    "64.37%",
    "945,531",
    "196,207",
]

REQUIRED_SAFETY_PHRASES = [
    "not real patient records",
    "not intended for clinical-decision support",
    "synthetic",
    ".pbix` file remains local",
    "not committed",
]

REQUIRED_LIMITATION_PHRASES = [
    "DAX-to-SQL reconciliation is handled in the next validation user story",
    "known governed duplicate-observation caveat",
    "planned-versus-unplanned",
    "API/FHIR coverage is documented as planned scope",
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
    failures.extend(check_contains(text, REQUIRED_MEASURES, "DAX measure"))
    failures.extend(check_contains(text, REQUIRED_DAX_TERMS, "DAX expression term"))
    failures.extend(check_contains(text, REQUIRED_SOURCE_OBJECTS, "source object"))
    failures.extend(check_contains(text, REQUIRED_POWERBI_ACTIONS, "Power BI implementation action"))
    failures.extend(check_contains(text, REQUIRED_EXPECTED_VALUES, "sanity-check expected value"))
    failures.extend(check_normalized_contains(text, REQUIRED_SAFETY_PHRASES, "portfolio-safety phrase"))
    failures.extend(check_normalized_contains(text, REQUIRED_LIMITATION_PHRASES, "limitation / scope phrase"))

    dax_block_count = text.count("```DAX")
    if dax_block_count < 10:
        failures.append(f"Expected at least 10 DAX code blocks; found {dax_block_count}.")

    markdown_table_count = text.count("|---")
    if markdown_table_count < 8:
        failures.append(f"Expected at least 8 markdown tables; found {markdown_table_count}.")

    if "Assumptions" not in text or "Limitations" not in text:
        failures.append("Missing assumptions and limitations coverage.")

    if failures:
        print("FAIL: DAX measure definitions validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: powerbi/measure_definitions.md exists and satisfies AB#1588 acceptance criteria.")
    print(f"Validated documented measures: {len(REQUIRED_MEASURES)}")
    print(f"Validated DAX code blocks: {dax_block_count}")
    print("Validated Power BI implementation steps, formatting guidance, source objects, sanity checks, assumptions, and limitations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
