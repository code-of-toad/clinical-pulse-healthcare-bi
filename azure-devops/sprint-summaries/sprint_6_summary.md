# ClinicalPulse Sprint 6 Summary — Power BI Reporting

## 1. Sprint Overview

Sprint 6 completed the ClinicalPulse Power BI reporting layer and supporting governance documentation for the v1.0 governed hospital BI platform.

This sprint moved the project from a validated SQL Server gold layer into a reviewer-ready Power BI reporting experience. The final scope includes a gold-layer Power BI semantic model, documented measures, DAX-to-SQL validation, dashboard screenshots, screenshot walkthrough documentation, dashboard interpretation notes, and final UX/accessibility review.

ClinicalPulse uses synthetic Synthea data. The dashboards and documentation do not represent real patient records, real hospital performance, clinical evidence, or clinical recommendations. The project is not intended for clinical-decision support.

## 2. Sprint Goal

Build and document the ClinicalPulse Power BI reporting layer so that portfolio reviewers can evaluate:

- governed SQL Server gold-layer reporting
- validated Power BI measures
- operational dashboard pages
- data quality visibility
- governance transparency
- screenshot-based portfolio evidence
- report readability and UX/accessibility review

## 3. Completed User Stories

| Work item | Title | Status | Primary deliverable |
|---|---|---|---|
| AB#1566 | Create data asset catalog | Complete | `docs/data_asset_catalog.md` |
| AB#1569 | Create data lineage document | Complete | `docs/data_lineage.md` |
| AB#1572 | Create data asset scorecards | Complete | `docs/data_asset_scorecards.md` |
| AB#1575 | Document ownership, stewardship, and security assumptions | Complete | `docs/security_model.md`, `docs/data_governance_plan.md` |
| AB#1580 | Connect Power BI to SQL Server gold schema | Complete | `powerbi/semantic_model_notes.md` |
| AB#1584 | Build relationships and date table | Complete | `powerbi/semantic_model_notes.md` |
| AB#1588 | Document DAX measure definitions | Complete | `powerbi/measure_definitions.md` |
| AB#1592 | Validate DAX measures against SQL outputs | Complete | `docs/powerbi_validation_log.md` |
| AB#1597 | Build Executive Overview dashboard page | Complete | `powerbi/screenshots/executive_overview.png` |
| AB#1600 | Build Patient Flow and LOS dashboard pages | Complete | `powerbi/screenshots/patient_flow.png`, `powerbi/screenshots/length_of_stay.png` |
| AB#1603 | Build Readmissions dashboard page | Complete | `powerbi/screenshots/readmissions.png` |
| AB#1606 | Build Conditions and Procedures dashboard page | Complete | `powerbi/screenshots/conditions_procedures.png` |
| AB#1609 | Build Lab / Observation Operations dashboard page | Complete | `powerbi/screenshots/lab_operations.png` |
| AB#1612 | Build Data Quality and Governance dashboard page | Complete | `powerbi/screenshots/data_quality_governance.png` |
| AB#1620 | Create screenshot documentation | Complete | `docs/dashboard_walkthrough.md` |
| AB#1623 | Write dashboard interpretation notes | Complete | `docs/dashboard_walkthrough.md` |
| AB#1626 | Finalize report UX and accessibility checks | Complete | `docs/report_design_checklist.md` |

## 4. Deferred Scope

| Work item / area | Decision | Reason |
|---|---|---|
| AB#1616 — Build FHIR API Demonstration dashboard page | Deferred from v1.0 | FHIR/API interoperability remains future scope and should not be represented as implemented. |
| FHIR/API implementation | Deferred from v1.0 | The v1.0 project is closed as a governed SQL Server + Power BI hospital BI platform. |
| Optional pipeline hardening | Deferred from v1.0 | Not required for the portfolio-ready BI platform release. |

The FHIR/API and optional pipeline-hardening work remain valid future extensions, but they are not completed v1.0 implementation work.

## 5. Power BI Reporting Outcomes

Sprint 6 produced a complete Power BI report experience using SQL Server gold-layer assets.

### Completed dashboard pages

| Dashboard page | Screenshot path | Main purpose |
|---|---|---|
| Executive Overview | `powerbi/screenshots/executive_overview.png` | High-level operational KPIs, encounter trend, encounter class mix, and data quality status. |
| Patient Flow | `powerbi/screenshots/patient_flow.png` | Encounter volume, patient mix, encounter class distribution, and patient-flow trend. |
| Length of Stay | `powerbi/screenshots/length_of_stay.png` | Average/median LOS, long-stay indicator, LOS trend, and LOS by encounter class. |
| Readmissions | `powerbi/screenshots/readmissions.png` | 30-day readmission count/rate, eligible encounters, readmission trend, and days-to-readmission patterns. |
| Conditions & Procedures | `powerbi/screenshots/conditions_procedures.png` | Case mix, procedure utilization, top conditions/procedures, and trend patterns. |
| Lab / Observation Operations | `powerbi/screenshots/lab_operations.png` | Observation volume, top observation codes, observation group mix, and observation trends. |
| Data Quality & Governance | `powerbi/screenshots/data_quality_governance.png` | Quality rule status, scorecard summary, KPI documentation count, and governance caveats. |

## 6. Power BI Model and Measure Work

### Gold-layer source rule

Power BI was connected to SQL Server gold schema assets only. Raw CSV files, bronze tables, and silver tables were excluded from the reporting model.

### Semantic model work completed

- SQL Server gold schema connection documented.
- Gold reporting tables/views documented.
- Date table marked using `gold.dim_date[full_date]`.
- Relationships created from gold dimensions to gold fact tables.
- Auto date/time guidance documented.
- Relationship standards documented as one-to-many, single-direction where appropriate.
- `.pbix` file kept local and excluded from Git.

### Measures documented

Power BI measure definitions were documented in:

```text
powerbi/measure_definitions.md
```

The documented measure set includes operational, readmission, LOS, observation, procedure, and data quality measures.

## 7. DAX-to-SQL Validation

DAX measures were reconciled to SQL validation outputs in:

```text
docs/powerbi_validation_log.md
```

Validated baseline values included:

| Metric | SQL / validation baseline |
|---|---:|
| Total Encounters | 71,663 |
| Unique Patients | 1,145 |
| Average LOS | 0.247679 |
| 30-Day Readmission Rate | 0.643707 |
| Observation Volume | 945,531 |
| Procedure Volume | 196,207 |

Dashboard screenshots use a focused `2000-2026` reporting window where applicable, so screenshot card values may differ from unfiltered SQL validation baselines.

## 8. Governance Documentation Completed

Sprint 6 strengthened ClinicalPulse governance with:

| Artifact | Purpose |
|---|---|
| `docs/data_asset_catalog.md` | Catalogs bronze, silver, gold, governance, audit, Power BI, and planned API/FHIR assets. |
| `docs/data_lineage.md` | Traces source-to-bronze-to-silver-to-gold-to-Power-BI/API lineage. |
| `docs/data_asset_scorecards.md` | Rates key assets by reliability, documentation, validation, security, and readiness. |
| `docs/security_model.md` | Documents ownership, stewardship, least-privilege assumptions, and portfolio safety. |
| `docs/data_governance_plan.md` | Documents governance roles, governed artifacts, change practices, and data layer governance. |
| `docs/powerbi_validation_log.md` | Records DAX-to-SQL reconciliation evidence. |
| `docs/dashboard_walkthrough.md` | Documents screenshot evidence and non-technical dashboard interpretation notes. |
| `docs/report_design_checklist.md` | Records final UX, readability, accessibility, and portfolio-safety review. |

## 9. Data Quality and Governance Visibility

The final Data Quality & Governance dashboard makes reporting trust visible through:

- Data Quality Pass Rate
- Data Quality Checks
- Data Quality Checks Passed
- Failed Checks
- Governed KPIs Documented
- Scored Assets
- Scorecard Dimensions
- Dashboard Readiness Mappings
- Detailed Scorecards
- Quality Checks by Dimension
- Quality Rule Details
- Data Quality Checks by Status

The known observation duplicate-record caveat remains visible and documented. This is intentionally treated as governed transparency rather than hidden failure.

## 10. Validation Scripts Added

| Validation script | Validates |
|---|---|
| `src/validate_data_asset_catalog_ab1568.py` | Data asset catalog |
| `src/validate_data_lineage_ab1571.py` | Data lineage document |
| `src/validate_data_asset_scorecards_ab1574.py` | Data asset scorecards |
| `src/validate_ownership_security_ab1577.py` | Security model and data governance plan |
| `src/validate_powerbi_gold_connection_ab1582.py` | Power BI gold connection notes |
| `src/validate_powerbi_relationships_ab1586.py` | Relationships and date table notes |
| `src/validate_measure_definitions_ab1590.py` | DAX measure definitions |
| `src/validate_powerbi_validation_log_ab1594.py` | DAX-to-SQL validation log |
| `src/validate_executive_overview_ab1599.py` | Executive Overview screenshot |
| `src/validate_patient_flow_los_ab1602.py` | Patient Flow and LOS screenshots |
| `src/validate_readmissions_ab1605.py` | Readmissions screenshot |
| `src/validate_conditions_procedures_ab1608.py` | Conditions & Procedures screenshot |
| `src/validate_lab_operations_ab1611.py` | Lab / Observation Operations screenshot |
| `src/validate_data_quality_governance_ab1614.py` | Data Quality & Governance screenshot |
| `src/validate_dashboard_walkthrough_ab1622.py` | Screenshot walkthrough documentation |
| `src/validate_dashboard_walkthrough_ab1625.py` | Dashboard interpretation notes |
| `src/validate_report_design_checklist_ab1628.py` | Report UX and accessibility checklist |

## 11. Repository Safety

Sprint 6 followed the portfolio safety rules:

- Do not commit `.pbix` files.
- Do not commit credentials, `.env` files, connection strings, local database backups, or raw generated data.
- Commit Power BI screenshot evidence instead of the report file.
- Keep dashboard screenshots aggregate and reviewer-safe.
- Clearly mark synthetic Synthea data.
- Do not claim clinical decision support.
- Do not imply FHIR/API functionality was implemented when it was deferred.

## 12. Key Design Decisions

| Decision | Rationale |
|---|---|
| Use screenshots as committed Power BI evidence | Avoids committing `.pbix` while still showing report results. |
| Use focused `2000-2026` dashboard window | Improves readability of trends in screenshots. |
| Use dark dashboard theme | Creates consistent, polished portfolio visuals. |
| Use page-specific slicers | Avoids slicers that do not affect visuals. |
| Defer FHIR/API page | Prevents overstating unimplemented interoperability scope. |
| Keep Data Quality & Governance page transparent | Shows known quality findings rather than hiding them. |

## 13. Known Limitations

- The `.pbix` file remains local and is not included in the repository.
- Static screenshots do not capture every interactive slicer behavior.
- The dashboards use synthetic Synthea data and do not reflect real hospital operations.
- Readmission logic is simplified and does not distinguish planned from unplanned readmissions.
- Observation volume includes a governed duplicate-record caveat.
- Full accessibility certification is not claimed.
- FHIR/API interoperability is deferred from v1.0.

## 14. Sprint 6 Final Status

Sprint 6 is complete.

ClinicalPulse v1.0 is now a governed healthcare BI portfolio project with:

- SQL Server medallion-style architecture
- gold-layer reporting model
- documented KPI definitions
- DAX-to-SQL validation evidence
- Power BI dashboard screenshots
- data quality and governance transparency
- screenshot walkthrough documentation
- non-technical dashboard interpretation notes
- final report design checklist

## 15. Suggested Pull Request Summary

```text
Completed Sprint 6 Power BI reporting scope for ClinicalPulse.

This PR adds the final Power BI reporting documentation, semantic model notes, DAX measure definitions, DAX-to-SQL validation log, dashboard screenshot evidence, dashboard walkthrough notes, and report design checklist. The final v1.0 report scope includes Executive Overview, Patient Flow, Length of Stay, Readmissions, Conditions & Procedures, Lab / Observation Operations, and Data Quality & Governance pages.

FHIR/API interoperability and optional pipeline hardening are deferred from v1.0 and documented as future scope. The `.pbix` file remains local and is not committed.
```

## 16. Suggested Azure Boards Closing Note

```text
Sprint 6 Power BI Reporting completed.

Completed gold-layer Power BI connection documentation, relationships/date-table documentation, measure definitions, DAX-to-SQL validation, dashboard screenshots, screenshot walkthrough documentation, dashboard interpretation notes, and report UX/accessibility checklist.

Final committed screenshot set covers Executive Overview, Patient Flow, Length of Stay, Readmissions, Conditions & Procedures, Lab / Observation Operations, and Data Quality & Governance.

FHIR/API demonstration and optional pipeline hardening were deferred from ClinicalPulse v1.0 and remain future scope. The project is closed as a governed SQL Server + Power BI hospital BI platform using synthetic Synthea data.
```
