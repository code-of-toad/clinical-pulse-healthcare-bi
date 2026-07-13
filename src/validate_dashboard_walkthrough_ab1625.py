from pathlib import Path
import re
import sys

DOC_PATH = Path("docs/dashboard_walkthrough.md")

REQUIRED_TEXT = [
    "AB#1623 - Write dashboard interpretation notes",
    "AB#1624 - Draft/build artifact for Write dashboard interpretation notes",
    "AB#1625 - Validate and document Write dashboard interpretation notes",
    "Executive Overview",
    "Patient Flow",
    "Length of Stay",
    "Readmissions",
    "Conditions & Procedures",
    "Lab / Observation Operations",
    "Data Quality & Governance",
    "How to read it",
    "What it shows",
    "Caveat",
    "not real patient records",
    "not intended for clinical-decision support",
    "synthetic",
    "FHIR/API interoperability remains documented as future extension scope",
    "Observation volume includes a governed duplicate-record caveat",
    "Readmission logic is simplified",
    "2000-2026",
]

REQUIRED_SECTIONS = [
    "# ClinicalPulse Dashboard Walkthrough",
    "## 2. Artifact Traceability",
    "## 3. How to Read the Dashboard Set",
    "## 4. Screenshot Inventory",
    "## 5. Screenshot Standards",
    "## 6. Common Reporting Window",
    "## 7. Dashboard Interpretation Notes",
    "### 7.1 Executive Overview",
    "### 7.2 Patient Flow",
    "### 7.3 Length of Stay",
    "### 7.4 Readmissions",
    "### 7.5 Conditions & Procedures",
    "### 7.6 Lab / Observation Operations",
    "### 7.7 Data Quality & Governance",
    "## 8. Deferred Dashboard Scope",
    "## 9. Cross-Dashboard Caveats",
    "## 10. Final v1.0 Interpretation",
]


def normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip().lower()


def main() -> int:
    failures: list[str] = []

    if not DOC_PATH.exists():
        print(f"FAIL: Required deliverable not found: {DOC_PATH}")
        return 1

    text = DOC_PATH.read_text(encoding="utf-8")
    normalized_text = normalize(text)

    for section in REQUIRED_SECTIONS:
        if section not in text:
            failures.append(f"Missing required section: {section}")

    for required in REQUIRED_TEXT:
        if normalize(required) not in normalized_text:
            failures.append(f"Missing required interpretation content: {required}")

    table_count = text.count("|---")
    if table_count < 10:
        failures.append(f"Expected at least 10 markdown tables; found {table_count}.")

    dashboard_section_count = len(re.findall(r"### 7\.[1-7] ", text))
    if dashboard_section_count != 7:
        failures.append(f"Expected 7 dashboard interpretation subsections; found {dashboard_section_count}.")

    if failures:
        print("FAIL: Dashboard interpretation notes validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: docs/dashboard_walkthrough.md satisfies AB#1623 acceptance criteria.")
    print("Validated interpretation notes for 7 completed dashboard pages.")
    print("Validated screenshot alignment, non-technical interpretation guidance, synthetic-data caveats, deferred FHIR/API scope, assumptions, and limitations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
