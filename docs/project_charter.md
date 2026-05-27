# ClinicalPulse Project Charter

## 1. Project Overview

ClinicalPulse is a governed healthcare business intelligence platform that simulates how a hospital analytics team transforms synthetic EHR data into trusted reporting assets, governed KPI definitions, Power BI dashboards, and lightweight FHIR-aligned API outputs.

The project demonstrates the healthcare BI lifecycle from source data ingestion through SQL Server modeling, medallion-style transformation, data quality validation, KPI documentation, Power BI reporting, and portfolio-safe healthcare interoperability.

## 2. Project Purpose

The purpose of ClinicalPulse is to demonstrate the design and implementation of a healthcare BI platform that connects technical execution with governance, reporting trust, and stakeholder-facing decision support.

The project shows how raw synthetic healthcare source data can be transformed into validated, documented, and reusable reporting assets for hospital operational analytics.

## 3. Business Problem

Hospital leaders and operational teams need reliable visibility into patient flow, encounter volume, length of stay, readmissions, service utilization, lab activity, and data quality.

Without governed metric definitions, validated transformations, and clear lineage, dashboard users may interpret the same metric differently or lose trust in reported numbers.

ClinicalPulse addresses this by creating a controlled BI environment where KPIs are defined, data quality is checked, source-to-report lineage is documented, and dashboards are built from curated reporting layers rather than raw files.

## 4. Project Vision

ClinicalPulse will model a realistic healthcare analytics workflow using synthetic EHR data, SQL Server, Python, Power BI, Git/GitHub, Azure DevOps, and a lightweight FHIR-aligned API.

The project will be successful if a reviewer can understand the business purpose, inspect the data model, trace KPI logic, verify data quality assumptions, and see how curated healthcare data supports operational reporting.

## 5. Primary Users and Stakeholders

| Stakeholder Group | Role in the Project |
|---|---|
| Executive leaders | Review high-level operational trends and reporting trust indicators. |
| Operational managers | Use dashboards to understand patient flow, utilization, length of stay, and service demand. |
| BI developers | Build and maintain SQL transformations, reporting layers, semantic models, and dashboard measures. |
| Data stewards | Review KPI definitions, data quality rules, lineage, and documentation completeness. |
| Analytics stakeholders | Translate business questions into reporting requirements and validate whether outputs are useful. |
| Interoperability reviewers | Review how selected relational entities map to FHIR-style API resources. |
| Portfolio reviewers | Evaluate the project as evidence of healthcare BI, data governance, and delivery discipline. |

## 6. In Scope

ClinicalPulse Version 1 includes:

- Synthea synthetic healthcare data as the source dataset
- SQL Server bronze, silver, gold, governance, audit, and API-facing schemas
- Python-assisted ingestion, validation, reconciliation, and FHIR-style export support
- Core operational BI domains:
  - patients
  - encounters
  - organizations
  - providers, lightweight
  - conditions
  - observations and labs
  - procedures, limited
- Governed KPIs for patient flow, length of stay, readmissions, service utilization, lab activity, and reporting trust
- Power BI dashboards connected to curated gold tables or views
- Documentation for KPI definitions, data quality rules, security assumptions, data governance, lineage, and architecture
- A minimal read-only FHIR-aligned API demonstration using selected synthetic entities
- Git/GitHub version control and Azure DevOps work tracking

## 7. Out of Scope

ClinicalPulse Version 1 does not include:

- Real patient data
- Clinical decision support
- Production hospital deployment
- A certified production FHIR server
- Full medication, payer, care plan, or microbiology analytics
- Predictive modeling or machine learning
- Real-time streaming ingestion
- Enterprise identity management or production-grade access provisioning
- Publishing raw generated source files to GitHub, except for intentionally curated tiny synthetic samples if needed

## 8. Major Deliverables

| Deliverable | Purpose |
|---|---|
| Project charter | Defines purpose, scope, stakeholders, assumptions, limitations, and success criteria. |
| Business requirements document | Translates stakeholder questions into functional reporting requirements. |
| Stakeholder matrix | Defines users, owners, stewards, decision-makers, and consumers. |
| Architecture overview | Shows how data flows from Synthea source files to SQL Server, Power BI, governance assets, and FHIR outputs. |
| KPI dictionary | Defines dashboard metrics, formulas, grain, source objects, validation logic, owners, and limitations. |
| Data governance plan | Defines governance practices for ownership, lineage, quality, documentation, and reporting trust. |
| Security model | Documents synthetic data handling, least-privilege assumptions, secrets management, and public portfolio safety. |
| SQL Server implementation | Provides bronze, silver, gold, governance, audit, and API-facing database objects. |
| Python scripts | Support ingestion, validation, reconciliation, metadata handling, and FHIR-style outputs. |
| Power BI dashboard | Surfaces governed operational KPIs and data quality indicators. |
| FHIR mapping and API documentation | Shows how selected relational entities map to FHIR-style JSON resources. |
| README and portfolio documentation | Explain project value, setup, architecture, and reviewer-facing highlights. |

## 9. Success Criteria

ClinicalPulse will be considered successful when:

- The repository clearly explains the project purpose, architecture, setup, and deliverables.
- Synthetic source data is ingested into SQL Server using a documented and reproducible process.
- Bronze, silver, and gold layers separate raw ingestion, cleaned entities, and reporting-ready assets.
- Power BI connects to curated gold-layer tables or views, not raw source files.
- Core KPIs have documented business definitions, formulas, source objects, limitations, and validation queries.
- Data quality checks are defined and results are made visible through documentation, SQL outputs, or reporting assets.
- At least one KPI can be traced from source data through SQL transformations to Power BI reporting.
- Security and public portfolio safety assumptions are clearly documented.
- Selected healthcare entities are mapped to FHIR-style resources through documentation and a lightweight API demonstration.
- Azure DevOps work items can be traced to committed project artifacts.

## 10. Assumptions

- Synthea data is used as synthetic EHR-like source data and does not represent real patients.
- The project is designed for portfolio demonstration and learning, not production clinical use.
- SQL Server is the analytical backbone for the project.
- Power BI dashboards are built from curated gold-layer reporting assets.
- Python is used for ingestion support, validation automation, reconciliation, and API-related tasks.
- Governance documentation is treated as part of the platform, not as an afterthought.
- The FHIR API component is read-only and demonstration-oriented.
- Raw generated datasets, secrets, local database backups, and embedded credentials are excluded from Git.
- Any screenshots, samples, or API responses use synthetic or aggregate data only.

## 11. Limitations

- Synthetic data may not reflect the complexity, messiness, volume, or operational patterns of a real hospital EHR.
- The project does not validate clinical correctness or support patient care decisions.
- FHIR outputs are FHIR-aligned examples, not certified FHIR server implementations.
- Access control is documented through role-based assumptions rather than implemented through enterprise identity systems.
- Dashboard insights are intended to demonstrate BI design and governance practices, not to represent real hospital performance.
- Some optional domains, such as medications, payers, and care plans, may be deferred to keep Version 1 focused and achievable.

## 12. Delivery Approach

ClinicalPulse will be delivered incrementally through Azure DevOps user stories and tasks. Each major artifact or implementation step will be tracked, committed, and connected to the relevant work item.

The delivery workflow will prioritize:

- Small, traceable commits
- Clear documentation
- Public portfolio safety
- Practical implementation over unnecessary complexity
- Governed reporting assets before dashboard polish
- Business meaning before tool demonstration

## 13. Project North Star

ClinicalPulse should show the complete loop from raw synthetic healthcare data to trusted healthcare BI outputs.

A successful reviewer should be able to say:

> This project demonstrates how a healthcare BI analyst or developer can ingest synthetic EHR data, model it in SQL Server, validate it, define governed KPIs, build Power BI dashboards, document lineage and assumptions, and expose selected entities through FHIR-style API outputs in a portfolio-safe way.
