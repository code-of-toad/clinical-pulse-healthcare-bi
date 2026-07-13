# ClinicalPulse Dashboard User Guide

## 1. Purpose

This guide explains how to navigate and interpret the ClinicalPulse Power BI dashboard set. It is intended for operational leaders, dashboard consumers, data stewards, analysts, and portfolio reviewers who need a practical explanation of the report pages, filters, KPIs, and known limitations.

ClinicalPulse uses synthetic Synthea data. The dashboard does not contain real patient records, represent real hospital performance, provide clinical evidence, or support clinical decision-making.

## 2. Dashboard Scope

The completed dashboard contains seven pages:

| Page | Primary purpose |
|---|---|
| Executive Overview | Review headline operational activity and reporting trust |
| Patient Flow | Examine encounter volume and patient-mix patterns |
| Length of Stay | Compare average, median, trend, and encounter-class LOS patterns |
| Readmissions | Review simplified 30-day readmission frequency and timing |
| Conditions & Procedures | Examine synthetic case mix and procedure utilization |
| Lab / Observation Operations | Review observation workload, categories, codes, and trends |
| Data Quality & Governance | Review quality checks, known findings, KPI documentation, and asset readiness |

The FHIR/API demonstration page is not part of the completed dashboard scope.

## 3. Before Using the Dashboard

Keep these interpretation rules in mind:

- All values come from synthetic data.
- Dashboard patterns should be treated as BI demonstrations, not evidence about real patients or hospitals.
- Power BI connects to governed SQL Server gold-layer assets.
- KPI values may change when page filters or visual selections are active.
- Most committed screenshots use a focused `2000-2026` reporting window.
- The local Power BI file is interactive; screenshots in the repository are static evidence only.
- The local `.pbix` remains outside Git because Import mode can embed data and connection metadata.

## 4. Quick Start

1. Open the local ClinicalPulse Power BI report.
2. Start on **Executive Overview**.
3. Check the active date range and other slicers before interpreting KPI cards.
4. Use detail pages to investigate the metric or pattern of interest.
5. Review **Data Quality & Governance** before treating a result as trustworthy.
6. Consult the KPI dictionary when a metric definition, denominator, exclusion, or limitation is unclear.
7. Clear filters before comparing a result with the documented unfiltered validation baseline.

## 5. Navigation and Interaction

### 5.1 Moving between pages

Use the report page tabs to move between the seven dashboard pages. Begin with Executive Overview, then use the detail page that best matches the business question.

### 5.2 Using slicers

Available slicers vary by page and may include:

- year or date range
- age band
- encounter class
- organization
- condition group
- procedure group
- observation group

To use a slicer:

1. Select the required value or range.
2. Confirm that the KPI cards and related visuals update.
3. Review all active slicers before interpreting the result.
4. Use the slicer clear-selection control to return to the default view.

Where multi-selection is enabled, select more than one value to compare combined groups.

### 5.3 Selecting chart elements

Where visual interactions are enabled:

- select a bar, line point, donut segment, or table row to filter or highlight related visuals
- select the same item again, select an empty area, or clear the selection to return to the prior view
- hover over a visual mark to view its tooltip

A page-specific slicer may intentionally affect only the visuals supported by that domain and semantic-model relationship.

### 5.4 Static screenshot users

Repository screenshots cannot be filtered or cross-highlighted. Use them to review layout, visible KPI values, trends, governance disclosures, and portfolio evidence. Do not infer hidden filter behavior from a static image.

## 6. KPI Reference

| KPI | Meaning | Important interpretation note |
|---|---|---|
| Total Encounters | Count of eligible encounter records in the current filter context | Values depend on date and other active filters |
| Unique Patients | Distinct synthetic patients represented by eligible encounters | This is not a real hospital catchment population |
| Average LOS | Mean length of stay in days for encounters with valid non-negative duration | Longer stays can raise the average |
| Median LOS | Middle length-of-stay value for eligible encounters | Compare with average LOS to identify skew |
| Long Stay Encounters | Encounters meeting the implemented long-stay rule | Review the configured rule before treating the count as a standard hospital threshold |
| 30-Day Readmissions | Eligible index encounters followed by another encounter within 30 days | The model does not distinguish planned from unplanned returns |
| Readmission Eligible Encounters | Index encounters included in the readmission denominator | The rate cannot be interpreted without this denominator |
| 30-Day Readmission Rate | 30-Day Readmissions divided by Readmission Eligible Encounters | Simplified synthetic sequencing can produce values unlike real hospital benchmarks |
| Condition Volume | Count of eligible condition records | Synthetic condition patterns are not prevalence estimates |
| Procedure Volume | Count of eligible procedure records | Synthetic procedure patterns are not real service-line utilization |
| Observation Volume | Count of observation records | Includes a known governed duplicate-record caveat |
| Average Observations per Encounter | Observation workload relative to encounter volume | Interpret alongside observation-linkage and duplicate limitations |
| Data Quality Checks | Count of implemented checks represented in reporting trust | This counts checks, not evaluated source rows |
| Data Quality Checks Passed | Count of checks with passed status | One failed check may affect a high-volume domain |
| Failed Checks | Count of checks with failed status | A visible failure is governed transparency, not necessarily system failure |
| Data Quality Pass Rate | Passed quality checks divided by total implemented checks | Current implementation is check-based, not record-weighted |
| Governed KPIs Documented | Number of KPIs represented in governance documentation | Documentation coverage does not by itself prove operational adoption |

Detailed definitions, inclusions, exclusions, source objects, and limitations are maintained in `docs/kpi_dictionary.md` and `powerbi/measure_definitions.md`.

## 7. Dashboard Page Guide

### 7.1 Executive Overview

**Audience:** Executive leader, operational leader, portfolio reviewer

**Use this page to answer:**  
What is the overall level of synthetic operational activity, and is the reporting layer transparent about data quality?

**Main KPIs**

- Total Encounters
- Unique Patients
- Average LOS
- 30-Day Readmission Rate
- Observation Volume
- Procedure Volume
- Data Quality Pass Rate

**Main visuals**

- encounters over time
- encounters by encounter class
- data quality checks by status

**How to interpret it**

- Begin with the date range and filter state.
- Use KPI cards for a high-level snapshot.
- Use the trend chart to identify changes over time.
- Use encounter-class mix to understand which categories contribute most volume.
- Read Data Quality Pass Rate alongside failed-check information; a high pass rate does not mean every domain is issue-free.

**Do not conclude**

- that the values represent real hospital performance
- that a trend signals a clinical or capacity problem
- that a high data quality pass rate guarantees every record is correct

---

### 7.2 Patient Flow

**Audience:** Operational manager, analyst

**Use this page to answer:**  
How is encounter activity distributed over time, across age bands, and across encounter classes?

**Main KPIs**

- Total Encounters
- Unique Patients
- Average LOS
- 30-Day Readmission Rate

**Main visuals**

- encounters over time
- encounters by age band
- encounters by encounter class

**Common filters**

- year or reporting period
- age band
- encounter class
- organization, where supported

**How to interpret it**

- Compare encounter volume across time periods.
- Review age-band concentration as a description of the synthetic population.
- Compare encounter classes to understand the modeled mix of care settings.
- Use Average LOS and Readmission Rate as contextual measures rather than isolated conclusions.

**Do not conclude**

- that high encounter volume proves operational pressure
- that an age-band pattern reflects a real community
- that synthetic encounter mix can be benchmarked against a hospital

---

### 7.3 Length of Stay

**Audience:** Operational manager, analyst

**Use this page to answer:**  
How long do encounters last, and do longer stays influence the average?

**Main KPIs**

- Average LOS
- Median LOS
- Total Encounters
- Unique Patients
- Long Stay Encounters

**Main visuals**

- average LOS over time
- median LOS by encounter class
- average LOS by encounter class

**Common filters**

- year or reporting period
- age band
- encounter class
- organization, where supported

**How to interpret it**

- Compare Average LOS with Median LOS.
- An average above the median suggests that longer encounters may be pulling the mean upward.
- Compare encounter classes because different classes naturally have different duration patterns.
- Review the long-stay count only in relation to its configured definition.

**Do not conclude**

- that the LOS level represents real hospital efficiency
- that one encounter class is clinically better or worse
- that the long-stay definition is a universal hospital standard

---

### 7.4 Readmissions

**Audience:** Operational manager, reporting owner

**Use this page to answer:**  
How often are eligible encounters followed by another encounter within 30 days, and how does this vary by encounter class?

**Main KPIs**

- 30-Day Readmissions
- Readmission Eligible Encounters
- 30-Day Readmission Rate
- Total Encounters
- Unique Patients

**Main visuals**

- 30-day readmission rate over time
- average days to 30-day readmission by encounter class
- readmission rate by encounter class

**Common filters**

- year or reporting period
- age band
- encounter class
- organization, where supported

**How to interpret it**

- Read the numerator, denominator, and rate together.
- Use the time trend to identify changes in the synthetic sequence logic.
- Compare encounter classes cautiously because the underlying mix and eligibility can differ.
- Average days to readmission applies to events that meet the implemented 30-day condition.

**Critical limitation**

The logic identifies subsequent encounters within 30 days but does not reliably distinguish planned from unplanned readmissions. The result is not a clinical quality measure and should not be compared with regulated or hospital-reported readmission benchmarks.

---

### 7.5 Conditions & Procedures

**Audience:** Operational manager, analyst

**Use this page to answer:**  
Which synthetic condition and procedure groups account for the greatest volume?

**Main KPIs**

- Condition Volume
- Procedure Volume
- Total Encounters
- Unique Patients

**Main visuals**

- top conditions
- top procedures
- condition volume over time
- procedure volume over time

**Common filters**

- year or reporting period
- condition group
- procedure group
- age band or organization, where supported

**How to interpret it**

- Use top-N visuals to identify the categories dominating the selected filter context.
- Use trends to determine whether volume changes over time.
- Apply condition and procedure filters independently when narrowing the page.
- Treat category groupings as reporting classifications, not complete clinical taxonomies.

**Important interaction note**

A non-functional encounter-class slicer was removed from the final page. Do not expect encounter class to be a primary filter for this page unless a later model change explicitly restores and validates it.

**Do not conclude**

- that condition volume represents disease prevalence
- that procedure volume represents real service demand
- that the most common synthetic category is the most clinically important

---

### 7.6 Lab / Observation Operations

**Audience:** Operational manager, data quality reviewer

**Use this page to answer:**  
What observation groups and codes contribute most to synthetic observation workload?

**Main KPIs**

- Observation Volume
- Total Encounters
- Unique Patients
- Data Quality Pass Rate
- Average Observations per Encounter

**Main visuals**

- observation volume over time
- top observation codes
- observation volume by group

**Common filters**

- year or reporting period
- observation group
- age band, encounter class, or organization where supported

**How to interpret it**

- Use observation group mix to distinguish laboratory, survey, vital-sign, and other modeled activity.
- Use top observation codes to identify high-volume types.
- Compare Observation Volume with Average Observations per Encounter to separate total activity from intensity.
- Review Data Quality Pass Rate and the duplicate-record caveat before treating counts as exact workload.

**Critical limitation**

The quality framework detected 256 excess duplicate observation records under the governed natural-grain definition. These records remain visible as a documented finding rather than being silently removed. Observation volume may therefore overstate unique activity.

---

### 7.7 Data Quality & Governance

**Audience:** Data steward, BI developer, technical reviewer, reporting owner

**Use this page to answer:**  
Are dashboard outputs governed, validated, documented, and transparent about known issues?

**Main KPIs**

- Data Quality Pass Rate
- Data Quality Checks
- Data Quality Checks Passed
- Failed Checks
- Governed KPIs Documented
- supporting scorecard and readiness counts

**Main visuals**

- quality checks by dimension
- quality rule details
- data quality checks by status
- asset scorecard and governance summary

**How to interpret it**

- Use the pass rate as a summary of implemented check outcomes.
- Review the failed-check count and rule-detail table before declaring the data trustworthy.
- Review quality dimensions to understand coverage across completeness, uniqueness, validity, consistency, freshness, lineage, and referential integrity.
- Use scorecards and KPI documentation counts to assess governance readiness rather than operational performance.

**Current governed finding**

The page shows 20 implemented checks, 19 passed checks, 1 failed check, and a 95.00% check-based pass rate in the documented v1.0 state. The failed observation uniqueness check is intentionally disclosed.

**Do not conclude**

- that 95% means 95% of all database rows are correct
- that documentation coverage proves production readiness
- that a failed check should be hidden to improve presentation

## 8. Filter and Comparison Guidance

### 8.1 Always confirm filter context

Before recording or comparing a value, note:

- dashboard page
- date range
- age band
- encounter class
- organization
- domain-specific group filters
- any selected chart element

Two users can obtain different values from the same page because their filter context differs.

### 8.2 Compare like with like

When comparing periods or groups:

- keep all unrelated slicers unchanged
- use the same KPI definition
- confirm that both visuals use the same date and dimensional context
- avoid comparing filtered screenshot values with unfiltered SQL baselines

### 8.3 Reset before validation

When reconciling a dashboard value with documented SQL output:

1. clear page slicers and visual selections
2. confirm the report is showing the intended full data scope
3. verify that the measure name matches the validation log
4. compare with `docs/powerbi_validation_log.md`

## 9. Unfiltered Validation Reference

The following values are documented SQL-to-DAX baselines before dashboard filters:

| Metric | Unfiltered baseline |
|---|---:|
| Total Encounters | 71,663 |
| Unique Patients | 1,145 |
| Average LOS | Approximately 0.247679 days |
| 30-Day Readmission Rate | Approximately 64.37% |
| Observation Volume | 945,531 |
| Procedure Volume | 196,207 |
| Data Quality Pass Rate | 95.00% in the documented 20-check state |

Screenshot values may differ because most portfolio screenshots use a `2000-2026` window or other page filters.

## 10. Interpreting Data Quality Correctly

Data quality information should be read at three levels:

| Level | Question |
|---|---|
| Summary | What proportion of implemented checks passed? |
| Rule | Which specific rule passed or failed? |
| Business impact | Which KPI, page, or domain could the finding affect? |

A failed check does not make every dashboard page unusable. Its effect depends on the target asset and metric. For example, the observation uniqueness finding primarily affects observation-volume interpretation rather than Total Encounters.

## 11. Troubleshooting

| Issue | Suggested action |
|---|---|
| A card value differs from documentation | Clear slicers and chart selections; confirm whether the screenshot uses the 2000-2026 window |
| A slicer does not change a visual | Confirm that the page and visual support that dimension; some filters are intentionally page-specific |
| Multiple visuals remain highlighted | Select an empty area or clear the active visual selection |
| A rate appears unusually high | Review its numerator, denominator, synthetic-data assumptions, and KPI limitations |
| Observation totals seem inflated | Review the duplicate-observation caveat and quality-rule details |
| A dashboard page appears unavailable | Confirm that the local `.pbix` contains the completed seven-page report |
| A public reviewer cannot interact with the report | Repository screenshots are static; the `.pbix` is intentionally not published |
| A metric definition is unclear | Consult `docs/kpi_dictionary.md` and `powerbi/measure_definitions.md` |
| A value cannot be reconciled | Consult `docs/powerbi_validation_log.md` and verify filter context |
| A governance claim is unclear | Consult `docs/data_lineage.md`, `docs/data_asset_scorecards.md`, and `docs/security_model.md` |

## 12. Related Documentation

| Document | Use |
|---|---|
| `docs/dashboard_walkthrough.md` | Screenshot-by-screenshot dashboard interpretation |
| `docs/kpi_dictionary.md` | Governed KPI definitions and limitations |
| `powerbi/measure_definitions.md` | Implemented DAX definitions |
| `powerbi/semantic_model_notes.md` | Data source, tables, relationships, and date-model decisions |
| `docs/powerbi_validation_log.md` | DAX-to-SQL reconciliation evidence |
| `docs/data_lineage.md` | Source-to-dashboard traceability |
| `docs/data_asset_scorecards.md` | Asset readiness and governance scoring |
| `docs/report_design_checklist.md` | UX, readability, accessibility, and portfolio-safety review |
| `docs/security_model.md` | Access assumptions and public portfolio safety |
| `docs/adoption_plan.md` | Audience, training, feedback, and adoption approach |

## 13. Public Portfolio Safety

- Use aggregate dashboard pages and screenshots.
- Do not publish the local `.pbix`.
- Do not expose credentials, connection strings, server details, or private local paths.
- Do not publish unnecessary row-level patient-like records.
- Preserve the synthetic-data disclaimer.
- Do not claim clinical-decision support, real hospital deployment, regulatory certification, FHIR implementation, or production readiness.

## 14. Assumptions

- The user is reviewing either the completed local Power BI report or the committed screenshot set.
- Power BI Desktop is the authoring environment.
- The report uses Import mode and SQL Server gold-layer assets.
- The semantic model relationships and date table are configured according to the documented model.
- The screenshots represent the v1.0 report state at the time of completion.
- Page filters and supported visual interactions may vary by domain.
- KPI definitions and validation evidence are maintained separately as governed documentation.

## 15. Limitations

- Static screenshots cannot demonstrate interactive filtering, cross-highlighting, tooltips, tab order, or drill behavior.
- Full keyboard, screen-reader, alt-text, WCAG, and Power BI Service accessibility certification has not been completed.
- The report has not been deployed to a production Power BI Service workspace.
- Synthetic data cannot reproduce real hospital workflow, case mix, care delivery, privacy obligations, or operational constraints.
- Readmission logic is simplified and does not distinguish planned from unplanned events.
- Observation volume is affected by the documented duplicate-record finding.
- Long-stay interpretation depends on the implemented project rule rather than a universal operational standard.
- The dashboard does not include the deferred FHIR/API component or optional pipeline hardening.
