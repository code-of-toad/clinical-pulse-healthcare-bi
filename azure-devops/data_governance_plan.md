# Data Governance Plan

## 1. Purpose

This document defines the data governance approach for ClinicalPulse.

ClinicalPulse treats governance as part of delivery. KPI definitions, data quality checks, lineage, ownership, security assumptions, and documentation are not separate add-ons; they are required for the platform to be considered trustworthy and reviewer-ready.

The goal is to make ClinicalPulse understandable as a governed healthcare BI platform, not only as a collection of SQL scripts, Python scripts, dashboards, and API endpoints.

## 2. Intended Audience

This document is intended for:

- data stewards reviewing metric definitions, quality rules, and lineage
- BI developers implementing SQL transformations, Power BI measures, and validation queries
- technical reviewers evaluating whether the system is traceable and well controlled
- portfolio reviewers assessing whether the project reflects professional healthcare data handling practices
- operational stakeholders who need confidence that reported metrics are defined and governed

## 3. Governance Objectives

ClinicalPulse governance is designed to ensure that:

- KPI definitions are clear, consistent, and traceable
- dashboard values can be reconciled to SQL logic
- data quality issues are identified and documented
- reporting assets have clear ownership and stewardship assumptions
- raw, curated, and reporting-ready layers have distinct responsibilities
- synthetic data is handled in a portfolio-safe way
- FHIR-aligned API outputs are documented with appropriate boundaries
- project artifacts support review, reuse, and future extension

## 4. Governance Principles

| Principle | Meaning for ClinicalPulse |
|---|---|
| Business meaning before tooling | Reporting requirements and KPI definitions should be understandable before implementation details dominate the work. |
| Governed metrics | Dashboard metrics should have documented definitions, formulas, source objects, validation expectations, and limitations. |
| Traceability | A reviewer should be able to trace selected metrics from source data through SQL transformations to Power BI measures. |
| Layer separation | Bronze, silver, and gold schemas should have distinct responsibilities. Raw source structures should not be mixed with reporting-ready assets. |
| Quality visibility | Data quality checks should be documented and, where implemented, stored in governance or audit outputs. |
| Portfolio safety | Synthetic data should be clearly identified, and raw generated files, secrets, local backups, and unnecessary row-level details should not be committed. |
| Documentation as part of delivery | Governance artifacts should be maintained as part of the system, not written only after technical work is complete. |
| Practical scope control | Governance should support the project without adding unnecessary complexity beyond the deliverables required for the current version. |

## 5. Governance Roles and Responsibilities

The following roles are modeled for project clarity. They may be represented by one builder in this portfolio project, but the responsibilities are separated to reflect professional delivery practice.

| Role | Responsibilities |
|---|---|
| Project Owner | Maintains project scope, delivery priorities, and alignment with the ClinicalPulse vision. |
| Operational Reporting Owner | Defines operational reporting needs, reviews business questions, and validates whether dashboards answer useful questions. |
| BI Developer | Builds SQL transformations, Power BI measures, semantic model relationships, and reporting assets. |
| Data Steward | Reviews KPI definitions, data quality rules, lineage documentation, assumptions, and limitations. |
| Data Platform Owner | Maintains database structure, ingestion assumptions, API-facing views, and technical platform boundaries. |
| Security / Portfolio Safety Reviewer | Reviews synthetic-data disclaimers, public repository safety, secret handling, and safe screenshot/API example practices. |
| Technical Reviewer | Reviews whether architecture, source-to-report flow, and implementation artifacts are understandable and traceable. |
| Dashboard Consumer | Uses final dashboards and documentation to interpret operational trends and reporting trust indicators. |

## 6. Governed Artifacts

| Artifact | Governance Purpose |
|---|---|
| `docs/project_charter.md` | Defines purpose, scope, stakeholders, assumptions, limitations, and success criteria. |
| `docs/business_requirements.md` | Captures analytical needs and reporting questions in business language. |
| `docs/stakeholder_matrix.md` | Identifies users, owners, stewards, reviewers, and dashboard consumers. |
| `docs/architecture_overview.md` | Explains end-to-end data flow, system components, and architectural boundaries. |
| `docs/kpi_dictionary.md` | Defines metric templates and KPI expectations to prevent conflicting interpretations. |
| `docs/data_governance_plan.md` | Defines governance responsibilities, principles, and delivery practices. |
| `docs/security_model.md` | Documents role-based access assumptions, least-privilege expectations, and portfolio safety rules. |
| `docs/data_lineage.md` | Traces selected entities and KPIs from source files through SQL layers to reporting and API outputs. |
| `docs/data_asset_catalog.md` | Lists important tables, views, marts, dashboards, and API-facing assets. |
| `docs/data_asset_scorecards.md` | Rates selected assets for reliability, usability, validation coverage, documentation, and readiness. |
| `docs/fhir_mapping.md` | Maps selected relational entities to FHIR-style resources and API outputs. |
| `powerbi/measure_definitions.md` | Documents implemented Power BI measures and their relationship to governed KPIs. |

Some artifacts may be created in later sprints. This plan defines the governance expectations that those artifacts should satisfy.

## 7. Data Layer Governance

ClinicalPulse uses SQL Server schemas that mirror a medallion-style architecture.

| Layer | Governance Responsibility |
|---|---|
| Bronze | Preserve source-like Synthea structures, load metadata, source identifiers, source file references, and ingestion audit details. |
| Silver | Standardize names, data types, derived business fields, validity flags, and cleaned healthcare entities while preserving lineage back to bronze. |
| Gold | Provide reporting-ready dimensions, facts, marts, and KPI-ready views for Power BI and validation. |
| Governance | Store or document KPI definitions, data quality rules, check results, asset metadata, scorecards, lineage, and FHIR mappings. |
| Audit | Track ingestion batches, transformation runs, file logs, reconciliation results, and run history. |
| API | Expose selected SQL views prepared for FHIR-aligned JSON responses. |

Power BI should connect to gold-layer tables or views, not raw source files or bronze tables.

## 8. KPI Governance

Every dashboard KPI should have a corresponding entry in the KPI dictionary before it is treated as final.

Each KPI definition should include:

- KPI name
- business question
- plain-English definition
- formal formula
- grain
- inclusion criteria
- exclusion criteria
- SQL source objects
- Power BI measure name
- owner
- steward
- refresh frequency
- validation query or validation approach
- data quality dependencies
- known limitations
- related dashboard page
- related FHIR resources, where applicable
- implementation status

Initial KPI governance will focus on:

- Total Encounters
- Unique Patients
- Average Length of Stay
- Median Length of Stay
- 30-Day Readmission Rate
- Observation Volume
- Procedure Volume
- Data Quality Pass Rate
- API Resource Coverage

KPI definitions may be refined as SQL objects, Power BI measures, and validation queries are implemented.

## 9. Data Quality Governance

ClinicalPulse data quality checks should focus on whether reporting outputs are trustworthy enough for portfolio demonstration.

Primary quality dimensions include:

| Quality Dimension | Examples |
|---|---|
| Completeness | Missing patient IDs, encounter IDs, dates, organization IDs, observation codes, or required fields. |
| Uniqueness | Duplicate patient identifiers, duplicate encounter records, or duplicate observation rows. |
| Referential integrity | Encounters without patients, observations without encounters, conditions without patients. |
| Validity | Encounter stop before start, negative length of stay, impossible dates, invalid timestamps. |
| Consistency | Inconsistent encounter classes, condition categories, observation units, or procedure groupings. |
| Timeliness / freshness | Latest ingestion batch, expected file count, latest transformation run. |
| Lineage | Gold rows traceable to silver and bronze source records. |
| API readiness | API-facing views contain required identifiers and JSON-ready fields. |

Quality results should be documented or stored in governance/audit outputs once implementation begins. Data quality issues should be visible in the reporting trust layer where practical.

## 10. Lineage Expectations

ClinicalPulse should make selected source-to-report paths traceable.

At minimum, lineage should eventually show how core entities and KPIs move through:

```text
Synthea source files
-> bronze SQL Server tables
-> silver cleaned entities
-> gold reporting facts, dimensions, and marts
-> Power BI measures and dashboard pages
-> governance documentation
-> selected FHIR-aligned API views or outputs
```

Lineage documentation should prioritize high-value examples rather than attempting exhaustive coverage too early.

Priority lineage examples:

| Lineage Example | Why It Matters |
|---|---|
| Total Encounters | Core volume KPI and baseline for patient flow reporting. |
| Average / Median Length of Stay | Demonstrates derived timing logic and invalid-date handling. |
| 30-Day Readmission Rate | Demonstrates patient-level sequencing, inclusion criteria, and assumptions. |
| Observation Volume | Demonstrates lab/observation activity and source-to-gold aggregation. |
| Data Quality Pass Rate | Demonstrates governance visibility and reporting trust. |
| Patient or Encounter FHIR output | Demonstrates relationship between relational reporting data and API-facing resources. |

## 11. Data Asset Governance

Important data assets should be cataloged or scorecarded as the project matures.

Candidate assets for cataloging include:

- `bronze.patients`
- `bronze.encounters`
- `bronze.conditions`
- `bronze.observations`
- `bronze.procedures`
- `silver.patient`
- `silver.encounter`
- `silver.condition`
- `silver.observation`
- `silver.procedure`
- `gold.dim_patient`
- `gold.fact_encounter`
- `gold.fact_observation`
- `gold.fact_readmission`
- `gold.mart_patient_flow`
- `gold.mart_length_of_stay`
- `gold.mart_readmissions`
- `gold.mart_lab_operations`
- `gold.mart_reporting_trust`
- `api.vw_fhir_patient`
- `api.vw_fhir_encounter`
- `api.vw_fhir_observation`
- Power BI dashboard pages

Asset scorecards should evaluate practical readiness, including reliability, documentation, validation coverage, ownership, usability, security assumptions, and adoption readiness.

## 12. Security and Portfolio Safety Relationship

ClinicalPulse uses synthetic data, but it should still model professional healthcare data handling.

Governance expectations include:

- clearly state that the data is synthetic and not real patient data
- avoid claiming that outputs support real clinical decision-making
- keep raw generated files out of Git unless a tiny curated sample is intentionally included
- exclude secrets, credentials, local backups, `.env` files, and unnecessary generated data from version control
- use aggregate dashboard screenshots where possible
- avoid unnecessary row-level detail in public-facing screenshots
- clearly mark API examples as synthetic demonstration outputs
- document least-privilege access assumptions in the security model

Security details should be handled primarily in `docs/security_model.md`, but this plan establishes that public portfolio safety is a governance responsibility.

## 13. FHIR and API Governance

The FHIR/API component is governed as a demonstration of healthcare interoperability awareness.

Governance expectations include:

- API outputs are read-only
- API examples use synthetic identifiers
- API documentation clearly states that the implementation is FHIR-aligned, not a certified production FHIR server
- selected relational entities are mapped to FHIR-style resources
- API-facing SQL views are documented
- API scope remains limited to selected resources and aggregate metrics

Planned FHIR-aligned resources include:

- Patient
- Encounter
- Observation
- Condition
- Procedure
- Organization
- Practitioner / PractitionerRole, where applicable

## 14. Change and Review Practices

Changes to governed artifacts should be traceable through Git commits and Azure DevOps work items.

Recommended practices:

- reference Azure Boards work item IDs in commit messages where relevant
- update documentation when KPI definitions, data quality rules, or source objects change
- avoid changing KPI formulas silently after dashboards are built
- document assumptions when exact real-world healthcare logic is simplified
- keep validation evidence in Azure Boards comments, commit messages, or pull request notes rather than inside stakeholder-facing documents
- review public-facing files before committing to ensure no raw data, secrets, local paths, or misleading clinical claims are included

## 15. Governance Lifecycle

| Stage | Governance Focus |
|---|---|
| Design | Define business questions, stakeholders, architecture, KPI templates, and safety assumptions. |
| Ingestion | Track source files, ingestion metadata, row counts, and source handling rules. |
| Transformation | Preserve lineage, standardize entities, document derived fields, and flag quality issues. |
| Reporting | Build Power BI measures from governed gold-layer assets and reconcile key values to SQL. |
| Interoperability | Map selected entities to FHIR-style resources and document API boundaries. |
| Review | Validate documentation, assumptions, limitations, and public portfolio safety before publishing. |

## 16. Assumptions

- ClinicalPulse is a portfolio project using synthetic Synthea data.
- Governance roles are modeled separately even if one builder performs all responsibilities.
- SQL Server is the analytical backbone for curated and reporting-ready data.
- Power BI dashboards will be built from gold-layer tables or views.
- Data quality checks and lineage documentation will mature as implementation progresses.
- FHIR/API outputs are demonstration-oriented and read-only.
- Governance documentation should remain practical and proportional to project scope.

## 17. Limitations

- This plan defines governance expectations but does not itself implement database controls, quality checks, or access rules.
- Enterprise identity management, production access provisioning, and production audit tooling are outside the scope of Version 1.
- Synthetic data limits the realism of operational, clinical, and quality patterns.
- Some governed artifacts listed in this plan may be created in later sprints.
- KPI ownership and stewardship are modeled for project clarity and do not represent a real hospital operating model.
- FHIR-aligned API outputs demonstrate mapping and interoperability literacy but do not represent certified FHIR server compliance.
