from pathlib import Path
import re
import sys

DOC_PATH = Path("docs/report_design_checklist.md")

REQUIRED_TEXT = [
    "AB#1626 - Finalize report UX and accessibility checks",
    "AB#1627 - Draft/build artifact for Finalize report UX and accessibility checks",
    "AB#1628 - Validate and document Finalize report UX and accessibility checks",
    "docs/report_design_checklist.md",
    "Executive Overview",
    "Patient Flow",
    "Length of Stay",
    "Readmissions",
    "Conditions & Procedures",
    "Lab / Observation Operations",
    "Data Quality & Governance",
    "Readability Checklist",
    "Accessibility Checklist",
    "Visual Design Checklist",
    "Portfolio Safety Checklist",
    "not real patient records",
    "not intended for clinical-decision support",
    "synthetic",
    "PBIX safety",
    ".pbix file remains local",
    "FHIR/API demonstration was deferred from v1.0",
    "Observation duplicate-record caveat",
    "Full accessibility certification",
    "Not claimed",
]

REQUIRED_SECTIONS = [
    "# ClinicalPulse Report Design Checklist",
    "## 2. Artifact Traceability",
    "## 3. Reviewed Dashboard Pages",
    "## 4. Overall Design Standard",
    "## 5. Page-Level UX Review",
    "## 6. Readability Checklist",
    "## 7. Accessibility Checklist",
    "## 8. Visual Design Checklist",
    "## 9. Portfolio Safety Checklist",
    "## 10. Final UX Review Summary",
    "## 11. Assumptions",
    "## 12. Limitations",
    "## 13. Final Decision",
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
            failures.append(f"Missing required checklist content: {required}")

    table_count = text.count("|---")
    if table_count < 9:
        failures.append(f"Expected at least 9 markdown tables; found {table_count}.")

    passed_count = len(re.findall(r"\| Passed \|", text))
    if passed_count < 25:
        failures.append(f"Expected at least 25 passed checklist rows; found {passed_count}.")

    if "Not performed" not in text:
        failures.append("Missing explicit limitation for manual accessibility testing not performed.")

    if "Not claimed" not in text:
        failures.append("Missing explicit statement that full accessibility certification is not claimed.")

    if failures:
        print("FAIL: Report design checklist validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: docs/report_design_checklist.md satisfies AB#1626 acceptance criteria.")
    print("Validated UX, readability, accessibility, portfolio-safety, assumptions, and limitations.")
    print("Validated reviewed dashboard pages: 7")
    print("Validated checklist passed rows: " + str(passed_count))
    return 0


if __name__ == "__main__":
    sys.exit(main())
