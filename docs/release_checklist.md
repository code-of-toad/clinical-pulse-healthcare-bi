# ClinicalPulse Final Release and Evidence Checklist

## 1. Release Identification

| Field | Value |
|---|---|
| Project | ClinicalPulse — Governed Hospital BI Platform |
| Release | `v1.0.0` |
| Release type | Final portfolio release |
| Azure Boards user story | AB#1705 |
| Draft/build task | AB#1706 |
| Review/document task | AB#1707 |
| Author | Danny Han |
| Release status | Pending final commit and tag |

## 2. Final Release Scope

ClinicalPulse `v1.0.0` includes:

- synthetic Synthea healthcare source data documentation
- Python-assisted CSV ingestion and row-count reconciliation
- SQL Server bronze, silver, gold, governance, and audit layers
- reporting-ready dimensions, facts, and marts
- governed KPI definitions and SQL validation queries
- data quality rules and persisted reporting-trust results
- Power BI semantic-model documentation and DAX measures
- seven stakeholder-facing dashboard pages
- architecture, lineage, catalog, scorecards, security, adoption, user guidance, change control, and portfolio documentation
- Git, GitHub, and Azure DevOps delivery evidence

ClinicalPulse `v1.0.0` does **not** include:

- a FHIR API or FastAPI service
- API-facing SQL views presented as completed
- optional pipeline hardening or Azure Pipeline implementation
- production Power BI Service deployment
- real patient or hospital data
- clinical-decision support
- regulatory, privacy, or security certification

## 3. Release Evidence Matrix

### 3.1 Project narrative and architecture

| Evidence | Repository path | Status |
|---|---|---|
| Final project narrative | `README.md` | [ ] |
| Final architecture diagram | `docs/architecture_diagram.png` | [ ] |
| Architecture overview | `docs/architecture_overview.md` | [ ] |
| Final project walkthrough | `docs/final_walkthrough.md` | [ ] |

### 3.2 Business and governance documentation

| Evidence | Repository path | Status |
|---|---|---|
| Project charter | `docs/project_charter.md` | [ ] |
| Business requirements | `docs/business_requirements.md` | [ ] |
| Stakeholder matrix | `docs/stakeholder_matrix.md` | [ ] |
| KPI dictionary | `docs/kpi_dictionary.md` | [ ] |
| Data governance plan | `docs/data_governance_plan.md` | [ ] |
| Data asset catalog | `docs/data_asset_catalog.md` | [ ] |
| Data asset scorecards | `docs/data_asset_scorecards.md` | [ ] |
| Data lineage | `docs/data_lineage.md` | [ ] |
| Security model | `docs/security_model.md` | [ ] |
| Adoption plan | `docs/adoption_plan.md` | [ ] |
| Feedback and change control | `docs/change_control.md` | [ ] |

### 3.3 SQL Server implementation

| Evidence | Repository path | Status |
|---|---|---|
| Database creation | `sql/00_create_database.sql` | [ ] |
| Schema creation | `sql/01_create_schemas.sql` | [ ] |
| Bronze tables | `sql/02_create_bronze_tables.sql` | [ ] |
| Silver tables | `sql/03_create_silver_tables.sql` | [ ] |
| Gold tables and marts | `sql/04_create_gold_tables.sql` | [ ] |
| Bronze-to-silver transformation | `sql/05_transform_bronze_to_silver.sql` | [ ] |
| Silver-to-gold transformation | `sql/06_transform_silver_to_gold.sql` | [ ] |
| Data quality checks | `sql/07_data_quality_checks.sql` | [ ] |
| KPI validation queries | `sql/08_kpi_validation_queries.sql` | [ ] |
| Audit structures | `sql/audit_tables.sql` | [ ] |

### 3.4 Python implementation

| Evidence | Repository path | Status |
|---|---|---|
| Database configuration support | `src/db_config.py` | [ ] |
| Synthea CSV ingestion | `src/ingest_synthea_csv_to_sqlserver.py` | [ ] |
| Row-count reconciliation | `src/row_count_reconciliation.py` | [ ] |
| Quality-check execution | `src/run_quality_checks.py` | [ ] |
| Configuration guidance | `src/config.md` | [ ] |

Historical validation scripts may remain as implementation evidence, but no new generated validation script is required for this release.

### 3.5 Power BI implementation and evidence

| Evidence | Repository path | Status |
|---|---|---|
| Measure definitions | `powerbi/measure_definitions.md` | [ ] |
| Semantic-model notes | `powerbi/semantic_model_notes.md` | [ ] |
| SQL-to-DAX validation log | `docs/powerbi_validation_log.md` | [ ] |
| Dashboard walkthrough | `docs/dashboard_walkthrough.md` | [ ] |
| Dashboard user guide | `docs/dashboard_user_guide.md` | [ ] |
| Report design checklist | `docs/report_design_checklist.md` | [ ] |

Dashboard screenshots:

| Dashboard page | Repository path | Status |
|---|---|---|
| Executive Overview | `powerbi/screenshots/executive_overview.png` | [ ] |
| Patient Flow | `powerbi/screenshots/patient_flow.png` | [ ] |
| Length of Stay | `powerbi/screenshots/length_of_stay.png` | [ ] |
| Readmissions | `powerbi/screenshots/readmissions.png` | [ ] |
| Conditions & Procedures | `powerbi/screenshots/conditions_procedures.png` | [ ] |
| Lab / Observation Operations | `powerbi/screenshots/lab_operations.png` | [ ] |
| Data Quality & Governance | `powerbi/screenshots/data_quality_governance.png` | [ ] |

The local Power BI `.pbix` remains excluded from Git. Aggregate screenshots and semantic-model documentation are the public release evidence.

### 3.6 Portfolio and career documentation

| Evidence | Repository path | Status |
|---|---|---|
| Public portfolio safety | `README.md`; `docs/security_model.md` | [ ] |
| Dashboard adoption approach | `docs/adoption_plan.md` | [ ] |
| Dashboard user guidance | `docs/dashboard_user_guide.md` | [ ] |
| Change-control process | `docs/change_control.md` | [ ] |
| Resume and interview talking points | `docs/interview_talking_points.md` | [ ] |
| Final project walkthrough | `docs/final_walkthrough.md` | [ ] |
| Final release checklist | `docs/release_checklist.md` | [ ] |

## 4. Key Release Results

The final release documents the following implementation state:

| Result | Final documented value |
|---|---:|
| Synthetic source entities ingested | 7 |
| Source rows loaded | 1,259,956 |
| Gold reporting assets | 20 |
| Power BI dashboard pages | 7 |
| Implemented quality checks | 20 |
| Passed quality checks | 19 |
| Failed quality checks | 1 |
| Check-based data quality pass rate | 95.00% |
| Known excess duplicate observations | 256 |

These values describe the synthetic ClinicalPulse environment and must not be presented as real hospital performance.

## 5. Known Limitations

- Synthea data does not reproduce real hospital workflow, case mix, privacy obligations, or operational complexity.
- The 30-day readmission logic uses simplified encounter sequencing and does not distinguish planned from unplanned returns.
- Observation Volume is affected by the documented duplicate-observation finding.
- Static screenshots do not reproduce full Power BI interaction behavior.
- The report has not been deployed to a production Power BI Service workspace.
- Modeled ownership and access roles are governance assumptions rather than deployed enterprise controls.
- The project does not claim production readiness, clinical validity, or regulatory compliance.

## 6. Portfolio-Safety Checks

Before tagging the release:

- [ ] Raw data under `data/raw/`, `data/interim/`, and `data/processed/` is not tracked.
- [ ] No `.pbix` file is tracked.
- [ ] No `.bak`, `.env`, credential, password, token, or connection string is tracked.
- [ ] No Python cache or virtual-environment files are tracked.
- [ ] Dashboard screenshots contain no credentials, local paths, or unnecessary row-level identifiers.
- [ ] README clearly states that the data is synthetic.
- [ ] Current-facing documentation does not claim real hospital deployment or clinical use.
- [ ] FHIR/API and optional pipeline hardening are described only as excluded or historical scope.
- [ ] Power BI Service deployment is not claimed.
- [ ] Known data-quality and readmission limitations remain visible.

## 7. Repository and Rendering Checks

- [ ] `git status` shows only intended release changes.
- [ ] No unsafe artifact is staged.
- [ ] README renders correctly on GitHub.
- [ ] Architecture diagram renders correctly.
- [ ] All seven dashboard screenshots render correctly.
- [ ] Key relative links open successfully.
- [ ] No links reference `sandbox:`, `/mnt/data/`, or local `C:\` paths.
- [ ] No unresolved `TODO`, `TBD`, placeholder, or merge-conflict marker remains.
- [ ] The default branch contains the intended final release state.

Recommended commands:

```powershell
git status
git diff
git diff --cached
git ls-files | Sort-Object
```

## 8. Final Release Commit

Stage the final release documentation:

```powershell
git add README.md docs powerbi azure-devops
```

Review the staged changes:

```powershell
git status --short
git diff --cached
```

Create the final release commit:

```powershell
git commit -m "Prepare ClinicalPulse v1.0.0 final release AB#1705"
git push
```

Record the final commit:

| Field | Value |
|---|---|
| Branch |  |
| Commit SHA |  |
| Pull request |  |
| Commit date |  |

## 9. Create the Final Release Tag

Create an annotated semantic-version tag:

```powershell
git tag -a v1.0.0 -m "ClinicalPulse v1.0.0 - Governed Hospital BI Platform"
git push origin v1.0.0
```

Confirm the tag:

```powershell
git show v1.0.0
git tag --list
```

Record the tag evidence:

| Field | Value |
|---|---|
| Tag | `v1.0.0` |
| Tagged commit SHA |  |
| Tag date |  |
| GitHub tag URL |  |
| Result | Pending / Passed |

## 10. GitHub Release

Recommended release title:

```text
ClinicalPulse v1.0.0 — Governed Hospital BI Platform
```

Recommended release summary:

```text
ClinicalPulse v1.0.0 is the final portfolio release of a governed hospital
business intelligence platform built with synthetic Synthea data, Python,
SQL Server, T-SQL, Power BI, DAX, Git, and Azure DevOps.

The release includes auditable bronze, silver, and gold data layers,
reporting-ready dimensions, facts and marts, governed KPI definitions,
data quality and lineage documentation, seven Power BI dashboard pages,
SQL-to-DAX validation evidence, and portfolio-ready governance,
security, adoption, and change-control documentation.

The release uses synthetic data only. It is not a production hospital
deployment, clinical-decision support system, or regulatory-compliance
implementation. The originally planned FHIR API and optional pipeline
hardening components are outside the completed v1.0.0 scope.
```

GitHub release evidence:

| Field | Value |
|---|---|
| Release title | ClinicalPulse v1.0.0 — Governed Hospital BI Platform |
| Release URL |  |
| Published date |  |
| Result | Pending / Passed |

## 11. Azure DevOps Completion Evidence

Before closing AB#1705:

- [ ] AB#1706 is complete.
- [ ] AB#1707 is complete.
- [ ] The final commit is linked or referenced.
- [ ] The `v1.0.0` tag is recorded.
- [ ] The GitHub release URL is recorded, if created.
- [ ] Final deliverables and screenshots are listed.
- [ ] Assumptions, exclusions, and limitations are documented.
- [ ] AB#1705 is moved to Done.

Suggested Azure Boards comment:

```text
Completed the ClinicalPulse v1.0.0 final release and evidence checklist.

The release evidence records the final business, SQL Server, Python,
Power BI, governance, documentation, screenshot, validation, and
portfolio-safety artifacts. The final release scope excludes the FHIR/API
component and optional pipeline hardening.

Final artifact:
- docs/release_checklist.md

Release tag:
- v1.0.0

Final commit:
- [insert commit SHA]

GitHub release:
- [insert release URL, if created]
```

## 12. Final Approval

| Review area | Status | Evidence or note |
|---|---|---|
| Final scope accuracy |  |  |
| Required deliverables |  |  |
| SQL implementation |  |  |
| Python implementation |  |  |
| Power BI model and measures |  |  |
| Dashboard screenshots |  |  |
| KPI and validation evidence |  |  |
| Governance documentation |  |  |
| Portfolio safety |  |  |
| Repository rendering |  |  |
| Final commit |  |  |
| `v1.0.0` tag |  |  |
| GitHub release |  |  |

Final decision:

```text
[ ] Approved for ClinicalPulse v1.0.0 release
[ ] Approved with documented exceptions
[ ] Not approved
```

Reviewer:

```text
Name:
Date:
Final note:
```

## 13. Completion Rule

ClinicalPulse is officially complete when:

- the final release commit is pushed
- the `v1.0.0` annotated tag is pushed
- the final evidence fields are completed
- the public repository renders correctly
- AB#1705, AB#1706, and AB#1707 are closed
- no excluded artifact or unsupported claim appears in the release

At that point, ClinicalPulse is complete as a governed SQL Server and Power BI hospital BI portfolio project.
