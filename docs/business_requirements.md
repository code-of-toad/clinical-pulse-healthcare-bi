# ClinicalPulse Business Requirements Document

## 1. Purpose

This document defines the business requirements for ClinicalPulse, a governed hospital business intelligence platform built with synthetic EHR data. It translates stakeholder reporting needs into business-facing requirements before technical design, SQL implementation, Power BI modeling, and FHIR-aligned API work proceed.

The document is intended for operational stakeholders, BI developers, data stewards, and portfolio reviewers who need to understand what the platform must support and why those requirements matter.

## 2. Business Objective

ClinicalPulse must provide trusted operational reporting for a simulated hospital analytics environment. The platform should help users understand patient flow, encounter activity, length of stay, readmissions, service utilization, lab and observation activity, data quality, and reporting trust.

The project must demonstrate that healthcare BI outputs are not only technically built, but also governed, documented, validated, and understandable to non-technical stakeholders.

## 3. Business Problem

Hospital leaders and operational teams need reliable visibility into operational pressure points. However, reporting can become unreliable when source data is used directly, KPI definitions are unclear, validation is inconsistent, or users cannot trace dashboard numbers back to source logic.

ClinicalPulse addresses this problem by requiring curated reporting layers, governed KPI definitions, documented assumptions, data quality checks, and stakeholder-ready Power BI dashboards.

## 4. Primary Stakeholders and Users

| Stakeholder Group | Business Need |
|---|---|
| Executive leaders | Need a high-level view of operational trends, key indicators, and reporting trust. |
| Operational managers | Need actionable reporting on patient flow, encounter volume, utilization, length of stay, and service demand. |
| BI developers | Need clear requirements, defined KPIs, curated data models, and validation expectations. |
| Data stewards | Need documented definitions, quality rules, ownership assumptions, and lineage. |
| Analytics stakeholders | Need business questions translated into usable reporting outputs. |
| Interoperability reviewers | Need a lightweight demonstration of how reporting entities relate to FHIR-style resources. |
| Portfolio reviewers | Need to understand the project’s business value, governance discipline, and technical execution. |

## 5. Reporting Domains

ClinicalPulse must support the following reporting domains:

| Domain | Business Purpose |
|---|---|
| Patient flow | Understand encounter volume, timing, duration, and operational pressure. |
| Length of stay | Identify how long patients remain in care and how duration varies by encounter class, organization, age band, or condition group. |
| Readmissions | Monitor follow-up encounters within a defined period and identify patterns by patient, condition, organization, or age band. |
| Service utilization | Understand which procedures, conditions, and encounter types create operational demand. |
| Lab and observation activity | Track observation volume, high-volume tests, abnormal or flagged values where available, and activity by encounter type. |
| Data quality and governance | Show whether reporting assets are documented, validated, traceable, and ready for stakeholder use. |
| FHIR/API demonstration | Show how selected healthcare entities can be exposed as FHIR-aligned JSON resources for interoperability literacy. |

## 6. Business Questions

ClinicalPulse must answer the following business questions where supported by the available synthetic data:

### 6.1 Patient Flow

- How many encounters occurred over time?
- Which encounter classes or organizations have the highest volume?
- How does encounter activity vary by date, organization, encounter class, and patient group?
- Which encounters appear unusually long or operationally significant?

### 6.2 Length of Stay

- What is the average and median length of stay for encounters in scope?
- How does length of stay vary by encounter class, organization, age band, condition group, or procedure group?
- Which records should be excluded from length-of-stay calculations because of missing or invalid dates?

### 6.3 Readmissions

- Which eligible encounters are followed by another encounter for the same patient within 30 days?
- What is the 30-day readmission count and rate?
- How do readmission patterns vary by condition group, age band, organization, and encounter class?
- What assumptions are used to define eligible encounters and planned versus unplanned returns?

### 6.4 Service Utilization

- Which conditions, procedures, and encounter types create the greatest volume?
- How does utilization vary by organization, date, patient group, or encounter class?
- Which procedure or condition groupings are useful for stakeholder interpretation?

### 6.5 Lab and Observation Activity

- Which observation or lab codes have the highest volume?
- How does observation activity vary by encounter type, organization, and time period?
- Which observations are missing required relationships to patients or encounters?
- Which abnormal or flagged values are available for reporting, if supported by the source data?

### 6.6 Data Quality and Governance

- Which source entities contain missing, invalid, duplicate, or inconsistent values?
- Which reporting assets are documented, validated, and ready for stakeholder use?
- Which KPIs have complete definitions, formulas, source objects, validation queries, and known limitations?
- Can dashboard numbers be traced from source data through SQL transformations to Power BI measures?

### 6.7 FHIR/API Demonstration

- Which ClinicalPulse entities map to FHIR-style resources such as Patient, Encounter, Observation, Condition, Procedure, Organization, and Practitioner?
- Which read-only API endpoints demonstrate selected synthetic records or governed aggregate metrics?
- What limitations distinguish this demonstration API from a production FHIR server?

## 7. Functional Reporting Requirements

| Requirement ID | Requirement |
|---|---|
| BRD-FR-001 | The platform must ingest selected Synthea synthetic healthcare entities into SQL Server. |
| BRD-FR-002 | The platform must separate raw/staged, cleaned, and reporting-ready data using bronze, silver, and gold layers. |
| BRD-FR-003 | Power BI reporting must connect to curated gold-layer tables or views, not directly to raw source files. |
| BRD-FR-004 | The dashboard must include an executive-level view of operational KPIs and data quality indicators. |
| BRD-FR-005 | The dashboard must support analysis of patient flow, length of stay, readmissions, service utilization, and observation activity. |
| BRD-FR-006 | The dashboard must include slicers or filters for practical stakeholder exploration, such as date range, organization, encounter class, age band, condition group, or procedure group where available. |
| BRD-FR-007 | Each dashboard KPI must have a corresponding KPI dictionary entry. |
| BRD-FR-008 | KPI definitions must include business meaning, formula, grain, source objects, inclusion criteria, exclusion criteria, validation approach, and known limitations. |
| BRD-FR-009 | Data quality checks must cover relevant completeness, uniqueness, referential integrity, validity, consistency, freshness, lineage, and API-readiness concerns. |
| BRD-FR-010 | At least one KPI must be traceable from source data through SQL transformation logic to Power BI reporting. |
| BRD-FR-011 | The project must document public portfolio safety rules, including synthetic data handling, no secrets in Git, and exclusion of raw generated data unless intentionally curated as a tiny safe sample. |
| BRD-FR-012 | The project must include a minimal read-only FHIR-aligned API or documented API demonstration for selected synthetic healthcare entities. |

## 8. Data Requirements

ClinicalPulse must prioritize the following source entities for Version 1:

| Source Entity | Requirement |
|---|---|
| Patients | Required for patient demographics, age bands, patient counts, and encounter attribution. |
| Encounters | Required as the core entity for patient flow, length of stay, readmissions, and utilization reporting. |
| Organizations | Required for site-level or organization-level operational reporting. |
| Providers | Required only at a lightweight level for healthcare modeling and FHIR references. |
| Conditions | Required for diagnosis context, cohorting, case mix, and readmission breakdowns. |
| Observations | Required for lab and clinical observation activity reporting. |
| Procedures | Required in limited scope for service utilization and encounter complexity. |

Medications, payers, and care plans are optional and should not be added to Version 1 unless they support the core operational reporting goals without expanding scope unnecessarily.

## 9. KPI Requirements

The project must define and eventually implement governed KPI entries for the following metric families:

| KPI Family | Required Business Meaning |
|---|---|
| Total encounters | Count of encounters within the selected reporting period and scope. |
| Unique patients | Count of distinct synthetic patients with at least one encounter in scope. |
| Average length of stay | Average duration between encounter start and stop for eligible encounters. |
| Median length of stay | Median encounter duration for eligible encounters. |
| 30-day readmission rate | Percentage of eligible encounters followed by another encounter for the same patient within 30 days. |
| Observation volume | Count of observation records by observation type, encounter, organization, or time period. |
| Procedure volume | Count of procedures by category, organization, encounter class, or time period. |
| Data quality pass rate | Percentage of selected quality checks or records passing defined validation rules. |
| API resource coverage | Percentage of selected entities mapped to FHIR-style API resources. |

Each KPI must document its definition before it is treated as stakeholder-ready.

## 10. Data Quality and Governance Requirements

ClinicalPulse must treat data quality and governance as part of the reporting product. The project must support:

- KPI definitions that prevent conflicting interpretations.
- Data quality checks that identify reporting risks before dashboard use.
- Lineage documentation from source entities to reporting assets.
- Ownership and stewardship assumptions for major artifacts and data assets.
- Data asset readiness indicators through documentation or scorecards.
- Security and public portfolio safety assumptions appropriate for synthetic healthcare data.
- Clear labels distinguishing synthetic demonstration outputs from real clinical or operational systems.

## 11. Power BI Requirements

The Power BI report must be stakeholder-facing and KPI-driven. It should support the following dashboard areas:

| Dashboard Area | Required Purpose |
|---|---|
| Executive Overview | Summarize high-level operational KPIs and reporting trust. |
| Patient Flow | Show encounter activity, trends, volume, and duration patterns. |
| Readmissions | Show 30-day readmission counts, rates, and breakdowns. |
| Conditions and Procedures | Show case mix and utilization patterns. |
| Lab / Observation Operations | Show observation activity and operational load. |
| Data Quality and Governance | Show validation status, data quality issues, KPI documentation status, and asset readiness. |
| FHIR API Demonstration | Show or document how selected resources relate to API outputs. |

The report must avoid unnecessary row-level exposure and should prioritize aggregate views suitable for a public portfolio project.

## 12. FHIR/API Requirements

ClinicalPulse must include a minimal interoperability component. The API work must remain bounded and should demonstrate healthcare data literacy rather than production FHIR compliance.

Required API-related business requirements:

- Document how selected ClinicalPulse entities map to FHIR-style resources.
- Prepare selected SQL views or curated outputs for FHIR-aligned JSON structures.
- Expose or document read-only endpoints for selected synthetic Patient, Encounter, Observation, and Condition examples where feasible.
- Include a health or metadata endpoint if an API service is implemented.
- Clearly state that the API is FHIR-aligned and demonstration-oriented, not a certified production FHIR server.

## 13. Non-Functional Requirements

| Category | Requirement |
|---|---|
| Trust | Metrics must be defined, validated, and traceable before being treated as dashboard-ready. |
| Usability | Documentation and dashboards must be understandable to both technical and non-technical reviewers. |
| Reproducibility | Source generation or acquisition, ingestion assumptions, and setup steps must be documented. |
| Maintainability | SQL, Python, documentation, and dashboard artifacts must be organized in a clear repository structure. |
| Security | Secrets, credentials, local database backups, and raw generated data must not be committed to Git. |
| Portfolio safety | The project must clearly state that data is synthetic and not suitable for clinical decision-making. |
| Governance | KPI definitions, data quality rules, lineage, and ownership assumptions must be documented. |
| Scope control | Optional domains should not be added unless they support the core operational BI purpose. |

## 14. Assumptions

- Synthea synthetic healthcare data is the source system for the project.
- The data does not represent real patients, real facilities, or real operational performance.
- SQL Server is the primary analytical backbone.
- Power BI consumes curated gold-layer tables or views.
- Python supports ingestion, validation, reconciliation, and API-related tasks.
- Governance artifacts are part of the platform and are required for reporting trust.
- FHIR API work is demonstration-oriented and read-only.
- Public outputs will use synthetic data, aggregate views, or intentionally curated safe examples only.

## 15. Limitations

- Synthetic data may not fully reflect real hospital workflows, coding practices, data quality issues, or operational complexity.
- The platform does not support clinical decision-making, patient care, or production operations.
- FHIR-aligned outputs are not a substitute for a certified FHIR server.
- Security implementation is limited to documented assumptions and safe repository practices unless later expanded.
- Some reporting domains may be limited by available Synthea fields and generated data quality.
- Version 1 prioritizes core operational BI and should not attempt to cover every possible healthcare analytics domain.
