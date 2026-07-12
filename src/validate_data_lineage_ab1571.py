from pathlib import Path
import re
import sys


DOC_PATH = Path("docs/data_lineage.md")

REQUIRED_SECTIONS = [
    "# ClinicalPulse Data Lineage Document",
    "## 2. Artifact Traceability",
    "## 3. Lineage Scope",
    "## 4. End-to-End Lineage Overview",
    "## 5. Layer Responsibilities",
    "## 6. Source-to-Bronze-to-Silver-to-Gold Lineage",
    "## 7. Bronze-to-Silver Transformation Lineage",
    "## 8. Silver-to-Gold Transformation Lineage",
    "## 9. KPI Lineage",
    "## 10. Power BI Dashboard Lineage",
    "## 11. Planned API / FHIR Lineage",
    "## 12. Quality and Validation Lineage",
    "## 14. Assumptions",
    "## 15. Limitations",
]

REQUIRED_TRACEABILITY = [
    "AB#1569 - Create data lineage document",
    "AB#1570 - Draft/build artifact for Create data lineage document",
    "AB#1571 - Validate and document Create data lineage document",
]

REQUIRED_LAYER_TERMS = [
    "Synthea CSV source files",
    "SQL Server bronze",
    "SQL Server silver",
    "SQL Server gold",
    "Power BI semantic model",
    "planned API/FHIR views",
]

REQUIRED_SOURCE_CHAINS = [
    ["patients.csv", "bronze.patients", "silver.patient", "gold.dim_patient", "Patient"],
    ["encounters.csv", "bronze.encounters", "silver.encounter", "gold.fact_encounter", "gold.fact_readmission", "Encounter"],
    ["conditions.csv", "bronze.conditions", "silver.condition", "gold.fact_condition", "gold.dim_condition", "Condition"],
    ["observations.csv", "bronze.observations", "silver.observation", "gold.fact_observation", "gold.dim_observation", "Observation"],
    ["procedures.csv", "bronze.procedures", "silver.procedure", "gold.fact_procedure", "gold.dim_procedure"],
    ["organizations.csv", "bronze.organizations", "gold.dim_organization"],
    ["providers.csv", "bronze.providers", "gold.dim_provider"],
]

REQUIRED_GOLD_ASSETS = [
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

REQUIRED_KPIS = [
    "Total Encounters",
    "Unique Patients",
    "Average Length of Stay",
    "Median Length of Stay",
    "30-Day Readmission Rate",
    "Observation Volume",
    "Procedure Volume",
    "Data Quality Pass Rate",
    "API Resource Coverage",
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

REQUIRED_API_ASSETS = [
    "api.vw_fhir_patient",
    "api.vw_fhir_encounter",
    "api.vw_fhir_observation",
    "api.vw_fhir_condition",
    "GET /fhir/Patient/{patient_id}",
    "GET /fhir/Encounter/{encounter_id}",
    "GET /fhir/Observation?patient={patient_id}",
    "GET /fhir/Condition?patient={patient_id}",
]

REQUIRED_GOVERNANCE_ASSETS = [
    "governance.quality_rule",
    "governance.vw_quality_check_current",
    "governance.quality_check_result",
    "audit.ingestion_batch",
    "audit.ingestion_file_log",
]

REQUIRED_SAFETY_PHRASES = [
    "not real patient records",
    "not intended for clinical-decision support",
    "synthetic",
]

REQUIRED_GUIDANCE_PHRASES = [
    "Power BI should connect to gold schema tables/views",
    "not a certified production FHIR server",
    "planned and should not be treated as failed Sprint 6 reporting deliverables",
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


def check_source_chains(text: str) -> list[str]:
    failures = []
    for chain in REQUIRED_SOURCE_CHAINS:
        missing_parts = [part for part in chain if part not in text]
        if missing_parts:
            failures.append(
                "Missing lineage chain parts: "
                + " -> ".join(chain)
                + f" | Missing: {', '.join(missing_parts)}"
            )
    return failures


def main() -> int:
    failures: list[str] = []

    if not DOC_PATH.exists():
        print(f"FAIL: Required deliverable not found: {DOC_PATH}")
        return 1

    text = DOC_PATH.read_text(encoding="utf-8")

    failures.extend(check_contains(text, REQUIRED_SECTIONS, "required section"))
    failures.extend(check_contains(text, REQUIRED_TRACEABILITY, "Azure Boards traceability"))
    failures.extend(check_contains(text, REQUIRED_LAYER_TERMS, "lineage layer term"))
    failures.extend(check_source_chains(text))
    failures.extend(check_contains(text, REQUIRED_GOLD_ASSETS, "gold asset"))
    failures.extend(check_contains(text, REQUIRED_KPIS, "KPI lineage entry"))
    failures.extend(check_contains(text, REQUIRED_DASHBOARD_PAGES, "dashboard lineage entry"))
    failures.extend(check_contains(text, REQUIRED_API_ASSETS, "API/FHIR lineage asset"))
    failures.extend(check_contains(text, REQUIRED_GOVERNANCE_ASSETS, "governance/audit lineage asset"))
    failures.extend(check_normalized_contains(text, REQUIRED_SAFETY_PHRASES, "portfolio-safety phrase"))
    failures.extend(check_normalized_contains(text, REQUIRED_GUIDANCE_PHRASES, "lineage guidance phrase"))

    if "```mermaid" not in text:
        failures.append("Missing Mermaid end-to-end lineage diagram.")

    markdown_table_count = text.count("|---")
    if markdown_table_count < 10:
        failures.append(
            f"Expected at least 10 markdown tables for lineage coverage; found {markdown_table_count}."
        )

    if "assumptions" not in normalize(text) or "limitations" not in normalize(text):
        failures.append("Missing assumptions and limitations coverage.")

    if failures:
        print("FAIL: data lineage document validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: docs/data_lineage.md exists and satisfies AB#1569 acceptance criteria.")
    print(f"Validated source-to-gold lineage chains: {len(REQUIRED_SOURCE_CHAINS)}")
    print(f"Validated gold assets: {len(REQUIRED_GOLD_ASSETS)}")
    print(f"Validated KPI lineage entries: {len(REQUIRED_KPIS)}")
    print(f"Validated dashboard lineage entries: {len(REQUIRED_DASHBOARD_PAGES)}")
    print(f"Validated planned API/FHIR lineage assets and endpoints: {len(REQUIRED_API_ASSETS)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
