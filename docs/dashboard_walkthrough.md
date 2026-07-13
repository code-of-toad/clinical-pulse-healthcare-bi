# ClinicalPulse Dashboard Walkthrough

## 1. Purpose

This document provides a reviewer-facing walkthrough of the final ClinicalPulse v1.0 Power BI dashboard screenshots.

It exists so portfolio reviewers can understand what each dashboard page captures, where the screenshot evidence is stored, and how the Power BI report supports the governed hospital BI platform story.

ClinicalPulse uses synthetic Synthea data. The screenshots represent not real patient records and should not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. These dashboards are not intended for clinical-decision support.

## 2. Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1620 - Create screenshot documentation |
| Parent area | ClinicalPulse\Power BI |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Screenshot deliverable folder | `powerbi/screenshots/` |
| Primary documentation deliverable | `docs/dashboard_walkthrough.md` |
| Validation support | `src/validate_dashboard_walkthrough_ab1622.py` |
| Related task | AB#1621 - Draft/build artifact for Create screenshot documentation |
| Validation task | AB#1622 - Validate and document Create screenshot documentation |

## 3. Screenshot Inventory

| Dashboard page | Screenshot path | Status | What the screenshot demonstrates |
|---|---|---|---|
| Executive Overview | `powerbi/screenshots/executive_overview.png` | Complete | High-level operational KPIs, encounter trend, encounter class mix, and data quality status. |
| Patient Flow | `powerbi/screenshots/patient_flow.png` | Complete | Encounter volume, patient mix, encounter class mix, and patient-flow trend patterns. |
| Length of Stay | `powerbi/screenshots/length_of_stay.png` | Complete | Average/median LOS, long-stay indicator, LOS trend, and LOS by encounter class. |
| Readmissions | `powerbi/screenshots/readmissions.png` | Complete | 30-day readmission count/rate, eligible encounters, readmission trend, days-to-readmission pattern, and encounter class comparisons. |
| Conditions & Procedures | `powerbi/screenshots/conditions_procedures.png` | Complete | Case mix, procedure utilization, condition trend, procedure trend, and condition/procedure group filtering. |
| Lab / Observation Operations | `powerbi/screenshots/lab_operations.png` | Complete | Observation volume, top observation codes, observation group mix, observation trend, and average observations per encounter. |
| Data Quality & Governance | `powerbi/screenshots/data_quality_governance.png` | Complete | Quality rule status, quality dimensions, failed rule detail, KPI governance count, scorecard summary, and governance caveats. |

## 4. Screenshot Standards

| Standard | Applied rule |
|---|---|
| File type | Screenshots are saved as `.png` files. |
| Repository location | Screenshots are stored under `powerbi/screenshots/`. |
| Power BI source layer | Report pages are based on SQL Server gold-schema assets. |
| PBIX safety | The local `.pbix` file remains uncommitted. |
| Synthetic-data safety | Screenshots include or are supported by synthetic-data disclaimers. |
| Credential safety | Screenshots must not show database credentials, source dialogs, local private paths, or connection strings. |
| Row-level safety | Screenshots avoid unnecessary row-level patient-like detail. |
| Public portfolio safety | Screenshots are intended to be safe for public portfolio review. |

## 5. Common Reporting Window

Most dashboard screenshots use the focused reporting window:

```text
2000-2026
```

This range improves readability for the dashboard screenshots. Earlier calendar dates remain available in the underlying `gold.dim_date` table, but are not emphasized in the final screenshot set.

## 6. Dashboard Page Walkthrough

### 6.1 Executive Overview

| Item | Description |
|---|---|
| Screenshot | `powerbi/screenshots/executive_overview.png` |
| Intended reader | Executive viewer / portfolio reviewer |
| Main KPIs | Total Encounters, Unique Patients, Average LOS, 30-Day Readmission Rate, Observation Volume, Procedure Volume, Data Quality Pass Rate |
| Main visuals | Encounters over time, encounters by encounter class, data quality checks by status |
| Interpretation focus | Provides the high-level entry point into operational activity and reporting trust. |

### 6.2 Patient Flow

| Item | Description |
|---|---|
| Screenshot | `powerbi/screenshots/patient_flow.png` |
| Intended reader | Operational manager |
| Main KPIs | Total Encounters, Unique Patients, Average LOS, 30-Day Readmission Rate |
| Main visuals | Encounters over time, encounters by age band, encounters by encounter class |
| Interpretation focus | Helps reviewers understand encounter volume patterns and synthetic patient-flow mix. |

### 6.3 Length of Stay

| Item | Description |
|---|---|
| Screenshot | `powerbi/screenshots/length_of_stay.png` |
| Intended reader | Operational manager |
| Main KPIs | Average LOS, Median LOS, Total Encounters, Unique Patients, Long Stay Encounters |
| Main visuals | Average LOS over time, median LOS by encounter class, average LOS by encounter class |
| Interpretation focus | Shows LOS trend, typical stay length, and long-stay indicators. |

### 6.4 Readmissions

| Item | Description |
|---|---|
| Screenshot | `powerbi/screenshots/readmissions.png` |
| Intended reader | Operational manager |
| Main KPIs | 30-Day Readmissions, Eligible Encounters, 30-Day Readmission Rate, Total Encounters, Unique Patients |
| Main visuals | 30-day readmission rate over time, average days to 30-day readmission by encounter class, readmission rate by encounter class |
| Interpretation focus | Shows 30-day readmission patterns and timing of readmission events within the synthetic model. |

### 6.5 Conditions & Procedures

| Item | Description |
|---|---|
| Screenshot | `powerbi/screenshots/conditions_procedures.png` |
| Intended reader | Operational manager |
| Main KPIs | Condition Volume, Procedure Volume, Total Encounters, Unique Patients |
| Main visuals | Top conditions, top procedures, condition volume over time, procedure volume over time |
| Interpretation focus | Shows case mix and procedure utilization patterns. |

### 6.6 Lab / Observation Operations

| Item | Description |
|---|---|
| Screenshot | `powerbi/screenshots/lab_operations.png` |
| Intended reader | Operational manager / data quality reviewer |
| Main KPIs | Observation Volume, Total Encounters, Unique Patients, Data Quality Pass Rate, Average Observations per Encounter |
| Main visuals | Observation volume over time, top observation codes, observation volume by group |
| Interpretation focus | Shows observation workload, high-volume observation categories, and observation trend patterns. |
| Caveat | Observation volume includes the governed duplicate-record caveat documented in data quality outputs. |

### 6.7 Data Quality & Governance

| Item | Description |
|---|---|
| Screenshot | `powerbi/screenshots/data_quality_governance.png` |
| Intended reader | Data steward / technical reviewer |
| Main KPIs | Data Quality Pass Rate, Data Quality Checks, Data Quality Checks Passed, Failed Checks, Governed KPIs Documented |
| Main visuals | Quality checks by dimension, quality rule details, data quality checks by status, scorecard/governance summary |
| Interpretation focus | Shows whether reporting outputs have visible quality checks, governance documentation, and transparent known issue disclosure. |

## 7. Deferred Dashboard Scope

The FHIR API Demonstration dashboard page is deferred from ClinicalPulse v1.0.

FHIR/API interoperability remains documented as future extension scope and should not be represented as completed implementation work in v1.0 screenshots. This avoids overstating the maturity of the API layer.

## 8. Assumptions

- The screenshots represent the local Power BI report state at the time of v1.0 completion.
- The local `.pbix` file is saved outside Git and remains uncommitted.
- Screenshot values may reflect page-level filters, especially the 2000-2026 reporting window.
- DAX measure baseline reconciliation is documented separately in `docs/powerbi_validation_log.md`.
- Dashboard screenshots are intended for portfolio review, not production clinical operations.

## 9. Limitations

- Static screenshots do not capture every interactive slicer behavior in the local Power BI report.
- Screenshots are not a substitute for the local `.pbix` report file.
- The underlying data is synthetic and does not represent real patient records or real hospital operations.
- Observation volume should be interpreted with the governed duplicate-record caveat documented in data quality outputs.
- Readmission logic is simplified and does not distinguish planned from unplanned readmissions.
- The FHIR/API demonstration page is deferred from v1.0 and should not be treated as implemented.
