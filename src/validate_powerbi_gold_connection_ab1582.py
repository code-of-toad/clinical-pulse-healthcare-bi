from pathlib import Path
import re
import sys


DOC_PATH = Path("powerbi/semantic_model_notes.md")

REQUIRED_SECTIONS = [
    "# ClinicalPulse Power BI Semantic Model Notes",
    "## 2. Artifact Traceability",
    "## 3. Connection Decision",
    "## 4. Why the Gold Schema Is the Power BI Source",
    "## 5. Explicitly Excluded Sources",
    "## 6. Gold Tables and Views Available for Power BI",
    "## 7. Initial Import Plan",
    "## 8. Power BI Desktop Connection Steps",
    "## 9. Connection Validation Checklist",
    "## 10. Evidence to Capture for AB#1583",
    "## 11. Relationship to Future Power BI Stories",
    "## 12. Assumptions",
    "## 13. Limitations",
]

REQUIRED_TRACEABILITY = [
    "AB#1580 - Connect Power BI to SQL Server gold schema",
    "AB#1581 - Draft/build artifact for Connect Power BI to SQL Server gold schema",
    "AB#1582 - Validate and document Connect Power BI to SQL Server gold schema",
    "AB#1583 - Commit and link implementation evidence for Connect Power BI to SQL Server gold schema",
]

REQUIRED_CONNECTION_TERMS = [
    "Power BI Desktop",
    "SQL Server",
    "gold",
    "Import mode",
    "ClinicalPulse SQL Server database",
    "Power BI should connect to SQL Server gold schema tables/views",
    "Use gold schema tables/views only for Power BI reporting",
]

REQUIRED_EXCLUSIONS = [
    "Raw Synthea CSV files",
    "Local unmanaged CSV exports",
    "`bronze` schema tables",
    "`silver` schema tables",
    "Manual spreadsheet copies",
    "do not commit `.pbix` files",
    "do not commit credentials",
]

REQUIRED_GOLD_OBJECTS = [
    "gold.dim_patient",
    "gold.dim_date",
    "gold.dim_organization",
    "gold.dim_provider",
    "gold.dim_encounter_class",
    "gold.dim_condition",
    "gold.dim_observation",
    "gold.dim_procedure",
    "gold.fact_encounter",
    "gold.fact_readmission",
    "gold.fact_condition",
    "gold.fact_observation",
    "gold.fact_procedure",
    "gold.fact_data_quality_issue",
    "gold.mart_patient_flow",
    "gold.mart_length_of_stay",
    "gold.mart_readmissions",
    "gold.mart_lab_operations",
    "gold.mart_service_utilization",
    "gold.mart_reporting_trust",
]

REQUIRED_ROW_COUNTS = [
    "1,145",
    "40,365",
    "71,663",
    "945,531",
    "196,207",
    "935,704",
]

REQUIRED_FUTURE_STORIES = [
    "Build relationships and date table",
    "Document DAX measure definitions",
    "Validate DAX measures against SQL outputs",
    "Build dashboard pages",
    "Create screenshot documentation",
]

REQUIRED_SAFETY_PHRASES = [
    "not real patient records",
    "not intended for clinical-decision support",
    "synthetic",
    "not raw files",
    "bronze tables",
    "unmanaged extracts",
    "credentials",
    "connection strings",
    ".pbix",
    "aggregate views",
]

REQUIRED_VALIDATION_ITEMS = [
    "Raw CSV files used?",
    "`bronze` tables used?",
    "`silver` tables used as reporting source?",
    "Gold dimensions available",
    "Gold facts available",
    "Credentials committed?",
    "`.pbix` committed?",
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
    failures.extend(check_contains(text, REQUIRED_CONNECTION_TERMS, "connection decision"))
    failures.extend(check_contains(text, REQUIRED_EXCLUSIONS, "excluded source / safety rule"))
    failures.extend(check_contains(text, REQUIRED_GOLD_OBJECTS, "gold object"))
    failures.extend(check_contains(text, REQUIRED_ROW_COUNTS, "gold row count"))
    failures.extend(check_contains(text, REQUIRED_FUTURE_STORIES, "future Power BI dependency"))
    failures.extend(check_contains(text, REQUIRED_VALIDATION_ITEMS, "connection validation checklist item"))
    failures.extend(check_normalized_contains(text, REQUIRED_SAFETY_PHRASES, "portfolio-safety phrase"))

    markdown_table_count = text.count("|---")
    if markdown_table_count < 8:
        failures.append(
            f"Expected at least 8 markdown tables for connection notes and inventory; found {markdown_table_count}."
        )

    if "Assumptions" not in text or "Limitations" not in text:
        failures.append("Missing assumptions and limitations coverage.")

    if "bronze." in text or "silver." in text:
        failures.append("Do not list bronze.* or silver.* objects as Power BI sources in this connection artifact.")

    if failures:
        print("FAIL: Power BI gold connection validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: powerbi/semantic_model_notes.md exists and satisfies AB#1580 acceptance criteria.")
    print(f"Validated gold objects documented for Power BI: {len(REQUIRED_GOLD_OBJECTS)}")
    print("Validated SQL Server source, gold-schema-only rule, raw/bronze/silver exclusions, Import mode, evidence notes, assumptions, and limitations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
