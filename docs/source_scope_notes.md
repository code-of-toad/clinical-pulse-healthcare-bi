# Source Scope Notes

## Purpose

This document identifies Synthea source entities that are useful for future ClinicalPulse expansion but are intentionally outside the current core implementation scope.

The goal is to preserve a clear expansion path without weakening the first governed BI build. The current implementation focuses on hospital operational reporting around patients, encounters, conditions, observations, procedures, organizations, and providers.

## Current Core Source Scope

| Source File | Scope Status | Primary Use |
|---|---|---|
| `patients.csv` | Core | Patient demographics, age bands, death indicator, patient dimension |
| `encounters.csv` | Core | Encounter volume, encounter class, length of stay, readmission logic |
| `conditions.csv` | Core | Diagnosis context, cohorting, readmission breakdowns |
| `observations.csv` | Core | Lab and clinical observation activity, observation volume |
| `procedures.csv` | Core, limited | Procedure volume, service utilization, encounter complexity |
| `organizations.csv` | Core | Organization and facility reference context |
| `providers.csv` | Core, lightweight | Provider reference data and organization attribution |

## Optional Entities for Later Expansion

| Optional Entity | Scope Decision | Future Analytical Value | Reason Deferred |
|---|---|---|---|
| `medications.csv` | Defer | Medication utilization, prescribing patterns, treatment context, medication-related cohorting | Adds clinical complexity and requires careful medication grouping before it supports the operational BI focus |
| `careplans.csv` | Defer | Care pathway analysis, chronic-condition follow-up, planned care context | Useful for care-management analysis but not required for encounter flow, length of stay, readmissions, or lab operations |
| `payers.csv` | Defer | Payer mix, administrative context, coverage-related analysis | Secondary to hospital operational BI and may distract from the main governed reporting model |
| `allergies.csv` | Defer | Patient safety context, clinical profile enrichment | Not required for the selected operational dashboards or KPI definitions |
| `immunizations.csv` | Defer | Preventive care and population-health reporting | More relevant to ambulatory/population-health use cases than hospital operational BI |
| `imaging_studies.csv` | Defer | Imaging utilization and diagnostic services analysis | Adds domain-specific complexity and is not needed for the first service-utilization model |
| `devices.csv` | Defer | Device utilization and clinical equipment context | Not required for the selected patient-flow, readmission, lab, or service-utilization use cases |
| `supplies.csv` | Defer | Supply utilization and operational cost context | Useful for future operational expansion, but outside the current reporting focus |
| `claims.csv` or claim-related exports | Defer | Revenue-cycle, billing, payer, and reimbursement analysis | Financial and claims modeling would require a separate business scope and governance treatment |

## Expansion Priority

| Priority | Entity | Rationale |
|---:|---|---|
| 1 | `medications.csv` | Strong clinical context and useful for future medication-utilization reporting, but should be added only after the encounter and condition models are stable |
| 2 | `payers.csv` | Useful administrative dimension for payer-mix analysis and optional reporting slices |
| 3 | `careplans.csv` | Useful for care pathway and chronic-condition analysis once core patient and encounter modeling is complete |
| 4 | `imaging_studies.csv` | Useful for diagnostic service utilization if the project expands beyond general procedure reporting |
| 5 | `immunizations.csv`, `allergies.csv`, `devices.csv`, `supplies.csv` | Useful for specialized reporting scenarios, but not necessary for the current hospital operations BI focus |

## Decision Rules for Adding Optional Entities

An optional entity should be added only when it satisfies all of the following:

| Decision Rule | Requirement |
|---|---|
| Clear business question | The entity supports a specific reporting question or KPI |
| Defined source grain | The entity’s row-level meaning is understood before ingestion |
| Relationship path is clear | The entity can be traced to patient, encounter, organization, provider, or another governed entity |
| Data quality checks are defined | Completeness, validity, uniqueness, and relationship checks are known |
| Modeling impact is understood | Bronze, silver, gold, and Power BI model changes are documented |
| Governance impact is documented | KPI dictionary, lineage, scorecard, and limitations are updated |
| Public safety is preserved | No raw generated source data or unnecessary row-level detail is committed or exposed |

## Candidate Future Use Cases

### Medication Utilization

Potential entities:

```text
medications.csv
```

Possible questions:

- Which medication classes appear most frequently in the synthetic dataset?
- How does medication activity vary by encounter class or condition group?
- Which medications are associated with selected cohorts?

Required additions:

- Medication source profile
- Medication grouping logic
- Medication fact table or medication utilization mart
- Data quality checks for medication dates, codes, patient references, and encounter references
- Documentation that medication outputs are synthetic and not clinical guidance

### Payer Mix and Administrative Context

Potential entities:

```text
payers.csv
```

Possible questions:

- What payer categories appear in the synthetic population?
- How do encounters vary by payer category?
- How does payer context relate to synthetic claim-cost fields?

Required additions:

- Payer source profile
- Payer dimension
- Payer relationship validation
- Clear limitations on synthetic payer and cost interpretation

### Care Pathway Analysis

Potential entities:

```text
careplans.csv
```

Possible questions:

- Which care plans are most common in selected cohorts?
- How do care plans relate to chronic conditions?
- Which patients have recurring or long-running care pathways?

Required additions:

- Care plan source profile
- Care plan fact or bridge table
- Condition-to-care-plan relationship review
- Care pathway definitions and limitations

### Imaging and Diagnostic Service Utilization

Potential entities:

```text
imaging_studies.csv
```

Possible questions:

- How many imaging studies occur over time?
- Which imaging modalities are most common?
- How does imaging activity relate to encounter class or condition group?

Required additions:

- Imaging source profile
- Imaging utilization mart
- Code and modality grouping
- Relationship validation to patient and encounter records

## Out-of-Scope for the Current Core Build

The following are intentionally out of scope for the current core build:

- Medication prescribing dashboards
- Payer mix dashboards
- Claims, billing, or reimbursement analysis
- Care pathway analytics
- Imaging operations dashboards
- Device, supply, allergy, or immunization reporting
- Individual provider performance reporting
- Clinical decision support
- Real-world hospital benchmarking

## Governance Notes

Optional entities should not be added only because the files exist. Each expansion should be tied to a clear reporting question, defined KPI, documented lineage path, and validation approach.

Adding an optional entity may require updates to:

- `docs/source_file_inventory.md`
- `docs/source_entity_profile.md`
- `docs/data_lineage.md`
- `docs/kpi_dictionary.md`
- `docs/data_asset_catalog.md`
- `docs/data_asset_scorecards.md`
- SQL Server bronze, silver, and gold scripts
- Power BI semantic model documentation
- FHIR mapping documentation, if the entity is exposed through API outputs

## Assumptions and Limitations

This document reflects a scope-control decision, not a statement that the deferred entities lack value.

The deferred entities may still be generated locally by Synthea, but they are not part of the selected source inventory unless they are explicitly promoted into scope.

The current core build is intentionally centered on hospital operational BI: patient flow, encounter volume, length of stay, readmissions, service utilization, lab and observation activity, data quality, and reporting trust.

All source data remains synthetic. No outputs should be interpreted as representing real patients, real hospitals, Ontario health-system operations, Massachusetts health-system operations, or clinical recommendations.
