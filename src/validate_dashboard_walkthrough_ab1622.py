from pathlib import Path
import sys

DOC_PATH = Path("docs/dashboard_walkthrough.md")
SCREENSHOT_DIR = Path("powerbi/screenshots")

SCREENSHOT_PATHS = [
    Path("powerbi/screenshots/executive_overview.png"),
    Path("powerbi/screenshots/patient_flow.png"),
    Path("powerbi/screenshots/length_of_stay.png"),
    Path("powerbi/screenshots/readmissions.png"),
    Path("powerbi/screenshots/conditions_procedures.png"),
    Path("powerbi/screenshots/lab_operations.png"),
    Path("powerbi/screenshots/data_quality_governance.png"),
]

REQUIRED_TEXT = [
    "AB#1620 - Create screenshot documentation",
    "AB#1621 - Draft/build artifact for Create screenshot documentation",
    "AB#1622 - Validate and document Create screenshot documentation",
    "powerbi/screenshots/",
    "docs/dashboard_walkthrough.md",
    "powerbi/screenshots/executive_overview.png",
    "powerbi/screenshots/patient_flow.png",
    "powerbi/screenshots/length_of_stay.png",
    "powerbi/screenshots/readmissions.png",
    "powerbi/screenshots/conditions_procedures.png",
    "powerbi/screenshots/lab_operations.png",
    "powerbi/screenshots/data_quality_governance.png",
    "not real patient records",
    "not intended for clinical-decision support",
    "synthetic",
    "PBIX safety",
    "Credential safety",
    "Row-level safety",
    "FHIR/API interoperability remains documented as future extension scope",
    "Observation volume should be interpreted with the governed duplicate-record caveat",
]

REQUIRED_SECTIONS = [
    "# ClinicalPulse Dashboard Walkthrough",
    "## 2. Artifact Traceability",
    "## 3. Screenshot Inventory",
    "## 4. Screenshot Standards",
    "## 5. Common Reporting Window",
    "## 6. Dashboard Page Walkthrough",
    "## 7. Deferred Dashboard Scope",
    "## 8. Assumptions",
    "## 9. Limitations",
]


def read_png_dimensions(path: Path) -> tuple[int | None, int | None]:
    with path.open("rb") as f:
        header = f.read(24)
    png_signature = b"\x89PNG\r\n\x1a\n"
    if len(header) < 24 or not header.startswith(png_signature):
        return None, None
    return (
        int.from_bytes(header[16:20], byteorder="big"),
        int.from_bytes(header[20:24], byteorder="big"),
    )


def main() -> int:
    failures: list[str] = []

    if not DOC_PATH.exists():
        print(f"FAIL: Required deliverable not found: {DOC_PATH}")
        return 1

    if not SCREENSHOT_DIR.exists():
        failures.append(f"Missing screenshot directory: {SCREENSHOT_DIR}")

    text = DOC_PATH.read_text(encoding="utf-8")

    for section in REQUIRED_SECTIONS:
        if section not in text:
            failures.append(f"Missing required section: {section}")

    for required in REQUIRED_TEXT:
        if required not in text:
            failures.append(f"Missing required documentation content: {required}")

    for screenshot_path in SCREENSHOT_PATHS:
        if not screenshot_path.exists():
            failures.append(f"Missing screenshot file: {screenshot_path}")
            continue

        width, height = read_png_dimensions(screenshot_path)
        if width is None or height is None:
            failures.append(f"Screenshot is not a valid PNG file: {screenshot_path}")
            continue

        if width < 1000 or height < 600:
            failures.append(f"Screenshot dimensions too small for {screenshot_path}: {width}x{height}")

        if screenshot_path.stat().st_size < 50_000:
            failures.append(f"Screenshot file unexpectedly small for {screenshot_path}: {screenshot_path.stat().st_size} bytes")

    table_count = text.count("|---")
    if table_count < 8:
        failures.append(f"Expected at least 8 markdown tables; found {table_count}.")

    if failures:
        print("FAIL: Dashboard walkthrough validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: docs/dashboard_walkthrough.md satisfies AB#1620 acceptance criteria.")
    print(f"Validated screenshot folder: {SCREENSHOT_DIR}")
    print(f"Validated documented screenshots: {len(SCREENSHOT_PATHS)}")
    print("Validated screenshot walkthrough, portfolio-safety notes, deferred FHIR/API scope, assumptions, and limitations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
