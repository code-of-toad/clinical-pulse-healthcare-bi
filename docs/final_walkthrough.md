# ClinicalPulse Final Project Walkthrough

## 1. Purpose

This walkthrough gives a portfolio reviewer a concise path through ClinicalPulse—from the hospital reporting problem to the implemented SQL Server platform, governed metrics, Power BI dashboards, and supporting evidence.

ClinicalPulse uses synthetic Synthea data. It does not contain real patient records, represent real hospital performance, provide clinical evidence, or support clinical decision-making.

## 2. Project in One Sentence

ClinicalPulse is a governed hospital business intelligence platform that transforms synthetic EHR data into auditable SQL Server reporting layers, validated operational KPIs, and stakeholder-facing Power BI dashboards.

## 3. Business Problem

Hospital leaders and operational teams need reliable visibility into:

- encounter activity
- patient flow
- length of stay
- 30-day readmissions
- condition and procedure utilization
- observation workload
- data quality and reporting trust

A dashboard alone does not make those metrics trustworthy. Users also need to know:

- what each KPI means
- which records are included or excluded
- where the number comes from
- whether the supporting data passed quality checks
- who owns the metric
- what limitations affect interpretation

ClinicalPulse addresses both the reporting need and the governance need.

## 4. Solution Overview

The implemented flow is:

```text
Synthea synthetic CSV data
        |
        v
Python ingestion and audit logging
        |
        v
SQL Server bronze schema
Source-preserving tables with ingestion metadata
        |
        v
SQL Server silver schema
Typed, standardized, quality-aware business entities
        |
        v
SQL Server gold schema
Dimensions, facts, and reporting marts
        |
        v
Power BI semantic model
Relationships, date model, and governed DAX measures
        |
        v
Operational dashboards and governance reporting
```

Governance spans the full platform through KPI definitions, data quality rules, lineage, asset cataloging, scorecards, ownership, security assumptions, validation evidence, and adoption documentation.

Review the visual architecture at:

```text
docs/architecture_diagram.png
```

## 5. What Was Built

### 5.1 Synthetic source foundation

ClinicalPulse uses seven Synthea CSV entities:

- patients
- encounters
- conditions
- observations
- procedures
- organizations
- providers

The latest documented source load contains **1,259,956 rows** across the seven files.

Raw generated data remains local and is excluded from the public repository.

### 5.2 Python-assisted ingestion

Python supports:

- reading the Synthea CSV files
- loading source records into SQL Server bronze tables
- recording batch and file-level metadata
- reconciling row counts
- executing and persisting quality-check results

The analytical backbone remains SQL Server rather than Python or local CSV files.

### 5.3 SQL Server medallion architecture

| Layer | Purpose |
|---|---|
| Bronze | Preserve source structure and ingestion metadata |
| Silver | Apply business-friendly naming, data typing, derived fields, validation flags, and source lineage |
| Gold | Deliver reporting-ready dimensions, facts, and marts |
| Governance | Store quality-rule definitions and quality-check results |
| Audit | Record ingestion batches, file loads, and reconciliation evidence |

The gold layer contains **20 reporting objects**:

- 8 dimensions
- 6 fact tables
- 6 reporting marts

Power BI connects only to governed gold-layer assets.

### 5.4 Data quality framework

The quality framework covers:

- completeness
- uniqueness
- referential integrity
- validity
- consistency
- freshness
- lineage

The documented reporting state contains:

- 20 implemented quality checks
- 19 passed checks
- 1 failed check
- 95.00% check-based pass rate

The failed check is not hidden. It documents **256 excess duplicate observation records** under the governed observation-grain definition.

This finding is carried into KPI and dashboard interpretation because observation counts may overstate unique activity.

### 5.5 Governed KPI layer

ClinicalPulse documents operational metrics through a KPI dictionary that records:

- business question
- plain-language definition
- formal formula
- grain
- inclusion and exclusion criteria
- SQL source objects
- Power BI measure
- owner and steward
- validation approach
- data quality dependencies
- known limitations

Core metrics include:

- Total Encounters
- Unique Patients
- Average LOS
- Median LOS
- 30-Day Readmissions
- 30-Day Readmission Rate
- Observation Volume
- Procedure Volume
- Data Quality Pass Rate

### 5.6 Power BI semantic model and dashboards

The Power BI model uses:

- SQL Server Import mode
- gold-layer tables and marts
- conformed dimensions
- a shared date table
- documented relationships
- governed DAX measures
- SQL-to-DAX reconciliation

The completed report contains seven pages:

| Page | Purpose |
|---|---|
| Executive Overview | Headline operational activity and reporting trust |
| Patient Flow | Encounter volume and patient-mix analysis |
| Length of Stay | Average, median, long-stay, and encounter-class patterns |
| Readmissions | Simplified 30-day return frequency and timing |
| Conditions & Procedures | Synthetic case mix and service utilization |
| Lab / Observation Operations | Observation workload, groups, codes, and trends |
| Data Quality & Governance | Quality checks, findings, KPI documentation, and asset readiness |

The local `.pbix` remains outside Git. Aggregate screenshots, measure definitions, semantic-model notes, and validation documentation provide public evidence.

## 6. Recommended Reviewer Walkthrough

The following sequence can be completed in approximately 10 minutes.

### Step 1 — Understand the project thesis

Open:

```text
README.md
```

Review:

- the business problem
- project thesis
- implemented technology stack
- completed scope
- portfolio-safety boundaries

Key message:

> ClinicalPulse is not merely a dashboard. It is a governed analytical workflow from synthetic source data to trusted reporting.

### Step 2 — Review the architecture

Open:

```text
docs/architecture_diagram.png
```

Follow the flow from:

1. Synthea CSV files
2. Python ingestion
3. bronze
4. silver
5. gold
6. Power BI
7. stakeholder use

Notice that audit, governance, quality, documentation, security, and delivery controls surround the data flow rather than appearing as an afterthought.

### Step 3 — Inspect the technical build

Review:

```text
sql/
src/
```

Focus on:

- database and schema creation
- bronze ingestion structures
- bronze-to-silver transformations
- silver-to-gold transformations
- quality checks
- KPI validation queries
- Python ingestion and reconciliation utilities

Key message:

> SQL Server is the source of truth for the analytical model, while Python supports ingestion and repeatable validation work.

### Step 4 — Review the governed reporting layer

Open:

```text
docs/kpi_dictionary.md
docs/data_lineage.md
docs/data_asset_catalog.md
docs/data_asset_scorecards.md
```

Select one KPI—such as Total Encounters, Average LOS, or 30-Day Readmission Rate—and trace:

1. business definition
2. source entity
3. bronze table
4. silver entity
5. gold fact or mart
6. Power BI measure
7. validation evidence
8. dashboard page

Key message:

> A reviewer can trace a visible metric back to its definition and implementation logic.

### Step 5 — Review the Power BI model

Open:

```text
powerbi/semantic_model_notes.md
powerbi/measure_definitions.md
docs/powerbi_validation_log.md
```

Confirm:

- Power BI connects only to gold assets
- the date table is used consistently
- relationships are documented
- DAX measures have SQL validation counterparts
- assumptions and exclusions remain visible

### Step 6 — Review the dashboards

Open:

```text
powerbi/screenshots/
docs/dashboard_user_guide.md
```

Begin with the Executive Overview, then review one operational page and the Data Quality & Governance page.

Suggested path:

1. Executive Overview
2. Length of Stay or Readmissions
3. Lab / Observation Operations
4. Data Quality & Governance

Key message:

> Operational measures and reporting-trust evidence are presented together.

### Step 7 — Review safety and adoption controls

Open:

```text
docs/security_model.md
docs/adoption_plan.md
docs/change_control.md
```

Review:

- synthetic-data boundaries
- local-only and excluded artifacts
- least-privilege assumptions
- role-based training
- feedback intake
- KPI and dashboard change control
- public-release safety checks

Key message:

> The project models how a BI product should be adopted, governed, maintained, and represented responsibly.

## 7. One KPI Traceability Example

### Total Encounters

| Stage | Artifact |
|---|---|
| Business definition | `docs/kpi_dictionary.md` |
| Source entity | `encounters.csv` |
| Bronze object | `bronze.encounters` |
| Silver object | `silver.encounter` |
| Gold object | `gold.fact_encounter` |
| Reporting mart | `gold.mart_patient_flow` |
| DAX measure | `Total Encounters` |
| Measure documentation | `powerbi/measure_definitions.md` |
| SQL validation | `sql/08_kpi_validation_queries.sql` |
| Reconciliation evidence | `docs/powerbi_validation_log.md` |
| Dashboard pages | Executive Overview; Patient Flow |

This trace demonstrates the central ClinicalPulse design principle: a dashboard number should be understandable, testable, and traceable.

## 8. Important Implementation Decisions

### SQL Server is the analytical backbone

Power BI does not connect directly to raw CSV files. Business logic is implemented in governed SQL Server layers before reporting.

### Bronze remains source-preserving

Bronze retains source-like fields and ingestion metadata so transformations remain auditable.

### Silver performs controlled standardization

Silver converts source strings into typed dates, timestamps, numeric fields, and derived business attributes while preserving lineage.

### Gold is reporting-ready

Facts, dimensions, and marts provide clear analytical grains and reusable reporting structures.

### Governance is visible

Known findings, limitations, KPI definitions, ownership, and quality results are documented rather than hidden.

### Public evidence avoids embedded data

The `.pbix`, raw data, backups, credentials, and local configuration remain outside Git. Public review relies on code, documentation, diagrams, and aggregate screenshots.

## 9. Completed Scope

ClinicalPulse demonstrates:

- synthetic healthcare source-data management
- Python-assisted SQL Server ingestion
- audit logging and row-count reconciliation
- bronze, silver, and gold data layers
- fact, dimension, and reporting-mart design
- data quality rules and persisted results
- governed KPI definitions
- source-to-dashboard lineage
- Power BI semantic modeling
- DAX measures and SQL reconciliation
- seven stakeholder-facing report pages
- ownership, security, adoption, and change-control documentation
- Git, GitHub, and Azure DevOps delivery discipline

## 10. Excluded Scope

The final release does not include:

- a FHIR API
- a production interoperability service
- optional CI/CD pipeline hardening
- a production Power BI Service deployment
- enterprise identity or role implementation
- real hospital or patient data
- clinical-decision support
- regulatory or security certification

These exclusions are deliberate scope decisions and must not be represented as completed functionality.

## 11. Portfolio Value

ClinicalPulse demonstrates the ability to combine:

- business problem framing
- healthcare data modeling
- SQL and Python implementation
- dimensional modeling
- Power BI reporting
- KPI governance
- data quality management
- lineage and ownership
- public portfolio safety
- stakeholder-facing documentation
- disciplined project delivery

The strongest portfolio signal is not any single tool. It is the complete chain from operational question to governed, traceable, and clearly communicated analytical output.

## 12. Suggested Closing Statement

> ClinicalPulse shows how I approach business intelligence as more than dashboard creation. I started with hospital operational questions, built auditable SQL Server data layers from synthetic EHR data, defined and validated the KPIs, created a governed Power BI model, surfaced known data-quality limitations, and documented how the solution should be reviewed, adopted, secured, and maintained.

## 13. Assumptions

- ClinicalPulse runs in a controlled local development environment.
- Synthea is the only healthcare-data source.
- SQL Server gold assets are the authoritative reporting layer.
- Power BI Desktop is the report-authoring environment.
- The `.pbix`, raw files, backups, and credentials remain local.
- Public screenshots represent the completed v1.0 report state.
- Modeled users, owners, and stewards represent governance responsibilities rather than real hospital staffing.

## 14. Limitations

- Synthetic data does not reproduce real hospital workflow, case mix, operational pressure, privacy obligations, or clinical complexity.
- The readmission model uses simplified encounter sequencing and does not distinguish planned from unplanned events.
- Observation volume is affected by the documented duplicate-record finding.
- Static screenshots cannot reproduce full Power BI interaction behavior.
- No real user adoption study, production deployment, or Power BI Service telemetry exists.
- The project does not claim production readiness, compliance certification, clinical validity, or real-world hospital performance.
