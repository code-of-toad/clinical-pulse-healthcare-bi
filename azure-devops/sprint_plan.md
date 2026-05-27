# ClinicalPulse Sprint Plan

## Purpose

This document records the Azure Boards planning structure for ClinicalPulse: Epics, Features, sprint cadence, and tagging conventions used to organize delivery work.

## Project Metadata

| Field | Value |
|---|---|
| Project | ClinicalPulse |
| Work Item | AB#1378 — Define epics, features, sprint cadence, and tags |
| Area Path | ClinicalPulse\Governance and Planning |
| Iteration Path | ClinicalPulse\Sprint 0 - Project Setup |
| Deliverable | azure-devops/sprint_plan.md |

## Epic and Feature Structure

| Epic Tag | Epic | Feature Tags and Features |
|---|---|---|
| E01 | Project Governance & Planning | F01.01 — DevOps Project Setup & Delivery Controls<br>F01.02 — Charter, Business Requirements, and Stakeholders<br>F01.03 — Architecture and Governance Baseline |
| E02 | Source Data Foundation | F02.01 — Synthea Dataset Generation<br>F02.02 — Source Inventory and Profiling<br>F02.03 — Data Handling and Repository Safety |
| E03 | SQL Server Ingestion | F03.01 — Database and Schema Foundation<br>F03.02 — Bronze Table Build<br>F03.03 — Python CSV Ingestion |
| E04 | Medallion Data Pipeline | F04.01 — Silver Business Entities<br>F04.02 — Gold Dimensional Model<br>F04.03 — Reporting Marts |
| E05 | Data Quality & Governance | F05.01 — Quality Rule Framework<br>F05.02 — KPI Dictionary and Validation<br>F05.03 — Data Assets, Lineage, and Scorecards |
| E06 | Power BI Reporting | F06.01 — Power BI Semantic Model<br>F06.02 — Dashboard Pages<br>F06.03 — Report Polish and Evidence |
| E07 | FHIR API & Interoperability | F07.01 — FHIR Mapping and API SQL Views<br>F07.02 — FastAPI Service<br>F07.03 — Testing and API Documentation |
| E08 | Documentation & Portfolio Delivery | F08.01 — README and Architecture Story<br>F08.02 — Adoption and Stakeholder Enablement<br>F08.03 — Final Portfolio Packaging |
| E09 | Optional Pipeline Hardening | F09.01 — Test Automation<br>F09.02 — CI Pipeline<br>F09.03 — DevOps Evidence |

## Sprint Cadence

| Iteration Path | Sprint Focus | User Stories |
|---|---|---|
| ClinicalPulse\Sprint 0 - Project Setup | Project setup and planning controls | AB#1375 — Create Azure DevOps project structure<br>AB#1378 — Define epics, features, sprint cadence, and tags<br>AB#1381 — Document GitHub and Azure Boards traceability conventions |
| ClinicalPulse\Sprint 1 - Governance and Design | Charter, requirements, stakeholders, architecture, KPI skeleton, governance baseline, and safety assumptions | Finalize the project charter<br>Create the business requirements document<br>Create the stakeholder matrix<br>Draft the architecture overview<br>Create the KPI dictionary skeleton<br>Draft the data governance plan<br>Define security and public portfolio safety assumptions |
| ClinicalPulse\Sprint 2 - Source Data Foundation | Synthea generation, source inventory, profiling, and repository safety | Choose Synthea generation settings<br>Generate or acquire selected Synthea CSV files<br>Document source acquisition and regeneration steps<br>Create source file inventory<br>Profile core clinical and operational source files<br>Identify optional entities for later expansion<br>Update .gitignore for raw data, secrets, and local artifacts<br>Create safe sample data policy<br>Document synthetic-data limitations and disclaimers |
| ClinicalPulse\Sprint 3 - SQL Server Ingestion | SQL Server database foundation, bronze tables, Python ingestion, audit logging, and row-count checks | Create database and schema scripts<br>Define SQL naming and scripting standards<br>Set up local SQL Server connection configuration<br>Create bronze patient and organization/provider tables<br>Create bronze encounter and condition tables<br>Create bronze observation and procedure tables<br>Add ingestion metadata columns to bronze tables<br>Build database configuration utilities<br>Build Synthea CSV ingestion script<br>Write ingestion logs to audit tables<br>Run initial load and verify row counts |
| ClinicalPulse\Sprint 4 - Silver Layer and Validation | Silver business entities and first data quality framework | Build silver.patient<br>Build silver.encounter with LOS fields<br>Build silver condition, procedure, and observation entities<br>Preserve lineage from bronze to silver<br>Create governance quality rule metadata table<br>Implement completeness, uniqueness, and referential integrity checks<br>Implement validity, consistency, and freshness checks<br>Persist quality check results |
| ClinicalPulse\Sprint 5 - Gold Layer and Marts | Gold dimensional model, reporting marts, KPI definitions, and KPI reconciliation | Create gold dimensions<br>Create gold encounter and readmission facts<br>Create gold condition, observation, and procedure facts<br>Create gold data quality issue fact<br>Create patient flow mart<br>Create length-of-stay and readmission marts<br>Create lab operations and service utilization marts<br>Create reporting trust mart<br>Define core KPI dictionary entries<br>Write SQL validation queries for core KPIs<br>Reconcile KPI outputs to gold marts |
| ClinicalPulse\Sprint 6 - Power BI Reporting | Power BI semantic model, dashboard pages, report polish, and dashboard evidence | Create data asset catalog<br>Create data lineage document<br>Create data asset scorecards<br>Document ownership, stewardship, and security assumptions<br>Connect Power BI to SQL Server gold schema<br>Build relationships and date table<br>Document DAX measure definitions<br>Validate DAX measures against SQL outputs<br>Build Executive Overview dashboard page<br>Build Patient Flow and LOS dashboard pages<br>Build Readmissions dashboard page<br>Build Conditions and Procedures dashboard page<br>Build Lab / Observation Operations dashboard page<br>Build Data Quality and Governance dashboard page<br>Build FHIR API Demonstration dashboard page<br>Create screenshot documentation<br>Write dashboard interpretation notes<br>Finalize report UX and accessibility checks |
| ClinicalPulse\Sprint 7 - FHIR API Component | FHIR mapping, API SQL views, FastAPI service, tests, sample JSON, and API documentation | Create FHIR mapping document<br>Create API views for Patient and Encounter<br>Create API views for Observation, Condition, and Procedure<br>Set up FastAPI app structure<br>Implement health and metadata endpoints<br>Implement Patient and Encounter endpoints<br>Implement Observation and Condition endpoints<br>Implement aggregate metrics summary endpoint<br>Add endpoint tests<br>Export sample FHIR-style JSON responses<br>Create API reference documentation |
| ClinicalPulse\Sprint 8 - Governance and Portfolio Delivery | Final documentation, adoption materials, repository cleanup, and portfolio packaging | Write README project narrative<br>Create final architecture diagram<br>Create public portfolio safety section<br>Create adoption plan<br>Create dashboard user guide<br>Create feedback and change-control loop<br>Create final project walkthrough<br>Clean repository and verify folder structure<br>Prepare resume and interview talking points<br>Create final release tag and evidence checklist |
| ClinicalPulse\Sprint 9 - Optional Pipeline Hardening | Optional test automation, CI checks, forbidden-file checks, and DevOps retrospective | Create pytest suite for quality rules<br>Create API endpoint and FHIR shape tests<br>Create configuration and secrets safety tests<br>Create Azure Pipeline YAML<br>Add lint, test, and documentation checks<br>Add forbidden-file checks<br>Document pipeline results<br>Add build badge or status notes<br>Create final DevOps retrospective |

## Tagging Conventions

Each work item should use a small set of tags that make bulk filtering and path assignment reliable.

| Tag Type | Format | Example |
|---|---|---|
| Project | `ClinicalPulse` | `ClinicalPulse` |
| Epic | `E##` | `E01` |
| Feature | `F##.##` | `F01.01` |
| Area Path | `AP-ClinicalPulse\<Area Path>` | `AP-ClinicalPulse\Governance and Planning` |
| Iteration Path | `IP-ClinicalPulse\<Sprint Name>` | `IP-ClinicalPulse\Sprint 0 - Project Setup` |
| Topic | Short descriptive label | `Azure-Boards`, `GitHub`, `SQL-Server`, `Power-BI`, `FHIR-API` |

### Area Path Tags

| Area Path | Area Path Tag |
|---|---|
| ClinicalPulse\Data Quality and Governance | `AP-ClinicalPulse\Data Quality and Governance` |
| ClinicalPulse\DevOps and Delivery | `AP-ClinicalPulse\DevOps and Delivery` |
| ClinicalPulse\Documentation and Portfolio | `AP-ClinicalPulse\Documentation and Portfolio` |
| ClinicalPulse\FHIR API | `AP-ClinicalPulse\FHIR API` |
| ClinicalPulse\Governance and Planning | `AP-ClinicalPulse\Governance and Planning` |
| ClinicalPulse\Power BI | `AP-ClinicalPulse\Power BI` |
| ClinicalPulse\Source Data | `AP-ClinicalPulse\Source Data` |
| ClinicalPulse\SQL Server | `AP-ClinicalPulse\SQL Server` |

### Iteration Path Tags

| Iteration Path | Iteration Path Tag |
|---|---|
| ClinicalPulse\Sprint 0 - Project Setup | `IP-ClinicalPulse\Sprint 0 - Project Setup` |
| ClinicalPulse\Sprint 1 - Governance and Design | `IP-ClinicalPulse\Sprint 1 - Governance and Design` |
| ClinicalPulse\Sprint 2 - Source Data Foundation | `IP-ClinicalPulse\Sprint 2 - Source Data Foundation` |
| ClinicalPulse\Sprint 3 - SQL Server Ingestion | `IP-ClinicalPulse\Sprint 3 - SQL Server Ingestion` |
| ClinicalPulse\Sprint 4 - Silver Layer and Validation | `IP-ClinicalPulse\Sprint 4 - Silver Layer and Validation` |
| ClinicalPulse\Sprint 5 - Gold Layer and Marts | `IP-ClinicalPulse\Sprint 5 - Gold Layer and Marts` |
| ClinicalPulse\Sprint 6 - Power BI Reporting | `IP-ClinicalPulse\Sprint 6 - Power BI Reporting` |
| ClinicalPulse\Sprint 7 - FHIR API Component | `IP-ClinicalPulse\Sprint 7 - FHIR API Component` |
| ClinicalPulse\Sprint 8 - Governance and Portfolio Delivery | `IP-ClinicalPulse\Sprint 8 - Governance and Portfolio Delivery` |
| ClinicalPulse\Sprint 9 - Optional Pipeline Hardening | `IP-ClinicalPulse\Sprint 9 - Optional Pipeline Hardening` |

## Assumptions and Limitations

- Azure Boards remains the system of record for live work item state, ownership, priority, and completion status.
- This document summarizes planning structure; it does not replace the live Azure Boards backlog.
- Sprint start and end dates are not defined in this file because the current Azure DevOps iteration setup does not show dates.
- User Story IDs are listed only where currently visible and confirmed.
- Sprint 9 is optional hardening work and may be reduced if the core platform needs more time.

## Traceability

This artifact supports AB#1378. Work related to this planning artifact should reference `AB#1378` in Git commits, pull requests, or Azure Boards comments.
