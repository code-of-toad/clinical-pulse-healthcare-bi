# Generate Synthea Data

## Purpose

This document defines the selected Synthea generation settings for ClinicalPulse.

The purpose is to make the synthetic source dataset reproducible, clearly scoped, and safe for a public healthcare BI portfolio project.

ClinicalPulse uses Synthea synthetic EHR data as the source system for downstream SQL Server ingestion, medallion-style transformation, data quality validation, Power BI reporting, and FHIR-aligned API demonstrations.

## Selected Generation Settings

| Setting | Decision |
|---|---|
| Source system | Synthea synthetic EHR data |
| Generation geography | Massachusetts, United States |
| Portfolio context | Ontario-facing governed hospital BI simulation |
| Population size | 1,000 synthetic patients for the initial development baseline |
| Random seed | Fixed seed: `1409` |
| Export format | CSV |
| Raw data location | `data/raw/synthea/` |
| Ingestion target | SQL Server bronze layer |
| FHIR export | Reserved for later FHIR/API implementation work |
| Git handling | Raw generated data must not be committed to Git |

## Rationale for Settings

Massachusetts is selected as the Synthea generation geography because it is a standard, low-risk Synthea-supported geography. This keeps the source data foundation focused on reproducible data generation rather than custom geography configuration.

ClinicalPulse remains framed as an Ontario-facing healthcare BI portfolio project. However, the generated dataset does not represent Ontario patients, Ontario hospitals, Ontario demographics, or Ontario health-system operations.

The fixed seed supports reproducibility. The selected population size of 1,000 synthetic patients is large enough to support meaningful source profiling, ingestion testing, quality validation, KPI development, and dashboard prototyping, while remaining small enough for fast local development and manual inspection.

Larger Synthea populations may be generated later for scalability or performance testing after the ingestion, transformation, validation, and reporting layers are stable.

CSV is selected as the export format because the source files will be loaded into SQL Server bronze tables.

## Source Data Scope

The core source entities are:

| Synthea Entity | ClinicalPulse Use |
|---|---|
| `patients.csv` | Patient dimension, demographics, age bands, death indicator |
| `encounters.csv` | Encounter volume, encounter type, start/stop timing, length of stay, readmission logic |
| `conditions.csv` | Diagnosis and cohorting context |
| `observations.csv` | Lab and clinical observation activity |
| `procedures.csv` | Procedure and service utilization context |
| `organizations.csv` | Organization and site context |
| `providers.csv` | Provider reference data |

Optional entities may be generated but are not part of the core implementation scope unless explicitly selected later:

| Optional Entity | Reason Deferred |
|---|---|
| `medications.csv` | Useful for later prescribing or treatment analysis, but outside the first operational BI scope |
| `careplans.csv` | Useful for care pathway analysis, but not required for core dashboards |
| `payers.csv` | Useful for administrative analysis, but secondary to operational BI |
| `allergies.csv` | Clinical context only; not required for the selected hospital operations use cases |
| `imaging_studies.csv` | Adds complexity and is not required for the initial reporting model |
| `immunizations.csv` | Not required for the selected hospital operations use cases |
| `devices.csv` | Not required for the selected hospital operations use cases |
| `supplies.csv` | Not required for the selected hospital operations use cases |

## Reproducibility Notes

The generation run should be documented with:

| Item | Value |
|---|---|
| Geography | Massachusetts, United States |
| Population | 1,000 synthetic patients |
| Seed | `1409` |
| Export format | CSV |
| Output folder | `data/raw/synthea/` |

The exact command used to generate or acquire the dataset should be recorded when the source files are generated.

## Data Handling Rules

Generated raw source files belong under:

```text
data/raw/synthea/
```

Raw generated files must not be committed to Git.

Only intentionally curated tiny sample files may be committed under:

```text
data/samples/
```

Any committed sample data must be synthetic, minimal, clearly documented, and safe for public portfolio use.

## Assumptions and Limitations

The dataset is synthetic and does not contain real patient information.

The dataset does not represent Ontario patients, Ontario hospitals, Ontario demographics, or Ontario healthcare operations.

ClinicalPulse uses the dataset to demonstrate healthcare BI engineering, governance, validation, reporting, and interoperability concepts.

Outputs from this project are not suitable for clinical decision-making, operational deployment, public health inference, or real hospital performance evaluation.

The geography decision is an implementation choice for reproducibility, not a claim about the project’s business setting.
