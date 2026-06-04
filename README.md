# ClinicalPulse

**ClinicalPulse** is a governed hospital BI platform that transforms synthetic EHR-style data into trusted SQL Server reporting layers, validated operational KPIs, and Power BI-ready analytics assets.

The project simulates how a healthcare analytics team moves from raw source data to governed reporting: ingestion, medallion-style modeling, data quality validation, KPI documentation, dashboard preparation, and planned FHIR-aligned API outputs.

> This project uses synthetic healthcare data. It does not contain real patient records and is not intended for clinical decision-making.

---

## Project Objective

ClinicalPulse is designed to demonstrate end-to-end healthcare BI delivery:

- ingest synthetic EHR data into SQL Server
- preserve raw source structure in a bronze layer
- standardize and validate business entities in a silver layer
- build reporting-ready gold facts, dimensions, and marts
- define governed KPIs before dashboard delivery
- validate metrics with SQL and Python checks
- prepare a Power BI semantic model and dashboard layer
- document security, lineage, data quality, and public-portfolio safety
- expose selected entities through a lightweight FHIR-aligned API in a later phase

The business focus is hospital operational reporting: patient flow, encounter volume, length of stay, readmissions, service utilization, observation/lab activity, and reporting trust.

---

## Current Status

| Area | Status |
|---|---|
| Project governance and planning | Complete |
| Source data foundation | Complete |
| SQL Server database and schemas | Complete |
| Bronze ingestion layer | Complete |
| Silver standardized entity layer | Complete |
| Data quality validation framework | Complete |
| Gold reporting layer and marts | Complete |
| KPI validation queries | Complete |
| Power BI semantic model and dashboards | In progress |
| FHIR-aligned API component | Planned |
| Optional pipeline hardening | Planned |

ClinicalPulse has reached the point where the SQL Server analytical foundation is ready for Power BI reporting work.

---

## Architecture

```text
Synthea synthetic EHR CSVs
        |
        v
SQL Server bronze layer
        |
        v
SQL Server silver layer  --->  Data quality checks  --->  Governance tables
        |
        v
SQL Server gold layer    --->  KPI validation queries --->  Governance tables
        |
        v
Power BI semantic model
        |
        v
Operational dashboards

Planned interoperability path:
SQL Server gold layer ---> FHIR-aligned API views ---> FastAPI endpoints
```

### Layering approach

| Layer | Purpose |
|---|---|
| Bronze | Source-preserving raw tables with ingestion metadata and row hashes. |
| Silver | Typed, standardized, validated business entities with lineage back to bronze. |
| Gold | Reporting-ready facts, dimensions, marts, and KPI-ready structures. |
| Governance | KPI definitions, quality rules, validation results, lineage, and reporting trust assets. |
| Audit | Ingestion and reconciliation run history. |
| API | Planned FHIR-aligned SQL views and FastAPI outputs. |

---

## Data Source

ClinicalPulse uses **Synthea synthetic healthcare data** to simulate EHR-like hospital data while remaining safe for a public portfolio repository.

Current loaded source entities include:

| Entity | Loaded Rows |
|---|---:|
| Patients | 1,145 |
| Encounters | 71,663 |
| Conditions | 43,758 |
| Observations | 945,531 |
| Procedures | 196,207 |
| Organizations | 826 |
| Providers | 826 |
| **Total loaded rows** | **1,259,956** |

Raw generated files are kept outside Git under `data/raw/` and are intentionally excluded from version control.

---

## Tech Stack

| Category | Tools |
|---|---|
| Database | SQL Server, T-SQL |
| Data ingestion | Python, pandas, SQLAlchemy, pyodbc |
| Validation | Python scripts, SQL validation queries, governance tables |
| BI reporting | Power BI, DAX, semantic modeling |
| Interoperability | FHIR-style JSON, FastAPI planned |
| Delivery | Git, GitHub, Azure DevOps Boards |
| Governance | KPI dictionary, data quality rules, lineage, scorecards, security assumptions |

---

## Repository Structure

```text
clinical-pulse-healthcare-bi/
├── azure-devops/          # Backlog, sprint planning, and work tracking exports
├── data/                  # Local-only raw/interim/processed data folders; raw data excluded from Git
├── docs/                  # Governance, architecture, KPI, source data, and delivery documentation
├── powerbi/               # Power BI notes, measure definitions, and screenshots when available
├── sql/                   # SQL Server database, schema, transformation, quality, and KPI scripts
├── src/                   # Python ingestion, reconciliation, validation, and future API scripts
├── tests/                 # Planned automated checks
├── .gitignore
└── README.md
```

---

## Implemented Components

### SQL Server foundation

The database currently uses dedicated schemas for:

- `bronze`
- `silver`
- `gold`
- `governance`
- `audit`
- `api`

Bronze tables preserve source-like Synthea structures. Silver tables apply typed fields, standardized names, quality flags, derived values, and lineage columns. Gold tables and marts support reporting and KPI validation.

### Ingestion and reconciliation

Python scripts load local Synthea CSV files into SQL Server and reconcile row counts across source files and database tables.

Key scripts include:

```text
src/ingest_synthea_csv_to_sqlserver.py
src/row_count_reconciliation.py
src/run_quality_checks.py
```

### Data quality framework

ClinicalPulse includes a governed quality framework with rule metadata and persisted check results.

Current validation coverage includes checks for:

- completeness
- uniqueness
- referential integrity
- date and timestamp validity
- consistency
- freshness
- lineage coverage

The latest quality run shows strong silver-layer readiness, with one governed observation-duplicate finding retained transparently instead of hidden.

### KPI governance

The KPI dictionary defines business-facing metrics before Power BI implementation. Core KPIs include:

- Total Encounters
- Unique Patients
- Average Length of Stay
- Median Length of Stay
- 30-Day Readmission Rate
- Observation Volume
- Procedure Volume
- Data Quality Pass Rate
- API Resource Coverage

Each KPI is tied to a business question, formal calculation approach, SQL source objects, expected Power BI measure, validation method, data quality dependencies, and known limitations.

---

## Power BI Reporting Scope

Power BI reporting is the active next layer of the project. The dashboard design is intended to connect to the SQL Server gold layer rather than raw CSV files or bronze tables.

Planned dashboard pages:

| Page | Purpose |
|---|---|
| Executive Overview | High-level operational KPIs and reporting trust indicators. |
| Patient Flow | Encounter trends, encounter class breakdowns, and length-of-stay patterns. |
| Readmissions | 30-day readmission count/rate and return-encounter patterns. |
| Conditions & Procedures | Case mix, procedure volume, and utilization context. |
| Lab / Observation Operations | Observation volume and test/activity trends. |
| Data Quality & Governance | Rule pass/fail status, asset readiness, and KPI documentation coverage. |
| FHIR API Demonstration | Planned interoperability coverage and sample resource outputs. |

---

## Public Portfolio Safety

ClinicalPulse is built to be public-portfolio-safe:

- uses synthetic Synthea data only
- excludes raw generated CSVs from Git
- excludes local credentials, secrets, database backups, and Power BI binary files where appropriate
- avoids presenting synthetic outputs as real hospital performance
- documents known limitations and data quality dependencies
- models governance practices even though the source data is synthetic

---

## Local Development Notes

A typical local build follows this sequence:

1. Generate or acquire Synthea CSV files locally.
2. Place raw files under `data/raw/synthea/`.
3. Configure local SQL Server connection settings through environment variables.
4. Run SQL setup scripts in order from the `sql/` folder.
5. Load source CSVs into bronze with the Python ingestion script.
6. Run row-count reconciliation.
7. Build silver and gold layers using the transformation scripts.
8. Run data quality and KPI validation scripts.
9. Connect Power BI to the gold reporting layer.

Example Python validation commands:

```bash
python src/row_count_reconciliation.py
python src/run_quality_checks.py
```

---

## Roadmap

Near-term work:

- build the Power BI semantic model
- implement DAX measures tied to the KPI dictionary
- validate Power BI measures against SQL validation queries
- capture dashboard screenshots and reporting notes

Later work:

- create FHIR-aligned SQL views under the `api` schema
- build lightweight FastAPI endpoints for selected synthetic resources
- add sample FHIR-style JSON responses
- add endpoint tests and optional pipeline checks
- finalize portfolio-facing documentation and architecture visuals

---

## Project Positioning

ClinicalPulse demonstrates practical healthcare analytics delivery across data engineering, BI development, governance, validation, and stakeholder-facing reporting.

It is intended to show not only that the data pipeline works, but that the resulting metrics are documented, traceable, validated, and safe to present in a public professional portfolio.
