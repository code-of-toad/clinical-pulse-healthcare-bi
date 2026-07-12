from pathlib import Path
import re
import sys


SECURITY_DOC = Path("docs/security_model.md")
GOVERNANCE_DOC = Path("docs/data_governance_plan.md")


SECURITY_REQUIRED = [
    "# Security Model and Public Portfolio Safety Assumptions",
    "ClinicalPulse is a portfolio demonstration project, not a production healthcare system.",
    "Synthetic Data Disclaimer",
    "Public Portfolio Safety Rules",
    "Repository Exclusion Rules",
    "Secrets and Credential Handling",
    "Role-Based Access Assumptions",
    "SQL Server Safety Assumptions",
    "Power BI Safety Assumptions",
    "FHIR/API Demonstration Safety",
    "Dashboard and Screenshot Safety",
    "Documentation Safety",
    "Local Development Assumptions",
    "Review Checklist Before Publishing",
    "Assumptions",
    "Limitations",
]

GOVERNANCE_REQUIRED = [
    "# Data Governance Plan",
    "ClinicalPulse treats governance as part of delivery.",
    "Governance Objectives",
    "Governance Principles",
    "Governance Roles and Responsibilities",
    "Governed Artifacts",
    "Data Layer Governance",
    "KPI Governance",
    "Data Quality Governance",
    "Lineage Expectations",
    "Data Asset Governance",
    "Security and Portfolio Safety Relationship",
    "FHIR and API Governance",
    "Change and Review Practices",
    "Governance Lifecycle",
    "Assumptions",
    "Limitations",
]

REQUIRED_GOVERNANCE_ROLES = [
    "Project Owner",
    "Operational Reporting Owner",
    "BI Developer",
    "Data Steward",
    "Data Platform Owner",
    "Security / Portfolio Safety Reviewer",
    "Technical Reviewer",
    "Dashboard Consumer",
]

REQUIRED_SECURITY_ROLES = [
    "BI Developer",
    "Data Steward",
    "Operational Leader",
    "Executive Viewer",
    "API Consumer",
    "Platform Administrator",
]

REQUIRED_GOVERNED_ARTIFACTS = [
    "docs/project_charter.md",
    "docs/business_requirements.md",
    "docs/stakeholder_matrix.md",
    "docs/architecture_overview.md",
    "docs/kpi_dictionary.md",
    "docs/data_governance_plan.md",
    "docs/security_model.md",
    "docs/data_lineage.md",
    "docs/data_asset_catalog.md",
    "docs/data_asset_scorecards.md",
    "docs/fhir_mapping.md",
    "powerbi/measure_definitions.md",
]

REQUIRED_LAYERS = [
    "Bronze",
    "Silver",
    "Gold",
    "Governance",
    "Audit",
    "API",
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

REQUIRED_SECURITY_AND_SAFETY_PHRASES = [
    "least-privilege",
    "does not represent real patients",
    "does not represent a real hospital population",
    "does not represent actual hospital performance",
    "must not be interpreted as clinical evidence",
    "must not be used for patient care, diagnosis, treatment, or operational decision-making",
    "Never commit",
    ".env",
    "*.pbix",
    "connect Power BI to curated gold-layer tables or views",
    "avoid building dashboards directly from raw source files",
    "aggregate visuals",
    "not certified FHIR server outputs",
    "avoid unnecessary row-level detail",
    "FHIR-aligned",
]

REQUIRED_REPOSITORY_EXCLUSIONS = [
    "data/raw/",
    "data/interim/",
    "data/processed/",
    "*.csv",
    "*.bak",
    "*.pbix",
    ".env",
    ".venv/",
]

ACCEPTANCE_COVERAGE_TERMS = [
    "ownership",
    "stewardship",
    "security",
    "least-privilege",
    "synthetic",
    "Power BI",
    "FHIR",
    "Assumptions",
    "Limitations",
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


def read_required_file(path: Path) -> tuple[str, list[str]]:
    if not path.exists():
        return "", [f"Required deliverable not found: {path}"]
    return path.read_text(encoding="utf-8"), []


def main() -> int:
    failures: list[str] = []

    security_text, security_file_failures = read_required_file(SECURITY_DOC)
    governance_text, governance_file_failures = read_required_file(GOVERNANCE_DOC)

    failures.extend(security_file_failures)
    failures.extend(governance_file_failures)

    if security_text:
        failures.extend(check_contains(security_text, SECURITY_REQUIRED, "security model content"))
        failures.extend(check_contains(security_text, REQUIRED_SECURITY_ROLES, "security role"))
        failures.extend(check_contains(security_text, REQUIRED_REPOSITORY_EXCLUSIONS, "repository exclusion"))
        security_table_count = security_text.count("|---")
        if security_table_count < 3:
            failures.append(
                f"Expected at least 3 markdown tables in security model; found {security_table_count}."
            )

    if governance_text:
        failures.extend(check_contains(governance_text, GOVERNANCE_REQUIRED, "data governance plan content"))
        failures.extend(check_contains(governance_text, REQUIRED_GOVERNANCE_ROLES, "governance role"))
        failures.extend(check_contains(governance_text, REQUIRED_GOVERNED_ARTIFACTS, "governed artifact reference"))
        failures.extend(check_contains(governance_text, REQUIRED_LAYERS, "governed data layer"))
        failures.extend(check_contains(governance_text, REQUIRED_KPIS, "KPI governance reference"))
        governance_table_count = governance_text.count("|---")
        if governance_table_count < 8:
            failures.append(
                f"Expected at least 8 markdown tables in governance plan; found {governance_table_count}."
            )

    combined_text = security_text + "\n" + governance_text

    failures.extend(
        check_normalized_contains(
            combined_text,
            REQUIRED_SECURITY_AND_SAFETY_PHRASES,
            "security / portfolio safety phrase",
        )
    )
    failures.extend(
        check_normalized_contains(
            combined_text,
            ACCEPTANCE_COVERAGE_TERMS,
            "AB#1575 acceptance coverage term",
        )
    )

    if "Assumptions" not in combined_text or "Limitations" not in combined_text:
        failures.append("Missing assumptions and limitations coverage.")

    if (
        "Power BI should connect to gold-layer tables or views" not in combined_text
        and "connect Power BI to curated gold-layer tables or views" not in combined_text
    ):
        failures.append("Missing explicit Power BI-to-gold-layer guidance.")

    if "FHIR-aligned" not in combined_text:
        failures.append("Missing FHIR-aligned API boundary language.")

    if failures:
        print("FAIL: ownership, stewardship, and security validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: docs/security_model.md and docs/data_governance_plan.md satisfy AB#1575 acceptance criteria.")
    print(f"Validated governance roles: {len(REQUIRED_GOVERNANCE_ROLES)}")
    print(f"Validated security roles: {len(REQUIRED_SECURITY_ROLES)}")
    print(f"Validated governed artifact references: {len(REQUIRED_GOVERNED_ARTIFACTS)}")
    print(f"Validated governed layers/domains: {len(REQUIRED_LAYERS)}")
    print(f"Validated KPI governance references: {len(REQUIRED_KPIS)}")
    print("Validated ownership, stewardship, least-privilege access, repository safety, Power BI safety, FHIR/API boundaries, assumptions, and limitations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
