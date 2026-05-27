# Security Model and Public Portfolio Safety Assumptions

## 1. Purpose

This document defines the security and public portfolio safety assumptions for ClinicalPulse.

ClinicalPulse uses synthetic healthcare data, but the project still models professional healthcare data handling practices. The goal is to make clear what data can be shared, what must stay local, how credentials are handled, and what access assumptions apply to dashboards, SQL objects, and FHIR-aligned API outputs.

## 2. Intended Audience

This document is intended for:

- security and portfolio-safety reviewers checking whether the repository is safe to publish
- BI developers handling SQL Server connections, Power BI files, and validation outputs
- data stewards reviewing privacy, access, and governance assumptions
- technical reviewers evaluating whether synthetic-data handling is explicit and controlled
- portfolio reviewers assessing whether the project reflects responsible healthcare data practices

## 3. Security Position

ClinicalPulse is a portfolio demonstration project, not a production healthcare system.

The project demonstrates security awareness through:

- synthetic-data disclaimers
- repository exclusion rules
- least-privilege access assumptions
- credential and connection-string handling
- aggregate-first dashboard publishing
- safe API demonstration boundaries
- clear limitations around clinical use and production deployment

## 4. Synthetic Data Disclaimer

ClinicalPulse uses synthetic Synthea healthcare data.

The data:

- does not represent real patients
- does not represent a real hospital population
- does not represent actual hospital performance
- must not be interpreted as clinical evidence
- must not be used for patient care, diagnosis, treatment, or operational decision-making

Project documentation, dashboard screenshots, API examples, and README content should clearly describe outputs as synthetic and demonstration-oriented.

## 5. Public Portfolio Safety Rules

The public repository should contain only project-safe artifacts.

| Item | Repository Rule |
|---|---|
| Source code | Safe to commit if it does not contain secrets, credentials, local paths, or restricted data. |
| SQL scripts | Safe to commit if they define schema, transformations, validation logic, or views without embedded sensitive values. |
| Documentation | Safe to commit if it does not imply real patient data, real hospital deployment, or clinical decision support. |
| Tiny synthetic samples | Allowed only if intentionally curated and clearly documented as synthetic. |
| Raw generated datasets | Keep out of Git by default. |
| Local database backups | Keep out of Git. |
| Power BI `.pbix` files | Keep out of Git unless intentionally reviewed and confirmed safe. |
| Dashboard screenshots | Use aggregate views and avoid unnecessary row-level detail. |
| API examples | Use synthetic identifiers and clearly mark responses as demonstration outputs. |
| Environment files | Keep out of Git. |
| Secrets and credentials | Never commit. |

## 6. Repository Exclusion Rules

The project `.gitignore` should exclude generated data, local environment files, credentials, and large or unsafe local artifacts.

Recommended exclusions:

```gitignore
data/raw/
data/interim/
data/processed/
*.csv
*.csv.gz
*.parquet
*.bak
*.pbix
.env
__pycache__/
*.pyc
.DS_Store
.venv/
venv/
```

Tiny demonstration samples may be stored under `data/samples/` only when they are deliberately curated, small, synthetic, and documented.

## 7. Secrets and Credential Handling

Database credentials and connection strings must not be hardcoded into committed scripts.

Expected practices:

- store local database credentials in `.env` or local machine configuration
- exclude `.env` from Git
- read credentials through environment variables
- avoid committing server names, usernames, passwords, tokens, API keys, or local file paths that reveal private configuration
- use placeholder values in documentation and sample configuration files

Example placeholder pattern:

```text
SQLSERVER_HOST=localhost
SQLSERVER_DATABASE=ClinicalPulse
SQLSERVER_DRIVER=ODBC Driver 17 for SQL Server
SQLSERVER_TRUSTED_CONNECTION=yes
```

If a sample environment file is needed later, it should be committed as `.env.example`, not `.env`.

## 8. Role-Based Access Assumptions

ClinicalPulse models least-privilege access through assumed roles. These roles are documented for project design clarity and are not production identity-management controls.

| Role | Assumed Access |
|---|---|
| BI Developer | Can build SQL transformations, validation queries, Power BI measures, and dashboard assets. |
| Data Steward | Can review KPI definitions, data quality rules, lineage, assumptions, and governed documentation. |
| Operational Leader | Can view aggregate dashboard outputs and business-facing KPI definitions. |
| Executive Viewer | Can view high-level dashboard pages and reporting trust indicators. |
| API Consumer | Can access selected read-only synthetic API endpoints for demonstration. |
| Platform Administrator | Can manage local SQL Server configuration, database objects, environment settings, and repository hygiene. |

Least-privilege expectation: each role should receive only the access required for its project responsibility.

## 9. SQL Server Safety Assumptions

ClinicalPulse SQL Server work is assumed to run in a local development environment.

Safety assumptions:

- SQL Server is used as the analytical backbone for synthetic data only
- local databases do not contain real patient data
- database backups are not committed
- SQL scripts should be reusable without embedding credentials
- bronze, silver, gold, governance, audit, and API schemas separate responsibilities
- audit and governance tables may store run metadata, quality results, lineage, and validation outputs
- API-facing views should expose only the fields needed for the demonstration

## 10. Power BI Safety Assumptions

Power BI outputs should be safe for portfolio review.

Rules:

- connect Power BI to curated gold-layer tables or views
- avoid building dashboards directly from raw source files
- use aggregate visuals where possible
- avoid unnecessary row-level tables in public screenshots
- document KPI definitions and measure assumptions
- validate dashboard metrics against SQL queries before presenting them as trustworthy
- avoid committing `.pbix` files unless the file has been reviewed for embedded data, credentials, and privacy safety

## 11. FHIR/API Demonstration Safety

The ClinicalPulse API component is read-only and demonstration-oriented.

Safety assumptions:

- API outputs use synthetic identifiers
- endpoints do not expose real patient data
- responses are FHIR-aligned examples, not certified FHIR server outputs
- API examples are clearly marked as synthetic demonstrations
- endpoints expose only selected resources needed to demonstrate interoperability literacy
- row-level API examples should be limited and intentional
- aggregate metric endpoints should not imply real hospital performance

Planned API resources may include Patient, Encounter, Observation, Condition, Procedure, Organization, and Practitioner-style outputs.

## 12. Dashboard and Screenshot Safety

Public screenshots should support review without creating misleading or unsafe disclosure.

Screenshot rules:

- prefer aggregate dashboard pages
- avoid unnecessary patient-level detail
- avoid screenshots containing local file paths, server names, usernames, or connection strings
- label synthetic data clearly where appropriate
- avoid claims that the dashboard reflects real hospital operations
- use screenshots to demonstrate BI design, governed KPIs, and reporting trust, not clinical conclusions

## 13. Documentation Safety

Documentation should be accurate about project boundaries.

Documentation must not claim that ClinicalPulse is:

- a production hospital system
- a clinical decision support tool
- a real patient dataset
- a certified FHIR server
- a substitute for hospital-grade security, privacy, compliance, or identity management

Documentation should state that ClinicalPulse is a governed healthcare BI portfolio project using synthetic EHR-style data.

## 14. Local Development Assumptions

ClinicalPulse assumes a local development workflow.

Expected local-only items include:

- raw generated Synthea files
- local SQL Server database files and backups
- `.env` files
- local Python virtual environments
- temporary exports
- intermediate transformed data files
- unreviewed Power BI files

These items should remain outside the public repository unless specifically curated for safe demonstration.

## 15. Review Checklist Before Publishing

Before committing or publishing project files, review for:

- raw generated data files
- `.env` files or secrets
- database backups
- embedded credentials
- local machine paths
- unnecessary row-level screenshots
- `.pbix` files with embedded data or credentials
- misleading claims about real patients, real hospitals, clinical use, or production deployment
- API examples that are not clearly synthetic
- documentation that contradicts the project’s synthetic-data scope

## 16. Assumptions

- ClinicalPulse uses synthetic Synthea data only.
- The project is public-portfolio-oriented and not intended for production deployment.
- One builder may perform multiple roles, but role separation is documented to model professional access thinking.
- Security controls are documented as assumptions and development practices, not implemented as enterprise controls.
- API outputs are read-only and demonstration-oriented.
- Power BI screenshots should prioritize aggregate reporting and avoid unnecessary row-level detail.

## 17. Limitations

- This document does not implement enterprise identity management, encryption policies, network security, or production audit controls.
- Role-based access is documented conceptually and may not be enforced through a production authorization system.
- Local SQL Server configuration is outside the scope of this document.
- Synthetic data reduces privacy risk but does not remove the need for responsible repository hygiene.
- FHIR-aligned API outputs demonstrate interoperability concepts but do not represent production FHIR compliance.
- Dashboard outputs are for portfolio demonstration and should not be interpreted as real operational or clinical findings.
