from pathlib import Path
import re
import sys


DOC_PATH = Path("powerbi/semantic_model_notes.md")

REQUIRED_SECTIONS = [
    "# ClinicalPulse Power BI Semantic Model Notes",
    "# AB#1584 Semantic Model Relationships and Date Table",
    "## 15. AB#1584 Artifact Traceability",
    "## 16. Actual Power BI Steps for AB#1584",
    "### 16.2 Turn Off Auto Date/Time",
    "### 16.3 Mark `gold.dim_date` as the Date Table",
    "### 16.4 Create Relationships in Model View",
    "## 17. Model Relationship Standards",
    "## 18. Evidence to Capture for AB#1587",
    "## 19. Assumptions for AB#1584",
    "## 20. Limitations for AB#1584",
]

REQUIRED_TRACEABILITY = [
    "AB#1584 - Build relationships and date table",
    "AB#1585 - Draft/build artifact for Build relationships and date table",
    "AB#1586 - Validate and document Build relationships and date table",
    "AB#1587 - Commit and link implementation evidence for Build relationships and date table",
]

REQUIRED_POWERBI_ACTIONS = [
    "clinicalpulse_powerbi_reporting.pbix",
    "Auto date/time",
    "Mark as date table",
    "Model view",
    "Manage relationships",
    "single",
    "one-to-many",
    "active relationship",
    "gold.dim_date",
]

REQUIRED_FILTER_REQUIREMENTS = [
    "date",
    "encounter class",
    "organization",
    "age band",
    "condition group",
    "procedure group",
]

REQUIRED_RELATIONSHIP_TABLES = [
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
]

REQUIRED_STANDARDS = [
    "Single direction from dimension to fact",
    "One-to-many from dimension to fact",
    "Avoid ambiguous or circular relationships",
    "Use `gold.dim_date`, not Auto date/time hidden tables",
    "Do not create a relationship if Power BI warns that it would create ambiguity",
]

REQUIRED_EVIDENCE = [
    "Confirmation that `gold.dim_date` is marked as the date table",
    "Confirmation that Auto date/time is disabled",
    "Relationship list or screenshot of Model view",
    "Confirmation that `.pbix` remains local and uncommitted",
    "Validation script output",
]

REQUIRED_SAFETY_PHRASES = [
    "not real patient records",
    ".pbix` is not committed",
    "credentials",
    "row-level synthetic patient detail",
    "synthetic data",
]

REQUIRED_EXCLUSIONS_OR_LIMITS = [
    "Dashboard visuals, DAX measures, and final screenshots are handled in later user stories",
    "Exact relationship column names must be confirmed",
    "do not commit",
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

    failures.extend(check_contains(text, REQUIRED_SECTIONS, "required AB#1584 section"))
    failures.extend(check_contains(text, REQUIRED_TRACEABILITY, "Azure Boards traceability"))
    failures.extend(check_contains(text, REQUIRED_POWERBI_ACTIONS, "Power BI action"))
    failures.extend(check_normalized_contains(text, REQUIRED_FILTER_REQUIREMENTS, "filter requirement"))
    failures.extend(check_contains(text, REQUIRED_RELATIONSHIP_TABLES, "relationship table"))
    failures.extend(check_contains(text, REQUIRED_STANDARDS, "model relationship standard"))
    failures.extend(check_contains(text, REQUIRED_EVIDENCE, "implementation evidence item"))
    failures.extend(check_normalized_contains(text, REQUIRED_SAFETY_PHRASES, "portfolio safety phrase"))
    failures.extend(check_contains(text, REQUIRED_EXCLUSIONS_OR_LIMITS, "scope limitation"))

    relationship_rows = len(re.findall(r"\| `gold\.dim_", text))
    if relationship_rows < 8:
        failures.append(
            f"Expected at least 8 relationship-plan rows referencing gold dimensions; found {relationship_rows}."
        )

    if "Assumptions for AB#1584" not in text or "Limitations for AB#1584" not in text:
        failures.append("Missing AB#1584 assumptions and limitations coverage.")

    if failures:
        print("FAIL: Power BI relationships/date table validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: powerbi/semantic_model_notes.md satisfies AB#1584 relationship/date table acceptance criteria.")
    print(f"Validated relationship/source tables documented: {len(REQUIRED_RELATIONSHIP_TABLES)}")
    print("Validated date table marking, Auto date/time guidance, relationship standards, slicer support, evidence notes, assumptions, and limitations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
