# ClinicalPulse Security Model

## 1. Purpose

This document defines the security, ownership, access, and public-portfolio safety assumptions for ClinicalPulse.

ClinicalPulse uses synthetic Synthea data. Its records are not real patient records and its outputs must not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. The platform is not intended for clinical-decision support or production hospital use.

## 2. Security Scope

This model covers:

- SQL Server access assumptions for the bronze, silver, gold, governance, and audit schemas
- Power BI access assumptions for the semantic model, report pages, local `.pbix`, and public screenshots
- ownership and stewardship responsibilities
- least-privilege practices
- repository and credential safety
- public portfolio publishing boundaries
- known risks, assumptions, and limitations

This is a portfolio security model, not an implemented enterprise identity, privacy, or regulatory-compliance program.

## 3. Security Principles

| Principle | ClinicalPulse application |
|---|---|
| Least privilege | A role should receive only the access required for its responsibility. |
| Separation of layers | Source-preserving, transformation, reporting, governance, and audit assets have different audiences and access assumptions. |
| Gold-only reporting | Power BI should use governed gold-layer assets rather than raw files, bronze tables, or unmanaged extracts. |
| Aggregate-first publication | Public dashboard evidence should emphasize aggregated KPIs, trends, and grouped breakdowns. |
| Synthetic-data transparency | Every public description should state that Synthea records are synthetic and do not represent real patients or hospitals. |
| No secrets in Git | Credentials, connection strings, `.env` files, backups, and local configuration must remain outside the repository. |
| Governed metric use | Dashboard measures should trace to documented KPI definitions and SQL validation logic. |
| Evidence without embedded data | Public screenshots and documentation should demonstrate the report while the local `.pbix` remains excluded. |
| Honest scope | Deferred FHIR/API and optional pipeline-hardening work must not be presented as implemented. |

## 4. Role-Based Access Assumptions

| Role | Intended access | Not intended to access | Primary responsibility |
|---|---|---|---|
| Project Owner | Repository, documentation, Azure Boards, delivery evidence, and portfolio-facing decisions | Production patient systems or real hospital data | Own scope, delivery discipline, and public portfolio safety |
| Data Platform Owner | SQL Server layers, ingestion scripts, transformations, audit outputs, and local configuration | Business reinterpretation of KPIs without governance review | Maintain data-layer structure and technical integrity |
| Data Steward | KPI dictionary, quality rules, lineage, data catalog, scorecards, and quality findings | Secret values or unnecessary direct-identifier-style fields | Maintain metric meaning, quality interpretation, and governance clarity |
| BI Developer | Gold-layer assets, semantic model, DAX measures, report pages, and screenshots | Raw source data or bronze identifiers except when needed for controlled troubleshooting | Build and reconcile stakeholder-facing reporting |
| Operational Reporting Owner | Dashboard pages, KPI definitions, interpretation notes, and adoption decisions | Database credentials, raw files, and transformation write access | Confirm business usefulness and appropriate interpretation |
| Executive Viewer | Aggregate dashboards and summary documentation | SQL Server write access, raw files, or row-level patient-like records | Consume high-level operational KPIs and trust indicators |
| Platform Administrator | Local SQL Server configuration and Power BI environment settings | Unreviewed ownership of metric definitions | Maintain platform configuration and technical access boundaries |
| Portfolio Reviewer | README, selected documentation, source code, aggregate screenshots, and reviewed examples | Raw generated data, `.pbix`, `.env`, backups, secrets, or local-only configuration | Review the project as a professional public artifact |

These roles are modeled governance responsibilities. They are not evidence that enterprise groups, service accounts, or production access controls have been deployed.

## 5. SQL Server Layer Access Assumptions

| Layer / schema | Typical access | Security assumption | Reporting use |
|---|---|---|---|
| `bronze` | Data Platform Owner; limited troubleshooting access for the BI Developer or Data Steward | Restricted because it preserves source-like structure and direct-identifier-style synthetic fields | Never a direct Power BI source |
| `silver` | Data Platform Owner, Data Steward, BI Developer | Controlled transformation and quality-review layer with lineage and validation flags | Used for validation and transformation, not primary reporting |
| `gold` | BI Developer, Data Steward, Operational Reporting Owner with read access | Governed, business-ready layer that excludes unnecessary direct identifiers | Authoritative Power BI source |
| `governance` | Data Steward and BI Developer with read access; Data Platform Owner with maintenance access | Contains quality-rule and reporting-trust evidence | Supports governance reporting |
| `audit` | Data Platform Owner and Data Steward | Contains ingestion, file-load, and reconciliation metadata | Used for traceability rather than business KPIs |

## 6. Direct-Identifier-Style Synthetic Fields

The bronze patient source includes Synthea fields resembling names, addresses, SSNs, driver identifiers, and passport identifiers. Although these values are synthetic, they are not required for the project’s analytical goals.

Required handling:

- keep the source-preserving bronze layer local
- do not carry unnecessary direct-identifier-style fields into gold assets
- do not expose these fields in public screenshots or documentation samples
- use synthetic technical identifiers only where traceability requires them
- prefer aggregate outputs for all public reporting evidence
- manually review any intentionally published sample before committing it

Synthetic data lowers real-world privacy risk but does not justify careless publishing practices.

## 7. Power BI Security Assumptions

| Area | Required practice |
|---|---|
| Data source | Connect Power BI to selected gold tables and marts only |
| Import storage | Treat the local `.pbix` as an embedded-data artifact because Import mode can contain copied model data |
| Semantic model | Build relationships and measures from governed gold assets and document them separately |
| Report pages | Present aggregate KPIs, trends, distributions, and grouped comparisons |
| Row-level detail | Avoid unnecessary patient-like records, identifiers, names, addresses, and unrestricted drill-through evidence |
| Screenshots | Review for identifiers, credentials, server names, local paths, and unintended UI information before publication |
| Public evidence | Publish aggregate screenshots, measure definitions, model notes, and reconciliation documentation |
| `.pbix` handling | Keep the `.pbix` local and excluded from Git |
| Power BI Service | No production deployment or workspace-security implementation is claimed |

## 8. Public Portfolio Safety Boundary

### 8.1 Safe public artifacts

The following may be committed after review:

- SQL and Python source code without credentials or hard-coded local secrets
- architecture, governance, lineage, KPI, semantic-model, and user documentation
- aggregate Power BI screenshots
- source inventories that redact direct-identifier-style sample values
- quality and reconciliation summaries
- intentionally curated synthetic examples that disclose their synthetic origin
- Azure DevOps planning and delivery evidence that does not reveal secrets

### 8.2 Local-only or excluded artifacts

The following should remain outside the public repository:

- `data/raw/`, `data/interim/`, and `data/processed/`
- generated CSV, compressed CSV, and Parquet files
- SQL Server database files and `.bak` backups
- the Power BI `.pbix`
- `.env` files
- passwords, access tokens, connection strings, and credentials
- local configuration containing machine-specific or sensitive server information
- unreviewed row-level exports
- temporary files, caches, and logs containing local paths or environment details

### 8.3 Publication decision matrix

| Artifact | Default disposition | Reason |
|---|---|---|
| Raw Synthea files | Exclude | Large, unnecessary for review, and may contain direct-identifier-style synthetic fields |
| Bronze sample rows | Exclude or heavily redact | Source-preserving fields exceed public reporting needs |
| Silver and gold SQL definitions | Publish | Demonstrates transformation and modeling logic without embedding data |
| Aggregate dashboard screenshots | Publish after review | Provides visual evidence without distributing the embedded semantic model |
| Power BI `.pbix` | Exclude | May contain imported model data, connection metadata, and local configuration |
| `.env` and credentials | Exclude | Secret material must never be committed |
| Database backups | Exclude | Contain full local database state and are unnecessary for portfolio review |
| KPI, lineage, and governance documents | Publish | Demonstrate governed reporting practices |
| Small synthetic examples | Publish only after manual review | Must be intentional, minimal, clearly synthetic, and free of unnecessary fields |

## 9. Repository Safety Controls

The `.gitignore` should cover at minimum:

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
*.pyc
```

Additional repository practices:

- use environment variables for database credentials and connection strings
- do not hard-code passwords or local authentication secrets
- inspect staged files before every public commit
- remove generated exports and local logs unless they provide reviewed, necessary evidence
- do not rely on `.gitignore` alone after a sensitive file has already been tracked
- review Git history before release if a secret or excluded artifact was ever committed
- preserve only documentation and evidence that serve a clear portfolio purpose

## 10. Asset Ownership Matrix

| Asset group | Owner role | Steward role | Security posture |
|---|---|---|---|
| Raw source files | Data Platform Owner | Data Steward | Local only |
| Bronze tables | Data Platform Owner | Data Steward | Restricted source-preserving layer |
| Silver tables | Data Platform Owner | Data Steward | Controlled transformation and validation layer |
| Gold dimensions and facts | Data Platform Owner | BI Developer / Data Steward | Governed analytical layer |
| Gold marts | BI Developer | Data Steward | Preferred reporting source |
| KPI dictionary | Operational Reporting Owner | Data Steward | Public governed-definition artifact |
| Data asset catalog | Data Steward | Data Steward | Public governance reference |
| Data lineage | Data Steward | Data Platform Owner | Public traceability reference |
| Data asset scorecards | Data Steward | Operational Reporting Owner | Public readiness and trust evidence |
| Power BI semantic model | BI Developer | Data Steward | Local model with public documentation |
| Dashboard pages | BI Developer | Operational Reporting Owner | Aggregate stakeholder reporting |
| Dashboard screenshots | BI Developer | Data Steward | Public only after safety review |
| Repository and release | Project Owner | Data Steward | Public portfolio surface |

## 11. Least-Privilege Examples

| Scenario | Appropriate access |
|---|---|
| Build report visuals | Read access to selected gold dimensions, facts, and marts |
| Review KPI meaning | KPI dictionary, related validation output, and gold query results |
| Investigate a quality issue | Relevant silver records, governance quality results, and lineage documentation |
| Review ingestion execution | Audit batch and file-log outputs without unrelated business data |
| Review the public project | README, source code, safe documentation, and aggregate screenshots |
| Maintain the local platform | Necessary SQL Server and Power BI configuration without exposing credentials to repository users |

## 12. Known Findings and Controls

| Area | Finding or risk | Control |
|---|---|---|
| Bronze patient fields | Source data contains direct-identifier-style synthetic values | Keep bronze local and exclude unnecessary fields from gold and screenshots |
| Power BI Import mode | The `.pbix` may contain imported data and connection metadata | Keep it local and provide screenshots and model documentation instead |
| Local credentials | Connection details may exist in environment or local configuration | Use `.env` and exclude secrets from Git |
| Observation duplicates | A governed duplicate-observation finding affects observation-volume interpretation | Keep the caveat visible in quality, KPI, and report documentation |
| Screenshots | UI captures can unintentionally expose paths, server details, or identifiers | Review and crop screenshots before publication |
| Synthetic-data claims | Reviewers may mistake simulated output for real hospital evidence | Repeat the synthetic-data disclaimer and state interpretation boundaries |
| Deferred components | Original plans included FHIR/API and optional pipeline hardening | Mark both as out of scope and do not present them as implemented |

## 13. Public Release Review

Before a public release or major portfolio update, confirm that:

- the README clearly states the synthetic-data boundary
- no raw, interim, or processed dataset is staged
- no `.pbix`, `.bak`, `.env`, credential, or connection string is staged
- screenshots contain aggregate views and no unnecessary identifiers
- SQL and Python files contain no hard-coded secrets
- sample data is minimal, intentional, and manually reviewed
- documentation does not imply real hospital deployment or clinical use
- FHIR/API and optional pipeline hardening are described only as excluded or deferred scope
- known data-quality limitations remain visible
- the release describes only artifacts that actually exist

## 14. Claims Not Made

ClinicalPulse does not claim:

- access to real patient, hospital, or production EHR data
- suitability for clinical-decision support
- production hospital deployment readiness
- compliance certification under HIPAA, PHIPA, SOC 2, or another framework
- implementation of enterprise SQL Server roles, Azure Entra ID groups, Power BI workspace roles, or row-level security
- a production FHIR server or completed interoperability API
- automated CI/CD or optional pipeline-hardening implementation

## 15. Assumptions

- ClinicalPulse runs in a controlled local development environment.
- All healthcare records are synthetic.
- SQL Server is the analytical backbone.
- Power BI uses Import mode and connects to gold-layer assets.
- The `.pbix`, source data, backups, and credentials remain local.
- Modeled roles represent governance intent rather than deployed enterprise security groups.
- Public portfolio evidence consists primarily of source code, documentation, and aggregate screenshots.

## 16. Limitations

- This document does not itself enforce database permissions, authentication, encryption, retention, or workspace access.
- Synthetic data does not reproduce the legal, privacy, security, and operational requirements of real healthcare data.
- Public screenshot review is a manual control and can fail if not performed carefully.
- A production implementation would require formal identity management, encryption review, audit policy, incident response, data retention rules, privacy review, and organizational approval.
- ClinicalPulse is not certified for HIPAA, PHIPA, SOC 2, or production clinical use.
