# ClinicalPulse Azure Boards CSV Package with Area/Iteration Path Tags

This package is the same tree-shaped CSV import package as before, with two additional tags appended to every work item:

- `AP-<Area Path>`
- `IP-<Iteration Path>`

These tags let you query/filter work items after import and bulk-assign `Area Path` and `Iteration Path` with confidence.

## Main import files

- `import_csv/00_pilot_branch_tree_import.csv` — use first as a small test import.
- `import_csv/01_all_items_tree_import_feature_and_story_criteria.csv` — full 371-item import with Feature and User Story acceptance criteria.
- `import_csv/02_all_items_tree_import_story_criteria_only.csv` — fallback if Feature-level acceptance criteria is rejected.
- `import_csv/by_epic/*.csv` — safer one-Epic-at-a-time imports.

## New reference files

- `reference_csv/path_tag_assignment_reference.csv` — exact Area Path and Iteration Path tag assigned to every work item.
- `reference_csv/path_tag_validation_report.csv` — confirms that every import row has both AP and IP tags.

## Assignment policy for sprint ranges

Some original backlog items were labeled with range sprints such as `Sprint 0-1`, `Sprint 4-5`, or `Sprint 4-6`. Since Azure DevOps work items can only be assigned to one Iteration Path at a time, this package normalizes them into exact sprint paths:

- Sprint 0-1: DevOps setup items -> Sprint 0; governance/design artifacts -> Sprint 1.
- Sprint 4-5: silver-layer items -> Sprint 4; gold/model/mart items -> Sprint 5.
- Sprint 4-6: quality-rule framework -> Sprint 4; KPI validation -> Sprint 5; data asset/lineage/scorecard governance -> Sprint 6.

Epics that span ranges are assigned to the sprint where that Epic-level outcome is expected to be complete.

## Bulk assignment workflow

After importing work items, query by a tag such as:

`Tags Contains AP-ClinicalPulse\SQL Server`

Then bulk edit the selected items and set:

`Area Path = ClinicalPulse\SQL Server`

Similarly, query by:

`Tags Contains IP-ClinicalPulse\Sprint 3 - SQL Server Ingestion`

Then bulk edit and set:

`Iteration Path = ClinicalPulse\Sprint 3 - SQL Server Ingestion`
