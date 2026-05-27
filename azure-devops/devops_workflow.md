# ClinicalPulse DevOps Workflow

## Purpose

This document defines the lightweight workflow used to connect GitHub activity with Azure Boards work items for ClinicalPulse. Azure Boards tracks planning and work status; GitHub stores committed project artifacts.

## Scope

This workflow applies to project documentation, SQL scripts, Python scripts, Power BI documentation, API code, and repository configuration files.

## Systems of Record

| System | Role |
|---|---|
| Azure Boards | Epics, features, user stories, tasks, sprint planning, and work item state |
| GitHub | Version-controlled code, documentation, and repository artifacts |

## Work Item Traceability

Work connected to an Azure Boards item should reference the relevant work item ID using:

```text
AB#<work-item-id>
```

Examples:

```text
Create Azure DevOps backlog structure artifact AB#1375
Define ClinicalPulse sprint plan and tagging conventions AB#1378
Document GitHub and Azure Boards traceability conventions AB#1381
```

## Branching Convention

Use `main` as the stable branch. Create short-lived feature branches for deliverable work.

```text
main
feature/ab-<work-item-id>-<short-description>
```

Examples:

```text
feature/ab-1375-backlog-structure
feature/ab-1378-sprint-plan
feature/ab-1381-devops-workflow
```

## Commit Convention

Use concise commit messages that describe the completed change and include the Azure Boards reference.

```text
<change summary> AB#<work-item-id>
```

Examples:

```text
Create project charter AB#1401
Add SQL Server schema setup scripts AB#1420
Document KPI dictionary assumptions AB#1452
```

## Pull Request Convention

Pull requests are used to practice a professional review workflow, even when the project is maintained by one developer.

| PR Field | Convention |
|---|---|
| Title | Summarize the deliverable and include the main Azure Boards ID |
| Description | State what changed and list the affected artifact paths |
| Review focus | Confirm that the artifact satisfies the relevant acceptance criteria |
| Merge target | Merge completed work into `main` |

## Work Item State Convention

Use a simple work item flow:

```text
New → Active → Closed
```

For user stories with child tasks:

1. Move the draft/build task to `Closed` after the deliverable exists.
2. Move the validate/document task to `Closed` after the deliverable is checked against the acceptance criteria.
3. Move the user story to `Closed` only after the required artifact is committed and traceable.

## Artifact Traceability Chain

ClinicalPulse work should be traceable through the following chain:

```text
Azure Boards User Story
→ Azure Boards Tasks
→ GitHub feature branch
→ Git commits referencing AB# ID
→ Repository artifact
→ Pull request or merge into main
```

## Assumptions and Limitations

- Azure Boards is the source of truth for work item status.
- GitHub is the source of truth for committed repository artifacts.
- The project uses a lightweight solo-developer workflow modeled after professional team practices.
- Pull requests may be used for review discipline even when there is no external reviewer.
- Azure Pipelines are optional unless later project work introduces automated checks.
