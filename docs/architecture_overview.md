# ClinicalPulse Architecture Overview

## 1. Purpose

This document explains the planned end-to-end architecture for ClinicalPulse before implementation begins. It is written for a technical reviewer who needs to understand the major system components, data flow, governance touchpoints, and design boundaries.

ClinicalPulse is a governed hospital business intelligence platform that uses synthetic EHR data to demonstrate how raw healthcare source files can be transformed into curated SQL Server reporting layers, validated KPIs, Power BI dashboards, and lightweight FHIR-aligned API outputs.

## 2. Architecture Summary

ClinicalPulse follows a governed data product flow:

```text
Synthea synthetic source files
        ↓
SQL Server bronze schema
        ↓
SQL Server silver schema
        ↓
SQL Server gold schema
        ↓
Power BI semantic model and dashboards
        ↓
Governance artifacts, KPI documentation, validation outputs, and FHIR-aligned API examples
```

SQL Server is the analytical backbone. Python supports ingestion, validation, reconciliation, documentation support, and API-related workflows. Power BI consumes curated gold-layer tables or views rather than raw files. Governance documentation is part of the system design, not a separate afterthought.

## 3. Major Components

| Component | Role in the Architecture |
|---|---|
| Synthea source data | Provides synthetic EHR-style source files for patients, encounters, conditions, observations, procedures, organizations, providers, and optional supporting entities. |
| SQL Server bronze schema | Stores source-preserving staged data with ingestion metadata and minimal transformation. |
| SQL Server silver schema | Stores cleaned, standardized, business-friendly entities with validation flags and preserved source lineage. |
| SQL Server gold schema | Stores reporting-ready dimensions, facts, marts, and KPI-ready views for Power BI. |
| Governance schema | Stores or represents KPI definitions, data quality rules, scorecards, lineage, ownership, and FHIR mappings. |
| Audit schema | Tracks ingestion batches, file logs, transformation runs, reconciliation results, and process history. |
| API schema | Provides SQL views shaped for FHIR-style API resources and selected demonstration endpoints. |
| Python scripts | Support CSV ingestion, quality checks, row-count reconciliation, FHIR-style exports, and FastAPI service logic. |
| Power BI | Provides stakeholder-facing dashboards and semantic model measures built on curated gold-layer objects. |
| Azure DevOps and GitHub | Track work items, version project artifacts, support commits, and demonstrate disciplined delivery. |

## 4. Source Data Layer

ClinicalPulse uses Synthea synthetic healthcare data as the source system. The source data is treated as EHR-like simulation data, not real patient data.

Primary source entities for Version 1 are:

- patients
- encounters
- organizations
- providers, lightweight
- conditions
- observations and labs
- procedures, limited

Medications, payers, and care plans may be added later if they support the reporting scope without creating unnecessary complexity.

Raw generated files are stored locally under `data/raw/` and excluded from Git unless a small curated synthetic sample is intentionally published under `data/samples/`.

## 5. SQL Server Data Layers

### 5.1 Bronze Layer

The bronze layer stores source-preserving staged data. Its purpose is to load Synthea files into SQL Server while keeping the original structure as intact as practical.

Bronze responsibilities include:

- preserving source identifiers
- recording ingestion metadata
- tracking source file names and load batches
- enabling row-count reconciliation
- avoiding irreversible transformations

Example objects:

- `bronze.patients`
- `bronze.encounters`
- `bronze.conditions`
- `bronze.observations`
- `bronze.procedures`
- `bronze.organizations`

### 5.2 Silver Layer

The silver layer stores cleaned and standardized business entities. It converts source-oriented records into more consistent analytical structures while preserving lineage back to bronze.

Silver responsibilities include:

- standardizing naming conventions and data types
- converting date and timestamp fields consistently
- deriving business-friendly fields such as age band, encounter duration, encounter class, condition category, and observation category
- flagging invalid or missing values
- checking referential relationships across patients, encounters, observations, conditions, and procedures

Example objects:

- `silver.patient`
- `silver.encounter`
- `silver.condition`
- `silver.observation`
- `silver.procedure`
- `silver.organization`

### 5.3 Gold Layer

The gold layer stores reporting-ready tables, views, and marts. Power BI connects to this layer rather than to raw source files or bronze tables.

Gold responsibilities include:

- providing dimensional and fact-style reporting structures
- supporting governed KPI calculations
- exposing marts for operational reporting domains
- simplifying Power BI semantic model design
- preserving metric traceability through documented lineage

Example objects:

- `gold.dim_patient`
- `gold.dim_date`
- `gold.dim_organization`
- `gold.fact_encounter`
- `gold.fact_observation`
- `gold.fact_readmission`
- `gold.mart_patient_flow`
- `gold.mart_length_of_stay`
- `gold.mart_readmissions`
- `gold.mart_lab_operations`
- `gold.mart_reporting_trust`

## 6. Reporting Architecture

Power BI is the stakeholder-facing reporting layer. It should be built only after the gold layer is reliable enough for dashboard use.

Expected dashboard areas include:

- Executive Overview
- Patient Flow
- Length of Stay
- Readmissions
- Conditions and Procedures
- Lab / Observation Operations
- Data Quality and Governance
- FHIR API Demonstration

Power BI measures must be supported by KPI dictionary entries and validated against SQL queries where practical. The dashboard should communicate operational trends and reporting trust, not simply display disconnected charts.

## 7. Governance Architecture

Governance is built into the architecture through documentation, SQL objects, and validation outputs.

Governance touchpoints include:

| Governance Area | Architectural Role |
|---|---|
| KPI dictionary | Defines business meaning, formulas, grain, source objects, inclusion/exclusion rules, owners, validation logic, and limitations for metrics. |
| Data quality rules | Define completeness, uniqueness, validity, consistency, referential integrity, freshness, lineage, and API-readiness checks. |
| Data lineage | Traces selected source entities through bronze, silver, gold, Power BI measures, and FHIR-style outputs. |
| Data asset catalog and scorecards | Document asset purpose, ownership, reliability, documentation status, validation coverage, and adoption readiness. |
| Security model | Documents least-privilege assumptions, synthetic data handling, secrets management, and public portfolio safety boundaries. |
| Audit logs | Record ingestion, transformation, reconciliation, validation, and optional API request activity. |

## 8. Python Responsibilities

Python supports the architecture but does not replace SQL Server as the analytical backbone.

Planned Python responsibilities include:

- loading selected Synthea CSV files into SQL Server bronze tables
- running or orchestrating data quality checks
- reconciling row counts across source, bronze, silver, and gold layers
- exporting selected FHIR-style JSON examples
- supporting a lightweight read-only FastAPI service
- providing basic tests for quality rules and API response shapes

Representative modules may include:

- `src/ingest_synthea_csv_to_sqlserver.py`
- `src/run_quality_checks.py`
- `src/row_count_reconciliation.py`
- `src/export_fhir_examples.py`
- `src/api/main.py`
- `src/api/db.py`
- `src/api/schemas.py`

## 9. FHIR-Aligned API Architecture

The FHIR API component is a demonstration of healthcare interoperability literacy. It is not intended to be a certified production FHIR server.

The API is read-only and exposes selected synthetic records or aggregate metrics through lightweight endpoints.

Planned API examples include:

| Endpoint | Purpose |
|---|---|
| `GET /health` | Confirms API service status. |
| `GET /api/metadata` | Returns supported resources and project/API metadata. |
| `GET /fhir/Patient/{patient_id}` | Returns one synthetic patient in FHIR-style JSON. |
| `GET /fhir/Encounter/{encounter_id}` | Returns one synthetic encounter with patient and organization references. |
| `GET /fhir/Observation?patient={patient_id}` | Returns observations for a selected synthetic patient. |
| `GET /fhir/Condition?patient={patient_id}` | Returns conditions for a selected synthetic patient. |
| `GET /api/metrics/summary` | Returns selected governed aggregate metrics used by dashboards. |

FHIR-style outputs should be clearly marked as demonstration outputs and should use synthetic identifiers only.

## 10. Security and Portfolio Safety Boundaries

Although the project uses synthetic data, the architecture models professional healthcare data handling practices.

Security and safety boundaries include:

- no real patient data
- no clinical decision-support claims
- no raw generated source files committed to Git by default
- no `.env` files, credentials, database backups, or secrets committed to Git
- database credentials handled through local environment configuration
- dashboard screenshots designed around aggregate views where possible
- API examples limited to synthetic demonstration records
- public documentation written to avoid implying production hospital deployment

## 11. Delivery and Traceability

ClinicalPulse uses Git/GitHub and Azure DevOps to make implementation work traceable.

Each major artifact or implementation step should be connected to Azure Boards work items through commits, pull requests, or work item comments. Architecture-related changes should be committed with a clear message referencing the relevant work item.

## 12. Assumptions

- Synthea provides the synthetic EHR-style source data for the project.
- SQL Server is the central analytical database platform.
- Power BI consumes curated gold-layer objects, not raw files.
- Python is used for supporting workflows such as ingestion, validation, reconciliation, and API implementation.
- Governance artifacts are maintained as project deliverables and should stay aligned with implementation decisions.
- The FHIR component is a lightweight demonstration of interoperability concepts, not a production-grade FHIR server.
- Azure DevOps is used for planning and traceability, while GitHub is used for public portfolio delivery.

## 13. Limitations

- Synthetic data may not reproduce the operational complexity, data quality issues, or clinical nuance of a real hospital system.
- The architecture is designed for portfolio demonstration rather than production deployment.
- Enterprise security features such as identity management, production role provisioning, and network controls are documented as assumptions rather than fully implemented.
- The FHIR API is FHIR-aligned but not a certified FHIR implementation.
- The first implementation should prioritize a complete and understandable end-to-end flow over optional advanced features.
