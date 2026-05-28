# ClinicalPulse Azure Boards Excel Tree-Import CSV Package

This package is built for the Excel tree-list method, not the Azure Boards web CSV importer.

## Main files

Use these from `import_csv/`:

1. `00_pilot_branch_tree_import.csv`  
   Publish this first to verify that your Excel tree-list setup works.

2. `01_all_items_tree_import_feature_and_story_criteria.csv`  
   Main file. Includes Feature-level success criteria and User Story acceptance criteria.

3. `02_all_items_tree_import_story_criteria_only.csv`  
   Fallback file if your Azure Boards process rejects `Acceptance Criteria` on Feature work items.

4. `by_epic/*.csv`  
   One Epic branch per file. Use these if you want to publish in manageable chunks.

## Required Excel tree-list shape

Create a connected Excel work item list, then add tree levels until the sheet has four title columns:

- `Title 1` for Epics
- `Title 2` for Features
- `Title 3` for User Stories
- `Title 4` for Tasks

Each CSV row has exactly one populated title column. Do not sort the sheet before publishing.

## Recommended workflow

1. Create the ClinicalPulse Azure DevOps project using the Agile process.
2. Open Excel on Windows.
3. Go to `Team > New List` and connect to the ClinicalPulse project.
4. Choose an input list.
5. Add tree levels until the sheet has `Title 1`, `Title 2`, `Title 3`, and `Title 4`.
6. Add these fields/columns if missing: `Work Item Type`, `State`, `Description`, `Acceptance Criteria`, `Tags`.
7. Paste rows from `00_pilot_branch_tree_import.csv` first.
8. Publish.
9. Verify the hierarchy in Azure Boards: Epic > Feature > User Story > Task.
10. If the pilot succeeds, publish either the full import file or the individual `by_epic` files one branch at a time.
11. After import, assign Area Paths and Iteration Paths using `reference_csv/planned_area_iteration_reference.csv`.

## Expected final count

- 9 Epics
- 27 Features
- 97 User Stories
- 238 Tasks
- 371 total work items

## Notes

- Do not use the web CSV importer for these tree files.
- Do not include an Azure DevOps `ID` column for new work items.
- If Feature-level Acceptance Criteria causes a publish error, use the story-only fallback file and keep `reference_csv/feature_success_criteria.csv` as your planning reference.
