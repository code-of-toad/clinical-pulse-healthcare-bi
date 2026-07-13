# ClinicalPulse Repository Release Checklist

## 1. Purpose

This checklist is used to clean and review the ClinicalPulse repository before the final public release.

It verifies that:

- the repository structure matches the implemented ClinicalPulse scope
- required code, documentation, and Power BI evidence are present
- abandoned FHIR/API and optional pipeline-hardening artifacts do not imply completed functionality
- raw data, embedded Power BI files, backups, credentials, and temporary files are not tracked
- public documentation is internally consistent and portfolio-safe
- the release can be traced to Azure DevOps and Git

ClinicalPulse uses synthetic Synthea data. It does not contain real patient data, represent real hospital performance, provide clinical evidence, or support clinical decision-making.

## 2. How to Use This Checklist

Complete this review from the repository root before the final release commit and tag.

Use these status values:

| Status | Meaning |
|---|---|
| `[ ]` | Not yet reviewed |
| `[x]` | Reviewed and passed |
| `N/A` | Not applicable, with a short explanation |

Do not mark an item complete solely because a file is listed in documentation. Confirm the actual tracked repository state.

## 3. Final Implemented Scope

The final ClinicalPulse release includes:

- Synthea synthetic CSV source-data documentation
- Python-assisted SQL Server ingestion and reconciliation
- SQL Server bronze, silver, gold, governance, and audit layers
- data quality rules and persisted quality results
- governed KPI definitions and lineage
- Power BI semantic-model documentation
- seven Power BI dashboard pages represented through aggregate screenshots
- public portfolio safety, adoption, user guidance, change control, and final walkthrough documentation
- Git, GitHub, and Azure DevOps delivery evidence

The final release excludes:

- FHIR API implementation
- FastAPI services and API endpoints
- API-facing SQL views presented as completed
- FHIR dashboard pages or API screenshots
- optional CI/CD pipeline hardening
- production Power BI Service deployment
- real hospital or patient data
- clinical-decision support
- regulatory or security certification

## 4. Expected High-Level Repository Structure

The final repository should follow this high-level structure:

```text
clinical-pulse-healthcare-bi/
|-- README.md
|-- .gitignore
|-- docs/
|   |-- architecture_diagram.png
|   |-- project_charter.md
|   |-- business_requirements.md
|   |-- stakeholder_matrix.md
|   |-- kpi_dictionary.md
|   |-- data_governance_plan.md
|   |-- data_asset_catalog.md
|   |-- data_asset_scorecards.md
|   |-- data_lineage.md
|   |-- security_model.md
|   |-- adoption_plan.md
|   |-- dashboard_user_guide.md
|   |-- change_control.md
|   |-- final_walkthrough.md
|   |-- release_checklist.md
|   `-- supporting implementation and dashboard documentation
|-- sql/
|   |-- database and schema creation
|   |-- bronze, silver, and gold table definitions
|   |-- bronze-to-silver and silver-to-gold transformations
|   |-- data quality checks
|   `-- KPI validation queries
|-- src/
|   |-- ingestion utilities
|   |-- reconciliation and quality-check utilities
|   `-- retained implementation-support files
|-- powerbi/
|   |-- screenshots/
|   |-- measure_definitions.md
|   `-- semantic_model_notes.md
|-- azure-devops/
|   `-- backlog and delivery-planning artifacts
`-- data/
    |-- raw/          local and ignored
    |-- interim/      local and ignored
    |-- processed/    local and ignored
    `-- samples/      public only when intentionally curated
```

Git does not track empty folders. Local data directories may therefore exist without appearing on GitHub.

## 5. Repository Structure Review

- [ ] `README.md` exists at the repository root.
- [ ] `.gitignore` exists at the repository root.
- [ ] `docs/` contains the current governance, portfolio, dashboard, and release documentation.
- [ ] `docs/architecture_diagram.png` exists and is referenced correctly from `README.md`.
- [ ] `docs/release_checklist.md` exists.
- [ ] `sql/` contains the implemented SQL Server build, transformation, quality, and KPI scripts.
- [ ] `src/` contains only purposeful implementation-support files.
- [ ] `powerbi/measure_definitions.md` exists.
- [ ] `powerbi/semantic_model_notes.md` exists.
- [ ] `powerbi/screenshots/` contains the reviewed dashboard screenshot set.
- [ ] `azure-devops/` contains only useful planning or delivery evidence.
- [ ] No duplicate root-level copies of files already stored under `docs/`, `powerbi/`, `sql/`, or `src/` remain.
- [ ] No temporary folders such as `tmp/`, `temp/`, `output/`, `exports/`, or unmanaged `archive/` folders remain unless they have a documented purpose.
- [ ] File and folder names use consistent casing and naming conventions.
- [ ] No file is retained solely because it was generated during drafting.

### Recommended inspection commands

```powershell
tree /F /A
git ls-files | Sort-Object
git status --short
```

Review the output manually against the expected high-level structure.

## 6. Required Final Documentation

Confirm the following final-stage artifacts exist and are current:

- [ ] `README.md`
- [ ] `docs/architecture_diagram.png`
- [ ] `docs/security_model.md`
- [ ] `docs/adoption_plan.md`
- [ ] `docs/dashboard_user_guide.md`
- [ ] `docs/change_control.md`
- [ ] `docs/final_walkthrough.md`
- [ ] `docs/release_checklist.md`

Confirm the earlier governance and reporting artifacts remain available:

- [ ] project charter
- [ ] business requirements
- [ ] stakeholder matrix
- [ ] KPI dictionary
- [ ] data governance plan
- [ ] data asset catalog
- [ ] data asset scorecards
- [ ] data lineage
- [ ] Power BI validation log
- [ ] dashboard walkthrough
- [ ] report design checklist
- [ ] measure definitions
- [ ] semantic-model notes

Actual filenames should match the paths used by the README and related documentation.

## 7. Power BI Evidence Review

The committed screenshot set should include:

- [ ] Executive Overview
- [ ] Patient Flow
- [ ] Length of Stay
- [ ] Readmissions
- [ ] Conditions & Procedures
- [ ] Lab / Observation Operations
- [ ] Data Quality & Governance

For every screenshot:

- [ ] The image is readable at normal GitHub viewing size.
- [ ] The page title is visible.
- [ ] No database credentials are visible.
- [ ] No server connection dialog is visible.
- [ ] No private local path is visible.
- [ ] No unnecessary row-level patient-like identifiers are visible.
- [ ] The screenshot represents synthetic demonstration data.
- [ ] The screenshot matches the current dashboard documentation.
- [ ] The image is referenced by the correct repository-relative path.

The local `.pbix` must remain excluded from Git.

## 8. FHIR/API and Pipeline Scope Cleanup

Because the FHIR/API and optional pipeline-hardening work were removed from the completed scope:

- [ ] No FastAPI application is presented as implemented.
- [ ] No API endpoint documentation is presented as completed.
- [ ] No API SQL views are presented as completed.
- [ ] No FHIR/API dashboard page is presented as completed.
- [ ] No FHIR response screenshots or samples are presented as completed.
- [ ] No Azure Pipeline is presented as an implemented release gate.
- [ ] README, architecture, walkthrough, resume material, and dashboard documentation describe these components only as excluded or deferred.
- [ ] Placeholder files that imply completed API or pipeline functionality have been removed.
- [ ] Historical planning artifacts may mention the original scope only when clearly distinguishable from the final implemented release.

Search for potentially outdated claims:

```powershell
rg -n -i "FHIR|FastAPI|API Resource Coverage|api endpoint|Power BI Service|pipeline hardening|Azure Pipeline" README.md docs powerbi azure-devops
```

Review every match. Acceptable matches should clearly describe excluded scope, historical planning, or limitations.

## 9. Unsafe and Local-Only Artifact Review

The following must not be tracked:

- raw, interim, or processed datasets
- full Synthea CSV exports
- compressed CSV or Parquet data
- SQL Server backups
- Power BI `.pbix` files
- `.env` files
- credentials, passwords, tokens, keys, or connection strings
- Python cache files
- virtual environments
- local database files
- temporary exports and unmanaged logs
- screenshots containing private local information

### Tracked-file check

Run:

```powershell
git ls-files |
    Select-String -Pattern '(^|/)(data/(raw|interim|processed)/|.*\.csv$|.*\.csv\.gz$|.*\.parquet$|.*\.bak$|.*\.pbix$|\.env$|.*\.pyc$|__pycache__/|\.venv/|venv/)'
```

Expected result: no unsafe tracked artifacts.

A deliberately curated public sample under `data/samples/` may be retained only when it is minimal, documented as synthetic, and manually reviewed.

### Local ignored-file check

```powershell
git status --short --ignored
```

Local raw files or the `.pbix` may appear as ignored. They must not appear as tracked or staged files.

### Staging check

```powershell
git diff --cached --name-only
```

Inspect every staged path before committing.

## 10. Credential and Configuration Review

- [ ] Database passwords are not hard-coded.
- [ ] Tokens, keys, and client secrets are not hard-coded.
- [ ] `.env` is ignored and untracked.
- [ ] Public documentation contains example placeholders rather than live credentials.
- [ ] Local server names and workstation paths are omitted unless harmless and necessary.
- [ ] SQL and Python source files use safe configuration handling.
- [ ] Git history has been considered if a secret was ever committed.

Search tracked text for high-risk patterns:

```powershell
git grep -n -I -E "Password=|PWD=|AccountKey=|ClientSecret=|Bearer [A-Za-z0-9]|api[_-]?key"
```

Review every match manually. Documentation explaining that secrets must not be committed may produce harmless matches.

Check whether excluded files ever entered history:

```powershell
git log --all -- .env "*.pbix" "*.bak" "data/raw/**"
```

Any unexpected history requires review before the public release.

## 11. `.gitignore` Review

Confirm `.gitignore` covers at minimum:

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
__pycache__/
*.pyc
.DS_Store
.venv/
venv/
```

Checklist:

- [ ] Raw data directories are ignored.
- [ ] Generated tabular data files are ignored.
- [ ] SQL Server backups are ignored.
- [ ] Power BI files are ignored.
- [ ] Environment and secret files are ignored.
- [ ] Python caches and virtual environments are ignored.
- [ ] OS-generated files are ignored.
- [ ] Any `data/samples/` exception is intentional and safe.

Remember: `.gitignore` does not remove a file that is already tracked.

## 12. Redundant and Obsolete File Review

- [ ] Draft files with names such as `_draft`, `_new`, `_updated`, `_corrected`, `_final2`, or `copy` have been consolidated.
- [ ] Superseded screenshots have been removed.
- [ ] Duplicate documentation files have been removed.
- [ ] Temporary generated text files have been removed.
- [ ] Empty placeholder documents have been removed.
- [ ] Broken experiments and abandoned implementation files have been removed.
- [ ] Obsolete FHIR/API placeholders have been removed.
- [ ] Obsolete pipeline placeholders have been removed.
- [ ] Retained historical Azure DevOps artifacts have a clear planning or evidence purpose.
- [ ] Existing validation scripts are retained only when they provide useful historical or implementation evidence.
- [ ] No new Python validation script is required for this documentation-only release checklist.

Useful filename search:

```powershell
Get-ChildItem -Recurse -File |
    Where-Object {
        $_.Name -match '(draft|copy|corrected|updated|final2|temp|backup|old)'
    } |
    Select-Object FullName
```

Review matches manually; do not delete a legitimate file merely because its name contains one of these words.

## 13. Documentation Consistency Review

Across `README.md`, `docs/`, and `powerbi/`, confirm:

- [ ] The project is consistently described as using synthetic Synthea data.
- [ ] No document implies that outputs represent real hospital performance.
- [ ] No document implies clinical-decision support.
- [ ] No document claims production deployment.
- [ ] No document claims HIPAA, PHIPA, SOC 2, or other certification.
- [ ] SQL Server is described as the analytical backbone.
- [ ] Power BI is described as using gold-layer assets.
- [ ] The `.pbix` is described as local and excluded.
- [ ] The report is described as containing seven completed dashboard pages.
- [ ] The known duplicate-observation finding remains visible.
- [ ] The simplified readmission limitation remains visible.
- [ ] FHIR/API and pipeline hardening are excluded from completed scope.
- [ ] Power BI Service deployment is not claimed.
- [ ] KPI names are consistent across the dictionary, DAX definitions, walkthroughs, and README.
- [ ] Repository paths are consistent across documents.
- [ ] No end-user-facing document contains unnecessary sprint-process language.
- [ ] README links render correctly on GitHub.

Useful consistency searches:

```powershell
rg -n -i "real patient|real hospital|clinical decision|HIPAA|PHIPA|SOC 2|production deployment" README.md docs powerbi
rg -n -i "duplicate observation|256|readmission|planned|unplanned" README.md docs powerbi
```

Review matches for accurate disclaimers and limitations.

## 14. Markdown Link and Image Review

Manually open the GitHub-rendered README and key documents.

- [ ] Architecture image renders.
- [ ] Executive Overview image renders if referenced.
- [ ] Relative links use correct casing.
- [ ] Links do not point to local `C:\` paths.
- [ ] Links do not point to `/mnt/data/` or `sandbox:` paths.
- [ ] Renamed files have no remaining old references.
- [ ] Heading anchors work where relied upon.
- [ ] Markdown tables render correctly.
- [ ] Code blocks are properly closed.
- [ ] No placeholder text such as `TODO`, `TBD`, or `INSERT SCREENSHOT` remains without an intentional explanation.

Search for unfinished content:

```powershell
rg -n -i "TODO|TBD|FIXME|INSERT|PLACEHOLDER|lorem ipsum|sandbox:|/mnt/data/|C:\\" README.md docs powerbi sql src
```

## 15. Source-Code and SQL Review

- [ ] Source files required to reproduce ingestion and transformations are present.
- [ ] SQL scripts are ordered and named consistently.
- [ ] SQL scripts do not contain live credentials.
- [ ] Python files do not contain machine-specific paths that prevent ordinary configuration.
- [ ] Comments and headers describe actual scope.
- [ ] No source file claims that the FHIR/API component exists.
- [ ] No unused API implementation folder remains unless clearly retained as historical, nonfunctional planning evidence.
- [ ] No abandoned pipeline YAML is presented as active.
- [ ] Generated cache files are absent from tracked files.
- [ ] One-off local troubleshooting files are removed.

This story does not require adding another Python validation script. Repository review is performed through direct inspection, Git commands, and documented evidence.

## 16. Git Status and History Review

Before the cleanup commit:

```powershell
git status
git diff
git diff --cached
git log --oneline --decorate -15
```

Confirm:

- [ ] The working tree changes are understood.
- [ ] No unrelated file is staged.
- [ ] No unsafe file is staged.
- [ ] Commit messages reference the relevant Azure Boards work item where appropriate.
- [ ] The branch is correct.
- [ ] The local branch is synchronized as intended before pushing.
- [ ] No accidental merge conflict markers remain.

Search for conflict markers:

```powershell
rg -n "^(<<<<<<<|=======|>>>>>>>)" .
```

Expected result: no unresolved merge conflicts.

## 17. Public GitHub Review

After pushing the cleanup commit, review the repository through GitHub rather than only through the local file system.

- [ ] Repository landing page displays the intended README.
- [ ] Architecture diagram renders.
- [ ] Dashboard screenshots render.
- [ ] Key document links open successfully.
- [ ] Repository folders are understandable to a reviewer.
- [ ] No unsafe file is visible.
- [ ] No `.pbix`, `.bak`, `.env`, or raw dataset is visible.
- [ ] The project description and topics remain accurate.
- [ ] The default branch contains the intended final files.
- [ ] The repository tells a coherent story without requiring access to local tools.

## 18. Final Release Readiness Summary

Record the final review state:

| Review area | Status | Evidence or note |
|---|---|---|
| Folder structure |  |  |
| Required artifacts |  |  |
| Power BI screenshots |  |  |
| FHIR/API scope cleanup |  |  |
| Pipeline scope cleanup |  |  |
| Unsafe tracked files |  |  |
| Credential review |  |  |
| `.gitignore` |  |  |
| Duplicate and obsolete files |  |  |
| Documentation consistency |  |  |
| Links and GitHub rendering |  |  |
| Git status and staging |  |  |
| Public repository review |  |  |

## 19. Completion Record

| Field | Value |
|---|---|
| Azure Boards user story | AB#1699 — Clean repository and verify folder structure |
| Draft/build task | AB#1700 |
| Review/document task | AB#1701 |
| Deliverable | `docs/release_checklist.md` |
| Reviewer |  |
| Review date |  |
| Branch |  |
| Commit |  |
| Pull request |  |
| Final result | Pending / Passed / Passed with documented exceptions |

## 20. Assumptions

- The review is performed from the actual ClinicalPulse repository root.
- Git and GitHub are the authoritative version-control and public-delivery systems.
- Azure DevOps remains the authoritative work-tracking system.
- Local raw data, SQL Server state, credentials, and the `.pbix` may continue to exist outside Git.
- Existing historical implementation evidence may remain when it has a clear purpose.
- A single project owner may perform several modeled review roles.

## 21. Limitations

- This checklist does not inspect the repository automatically.
- A completed checklist is only as reliable as the underlying manual review.
- Secret-pattern searches can produce false positives and cannot guarantee that every secret has been detected.
- GitHub rendering and link checks require reviewing the pushed repository.
- Real production release management would require formal security, privacy, operational, accessibility, and organizational approvals.
- ClinicalPulse remains a synthetic-data portfolio project rather than a production hospital platform.

## 22. Final Decision Rule

The repository is ready for final release only when:

- every required item is marked passed or has a documented exception
- no unsafe artifact is tracked or staged
- completed scope is represented accurately
- excluded scope is not presented as implemented
- README and key documentation render correctly on GitHub
- the cleanup work is traceable to AB#1699 and its committed artifact
