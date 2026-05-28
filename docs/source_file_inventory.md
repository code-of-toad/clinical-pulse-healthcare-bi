# Source File Inventory

## Purpose

This document inventories the selected Synthea CSV source files used by ClinicalPulse. It records where the raw files are stored locally, which files are in scope, row counts from the retained generation run, expected identifiers, and expected relationships needed for SQL Server ingestion and downstream modeling.

## Source Location

| Item | Value |
|---|---|
| Source system | Synthea synthetic EHR data |
| Local raw data folder | `data/raw/synthea/` |
| Export format | CSV |
| Git handling | Raw generated CSV files are local-only and must not be committed to Git |
| Generation documentation | `docs/generate_synthea_data.md` |

## Generation Run Summary

| Item | Value |
|---|---|
| Geography | Massachusetts, United States |
| Population setting | 1,000 living synthetic patients |
| Observed patient records | 1,145 total |
| Alive synthetic patients | 1,000 |
| Deceased synthetic patients | 145 |
| Synthea RNG | `1000` |
| Clinician RNG | `5643` |

## Selected Source Files

| File | Inclusion Status | Row Count | Expected Main Identifier | Important Relationship Fields | ClinicalPulse Use |
|---|---:|---:|---|---|---|
| `patients.csv` | Core | 1,145 | `Id` | Patient-level source entity | Patient demographics, age bands, death indicator, patient dimension |
| `encounters.csv` | Core | 71,663 | `Id` | `PATIENT`, `ORGANIZATION`, `PROVIDER` | Encounter volume, encounter class, start/stop timing, length of stay, readmission logic |
| `conditions.csv` | Core | 43,758 | No single source row ID; use generated bronze row key plus source fields | `PATIENT`, `ENCOUNTER` | Diagnosis and cohorting context |
| `observations.csv` | Core | 945,531 | No single source row ID; use generated bronze row key plus source fields | `PATIENT`, `ENCOUNTER` | Lab and clinical observation activity |
| `procedures.csv` | Core | 196,207 | No single source row ID; use generated bronze row key plus source fields | `PATIENT`, `ENCOUNTER` | Procedure and service utilization context |
| `organizations.csv` | Core | 826 | `Id` | Referenced by `encounters.csv` and `providers.csv` | Organization and facility context |
| `providers.csv` | Core | 826 | `Id` | `ORGANIZATION` | Provider reference data and optional operational attribution |

## Expected Relationship Map

| Source Relationship | Expected Join Logic | Notes |
|---|---|---|
| Patients to encounters | `patients.Id = encounters.PATIENT` | Supports patient-level encounter history and encounter-based KPIs |
| Patients to conditions | `patients.Id = conditions.PATIENT` | Supports condition and cohort analysis |
| Patients to observations | `patients.Id = observations.PATIENT` | Supports observation/lab activity by patient |
| Patients to procedures | `patients.Id = procedures.PATIENT` | Supports procedure utilization by patient |
| Encounters to conditions | `encounters.Id = conditions.ENCOUNTER` | Supports diagnosis context by encounter |
| Encounters to observations | `encounters.Id = observations.ENCOUNTER` | Supports observation activity by encounter |
| Encounters to procedures | `encounters.Id = procedures.ENCOUNTER` | Supports procedure activity by encounter |
| Organizations to encounters | `organizations.Id = encounters.ORGANIZATION` | Supports organization-level reporting |
| Organizations to providers | `organizations.Id = providers.ORGANIZATION` | Supports provider-to-organization reference context |
| Providers to encounters | `providers.Id = encounters.PROVIDER` | Supports optional provider-level attribution |

## Ingestion Notes

The raw CSV files should be loaded into SQL Server bronze tables as source-preserving objects. Bronze ingestion should preserve source identifiers and add technical metadata such as ingestion batch ID, ingestion timestamp, source file name, row hash, and load status.

For source files without a single stable row identifier, such as `conditions.csv`, `observations.csv`, and `procedures.csv`, the bronze layer should create a technical row key during ingestion. Candidate uniqueness checks can still use combinations of patient, encounter, code, date, description, value, and source file row position where applicable.

## Validation Performed

The selected source files were validated locally as present and non-empty under `data/raw/synthea/`.

Validation command used:

```powershell
$required = 'patients.csv','encounters.csv','conditions.csv','observations.csv','procedures.csv','organizations.csv','providers.csv'

$required | ForEach-Object {
    $path = ".\data\raw\synthea\$_"
    [pscustomobject]@{
        File = $_
        Exists = Test-Path $path
        Rows = if (Test-Path $path) { ([System.IO.File]::ReadLines($path) | Measure-Object).Count - 1 } else { $null }
    }
} | Format-List
```

Validation result:

| File | Exists | Rows |
|---|---:|---:|
| `patients.csv` | Yes | 1,145 |
| `encounters.csv` | Yes | 71,663 |
| `conditions.csv` | Yes | 43,758 |
| `observations.csv` | Yes | 945,531 |
| `procedures.csv` | Yes | 196,207 |
| `organizations.csv` | Yes | 826 |
| `providers.csv` | Yes | 826 |

## Assumptions and Limitations

The inventory reflects the retained local Synthea generation run documented in `docs/generate_synthea_data.md`.

The files are synthetic and do not contain real patient information.

The dataset does not represent Ontario patients, Ontario hospitals, Ontario demographics, or Ontario healthcare operations.

The raw CSV files are intentionally excluded from Git. This inventory documents the expected local source files so that the dataset can be regenerated, replaced, or validated without committing raw generated data.

Row counts may change if the Synthea version, seed, generation settings, export settings, or geography are changed. Any replacement dataset should update this inventory before downstream ingestion or modeling continues.
