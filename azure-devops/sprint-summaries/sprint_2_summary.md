# Sprint 2 Summary: Source Data Foundation

## Sprint Objective

Sprint 2 established the ClinicalPulse source data foundation using Synthea synthetic EHR data. The work focused on selecting reproducible generation settings, generating the local CSV dataset, documenting source acquisition and regeneration steps, inventorying and profiling core source files, identifying optional entities for later expansion, and strengthening repository safety rules for raw data, secrets, local artifacts, and public-safe samples.

## Completed User Stories

| ID | User Story | Outcome | Deliverable |
|---:|---|---|---|
| 1409 | Choose Synthea generation settings | Defined reproducible Synthea settings and project framing | `docs/generate_synthea_data.md` |
| 1412 | Generate or acquire selected Synthea CSV files | Generated selected Synthea CSV files locally for ingestion | `data/raw/synthea/` local-only |
| 1415 | Document source acquisition and regeneration steps | Expanded generation documentation with acquisition, command, validation, and replacement guidance | `docs/generate_synthea_data.md` |
| 1419 | Create source file inventory | Documented selected files, row counts, expected identifiers, and relationships | `docs/source_file_inventory.md` |
| 1422 | Profile core clinical and operational source files | Profiled core entities, columns, modeling implications, and data quality considerations | `docs/source_entity_profile.md` |
| 1425 | Identify optional entities for later expansion | Scoped deferred entities without derailing the core implementation | `docs/source_scope_notes.md` |
| 1429 | Update `.gitignore` for raw data, secrets, and local artifacts | Updated repository exclusions for generated data, secrets, SQL Server artifacts, Power BI files, caches, and local files | `.gitignore` |
| 1432 | Create safe sample data policy | Defined public-safe sample data rules and review checklist | `docs/data_handling_rules.md` |
| 1435 | Document synthetic-data limitations and disclaimers | Added clear synthetic-data disclaimers, prohibited claims, and public communication rules | `docs/data_handling_rules.md` |

## Key Decisions

| Decision Area | Final Decision |
|---|---|
| Source system | Synthea synthetic EHR data |
| Generation geography | Massachusetts, United States |
| Portfolio framing | Ontario-facing governed healthcare BI simulation |
| Population setting | 1,000 living synthetic patients |
| Observed generated patient records | 1,145 total records: 1,000 alive, 145 deceased |
| Synthea RNG | `1000` |
| Clinician RNG | `5643` |
| Export format | CSV |
| Local raw data path | `data/raw/synthea/` |
| Git handling | Raw generated data must remain out of Git |
| Sample data handling | Only curated, minimal, clearly synthetic samples may be committed under `data/samples/` |
| FHIR export | Deferred to the FHIR/API implementation work |
| Core implementation scope | Patients, encounters, conditions, observations, procedures, organizations, providers |
| Deferred scope | Medications, care plans, payers, allergies, immunizations, imaging studies, devices, supplies, claims-related exports |

## Source Data Validation Summary

The selected CSV files were generated locally and validated as present and non-empty.

| File | Rows | Scope |
|---|---:|---|
| `patients.csv` | 1,145 | Core |
| `encounters.csv` | 71,663 | Core |
| `conditions.csv` | 43,758 | Core |
| `observations.csv` | 945,531 | Core |
| `procedures.csv` | 196,207 | Core |
| `organizations.csv` | 826 | Core |
| `providers.csv` | 826 | Core |

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

## Repository Safety Work Completed

The `.gitignore` now excludes:

- Raw, interim, and processed data folders
- Generated CSV, Parquet, JSONL, and NDJSON files
- Environment files and secrets
- SQL Server local artifacts and backups
- Power BI and Excel local/reporting artifacts
- Python caches and virtual environments
- Logs, temporary files, IDE files, and OS-specific files

The repository still allows intentionally curated public-safe samples under:

```text
data/samples/
```

## Documentation Produced or Updated

| File | Purpose |
|---|---|
| `docs/generate_synthea_data.md` | Defines generation settings, acquisition method, generation command, retained run details, validation commands, and regeneration/replacement rules |
| `docs/source_file_inventory.md` | Lists selected source files, row counts, expected keys, expected relationships, and ingestion notes |
| `docs/source_entity_profile.md` | Profiles each core source entity, including columns, relationship fields, downstream use, data quality considerations, and modeling implications |
| `docs/source_scope_notes.md` | Identifies optional entities for later expansion and defines decision rules for adding them |
| `docs/data_handling_rules.md` | Defines raw data rules, safe sample policy, synthetic-data disclaimers, prohibited claims, and public communication rules |
| `.gitignore` | Prevents unsafe or unnecessary files from being committed |

## Acceptance Criteria Review

| Acceptance Area | Result |
|---|---|
| Required deliverables exist | Complete |
| Content aligns with ClinicalPulse specification | Complete |
| Raw Synthea data available locally | Complete |
| Raw generated data excluded from Git | Complete |
| Source files documented with row counts and expected keys | Complete |
| Core source entities profiled | Complete |
| Optional entities scoped without expanding implementation prematurely | Complete |
| Safe sample data policy documented | Complete |
| Synthetic-data limitations and disclaimers documented | Complete |
| Work items can be traced to committed artifacts | Ready for commit/PR traceability using `AB#` references |

## Recommended Commit History

If committing each completed story separately, use:

```bash
git add docs/generate_synthea_data.md
git commit -m "Choose Synthea generation settings AB#1409"

git commit --allow-empty -m "Generate selected Synthea CSV files locally AB#1412"

git add docs/generate_synthea_data.md
git commit -m "Document Synthea source acquisition and regeneration AB#1415"

git add docs/source_file_inventory.md
git commit -m "Create source file inventory AB#1419"

git add docs/source_entity_profile.md
git commit -m "Profile core source entities AB#1422"

git add docs/source_scope_notes.md
git commit -m "Identify optional source entities for later expansion AB#1425"

git add .gitignore
git commit -m "Update gitignore for raw data and secrets AB#1429"

git add docs/data_handling_rules.md
git commit -m "Create safe sample data policy AB#1432"

git add docs/data_handling_rules.md
git commit -m "Document synthetic data limitations and disclaimers AB#1435"
```

If the raw CSV generation story has no tracked file changes, the empty commit is optional. The Azure Boards comment can serve as the trace record instead.

## Pull Request Summary

Suggested PR title:

```text
Complete Sprint 2 source data foundation
```

Suggested PR description:

```markdown
## Summary

Completed the ClinicalPulse source data foundation work.

This PR documents the Synthea generation settings, source acquisition and regeneration process, source file inventory, source entity profiles, optional entity scope decisions, repository safety rules, safe sample data policy, and synthetic-data limitations/disclaimers.

## Completed Work Items

- AB#1409 Choose Synthea generation settings
- AB#1412 Generate or acquire selected Synthea CSV files
- AB#1415 Document source acquisition and regeneration steps
- AB#1419 Create source file inventory
- AB#1422 Profile core clinical and operational source files
- AB#1425 Identify optional entities for later expansion
- AB#1429 Update .gitignore for raw data, secrets, and local artifacts
- AB#1432 Create safe sample data policy
- AB#1435 Document synthetic-data limitations and disclaimers

## Validation

- Generated selected Synthea CSV files locally under `data/raw/synthea/`
- Validated all selected core source files are present and non-empty
- Confirmed raw generated data is excluded from Git
- Documented row counts, source relationships, scope decisions, safe sample rules, and synthetic-data limitations

## Notes

Raw generated Synthea CSV files are intentionally not included in this PR.
```

## Sprint Closeout Notes

Sprint 2 successfully moved ClinicalPulse from project planning into a concrete, reproducible source-data foundation. The project now has a local synthetic EHR dataset, documented source-generation settings, row-count inventory, source entity profiles, clear scope boundaries, and repository safety controls.

The next logical implementation area is SQL Server ingestion: creating schemas, bronze table structures, ingestion scripts, and load/reconciliation logging.
