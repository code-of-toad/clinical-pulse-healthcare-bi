# ClinicalPulse Feedback and Change-Control Process

## 1. Purpose

This document defines how feedback, defects, and future change requests for ClinicalPulse should be submitted, reviewed, approved, implemented, documented, and released.

The process is intended to preserve:

- stable KPI meaning
- trustworthy dashboard behavior
- traceability from request to committed artifact
- alignment between SQL Server, Power BI, and governance documentation
- public portfolio safety
- honest representation of implemented scope

ClinicalPulse is a synthetic-data portfolio project. This process models a professional governance approach and does not claim an active production support function or real hospital change-advisory board.

## 2. Scope

This process applies to changes affecting:

- KPI definitions
- SQL Server bronze, silver, gold, governance, or audit objects
- data quality rules and reporting-trust logic
- Power BI semantic model relationships
- DAX measures
- dashboard pages, visuals, filters, labels, and tooltips
- architecture, lineage, asset catalog, scorecards, and security documentation
- README and public portfolio materials
- screenshots and release evidence
- repository structure and delivery documentation

The process does not cover the deferred FHIR/API component or optional pipeline hardening unless those items are explicitly brought back into scope through a future approved release.

## 3. Change-Control Principles

| Principle | Application |
|---|---|
| Traceability | Every material change should link to an Azure DevOps work item or equivalent tracked request. |
| Business justification | Changes should solve a documented business, governance, technical, usability, or safety need. |
| KPI stability | Metric meaning should not change silently after use in dashboards or documentation. |
| Gold-layer authority | Reporting logic should remain anchored in governed gold-layer assets. |
| Documentation parity | Code, Power BI, and documentation should describe the same implemented state. |
| Evidence before release | Material changes should include review evidence appropriate to their impact. |
| Safety first | Credentials, raw data, `.pbix`, backups, and unsafe screenshots must remain excluded from Git. |
| Honest scope | Deferred or unimplemented components must not be presented as completed. |
| Proportional review | Low-risk documentation fixes should not require the same review as KPI or data-model changes. |

## 4. Roles

| Role | Change-control responsibility |
|---|---|
| Project Owner | Owns intake, prioritization, scope control, release coordination, and public portfolio accuracy |
| Operational Reporting Owner | Reviews business value and approves changes to KPI meaning or dashboard purpose |
| Data Steward | Reviews KPI definitions, lineage, quality dependencies, ownership, and limitations |
| BI Developer | Assesses and implements semantic-model, DAX, report, and usability changes |
| Data Platform Owner | Assesses and implements ingestion, SQL transformation, gold-layer, audit, and quality-rule changes |
| Security / Portfolio Reviewer | Reviews public-release safety, excluded artifacts, screenshots, credentials, and claims |
| Requester | Provides the issue, business impact, supporting evidence, and expected outcome |

These are modeled project roles and do not imply formally staffed hospital governance positions.

## 5. Feedback Intake

### 5.1 Approved intake channels

Feedback should be captured through one of the following:

- Azure DevOps user story, bug, task, or issue
- GitHub issue
- pull-request review comment
- structured review note converted into a tracked work item

Material requests should not remain only in chat, email, or informal notes.

### 5.2 Required intake fields

Each request should include:

| Field | Required content |
|---|---|
| Title | Concise description of the requested change |
| Requester role | Business, governance, technical, or portfolio perspective |
| Change category | KPI, data model, data quality, Power BI, documentation, security, repository, or enhancement |
| Affected asset | Specific page, measure, SQL object, document, screenshot, or folder |
| Current behavior | What currently exists |
| Requested outcome | What should change |
| Business or governance reason | Why the change matters |
| Evidence | Screenshot, query result, reproduction steps, or supporting documentation |
| Urgency | Critical, high, normal, or low |
| Scope impact | Expected downstream assets or users |
| Acceptance criteria | Observable conditions required for completion |

## 6. Change Categories

| Category | Examples |
|---|---|
| Defect | Incorrect calculation, broken filter, invalid relationship, missing data, misleading label |
| KPI definition | Formula, numerator, denominator, grain, inclusion, exclusion, owner, or limitation change |
| Data model | New or changed table, column, key, relationship, dimension, fact, or mart |
| Data quality | New rule, rule threshold, severity, failed-check treatment, or quality finding |
| Power BI | New measure, visual, filter, page, interaction, tooltip, formatting, or navigation |
| Documentation | Incorrect path, outdated scope, missing explanation, broken link, or inconsistent wording |
| Security / portfolio safety | Exposed data, credential, local path, unsafe screenshot, unsupported claim, or excluded file |
| Enhancement | New analytical question, new dimension, new page, or expanded reporting scope |
| Release / repository | Folder structure, tagging, evidence checklist, README, or final package update |

## 7. Priority and Severity

### 7.1 Priority

| Priority | Meaning |
|---|---|
| Critical | Public safety, credential exposure, major incorrect KPI, or unusable core report |
| High | Material reporting defect, KPI inconsistency, or governance gap affecting trust |
| Normal | Planned usability, documentation, model, or enhancement work |
| Low | Cosmetic improvement or non-urgent refinement |

### 7.2 Severity guidance

| Severity | Example |
|---|---|
| Critical | Secret committed, raw data exposed, materially incorrect executive KPI |
| High | Broken core filter, incorrect readmission denominator, gold-to-DAX mismatch |
| Medium | Ambiguous label, incomplete lineage, missing limitation, non-core visual defect |
| Low | Formatting, wording, minor layout, or optional documentation enhancement |

Priority reflects when the work should be addressed. Severity reflects the impact of the issue.

## 8. Impact Assessment

Before approval, evaluate the request across the following areas:

| Impact area | Review question |
|---|---|
| Business meaning | Does the request change what a KPI or visual means? |
| Data logic | Does it change ingestion, transformation, grain, keys, filters, or calculations? |
| Power BI | Does it change relationships, measures, page behavior, or visible outputs? |
| Governance | Does it affect ownership, lineage, quality rules, limitations, or readiness status? |
| Historical comparability | Would prior screenshots or reported values become non-comparable? |
| Security | Could the change expose identifiers, credentials, paths, or embedded data? |
| Documentation | Which documents must be updated to remain consistent? |
| Scope | Does the request expand beyond governed hospital BI v1.0? |
| Effort and risk | What is the implementation effort and likelihood of unintended impact? |

## 9. Change Classes

| Class | Typical examples | Required review |
|---|---|---|
| Class 1 — Editorial | Typo, broken link, wording clarification, formatting | Project Owner |
| Class 2 — Presentation | Visual title, layout, tooltip, color-independent readability, navigation | BI Developer and Operational Reporting Owner |
| Class 3 — Technical non-semantic | Refactor without changing outputs, repository cleanup, documentation restructure | Relevant technical owner |
| Class 4 — KPI or model change | Formula, relationship, grain, exclusion, fact, mart, or DAX change | Project Owner, Data Steward, relevant technical owner, Operational Reporting Owner |
| Class 5 — Safety or scope change | Exposed artifact, credential risk, new major component, public-claim change | Project Owner and Security / Portfolio Reviewer; additional owners as needed |

## 10. Approval Matrix

| Change type | Required approver(s) |
|---|---|
| Editorial documentation correction | Project Owner |
| Dashboard presentation change | BI Developer and Operational Reporting Owner |
| KPI wording clarification without calculation change | Data Steward and Operational Reporting Owner |
| KPI formula, grain, denominator, inclusion, or exclusion change | Data Steward, Operational Reporting Owner, BI Developer, Data Platform Owner |
| SQL transformation or gold-model change | Data Platform Owner, Data Steward, BI Developer when reporting is affected |
| Data quality rule or severity change | Data Steward and Data Platform Owner |
| Security or public portfolio change | Project Owner and Security / Portfolio Reviewer |
| New dashboard page or reporting domain | Project Owner, Operational Reporting Owner, Data Steward, BI Developer |
| Reintroducing FHIR/API or pipeline hardening | Project Owner through explicit scope and release approval |

For this portfolio implementation, the project owner may perform multiple modeled roles, but the review responsibilities should still be considered separately.

## 11. Standard Workflow

### 11.1 Intake

1. Create or update the tracked work item.
2. Record all required intake fields.
3. Attach evidence or reproduction steps.
4. Assign an initial category, priority, and owner.

### 11.2 Triage

1. Confirm that the issue is reproducible or the request is understandable.
2. Determine whether it is a defect, governance change, safety issue, or enhancement.
3. Identify affected assets and dependencies.
4. Assign the change class.
5. Reject, defer, request clarification, or send for impact assessment.

### 11.3 Impact assessment

1. Review business and KPI implications.
2. Review SQL and semantic-model implications.
3. Identify required documentation updates.
4. Review portfolio-safety implications.
5. Define acceptance criteria.
6. Estimate effort and release timing.

### 11.4 Approval

1. Obtain the approvers required by the change class.
2. Record the decision in the work item.
3. Record rejected alternatives or unresolved assumptions where material.
4. Move approved work into implementation.

### 11.5 Implementation

1. Work on an appropriately named branch.
2. Update the implementation artifact.
3. Update all dependent documentation.
4. Preserve existing naming, scope, and safety conventions.
5. Reference the work item in the commit or pull request.

### 11.6 Review

The reviewer should confirm:

- acceptance criteria are satisfied
- KPI meaning is documented
- SQL and DAX logic remain aligned
- screenshots and public artifacts are safe
- assumptions and limitations are updated
- deferred scope is not misrepresented
- changed paths and links are valid
- repository artifacts match the stated release

### 11.7 Release

1. Merge the approved change.
2. Update release notes or the evidence checklist when material.
3. Replace affected screenshots if visible outputs changed.
4. Communicate interpretation changes.
5. Tag the release when appropriate.
6. Close the work item with links to the commit, pull request, or artifacts.

## 12. KPI Change Procedure

A KPI change is material when it affects any of the following:

- business question
- plain-language definition
- formula
- numerator or denominator
- grain
- inclusion or exclusion criteria
- date logic
- source objects
- DAX measure
- validation query
- owner or steward
- limitation or data quality dependency

For a material KPI change:

1. Update the KPI dictionary first or as part of the same change.
2. Update SQL logic or source objects.
3. Update the DAX measure.
4. Reconcile the new result against SQL.
5. Update related lineage.
6. Update dashboard labels, tooltips, and user guidance.
7. State whether historical values are comparable.
8. Replace screenshots where the displayed value or meaning changed.
9. Record the change in release documentation.

KPI names should remain stable unless the existing name is misleading.

## 13. Power BI Change Procedure

For semantic-model or report changes:

1. Identify the affected gold assets.
2. Confirm relationship cardinality, direction, and active/inactive status.
3. Confirm date-table behavior.
4. Review impacted DAX measures.
5. Review page and visual filter behavior.
6. Confirm the change does not create unintended cross-filtering.
7. Update `powerbi/semantic_model_notes.md` when model behavior changes.
8. Update `powerbi/measure_definitions.md` when DAX changes.
9. Update `docs/dashboard_user_guide.md` when users will experience different behavior.
10. Update screenshots and walkthrough documentation where visible outputs change.
11. Keep the `.pbix` local and excluded from Git.

## 14. SQL and Data-Quality Change Procedure

For SQL Server or quality-rule changes:

1. Identify the source, bronze, silver, gold, governance, or audit objects affected.
2. Confirm the intended grain and keys.
3. Preserve lineage fields where applicable.
4. Review downstream marts and measures.
5. Review row-count and quality implications.
6. Document any newly discovered finding rather than hiding it.
7. Update the database schema inventory when table or column structure changes.
8. Update lineage, catalog, scorecards, and KPI sources where affected.
9. Confirm Power BI still uses governed gold-layer assets only.

## 15. Documentation Change Procedure

A documentation change should be reviewed for:

- correct intended audience
- correct artifact paths
- implemented rather than planned scope
- current KPI and object names
- consistency with README, architecture, lineage, and dashboard guidance
- synthetic-data disclaimer
- assumptions and limitations
- absence of unnecessary sprint language in end-user-facing documents
- absence of unsupported production, compliance, or clinical claims

## 16. Security and Portfolio-Safety Escalation

The following require immediate review:

- raw data committed or staged
- `.pbix`, `.bak`, `.env`, or credential file committed or staged
- passwords, tokens, or connection strings exposed
- screenshots showing local paths, credentials, server details, or unnecessary row-level identifiers
- documentation implying real patient data, production hospital use, clinical decision support, or compliance certification
- FHIR/API or pipeline hardening presented as completed when still excluded

Immediate actions:

1. Stop the release.
2. Remove the artifact from the working tree and staging area.
3. Determine whether it entered Git history.
4. Rotate any exposed secret.
5. clean Git history if required
6. document the incident and corrective action
7. re-review the release package before publication

## 17. Change Record Template

Use the following structure in Azure DevOps, GitHub, or release documentation:

```text
Change ID:
Title:
Requester / role:
Date submitted:
Category:
Priority:
Severity:
Affected assets:
Current behavior:
Requested outcome:
Business or governance reason:
Evidence:
Change class:
Impact assessment:
Approvers:
Decision:
Implementation summary:
Documentation updated:
Validation / review evidence:
Assumptions:
Limitations:
Commit / pull request:
Release:
Status:
```

## 18. Definition of Ready

A change is ready for implementation when:

- the problem or request is clear
- the affected assets are identified
- acceptance criteria are defined
- the change class is assigned
- major dependencies are known
- required approvers are identified
- scope and safety implications are understood
- unresolved questions do not prevent implementation

## 19. Definition of Done

A change is complete when:

- implementation matches approved acceptance criteria
- dependent SQL, Power BI, and documentation artifacts are updated
- KPI or semantic changes are reconciled where applicable
- assumptions and limitations are documented
- public portfolio safety has been reviewed
- the work item links to the committed artifact
- visible changes are reflected in screenshots or guidance
- the change is included in release evidence where material
- no excluded artifacts were committed

## 20. Change Statuses

| Status | Meaning |
|---|---|
| Submitted | Request has been recorded |
| Triage | Category, priority, and ownership are being assessed |
| Needs clarification | Request lacks sufficient detail |
| Impact assessment | Downstream effects and required review are being evaluated |
| Approved | Change is authorized for implementation |
| Deferred | Valid request postponed to a later release |
| Rejected | Request will not proceed and rationale is recorded |
| In progress | Implementation is underway |
| In review | Acceptance criteria and dependent artifacts are being checked |
| Ready for release | Approved change is complete and awaiting release |
| Released | Change is included in a committed or tagged version |
| Closed | Work item contains final evidence and decision |

## 21. Release Communication

For material changes, release communication should state:

- what changed
- why it changed
- which assets are affected
- whether KPI meaning or historical comparability changed
- which screenshots or documentation were replaced
- known limitations
- excluded scope
- work item, commit, pull request, and release tag

## 22. Review Cadence

For the completed portfolio project:

- review critical safety or correctness issues immediately
- review KPI and model changes before release
- batch low-risk presentation and documentation improvements where practical
- review README, architecture, screenshots, and portfolio-safety claims before each public release
- conduct a full documentation consistency review before the final release tag

A production environment would require an organization-defined support model and formal change calendar.

## 23. Metrics for the Process

The following may be tracked for future releases:

| Measure | Purpose |
|---|---|
| Requests by category | Understand the types of changes being submitted |
| Requests approved, deferred, and rejected | Show scope and prioritization discipline |
| Material changes with traceable work items | Measure governance completeness |
| KPI changes with updated dictionary and validation evidence | Measure metric-control completeness |
| Releases with completed safety review | Measure public portfolio discipline |
| Reopened defects | Identify incomplete review or implementation |
| Documentation inconsistencies found during release review | Identify maintenance gaps |

These are proposed process measures and are not presented as achieved operational results.

## 24. Assumptions

- Azure DevOps remains the primary work-tracking system.
- Git and GitHub remain the version-control and public-delivery systems.
- One person may perform several modeled roles in this portfolio project.
- The local Power BI `.pbix` is not committed.
- SQL Server gold-layer assets remain the authoritative Power BI source.
- Documentation is updated in the same change when meaning or visible behavior changes.
- The process applies to future maintenance after the initial ClinicalPulse release.

## 25. Limitations

- This process is documentation-led and does not enforce workflow states automatically.
- No production service desk, enterprise change board, or formal segregation of duties exists.
- Azure DevOps approvals and GitHub branch protections may vary by repository configuration.
- Real healthcare deployment would require organizational privacy, security, clinical, operational, accessibility, and regulatory review.
- This process does not certify ClinicalPulse for production use.
- The FHIR/API component and optional pipeline hardening remain outside the completed scope.
