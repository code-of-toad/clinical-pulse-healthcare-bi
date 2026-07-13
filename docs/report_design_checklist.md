# ClinicalPulse Report Design Checklist

## 1. Purpose

This checklist documents the final UX, readability, accessibility, and portfolio-safety review for the ClinicalPulse v1.0 Power BI dashboard report.

The goal is to confirm that the completed report pages are readable, visually consistent, not over-cluttered, and appropriate for public portfolio review.

ClinicalPulse uses synthetic Synthea data. The dashboards represent not real patient records and should not be interpreted as real hospital performance, clinical evidence, or clinical recommendations. These dashboards are not intended for clinical-decision support.

## 2. Artifact Traceability

| Field | Value |
|---|---|
| Azure Boards user story | AB#1626 - Finalize report UX and accessibility checks |
| Parent area | ClinicalPulse\Power BI |
| Iteration | ClinicalPulse\Sprint 6 - Power BI Reporting |
| Primary deliverable | `docs/report_design_checklist.md` |
| Validation support | `src/validate_report_design_checklist_ab1628.py` |
| Related task | AB#1627 - Draft/build artifact for Finalize report UX and accessibility checks |
| Validation task | AB#1628 - Validate and document Finalize report UX and accessibility checks |

## 3. Reviewed Dashboard Pages

| Dashboard page | Screenshot path | Review status |
|---|---|---|
| Executive Overview | `powerbi/screenshots/executive_overview.png` | Reviewed |
| Patient Flow | `powerbi/screenshots/patient_flow.png` | Reviewed |
| Length of Stay | `powerbi/screenshots/length_of_stay.png` | Reviewed |
| Readmissions | `powerbi/screenshots/readmissions.png` | Reviewed |
| Conditions & Procedures | `powerbi/screenshots/conditions_procedures.png` | Reviewed |
| Lab / Observation Operations | `powerbi/screenshots/lab_operations.png` | Reviewed |
| Data Quality & Governance | `powerbi/screenshots/data_quality_governance.png` | Reviewed |

## 4. Overall Design Standard

| Standard | Final decision |
|---|---|
| Theme | Consistent dark theme across final dashboard screenshots. |
| Page structure | Large page title, subtitle, KPI cards, compact slicers, primary visuals, safety note. |
| Reporting window | Final screenshots use a visible `2000-2026` window where applicable. |
| Visual density | Pages are intentionally limited to the most useful visuals instead of showing every possible field. |
| Interaction pattern | Slicers are compact and page-specific where possible. |
| Governance visibility | Synthetic-data safety notes, duplicate-observation caveat, and data quality status are visible where relevant. |
| Portfolio safety | Screenshots avoid raw patient-level tables, credentials, connection dialogs, local paths, and `.pbix` exposure. |

## 5. Page-Level UX Review

| Page | UX review result |
|---|---|
| Executive Overview | Uses high-level KPI cards, trend chart, encounter-class breakdown, and data quality status. Suitable as the report entry point. |
| Patient Flow | Uses focused encounter volume visuals by time, age band, and encounter class. Slicers are readable and page intent is clear. |
| Length of Stay | Uses LOS cards, long-stay indicator, LOS trend, and encounter-class LOS comparisons. Page supports operational LOS review without over-cluttering. |
| Readmissions | Uses readmission count/rate cards, eligible encounters, trend, days-to-readmission, and encounter-class rate comparison. Page reflects readmission story intent. |
| Conditions & Procedures | Uses condition/procedure volume cards, top-N case mix, utilization trends, and page-specific condition/procedure group slicers. Removed non-functional encounter-class slicer. |
| Lab / Observation Operations | Uses observation workload cards, top observation codes, observation group mix, trend, and duplicate-record caveat. Page supports observation operations review. |
| Data Quality & Governance | Uses quality summary cards, quality dimensions, rule details, check status, KPI documentation count, and scorecard summary. Page supports governance review. |

## 6. Readability Checklist

| Check | Status | Notes |
|---|---|---|
| Each page has a clear title | Passed | Dashboard page names are visible and aligned to their purpose. |
| Each page has a consistent subtitle | Passed | Subtitle identifies synthetic hospital BI dashboard, SQL Server gold layer, and Power BI. |
| KPI cards are readable | Passed | Large values and short labels are used. |
| Numeric formatting is readable | Passed | Count measures use comma separators where practical; rates use percentages. |
| Visual titles are plain English | Passed | Titles describe the business question or visual purpose. |
| Axes are readable | Passed | Time, encounter class, condition/procedure group, observation group, and quality dimensions are labeled. |
| Visuals are not over-cluttered | Passed | Pages use focused 3-5 visual patterns rather than dense report canvases. |
| Slicer placement is consistent | Passed | Most pages use a left-side compact slicer panel. |
| Slicer labels are readable | Passed | Filters use Year, Age Band, Encounter Class, Organization Key, or page-specific group slicers. |
| Page-specific slicers are used where appropriate | Passed | Conditions/Procedures and Lab pages use domain-specific group slicers. |
| Non-functional slicers were removed where identified | Passed | Encounter Class was removed from Conditions & Procedures when it did not filter the page correctly. |
| Safety notes are visible | Passed | Synthetic-data and no-clinical-decision-support notes are visible across final report pages. |

## 7. Accessibility Checklist

| Check | Status | Notes |
|---|---|---|
| Strong contrast between text and background | Passed | Dark theme uses light text and high-contrast chart elements. |
| Large title text | Passed | Page titles are prominent and readable. |
| Large card values | Passed | KPI values are visually prominent for quick scanning. |
| Visuals use direct labels where useful | Passed | Bar charts include data labels for easier interpretation. |
| Chart types are simple | Passed | Pages primarily use cards, line charts, bar charts, donut charts, and tables. |
| Pages avoid unnecessary color dependence | Passed | Visuals are interpretable through labels, titles, and values, not color alone. |
| Public screenshots avoid sensitive details | Passed | Screenshots do not show credentials, connection dialogs, local paths, or row-level patient-like detail. |
| Known caveats are visibly disclosed | Passed | Synthetic-data note and observation duplicate-record caveat are included where relevant. |
| Manual keyboard/screen-reader testing | Not performed | Static screenshot review cannot fully validate tab order or screen-reader behavior. |
| Power BI alt text review | Limited | Visuals are designed with clear titles, but full alt-text coverage should be considered future enhancement if publishing to Power BI Service. |

## 8. Visual Design Checklist

| Check | Status | Notes |
|---|---|---|
| Consistent dark visual theme | Passed | Final screenshots use a consistent dark report style. |
| Consistent page title placement | Passed | Page titles are centered and prominent. |
| Consistent KPI card placement | Passed | KPI cards are placed near the top of pages. |
| Consistent filter panel | Passed | Filters are generally placed on the left side. |
| Consistent safety note placement | Passed | Safety notes are included in page footer/side areas where space allows. |
| Top-N visuals used where appropriate | Passed | Conditions, procedures, and observations use top-N bars to reduce clutter. |
| Tables used only where useful | Passed | Data Quality & Governance uses a table because rule-level details are needed. |
| Excessive visuals avoided | Passed | Dashboard pages are intentionally focused and reviewer-friendly. |

## 9. Portfolio Safety Checklist

| Check | Status | Notes |
|---|---|---|
| `.pbix` file excluded from Git | Passed | Power BI file remains local and is not committed. The `.pbix file remains local` as part of PBIX safety. |
| Screenshots committed instead of PBIX | Passed | Screenshot evidence is stored under `powerbi/screenshots/`. |
| No secrets shown | Passed | Screenshots do not show credentials or connection strings. |
| No local private paths shown | Passed | Screenshots show report pages only. |
| No real patient records | Passed | Data is synthetic Synthea output. |
| No clinical decision support claim | Passed | Notes state dashboards are not intended for clinical-decision support. |
| FHIR/API not overstated | Passed | FHIR/API demonstration was deferred from v1.0 and is not represented as implemented. |
| Known data quality caveat disclosed | Passed | Observation duplicate-record caveat is documented and visible in relevant pages. |

## 10. Final UX Review Summary

| Review area | Result |
|---|---|
| Readability | Passed |
| Layout consistency | Passed |
| Visual density | Passed |
| Screenshot safety | Passed |
| Synthetic-data disclosure | Passed |
| Governance caveat disclosure | Passed |
| Non-technical reviewer usability | Passed |
| Full accessibility certification | Not claimed |

## 11. Assumptions

- Final review is based on the committed screenshot set and the local Power BI report state.
- The `.pbix` file remains local and intentionally uncommitted.
- Most report pages use the 2000-2026 screenshot window for readability.
- Screenshots are intended for portfolio review and GitHub documentation.
- The report is reviewed as a v1.0 governed BI portfolio artifact, not as a production hospital system.
- FHIR/API interoperability and optional pipeline hardening are deferred future scope.

## 12. Limitations

- Static screenshots cannot fully validate keyboard navigation, tab order, screen-reader output, or Power BI Service accessibility behavior.
- The report has not been certified against WCAG or enterprise accessibility standards.
- Manual alt-text coverage is limited and should be improved if the report is later published as an interactive Power BI Service artifact.
- Synthetic data limits the realism of operational patterns.
- Dashboard values are not clinical evidence and should not be used for clinical-decision support.
- Some labels may be shortened in screenshots due to available space, especially long condition, procedure, observation, or quality-rule names.

## 13. Final Decision

The ClinicalPulse v1.0 Power BI report is acceptable for portfolio release.

The report pages are readable, consistent, not over-cluttered, and aligned with the governed SQL Server plus Power BI scope of ClinicalPulse v1.0.
