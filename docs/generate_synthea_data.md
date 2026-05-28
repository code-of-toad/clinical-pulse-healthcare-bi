# Generate Synthea Data

## Purpose

This document defines how the ClinicalPulse source dataset is generated, stored, validated, and regenerated.

ClinicalPulse uses Synthea synthetic EHR data as the source system for downstream SQL Server ingestion, medallion-style transformation, data quality validation, Power BI reporting, and FHIR-aligned API demonstrations.

The source dataset is synthetic. It does not contain real patient information and must not be interpreted as representing real Ontario patients, hospitals, demographics, or health-system operations.

## Source Acquisition Method

The source data is generated locally using Synthea, an open-source synthetic patient generator. The generated CSV files are stored locally under:

```text
data/raw/synthea/
```

Raw generated CSV files are local development artifacts and must not be committed to Git.

## Selected Generation Settings

| Setting | Decision |
|---|---|
| Source system | Synthea synthetic EHR data |
| Generation geography | Massachusetts, United States |
| Portfolio context | Ontario-facing governed hospital BI simulation |
| Population setting | 1,000 living synthetic patients |
| Observed generated patient records | 1,145 total patient records |
| Observed living patients | 1,000 |
| Observed deceased patients | 145 |
| Observed Synthea RNG | `1000` |
| Observed clinician RNG | `5643` |
| Export format | CSV |
| Raw data location | `data/raw/synthea/` |
| SQL Server ingestion target | Bronze layer |
| Git handling | Raw generated data must not be committed to Git |

## Rationale for Settings

Massachusetts is selected as the Synthea generation geography because it is a standard, low-risk Synthea-supported geography. This keeps the project focused on healthcare BI implementation rather than custom geography configuration.

ClinicalPulse remains framed as an Ontario-facing healthcare BI portfolio project. The generated dataset is used to simulate governed hospital BI workflows, but it does not represent Ontario patients, Ontario hospitals, Ontario demographics, or Ontario healthcare operations.

The population setting is 1,000 living synthetic patients. Synthea may generate more than 1,000 total patient records because deceased simulated patients can be included in the output. The retained generation run produced 1,145 total patient records: 1,000 living and 145 deceased.

CSV is selected as the source export format because the next implementation layer loads source files into SQL Server bronze tables.

## Synthea Configuration File

Use a local Synthea configuration file such as:

```text
C:\tools\synthea\clinicalpulse.properties
```

Recommended configuration:

```properties
exporter.csv.export = true
exporter.fhir.export = false
exporter.hospital.fhir.export = false
exporter.text.export = false
exporter.ccda.export = false

exporter.baseDirectory = ./data/raw/synthea_generated
exporter.csv.folder_per_run = false
```

This configuration enables CSV export and disables unrelated export formats for the source data foundation. FHIR-style outputs are handled later through curated SQL views, sample JSON exports, and API work rather than by treating raw FHIR exports as the primary ingestion source.

## Generation Command

From the ClinicalPulse repository root, run:

```powershell
java -jar 'C:\tools\synthea\synthea-with-dependencies.jar' -c 'C:\tools\synthea\clinicalpulse.properties' -s 1000 -p 1000 Massachusetts
```

Command meaning:

| Argument | Meaning |
|---|---|
| `-c 'C:\tools\synthea\clinicalpulse.properties'` | Uses the ClinicalPulse Synthea export configuration |
| `-s 1000` | Uses the retained generation seed |
| `-p 1000` | Generates 1,000 living synthetic patients |
| `Massachusetts` | Uses Massachusetts as the Synthea geography |

The retained generation run reported:

```text
Records: total=1145, alive=1000, dead=145
RNG=1000
Clinician RNG=5643
```

## Move CSV Files into the Project Raw Data Folder

If Synthea writes CSV files into a generated output folder such as:

```text
data/raw/synthea_generated/csv/
```

copy the generated CSV files into the expected project folder:

```powershell
New-Item -ItemType Directory -Force -Path .\data\raw\synthea | Out-Null
Copy-Item .\data\raw\synthea_generated\csv\*.csv .\data\raw\synthea\ -Force
```

The canonical local source folder for ClinicalPulse is:

```text
data/raw/synthea/
```

## Required CSV Files

The core source files expected for the initial ClinicalPulse analytical scope are:

| Required File | ClinicalPulse Use |
|---|---|
| `patients.csv` | Patient dimension, demographics, age bands, death indicator |
| `encounters.csv` | Encounter volume, encounter type, start/stop timing, length of stay, readmission logic |
| `conditions.csv` | Diagnosis and cohorting context |
| `observations.csv` | Lab and clinical observation activity |
| `procedures.csv` | Procedure and service utilization context |
| `organizations.csv` | Organization and site context |
| `providers.csv` | Provider reference data |

The retained local generation run confirmed these files are present and non-empty under:

```text
data/raw/synthea/
```

## Local Validation Commands

Use PowerShell from the repository root.

Confirm that the expected files exist and contain rows:

```powershell
$required = 'patients.csv','encounters.csv','conditions.csv','observations.csv','procedures.csv','organizations.csv','providers.csv'

$required | ForEach-Object {
    $path = ".\data\raw\synthea\$_"
    [pscustomobject]@{
        File = $_
        Exists = Test-Path $path
        Rows = if (Test-Path $path) { ([System.IO.File]::ReadLines($path) | Measure-Object).Count - 1 } else { $null }
    }
} | Format-Table -AutoSize
```

Confirm that raw files are not being prepared for commit:

```powershell
git status --short --ignored data/raw/synthea/
```

The raw CSV files should appear as ignored local artifacts, not staged Git changes.

## Regeneration Steps

To regenerate the source dataset:

1. Confirm Java is installed and available from the command line.
2. Confirm the Synthea JAR exists locally, for example at `C:\tools\synthea\synthea-with-dependencies.jar`.
3. Confirm the ClinicalPulse Synthea configuration file exists, for example at `C:\tools\synthea\clinicalpulse.properties`.
4. Run the documented Synthea command from the repository root.
5. Copy generated CSV files into `data/raw/synthea/` if Synthea writes them to a staging output folder.
6. Run the local validation commands.
7. Confirm the generated raw CSV files remain excluded from Git.
8. Update this document if the seed, population setting, geography, export configuration, or retained generated output changes.

## Replacement Rules

The source dataset may be replaced later if there is a clear reason, such as larger-scale testing, changed generation settings, or a revised analytical scope.

Any replacement must document:

| Replacement Detail | Requirement |
|---|---|
| Generation geography | Must be stated clearly |
| Population setting | Must distinguish living-patient setting from total generated records |
| Seed/RNG | Must be recorded if reproducibility is expected |
| Export format | Must be stated clearly |
| Required files | Must be validated as present and non-empty |
| Output folder | Must remain under `data/raw/synthea/` unless intentionally changed |
| Git handling | Raw generated files must remain excluded from Git |
| Limitations | Synthetic-data limitations must remain explicit |

Do not silently replace the source dataset. If a new dataset is generated, update this document and any downstream source inventory, profiling, and validation artifacts affected by the change.

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
