# Data Handling Rules

## Purpose

This document defines how ClinicalPulse handles generated source data, curated sample data, local artifacts, and public repository content.

ClinicalPulse uses synthetic Synthea data, but the project still follows professional healthcare data handling practices: raw data stays local, public samples must be intentionally curated, and documentation must avoid implying that synthetic records represent real patients or real hospital operations.

## Data Classification

| Data Category | Examples | Repository Rule | Notes |
|---|---|---|---|
| Raw generated data | Full Synthea CSV exports under `data/raw/synthea/` | Do not commit | Used locally for ingestion, profiling, and validation |
| Interim data | Temporary extracts, transformed local files, staging outputs | Do not commit | Reproducible from raw data and scripts |
| Processed data | Generated analytical outputs, local marts, exports | Do not commit by default | Document structure and logic instead of committing data |
| Curated sample data | Small intentionally selected synthetic examples under `data/samples/` | May commit only if approved by this policy | Must be minimal, synthetic, documented, and safe |
| Secrets and credentials | `.env`, connection strings, passwords, keys | Do not commit | Use environment variables and local configuration |
| Local artifacts | SQL Server backups, Power BI files, caches, logs | Do not commit | Can contain machine-specific or bulky project state |
| Documentation | Markdown files under `docs/` | Commit | Should describe decisions, assumptions, limitations, and reproducibility steps |
| Source code and SQL scripts | Python, SQL, API, and test files | Commit | Must not contain embedded credentials or raw data |

## Raw Data Rules

Raw generated Synthea files belong under:

```text
data/raw/synthea/
```

Raw generated data must not be committed to Git.

This includes:

```text
*.csv
*.csv.gz
*.tsv
*.parquet
*.jsonl
*.ndjson
```

The raw dataset should remain reproducible through documentation rather than stored in the public repository. The generation settings, acquisition method, commands, and retained run summary are documented in:

```text
docs/generate_synthea_data.md
```

## Safe Sample Data Policy

Small sample files may be committed only under:

```text
data/samples/
```

A sample file is allowed only when all of the following are true:

| Requirement | Rule |
|---|---|
| Synthetic source | The sample must come only from synthetic Synthea data or manually created synthetic examples |
| Minimal size | Include only the few rows needed to demonstrate structure, tests, or documentation |
| No unnecessary identifiers | Exclude SSN, driver license, passport, full address, phone, and full-name fields unless explicitly required and clearly synthetic |
| No raw dump | The sample must not be a copied full source file or large subset |
| Clear purpose | The file must support a specific test, example, README section, or documentation need |
| Documented origin | The sample should be described as synthetic and curated |
| Public-safe content | The sample must not imply real patient, provider, hospital, or operational performance data |
| Review before commit | The sample must be inspected before staging and committing |

## Fields to Exclude from Public Samples

The following fields should generally be excluded from public sample files:

| Source File | Fields to Avoid in Public Samples |
|---|---|
| `patients.csv` | `SSN`, `DRIVERS`, `PASSPORT`, `FIRST`, `MIDDLE`, `LAST`, `MAIDEN`, `ADDRESS` |
| `organizations.csv` | `PHONE`, full street address fields unless needed for schema demonstration |
| `providers.csv` | Provider `NAME`, full address fields |
| Any file | Any field that creates unnecessary row-level detail for public demonstration |

Even when values are synthetic, these fields are not needed for public portfolio review and can distract from the governed BI purpose of the project.

## Acceptable Public Sample Examples

Acceptable sample files may include:

| Example | Purpose |
|---|---|
| A 5-row `patients_sample.csv` with synthetic IDs, birth year or age band, gender, race, ethnicity, and deceased flag | Demonstrates dimensional patient structure |
| A 10-row `encounters_sample.csv` with synthetic encounter IDs, patient IDs, start/stop dates, encounter class, and organization ID | Demonstrates encounter grain and joins |
| A 10-row `observations_sample.csv` with synthetic patient/encounter IDs, observation category, code, value type, and units | Demonstrates observation structure |
| A small expected-output fixture for tests | Supports repeatable validation without exposing raw generated files |

## Not Allowed in Public Samples

Do not commit:

- Full generated Synthea exports
- Large row subsets from `data/raw/`
- Local SQL Server backups
- Power BI `.pbix` files by default
- `.env` files or connection strings
- Files containing passwords, tokens, keys, or local machine paths
- Any sample that could be mistaken for real patient data
- Any sample that implies real hospital benchmarking, real clinical outcomes, or real operational performance

## Git Safety Rules

The repository `.gitignore` must exclude:

```text
data/raw/
data/interim/
data/processed/
*.csv
*.csv.gz
*.parquet
*.bak
*.pbix
.env
.venv/
venv/
__pycache__/
```

The repository may allow curated samples under:

```text
data/samples/
```

Before committing, run:

```powershell
git status --short
git status --short --ignored data/raw/synthea/
```

Raw generated files should appear as ignored or untracked local files, not staged changes.

## Sample Review Checklist

Before committing anything under `data/samples/`, confirm:

| Check | Expected Result |
|---|---|
| File is synthetic | Yes |
| File is intentionally small | Yes |
| File has a documented purpose | Yes |
| No credentials or secrets are present | Yes |
| No raw generated full file is included | Yes |
| Unnecessary direct identifiers are removed | Yes |
| File path is under `data/samples/` | Yes |
| README or documentation clearly identifies it as synthetic | Yes |

## Public Communication Rules

ClinicalPulse documentation, screenshots, samples, and dashboard exports should use clear synthetic-data language.

Use language such as:

```text
This project uses synthetic Synthea data for portfolio demonstration purposes.
```

Avoid language such as:

```text
This dashboard shows real hospital performance.
This data represents Ontario patients.
This output can support clinical decision-making.
```

## Assumptions and Limitations

Synthea data is synthetic and does not contain real patient information.

The dataset does not represent Ontario patients, Ontario hospitals, Ontario demographics, Massachusetts health-system performance, or real hospital operations.

Safe samples are allowed only to support reproducibility, testing, documentation, or portfolio review. They are not a substitute for the full local raw dataset.

Raw generated data should be regenerated or acquired locally using the documented Synthea settings rather than committed to the repository.
