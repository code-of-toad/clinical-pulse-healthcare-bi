from pathlib import Path
import re
import sys


DOC_PATH = Path("docs/data_asset_catalog.md")

REQUIRED_SUBSTRINGS = [
    "# ClinicalPulse Data Asset Catalog",
    "AB#1566 - Create data asset catalog",
    "AB#1567 - Draft/build artifact for Create data asset catalog",
    "AB#1568 - Validate and document Create data asset catalog",
    "ClinicalPulse uses synthetic Synthea data",
    "## 6. Bronze Layer Assets",
    "## 7. Silver Layer Assets",
    "## 8. Gold Dimension Assets",
    "## 9. Gold Fact Assets",
    "## 10. Gold Mart and View Assets",
    "## 11. Governance and Audit Assets",
    "## 12. Power BI Reporting Assets",
    "## 13. Planned API / FHIR Demonstration Assets",
    "## 16. Assumptions",
    "## 17. Limitations",
]

REQUIRED_ASSETS = [
    "bronze.patients",
    "bronze.encounters",
    "bronze.conditions",
    "bronze.observations",
    "bronze.procedures",
    "bronze.organizations",
    "bronze.providers",
    "silver.patient",
    "silver.encounter",
    "silver.condition",
    "silver.observation",
    "silver.procedure",
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
    "governance.quality_rule",
    "governance.quality_check_result",
    "governance.vw_quality_check_current",
    "audit.ingestion_batch",
    "audit.ingestion_file_log",
    "api.vw_fhir_patient",
    "api.vw_fhir_encounter",
    "api.vw_fhir_observation",
    "api.vw_fhir_condition",
]

REQUIRED_POWER_BI_ASSETS = [
    "ClinicalPulse Power BI semantic model",
    "Executive Overview",
    "Patient Flow",
    "Readmissions",
    "Conditions & Procedures",
    "Lab / Observation Operations",
    "Data Quality & Governance",
    "FHIR API Demonstration",
]

REQUIRED_FIELD_LABELS = [
    "Asset name",
    "Asset type",
    "Grain / purpose",
    "Current status",
    "Owner role",
    "Steward role",
    "Upstream assets",
    "Downstream usage",
    "Validation / trust notes",
    "Usage notes",
]

EXPECTED_API_STATUS_PHRASES = [
    "API/FHIR views are planned",
    "Not implemented",
    "Expected pending asset",
]

EXPECTED_SAFETY_PHRASES = [
    "not real patient records",
    "not be interpreted as real hospital performance",
    "not intended for clinical-decision support",
    "synthetic",
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

    failures.extend(check_contains(text, REQUIRED_SUBSTRINGS, "required section/content"))
    failures.extend(check_contains(text, REQUIRED_ASSETS, "cataloged data asset"))
    failures.extend(check_contains(text, REQUIRED_POWER_BI_ASSETS, "Power BI asset"))
    failures.extend(check_contains(text, REQUIRED_FIELD_LABELS, "catalog field label"))
    failures.extend(check_normalized_contains(text, EXPECTED_API_STATUS_PHRASES, "API status phrase"))
    failures.extend(check_normalized_contains(text, EXPECTED_SAFETY_PHRASES, "portfolio-safety phrase"))

    markdown_table_count = text.count("|---")
    if markdown_table_count < 10:
        failures.append(
            f"Expected at least 10 markdown tables for catalog coverage; found {markdown_table_count}."
        )

    if "Power BI should connect to gold schema tables/views" not in text:
        failures.append("Missing explicit Power BI-to-gold-source guidance.")

    if "assumptions" not in normalize(text) or "limitations" not in normalize(text):
        failures.append("Missing assumptions and limitations coverage.")

    if failures:
        print("FAIL: data asset catalog validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: docs/data_asset_catalog.md exists and satisfies AB#1566 acceptance criteria.")
    print(f"Validated asset references: {len(REQUIRED_ASSETS)}")
    print(f"Validated Power BI asset references: {len(REQUIRED_POWER_BI_ASSETS)}")
    print("Validated sections: purpose, traceability, scope, catalog fields, ownership, asset groups, assumptions, and limitations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
