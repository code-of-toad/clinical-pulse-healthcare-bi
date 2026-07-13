# ClinicalPulse Adoption Plan

## 1. Purpose

This document defines how ClinicalPulse should be introduced, explained, reviewed, and supported so that intended users can understand the dashboards, interpret governed KPIs correctly, and provide structured feedback.

ClinicalPulse is a portfolio-grade demonstration built with synthetic Synthea data. This plan models a professional adoption approach for a hospital analytics environment; it does not claim that the platform has been deployed in a real hospital or adopted by real clinical or operational users.

## 2. Adoption Scope

The adoption approach covers:

- the Power BI report and semantic model
- governed KPI definitions and validation evidence
- data quality and reporting-trust information
- architecture, lineage, ownership, and security documentation
- public portfolio materials and aggregate screenshots

The plan does not cover a production Power BI Service rollout, enterprise identity integration, real hospital change management, clinical workflow integration, or real patient-data access.

## 3. Adoption Objectives

ClinicalPulse adoption should enable users to:

1. understand the business purpose of each dashboard page
2. locate and interpret the principal operational KPIs
3. distinguish metric values from data-quality and governance indicators
4. trace important measures to documented definitions and source logic
5. recognize the project’s synthetic-data and portfolio-safety boundaries
6. provide feedback through a consistent review and change-control process
7. use the documentation package without depending on the project builder for every explanation

## 4. Intended Audiences

| Audience | Primary need | Expected use |
|---|---|---|
| Executive leaders | Concise view of operational performance and reporting trust | Review headline KPIs, trends, and major caveats |
| Operational managers | Deeper understanding of patient flow, LOS, readmissions, utilization, and observations | Explore operational patterns and identify questions for further analysis |
| Data stewards | Confidence in KPI meaning, quality dependencies, ownership, and limitations | Review definitions, findings, lineage, and governance readiness |
| BI developers and data analysts | Technical understanding of the semantic model, DAX measures, SQL sources, and reconciliation | Maintain or extend the analytical solution |
| Data platform reviewers | Understanding of ingestion, medallion layers, auditability, and gold-layer reporting | Review implementation quality and traceability |
| Recruiters and portfolio reviewers | Clear evidence of business framing, technical execution, and governance discipline | Assess the project through the README, diagrams, screenshots, and selected documentation |

## 5. Adoption Principles

- **Business purpose before tooling:** Begin with the operational questions the platform answers.
- **Role-based enablement:** Show each audience only the level of detail required for its responsibilities.
- **Governed interpretation:** Direct users to KPI definitions, quality dependencies, and limitations before metrics are treated as authoritative.
- **Aggregate-first communication:** Use portfolio-safe dashboards and screenshots rather than unnecessary patient-like detail.
- **Transparent limitations:** Keep synthetic-data caveats, known quality findings, and excluded scope visible.
- **Evidence-based change:** Require material dashboard or KPI changes to reference user feedback, validation evidence, or a documented business need.
- **Self-service documentation:** Maintain enough guidance that a reviewer can navigate the project independently.

## 6. Enablement Package

The adoption package should include the following materials:

| Material | Purpose |
|---|---|
| `README.md` | Provides the project thesis, business problem, architecture, stack, implemented scope, and review path |
| `docs/architecture_diagram.png` | Shows the implemented flow from Synthea through SQL Server and Power BI |
| `docs/dashboard_user_guide.md` | Explains report pages, filters, KPIs, navigation, and interpretation cautions |
| `docs/kpi_dictionary.md` | Defines KPI meaning, formulas, grain, inclusions, exclusions, dependencies, and limitations |
| `docs/data_lineage.md` | Traces selected metrics and assets through source, SQL, and Power BI layers |
| `docs/data_asset_catalog.md` | Identifies available assets, purposes, owners, and usage notes |
| `docs/data_asset_scorecards.md` | Summarizes reliability, documentation, validation, and readiness |
| `docs/security_model.md` | Defines access assumptions, public portfolio safety, and excluded artifacts |
| `powerbi/measure_definitions.md` | Documents the implemented DAX measures |
| `powerbi/semantic_model_notes.md` | Documents tables, relationships, date handling, and model assumptions |
| Dashboard screenshots | Provide safe visual evidence without publishing the local `.pbix` |

## 7. Role-Based Training Approach

### 7.1 Executive orientation

**Audience:** Executive leaders and senior reviewers  
**Recommended duration:** 20–30 minutes

Focus on:

- the hospital operational problem
- the Executive Overview page
- Total Encounters, Unique Patients, Average LOS, Median LOS, 30-Day Readmission Rate, and Data Quality Pass Rate
- the difference between operational metrics and reporting-trust indicators
- synthetic-data and interpretation limitations
- where to find KPI definitions and caveats

Expected outcome: the audience can explain what the headline metrics represent, identify major limitations, and recognize when a question requires deeper operational or governance review.

### 7.2 Operational dashboard walkthrough

**Audience:** Operational managers and analysts  
**Recommended duration:** 45–60 minutes

Focus on:

- report navigation and shared filters
- Patient Flow
- Length of Stay
- Readmissions
- Conditions & Procedures
- Lab / Observation Operations
- Data Quality & Governance
- appropriate use of date, encounter-class, organization, age-band, condition, and procedure filters
- interpretation of known synthetic-data and duplicate-observation limitations

Expected outcome: the audience can move between pages, apply filters, interpret the principal visuals, and distinguish an observed pattern from a validated operational conclusion.

### 7.3 Governance and stewardship review

**Audience:** Data stewards, governance reviewers, and reporting owners  
**Recommended duration:** 45–60 minutes

Focus on:

- KPI dictionary fields and ownership
- SQL-to-DAX reconciliation
- quality-rule coverage and known findings
- asset catalog and scorecards
- lineage examples
- ownership and security assumptions
- documentation and change-control expectations

Expected outcome: the audience can determine whether a metric is defined, implemented, validated, and appropriately qualified for use.

### 7.4 Technical handoff

**Audience:** BI developers, data analysts, and data platform reviewers  
**Recommended duration:** 60–90 minutes

Focus on:

- Synthea source entities
- Python ingestion and audit logging
- bronze, silver, and gold SQL Server layers
- gold facts, dimensions, and marts
- Power BI Import mode and gold-only connections
- semantic model relationships and date handling
- DAX measures and SQL validation queries
- repository structure and local-only artifacts
- known limitations and excluded components

Expected outcome: the audience can locate the implementation assets, understand the data flow, reproduce the principal logic, and identify where a future change should be made.

### 7.5 Portfolio reviewer path

**Audience:** Recruiters, hiring managers, and healthcare data professionals  
**Recommended duration:** 10–20 minutes self-guided

Suggested sequence:

1. Read `README.md`.
2. Review `docs/architecture_diagram.png`.
3. Inspect one dashboard screenshot.
4. Review one KPI definition.
5. Review one lineage example.
6. Review one asset scorecard.
7. Read the public portfolio safety section.

Expected outcome: the reviewer can understand the project’s value, implemented architecture, governance approach, and limitations without opening the local database or `.pbix`.

## 8. Adoption Stages

| Stage | Activities | Completion signal |
|---|---|---|
| 1. Readiness | Confirm documentation, screenshots, KPI definitions, safety statements, and review links are current | Adoption package is complete and internally consistent |
| 2. Orientation | Present the project thesis, architecture, business questions, and synthetic-data boundaries | Users understand what ClinicalPulse is and is not |
| 3. Role-based enablement | Deliver the appropriate walkthrough for each audience | Users can perform the expected navigation or review task |
| 4. Guided review | Ask users to complete representative scenarios and record confusion, defects, and requests | Feedback is specific enough to evaluate |
| 5. Triage and change control | Classify feedback, assess impact, approve changes, and update documentation | Decisions and affected assets are traceable |
| 6. Release communication | Summarize approved changes, limitations, and updated guidance | Reviewers can identify what changed and why |
| 7. Periodic review | Reassess KPI definitions, screenshots, quality findings, and documentation currency | The portfolio remains accurate and safe over time |

## 9. Guided Adoption Scenarios

### Executive scenario

- Open the Executive Overview.
- Identify the reporting period.
- Explain the values of Total Encounters and 30-Day Readmission Rate.
- Locate the reporting-trust indicator.
- State one limitation that affects interpretation.

### Operational scenario

- Filter to an encounter class and date range.
- Compare encounter volume and length-of-stay patterns.
- Navigate to the Readmissions page.
- Identify whether the observed pattern supports a question for further analysis rather than a clinical conclusion.

### Stewardship scenario

- Select one KPI from the dashboard.
- Locate its KPI dictionary entry.
- Identify its source objects, inclusion criteria, exclusions, and quality dependencies.
- Confirm whether reconciliation evidence exists.
- Record any definition or documentation gap.

### Technical scenario

- Trace one measure from the Power BI definition to its gold-layer source.
- Identify the relevant fact, dimension, or mart.
- Locate the related SQL validation logic.
- Confirm that the report does not connect directly to bronze or raw files.

## 10. Feedback Loop

Feedback should be collected through a consistent structure rather than informal, untraceable requests.

### 10.1 Feedback channels

For the portfolio implementation, feedback may be recorded through:

- Azure DevOps work items
- GitHub issues or pull-request comments
- structured review notes
- a maintained change log or release checklist

A production implementation would normally use an approved service-management or analytics-support channel.

### 10.2 Required feedback fields

Each material item should capture:

- submitter role
- affected dashboard page, KPI, document, or data asset
- issue or request
- business impact
- supporting example or evidence
- urgency
- proposed outcome, when known
- whether the request changes metric meaning, presentation, data logic, or access

### 10.3 Feedback classification

| Category | Examples | Primary reviewer |
|---|---|---|
| Defect | Incorrect value, broken filter, missing relationship, misleading label | BI Developer / Data Platform Owner |
| KPI definition | Ambiguous formula, inclusion/exclusion dispute, ownership gap | Data Steward / Operational Reporting Owner |
| Data quality | Duplicate, missing, stale, invalid, or inconsistent records | Data Steward / Data Platform Owner |
| Usability | Confusing navigation, layout, title, tooltip, or filter behavior | BI Developer / Operational Manager |
| Documentation | Missing explanation, outdated path, unsupported claim | Project Owner / Data Steward |
| Security or portfolio safety | Exposed identifier, credential, local path, or excluded artifact | Project Owner / Data Steward |
| Enhancement | New page, measure, dimension, or analytical question | Operational Reporting Owner / BI Developer |

### 10.4 Review cadence

- Critical safety or correctness issues: review immediately.
- Material KPI or data-logic changes: review before the next release.
- Usability and documentation changes: batch into the next planned update unless urgent.
- Enhancement requests: prioritize only when they support a documented business question and do not undermine the project’s focused scope.

A dedicated feedback and change-control document may provide the detailed workflow, approval states, and decision log.

## 11. Change Communication

When an approved change affects users, communicate:

- what changed
- why it changed
- which pages, measures, SQL objects, or documents are affected
- whether historical values or interpretation changed
- whether retraining or documentation review is required
- which known limitations remain
- the release or commit containing the change

Changes to KPI meaning must update the KPI dictionary before the dashboard is represented as current.

## 12. Proposed Success Measures

The following measures are adoption targets for a future guided review or pilot. They are not presented as results already achieved.

| Success area | Proposed measure | Target |
|---|---|---|
| Orientation | Participants can state that the data is synthetic and the solution is not for clinical decision-making | 100% |
| Navigation | Participants can locate the appropriate dashboard page for a stated business question | At least 80% without assistance |
| KPI comprehension | Participants can explain the meaning and principal limitation of a selected KPI | At least 80% |
| Governance discoverability | Participants can locate the KPI dictionary or lineage reference for a selected metric | At least 80% |
| Technical traceability | Technical reviewers can trace a selected measure to its gold-layer source and validation logic | 100% for sampled governed KPIs |
| Documentation completeness | Implemented dashboard measures have current definitions and related source documentation | 100% |
| Safety | Public releases contain no raw datasets, `.pbix`, backups, credentials, or unreviewed row-level exports | Zero violations |
| Feedback quality | Material requests include an affected asset, business impact, and evidence | At least 90% |
| Resolution transparency | Approved material changes have a traceable work item, commit, and updated documentation | 100% |
| Reviewer independence | A portfolio reviewer can understand the project through the documented review path | Demonstrated through guided review feedback |

## 13. Responsibilities

| Role | Adoption responsibility |
|---|---|
| Project Owner | Maintains the adoption package, coordinates reviews, and ensures public claims match implemented scope |
| Operational Reporting Owner | Confirms that the dashboard answers meaningful business questions and approves material KPI changes |
| Data Steward | Maintains definitions, lineage, quality interpretation, limitations, and governance documentation |
| BI Developer | Maintains report usability, semantic-model behavior, DAX measures, and dashboard guidance |
| Data Platform Owner | Maintains ingestion, SQL transformations, auditability, and technical correctness |
| Review participants | Complete guided scenarios and provide specific, evidence-based feedback |

These are modeled responsibilities for the project and are not claims of formally staffed hospital roles.

## 14. Ongoing Maintenance

The adoption package should be reviewed whenever:

- a dashboard page or measure changes
- a KPI definition, inclusion rule, or limitation changes
- a gold-layer object is added, removed, or renamed
- a known data-quality finding changes
- a screenshot is replaced
- repository paths or artifact names change
- public scope or safety boundaries change
- a release is prepared

At minimum, the README, dashboard user guide, KPI dictionary, measure definitions, lineage, security model, and architecture diagram should remain mutually consistent.

## 15. Assumptions

- ClinicalPulse operates in a controlled local development environment.
- The intended audiences are modeled stakeholders and portfolio reviewers.
- Power BI Desktop is the authoring environment.
- The local `.pbix` is excluded from the public repository.
- Public evidence is provided through aggregate screenshots and documentation.
- SQL Server gold assets are the authoritative reporting source.
- Training is documentation-led and demonstration-led rather than delivered through a production learning platform.
- Feedback is tracked through development and portfolio workflows rather than a hospital service desk.

## 16. Limitations

- No real hospital rollout, user pilot, or adoption survey has been conducted.
- The proposed success measures are targets and should not be reported as achieved results without evidence.
- There is no Power BI Service usage telemetry, workspace administration, or production access model.
- Synthetic data cannot reproduce the organizational, clinical, privacy, and workflow complexity of real hospital adoption.
- The plan does not replace formal organizational change management, privacy review, accessibility testing, training governance, or production support.
- The FHIR/API component and optional pipeline hardening are outside the completed ClinicalPulse scope.
