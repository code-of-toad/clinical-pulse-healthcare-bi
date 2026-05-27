# ClinicalPulse Azure DevOps Backlog Structure

## Purpose

This document records the Azure DevOps backlog structure used to plan, track, and connect ClinicalPulse work items to repository artifacts.

## Project Metadata

| Field | Value |
|---|---|
| Project | ClinicalPulse |
| Work Item | AB#1375 — Create Azure DevOps project structure |
| Area Path | ClinicalPulse\\Governance and Planning |
| Iteration Path | ClinicalPulse\\Sprint 0 - Project Setup |
| Deliverable | `azure-devops/backlog.md` |

## Azure Boards Hierarchy

ClinicalPulse uses the following work item hierarchy:

```text
Epic
└── Feature
    └── User Story
        └── Task
```

| Level | Purpose |
|---|---|
| Epic | Major project delivery area |
| Feature | Group of related capabilities |
| User Story | Deliverable-sized unit of work with acceptance criteria |
| Task | Concrete implementation or validation step |

## Repository Location

Azure DevOps planning documentation is stored under:

```text
azure-devops/
```

This document is located at:

```text
azure-devops/backlog.md
```

## Traceability

Work connected to this artifact should reference the Azure Boards work item in the Git commit message.

Traceability chain:

```text
Azure Boards User Story AB#1375
→ Tasks AB#1376 and AB#1377
→ Repository artifact azure-devops/backlog.md
→ Git commit referencing AB#1375
```

## Assumptions and Limitations

- Azure Boards is the system of record for work item state.
- GitHub stores implementation and documentation artifacts.
- This document records the backlog structure; it does not duplicate the full Azure Boards backlog.
- Detailed epic, feature, sprint cadence, and tag definitions are documented separately.
- This structure may be revised if the ClinicalPulse delivery plan changes.
