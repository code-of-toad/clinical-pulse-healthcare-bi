# ClinicalPulse Stakeholder Matrix

## 1. Purpose

This stakeholder matrix identifies the primary users, owners, stewards, reviewers, and consumers involved in ClinicalPulse. It clarifies who the platform is designed for, what each stakeholder group cares about, and how each group relates to governance, reporting trust, and project delivery.

ClinicalPulse is a portfolio-grade healthcare BI platform using synthetic EHR data. The stakeholder model is therefore representative rather than tied to a real hospital organization.

## 2. Stakeholder Groups

| Stakeholder Group | Primary Interest | Role in ClinicalPulse |
|---|---|---|
| Executive leaders | High-level operational visibility and reporting trust | Review strategic KPI summaries, operational trends, and data quality indicators. |
| Operational managers | Patient flow, length of stay, service demand, and operational pressure points | Use dashboards to understand activity patterns and identify areas requiring follow-up. |
| BI developers | Reliable reporting layer, semantic model, SQL logic, and dashboard implementation | Build SQL transformations, Power BI measures, validation queries, and dashboard assets. |
| Data stewards | KPI consistency, data quality, lineage, and documentation completeness | Review definitions, rule coverage, quality results, and known limitations. |
| Analytics stakeholders | Translation of business questions into reporting requirements | Validate whether the dashboards and metrics answer the intended analytical questions. |
| Interoperability reviewers | FHIR-aligned resource mapping and API demonstration | Review how selected relational entities map to FHIR-style API resources. |
| Platform administrator | Secure configuration, repository hygiene, and operational setup | Support environment assumptions, connection handling, and safe project configuration. |
| Portfolio reviewers | Project clarity, professional relevance, and implementation quality | Assess the project as evidence of healthcare BI, governance, data modeling, and delivery discipline. |

## 3. Stakeholder Responsibility Matrix

| Stakeholder Group | Key Responsibilities | Decisions or Inputs Owned | Main Outputs Reviewed |
|---|---|---|---|
| Executive leaders | Define high-level reporting priorities and interpret operational summaries. | Priority KPI domains, executive reporting needs, tolerance for summarized views. | Executive dashboard, KPI summary, data quality scorecard. |
| Operational managers | Provide operational context for patient flow, LOS, service utilization, and lab activity. | Reporting questions, useful slicers, operational definitions, dashboard usability feedback. | Patient flow dashboard, LOS analysis, utilization views, lab operations page. |
| BI developers | Implement SQL layers, Power BI model, DAX measures, validation queries, and documentation links. | Technical design choices, transformation logic, report model structure, measure implementation. | SQL scripts, gold tables/views, Power BI model, measure documentation. |
| Data stewards | Maintain governed definitions, quality rules, lineage, and issue visibility. | KPI definitions, data quality rules, validation requirements, known limitations. | KPI dictionary, data governance plan, data quality outputs, lineage documentation. |
| Analytics stakeholders | Confirm that requirements reflect real analytical needs in business language. | Business requirements, reporting acceptance expectations, question prioritization. | Business requirements document, dashboard pages, KPI definitions. |
| Interoperability reviewers | Evaluate whether selected entities are represented in FHIR-aligned form. | Resource mapping expectations, API demonstration boundaries, response-shape requirements. | FHIR mapping document, API reference, sample JSON responses. |
| Platform administrator | Protect credentials, local files, environment configuration, and repository safety. | Environment assumptions, .gitignore coverage, secrets-handling approach, local setup rules. | Security model, repository structure, configuration notes. |
| Portfolio reviewers | Evaluate whether the project communicates business value, technical skill, and governance maturity. | Reviewer expectations, portfolio clarity, documentation readability. | README, architecture overview, dashboard screenshots, final portfolio summary. |

## 4. RACI-Style Governance View

RACI labels:

- **R** = Responsible for producing or maintaining the artifact
- **A** = Accountable for final interpretation or decision
- **C** = Consulted for input
- **I** = Informed as a consumer or reviewer

| Artifact / Decision Area | Executive Leaders | Operational Managers | BI Developers | Data Stewards | Analytics Stakeholders | Interoperability Reviewers | Platform Administrator | Portfolio Reviewers |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Project charter | A | C | R | C | C | I | I | I |
| Business requirements | C | A | C | C | R | I | I | I |
| Stakeholder matrix | I | C | R | A | C | I | I | I |
| KPI dictionary | C | C | R | A | C | I | I | I |
| Data governance plan | I | C | C | A | C | I | C | I |
| Data quality rules | I | C | R | A | C | I | I | I |
| SQL medallion layers | I | I | A/R | C | I | I | C | I |
| Power BI dashboard | C | A | R | C | C | I | I | I |
| FHIR mapping and API demonstration | I | I | R | C | I | A/C | C | I |
| Security and public portfolio safety | I | I | C | C | I | I | A/R | I |
| README and portfolio presentation | I | I | R | C | I | C | C | A |

## 5. Stakeholder Needs by Reporting Domain

| Reporting Domain | Primary Stakeholders | Business Need |
|---|---|---|
| Executive overview | Executive leaders, portfolio reviewers | Summarize operational health, major trends, and reporting trust indicators. |
| Patient flow | Operational managers, analytics stakeholders | Understand encounter volume, encounter class patterns, and operational pressure points. |
| Length of stay | Operational managers, executive leaders, data stewards | Monitor encounter duration while ensuring invalid or incomplete timing data is handled consistently. |
| Readmissions | Executive leaders, operational managers, data stewards | Track follow-up encounters using documented readmission assumptions and clear eligibility rules. |
| Service utilization | Operational managers, analytics stakeholders | Identify procedure, condition, and encounter patterns that contribute to operational demand. |
| Lab / observation operations | Operational managers, data stewards | Monitor observation volume and identify where data quality issues may affect reporting interpretation. |
| Data quality and governance | Data stewards, BI developers, portfolio reviewers | Show whether reporting assets are documented, validated, and trustworthy. |
| FHIR API demonstration | Interoperability reviewers, BI developers, portfolio reviewers | Demonstrate how selected SQL entities can be represented as FHIR-style JSON resources. |

## 6. Communication and Review Expectations

| Stakeholder Group | Expected Communication Need | Suitable Project Artifact |
|---|---|---|
| Executive leaders | Concise summary of operational KPIs and trust indicators. | Executive dashboard, KPI summary, data quality scorecard. |
| Operational managers | Clear operational views with usable filters and business-language definitions. | Power BI dashboards, business requirements document, KPI dictionary. |
| BI developers | Technical implementation details and source-to-report traceability. | SQL scripts, architecture overview, lineage documentation, measure definitions. |
| Data stewards | Governed definitions, data quality rules, ownership, and limitations. | KPI dictionary, data governance plan, data asset scorecards. |
| Analytics stakeholders | Confirmation that reporting outputs answer the intended questions. | Business requirements document, dashboard pages, KPI dictionary. |
| Interoperability reviewers | Clear API boundaries and FHIR-style mapping rationale. | FHIR mapping document, API reference, sample responses. |
| Platform administrator | Safe repository structure and secure configuration expectations. | Security model, .gitignore, setup notes. |
| Portfolio reviewers | Clear explanation of project value and professional relevance. | README, architecture overview, dashboard screenshots, final project summary. |

## 7. Assumptions

- Stakeholder groups are representative roles for a simulated hospital BI environment.
- One person may fill multiple roles during project development, especially in a portfolio project.
- ClinicalPulse uses synthetic data and does not represent a real hospital, real patients, or a real production reporting program.
- The matrix is intended to guide documentation, reporting design, governance decisions, and reviewer interpretation.
- The FHIR/API stakeholder role is limited to reviewing demonstration-level interoperability concepts, not production FHIR compliance.

## 8. Limitations

- This matrix does not define real organizational job descriptions or reporting lines.
- RACI assignments are simplified for project clarity and may differ from a production hospital environment.
- Stakeholder needs are based on the ClinicalPulse project scope rather than live stakeholder interviews.
- Access control responsibilities are documented as assumptions and are not a substitute for enterprise identity, security, or privacy governance.
- The matrix should be updated if the project scope expands to include additional domains such as medications, payers, care plans, predictive modeling, or production-grade API capabilities.
