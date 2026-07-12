from pathlib import Path
import re
import sys


DOC_PATH = Path("docs/data_asset_scorecards.md")

REQUIRED_SECTIONS = [
    "# ClinicalPulse Data Asset Scorecards",
    "## 2. Artifact Traceability",
    "## 3. Scope",
    "## 4. Rating Scale",
    "## 5. Scorecard Dimensions",
    "## 6. Overall Score Calculation",
    "## 7. Summary Scorecard Register",
    "## 8. Detailed Asset Scorecards",
    "## 9. Asset Readiness by Dashboard Page",
    "## 10. Governance Follow-Up Items",
    "## 11. Assumptions",
    "## 12. Limitations",
]

REQUIRED_TRACEABILITY = [
    "AB#1572 - Create data asset scorecards",
    "AB#1573 - Draft/build artifact for Create data asset scorecards",
    "AB#1574 - Validate and document Create data asset scorecards",
]

REQUIRED_DIMENSIONS = [
    "Reliability",
    "Documentation",
    "Validation coverage",
    "Security / portfolio safety",
    "Adoption readiness",
]

REQUIRED_SCORECARD_ASSETS = [
    "gold.fact_encounter",
    "gold.fact_readmission",
    "gold.fact_observation",
    "gold.fact_procedure",
    "gold.fact_data_quality_issue",
    "gold.mart_patient_flow",
    "gold.mart_length_of_stay",
    "gold.mart_readmissions",
    "gold.mart_lab_operations",
    "gold.mart_service_utilization",
    "gold.mart_reporting_trust",
    "ClinicalPulse Power BI semantic model",
    "Executive Overview dashboard page",
    "FHIR API Demonstration assets",
]

REQUIRED_DASHBOARD_PAGES = [
    "Executive Overview",
    "Patient Flow",
    "Readmissions",
    "Conditions & Procedures",
    "Lab / Observation Operations",
    "Data Quality & Governance",
    "FHIR API Demonstration",
]

REQUIRED_READINESS_STATUSES = [
    "Ready",
    "Ready with minor caveats",
    "Internal use / needs review",
    "Limited readiness",
]

REQUIRED_SAFETY_PHRASES = [
    "not real patient records",
    "not intended for clinical-decision support",
    "synthetic",
]

REQUIRED_CAVEATS = [
    "observation duplicate",
    "planned versus unplanned",
    "not a certified production FHIR server",
    "Power BI should connect to gold schema tables/views",
]

REQUIRED_FIELD_LABELS = [
    "Asset type",
    "Primary purpose",
    "Overall score",
    "Readiness status",
    "Assumptions / limitations",
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
    failures.extend(check_contains(text, REQUIRED_DIMENSIONS, "scorecard dimension"))
    failures.extend(check_contains(text, REQUIRED_SCORECARD_ASSETS, "scored asset"))
    failures.extend(check_contains(text, REQUIRED_DASHBOARD_PAGES, "dashboard readiness mapping"))
    failures.extend(check_contains(text, REQUIRED_READINESS_STATUSES, "readiness status"))
    failures.extend(check_contains(text, REQUIRED_FIELD_LABELS, "scorecard field label"))
    failures.extend(check_normalized_contains(text, REQUIRED_SAFETY_PHRASES, "portfolio-safety phrase"))
    failures.extend(check_normalized_contains(text, REQUIRED_CAVEATS, "required caveat"))

    markdown_table_count = text.count("|---")
    if markdown_table_count < 10:
        failures.append(
            f"Expected at least 10 markdown tables for scorecard coverage; found {markdown_table_count}."
        )

    detailed_scorecard_count = len(re.findall(r"^### 8\.\d+", text, flags=re.MULTILINE))
    if detailed_scorecard_count < 10:
        failures.append(
            f"Expected at least 10 detailed scorecards; found {detailed_scorecard_count}."
        )

    for dimension in REQUIRED_DIMENSIONS:
        if text.count(dimension) < 2:
            failures.append(f"Expected repeated scorecard usage of dimension: {dimension}")

    if "assumptions" not in normalize(text) or "limitations" not in normalize(text):
        failures.append("Missing assumptions and limitations coverage.")

    if failures:
        print("FAIL: data asset scorecards validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: docs/data_asset_scorecards.md exists and satisfies AB#1572 acceptance criteria.")
    print(f"Validated scored assets: {len(REQUIRED_SCORECARD_ASSETS)}")
    print(f"Validated scorecard dimensions: {len(REQUIRED_DIMENSIONS)}")
    print(f"Validated dashboard readiness mappings: {len(REQUIRED_DASHBOARD_PAGES)}")
    print(f"Validated detailed scorecards: {detailed_scorecard_count}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
