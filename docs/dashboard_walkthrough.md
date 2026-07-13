# ClinicalPulse Dashboard Walkthrough

## 1. Purpose

This document provides a reviewer-facing walkthrough and interpretation guide for the final ClinicalPulse v1.0 Power BI dashboard screenshots.

It helps a non-technical reviewer understand what each page shows, how to read the visible metrics, where screenshot evidence is stored, and which assumptions or limitations apply.

ClinicalPulse uses synthetic Synthea data. The screenshots and dashboard values represent not real patient records and should not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. These dashboards are not intended for clinical-decision support.

## 2. Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1623 - Write dashboard interpretation notes |
| Prior related user story | AB#1620 - Create screenshot documentation |
| Parent area | ClinicalPulse\Power BI |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Screenshot deliverable folder | `powerbi/screenshots/` |
| Primary documentation deliverable | `docs/dashboard_walkthrough.md` |
| Validation support | `src/validate_dashboard_walkthrough_ab1625.py` |
| Related task | AB#1624 - Draft/build artifact for Write dashboard interpretation notes |
| Validation task | AB#1625 - Validate and document Write dashboard interpretation notes |

## 3. How to Read the Dashboard Set

| Principle | Interpretation guidance |
|---|---|
| Start with Executive Overview | Use the Executive Overview page as the high-level summary of activity, utilization, readmissions, observations, and data quality. |
| Use detail pages for explanation | Use Patient Flow, LOS, Readmissions, Conditions & Procedures, and Lab / Observation Operations to explain specific operational patterns. |
| Check governance last | Use Data Quality & Governance to understand reporting trust, quality-rule coverage, known findings, and documentation maturity. |
| Remember the reporting window | Most screenshots use a 2000-2026 reporting window for readability. |
| Treat values as synthetic | All values come from synthetic Synthea data, not real hospital operations. |
| Avoid clinical interpretation | Trends are portfolio BI demonstrations, not clinical evidence or care-quality conclusions. |

## 4. Screenshot Inventory

| Dashboard page | Screenshot path | Status | What the screenshot demonstrates |
|---|---|---|---|
| Executive Overview | `powerbi/screenshots/executive_overview.png` | Complete | High-level operational KPIs, encounter trend, encounter class mix, and data quality status. |
| Patient Flow | `powerbi/screenshots/patient_flow.png` | Complete | Encounter volume, patient mix, encounter class mix, and patient-flow trend patterns. |
| Length of Stay | `powerbi/screenshots/length_of_stay.png` | Complete | Average/median LOS, long-stay indicator, LOS trend, and LOS by encounter class. |
| Readmissions | `powerbi/screenshots/readmissions.png` | Complete | 30-day readmission count/rate, eligible encounters, readmission trend, days-to-readmission pattern, and encounter class comparisons. |
| Conditions & Procedures | `powerbi/screenshots/conditions_procedures.png` | Complete | Case mix, procedure utilization, condition trend, procedure trend, and condition/procedure group filtering. |
| Lab / Observation Operations | `powerbi/screenshots/lab_operations.png` | Complete | Observation volume, top observation codes, observation group mix, observation trend, and average observations per encounter. |
| Data Quality & Governance | `powerbi/screenshots/data_quality_governance.png` | Complete | Quality rule status, quality dimensions, failed rule detail, KPI governance count, scorecard summary, and governance caveats. |

## 5. Screenshot Standards

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

## 6. Common Reporting Window

Most dashboard screenshots use the focused reporting window:

```text
2000-2026
```

This range improves readability for the dashboard screenshots. Earlier calendar dates remain available in the underlying `gold.dim_date` table, but are not emphasized in the final screenshot set.

## 7. Dashboard Interpretation Notes

### 7.1 Executive Overview

| Topic | Interpretation |
|---|---|
| Screenshot | `powerbi/screenshots/executive_overview.png` |
| Intended reader | Executive viewer / portfolio reviewer |
| Main KPIs | Total Encounters, Unique Patients, Average LOS, 30-Day Readmission Rate, Observation Volume, Procedure Volume, Data Quality Pass Rate |
| Main visuals | Encounters over time, encounters by encounter class, data quality checks by status |
| How to read it | This page answers, “What is the overall operational picture, and can the reporting be trusted?” |
| What it shows | Encounter activity rises across the synthetic reporting window, ambulatory encounters dominate volume, and data quality pass rate is visible at 95.00%. |
| Caveat | Card values reflect the page filter window, not necessarily the unfiltered SQL validation baseline. |

### 7.2 Patient Flow

| Topic | Interpretation |
|---|---|
| Screenshot | `powerbi/screenshots/patient_flow.png` |
| Intended reader | Operational manager |
| Main KPIs | Total Encounters, Unique Patients, Average LOS, 30-Day Readmission Rate |
| Main visuals | Encounters over time, encounters by age band, encounters by encounter class |
| How to read it | This page answers, “How is synthetic patient activity distributed over time and across patient/encounter groups?” |
| What it shows | Encounter volume is concentrated in later years, older age bands contribute the largest encounter volume, and ambulatory encounters dominate. |
| Caveat | Patient-flow patterns reflect synthetic Synthea generation, not real demand, capacity, or throughput. |

### 7.3 Length of Stay

| Topic | Interpretation |
|---|---|
| Screenshot | `powerbi/screenshots/length_of_stay.png` |
| Intended reader | Operational manager |
| Main KPIs | Average LOS, Median LOS, Total Encounters, Unique Patients, Long Stay Encounters |
| Main visuals | Average LOS over time, median LOS by encounter class, average LOS by encounter class |
| How to read it | This page answers, “Which encounter classes show longer stays, and how does LOS change over time?” |
| What it shows | Hospice, SNF, and inpatient classes drive longer LOS patterns, while most encounter classes have very short stay durations. |
| Caveat | LOS values come from synthetic encounter timestamps and should not be interpreted as real hospital stay performance. |

### 7.4 Readmissions

| Topic | Interpretation |
|---|---|
| Screenshot | `powerbi/screenshots/readmissions.png` |
| Intended reader | Operational manager |
| Main KPIs | 30-Day Readmissions, Eligible Encounters, 30-Day Readmission Rate, Total Encounters, Unique Patients |
| Main visuals | 30-day readmission rate over time, average days to 30-day readmission by encounter class, readmission rate by encounter class |
| How to read it | This page answers, “How frequent are 30-day readmissions, and how quickly do they occur by encounter class?” |
| What it shows | The page highlights the readmission rate trend, compares readmission rates by encounter class, and shows average days to 30-day readmission within the 30-day window. |
| Caveat | Readmission logic is simplified and does not distinguish planned from unplanned readmissions. It is not clinical quality evidence. |

### 7.5 Conditions & Procedures

| Topic | Interpretation |
|---|---|
| Screenshot | `powerbi/screenshots/conditions_procedures.png` |
| Intended reader | Operational manager |
| Main KPIs | Condition Volume, Procedure Volume, Total Encounters, Unique Patients |
| Main visuals | Top conditions, top procedures, condition volume over time, procedure volume over time |
| How to read it | This page answers, “Which synthetic conditions and procedures dominate the reporting window?” |
| What it shows | The page summarizes top condition and procedure categories and shows condition/procedure volume trends over time. |
| Caveat | Condition and procedure patterns reflect synthetic data generation and should not be treated as real prevalence or service-line utilization. |

### 7.6 Lab / Observation Operations

| Topic | Interpretation |
|---|---|
| Screenshot | `powerbi/screenshots/lab_operations.png` |
| Intended reader | Operational manager / data quality reviewer |
| Main KPIs | Observation Volume, Total Encounters, Unique Patients, Data Quality Pass Rate, Average Observations per Encounter |
| Main visuals | Observation volume over time, top observation codes, observation volume by group |
| How to read it | This page answers, “What observation categories and codes drive synthetic observation workload?” |
| What it shows | Laboratory, survey, and vital-sign groups make up most observation activity, and top observation codes identify high-volume observation types. |
| Caveat | Observation volume includes a governed duplicate-record caveat. The known duplicate observation finding should be considered when interpreting volume. |

### 7.7 Data Quality & Governance

| Topic | Interpretation |
|---|---|
| Screenshot | `powerbi/screenshots/data_quality_governance.png` |
| Intended reader | Data steward / technical reviewer |
| Main KPIs | Data Quality Pass Rate, Data Quality Checks, Data Quality Checks Passed, Failed Checks, Governed KPIs Documented |
| Main visuals | Quality checks by dimension, quality rule details, data quality checks by status, scorecard/governance summary |
| How to read it | This page answers, “Are reporting outputs governed, validated, and transparent about known quality findings?” |
| What it shows | The page shows a 95.00% pass rate, 20 quality checks, 19 passed checks, 1 failed check, governed KPI documentation count, scorecard coverage, and rule-level details. |
| Caveat | The failed observation uniqueness check is intentionally visible as a governed finding, not hidden as an undocumented defect. |

## 8. Deferred Dashboard Scope

The FHIR API Demonstration dashboard page is deferred from ClinicalPulse v1.0.

FHIR/API interoperability remains documented as future extension scope and should not be represented as completed implementation work in v1.0 screenshots. This avoids overstating the maturity of the API layer.

## 9. Cross-Dashboard Caveats

| Caveat | Meaning |
|---|---|
| Synthetic data | The dashboards use Synthea-generated records only. |
| Not real patient records | Values and records do not represent real patients or a real hospital. |
| No clinical decision support | Dashboard patterns are portfolio BI artifacts, not clinical tools. |
| Screenshot limitations | Static screenshots do not show every interactive slicer behavior in the local Power BI report. |
| Page filters | Displayed values may reflect the 2000-2026 screenshot window. |
| PBIX not committed | The `.pbix` file remains local to avoid committing embedded model artifacts. |
| Observation duplicate caveat | Observation volume should be interpreted with the documented duplicate-record quality finding. |
| Simplified readmission logic | Readmissions do not distinguish planned from unplanned events. |
| Deferred FHIR/API | FHIR/API interoperability remains future scope, not completed v1.0 implementation. |

## 10. Final v1.0 Interpretation

ClinicalPulse v1.0 should be interpreted as a completed governed healthcare BI portfolio project with:

- SQL Server medallion-style reporting architecture
- gold-layer Power BI semantic model
- documented KPI definitions
- validated DAX-to-SQL baseline reconciliation
- data quality and governance transparency
- final dashboard screenshots for operational, clinical-operations-style, and governance review

FHIR/API interoperability and optional pipeline hardening are future extension scope, not completed v1.0 implementation.
