# Source Entity Profile

## Purpose

This document profiles the core Synthea CSV source files selected for ClinicalPulse. It summarizes each source entity, its row count, key fields, relationship fields, business-relevant fields, and implications for SQL Server ingestion, validation, and downstream reporting.

The profile is intended to help future maintainers understand the source data before bronze, silver, and gold modeling begins.

## Source Dataset Summary

| Item | Value |
|---|---|
| Source system | Synthea synthetic EHR data |
| Local raw data folder | `data/raw/synthea/` |
| Export format | CSV |
| Generation geography | Massachusetts, United States |
| Population setting | 1,000 living synthetic patients |
| Observed patient records | 1,145 total patients |
| Alive synthetic patients | 1,000 |
| Deceased synthetic patients | 145 |
| Synthea RNG | `1000` |
| Clinician RNG | `5643` |

## Entity Overview

| Source File | Row Count | Role in ClinicalPulse |
|---|---:|---|
| `patients.csv` | 1,145 | Patient demographics, patient dimension, age bands, death indicator |
| `encounters.csv` | 71,663 | Encounter volume, encounter class, start/stop timing, length of stay, readmission logic |
| `conditions.csv` | 43,758 | Diagnosis context, cohorting, condition group analysis |
| `observations.csv` | 945,531 | Lab and clinical observation activity, observation volume, abnormal/flagged-value analysis where applicable |
| `procedures.csv` | 196,207 | Procedure context, service utilization, encounter complexity |
| `organizations.csv` | 826 | Organization and facility reference context |
| `providers.csv` | 826 | Provider reference context and optional operational attribution |

## Entity Profiles

### `patients.csv`

| Attribute | Details |
|---|---|
| Row count | 1,145 |
| Expected main identifier | `Id` |
| Relationship role | Parent entity for encounters, conditions, observations, and procedures |
| Key fields | `Id`, `BIRTHDATE`, `DEATHDATE`, `RACE`, `ETHNICITY`, `GENDER`, `CITY`, `STATE`, `COUNTY`, `ZIP`, `LAT`, `LON` |
| Fields to protect or avoid exposing | `SSN`, `DRIVERS`, `PASSPORT`, full names, full address fields |
| Reporting use | Patient dimension, demographic breakdowns, age bands, deceased-patient flag, geography context |
| Modeling implication | Load as `bronze.patients`, standardize into `silver.patient`, and publish selected non-sensitive attributes through `gold.dim_patient` |

Columns:

```text
Id, BIRTHDATE, DEATHDATE, SSN, DRIVERS, PASSPORT, PREFIX, FIRST, MIDDLE, LAST, SUFFIX, MAIDEN, MARITAL, RACE, ETHNICITY, GENDER, BIRTHPLACE, ADDRESS, CITY, STATE, COUNTY, FIPS, ZIP, LAT, LON, HEALTHCARE_EXPENSES, HEALTHCARE_COVERAGE, INCOME
```

Profiling notes:

- `Id` is the source patient identifier and should be preserved for lineage.
- `BIRTHDATE` should be converted to a SQL Server date type and used to derive age and age bands.
- `DEATHDATE` supports deceased-patient flags and may be blank for living synthetic patients.
- Synthetic direct identifiers such as `SSN`, `DRIVERS`, `PASSPORT`, names, and address fields should not be exposed in public-facing reporting layers unless intentionally masked or excluded.
- Demographic and geography fields should be treated as synthetic simulation attributes, not as representative population statistics.

### `encounters.csv`

| Attribute | Details |
|---|---|
| Row count | 71,663 |
| Expected main identifier | `Id` |
| Relationship fields | `PATIENT`, `ORGANIZATION`, `PROVIDER`, `PAYER` |
| Key fields | `Id`, `START`, `STOP`, `PATIENT`, `ORGANIZATION`, `PROVIDER`, `ENCOUNTERCLASS`, `CODE`, `DESCRIPTION` |
| Cost fields | `BASE_ENCOUNTER_COST`, `TOTAL_CLAIM_COST`, `PAYER_COVERAGE` |
| Reporting use | Encounter volume, encounter class mix, length of stay, service utilization, readmission logic |
| Modeling implication | Core source for `silver.encounter`, `gold.fact_encounter`, patient-flow marts, length-of-stay marts, and readmission marts |

Columns:

```text
Id, START, STOP, PATIENT, ORGANIZATION, PROVIDER, PAYER, ENCOUNTERCLASS, CODE, DESCRIPTION, BASE_ENCOUNTER_COST, TOTAL_CLAIM_COST, PAYER_COVERAGE, REASONCODE, REASONDESCRIPTION
```

Profiling notes:

- `START` and `STOP` should be converted to SQL Server datetime types.
- Encounter duration and length of stay should be derived only after validating start/stop logic.
- `PATIENT` should join to `patients.Id`.
- `ORGANIZATION` should join to `organizations.Id`.
- `PROVIDER` should join to `providers.Id`.
- `ENCOUNTERCLASS`, `CODE`, and `DESCRIPTION` support encounter classification and dashboard slicing.
- `REASONCODE` and `REASONDESCRIPTION` may be useful for clinical context but should not be required for the first encounter fact.

### `conditions.csv`

| Attribute | Details |
|---|---|
| Row count | 43,758 |
| Expected main identifier | No single source row ID; use generated bronze row key plus source fields |
| Relationship fields | `PATIENT`, `ENCOUNTER` |
| Key fields | `START`, `STOP`, `PATIENT`, `ENCOUNTER`, `SYSTEM`, `CODE`, `DESCRIPTION` |
| Reporting use | Diagnosis context, cohorting, condition grouping, readmission breakdowns |
| Modeling implication | Load with a generated technical key, then standardize into `silver.condition` and `gold.fact_condition` |

Columns:

```text
START, STOP, PATIENT, ENCOUNTER, SYSTEM, CODE, DESCRIPTION
```

Profiling notes:

- `PATIENT` should join to `patients.Id`.
- `ENCOUNTER` should join to `encounters.Id` when present and valid.
- `START` and `STOP` support condition timing but may not always behave like encounter start/stop dates.
- `SYSTEM`, `CODE`, and `DESCRIPTION` define the clinical condition concept.
- Because the file does not include a single source row ID, bronze ingestion should create a technical row key and preserve source row position or row hash for lineage.

### `observations.csv`

| Attribute | Details |
|---|---|
| Row count | 945,531 |
| Expected main identifier | No single source row ID; use generated bronze row key plus source fields |
| Relationship fields | `PATIENT`, `ENCOUNTER` |
| Key fields | `DATE`, `PATIENT`, `ENCOUNTER`, `CATEGORY`, `CODE`, `DESCRIPTION`, `VALUE`, `UNITS`, `TYPE` |
| Reporting use | Observation volume, lab/clinical observation activity, operational load, selected abnormal or value-based analysis where feasible |
| Modeling implication | High-volume source requiring careful data typing, category handling, and value parsing before gold reporting |

Columns:

```text
DATE, PATIENT, ENCOUNTER, CATEGORY, CODE, DESCRIPTION, VALUE, UNITS, TYPE
```

Profiling notes:

- This is the largest selected file and should be treated as a high-volume ingestion and validation target.
- `DATE` should be converted to a SQL Server datetime type.
- `PATIENT` should join to `patients.Id`.
- `ENCOUNTER` should join to `encounters.Id` when present and valid.
- `CATEGORY`, `CODE`, `DESCRIPTION`, `UNITS`, and `TYPE` are important for grouping observation records.
- `VALUE` may contain numeric, categorical, or text-like values depending on observation type; it should not be blindly converted to a numeric field without profiling.
- A reporting-ready observation model may need separate typed fields or derived flags for numeric vs non-numeric values.

### `procedures.csv`

| Attribute | Details |
|---|---|
| Row count | 196,207 |
| Expected main identifier | No single source row ID; use generated bronze row key plus source fields |
| Relationship fields | `PATIENT`, `ENCOUNTER` |
| Key fields | `START`, `STOP`, `PATIENT`, `ENCOUNTER`, `SYSTEM`, `CODE`, `DESCRIPTION`, `BASE_COST` |
| Reporting use | Procedure volume, procedure grouping, service utilization, encounter complexity |
| Modeling implication | Load with a technical row key, standardize procedure codes/descriptions, and publish through procedure facts or utilization marts |

Columns:

```text
START, STOP, PATIENT, ENCOUNTER, SYSTEM, CODE, DESCRIPTION, BASE_COST, REASONCODE, REASONDESCRIPTION
```

Profiling notes:

- `PATIENT` should join to `patients.Id`.
- `ENCOUNTER` should join to `encounters.Id` when present and valid.
- `START` and `STOP` should be converted to SQL Server datetime types where applicable.
- `CODE` and `DESCRIPTION` support procedure grouping and service utilization analysis.
- `BASE_COST` can be retained for optional cost context, but ClinicalPulse should avoid framing synthetic costs as real hospital financial values.
- `REASONCODE` and `REASONDESCRIPTION` may support later clinical context but are not required for the first procedure utilization model.

### `organizations.csv`

| Attribute | Details |
|---|---|
| Row count | 826 |
| Expected main identifier | `Id` |
| Relationship role | Referenced by encounters and providers |
| Key fields | `Id`, `NAME`, `CITY`, `STATE`, `ZIP`, `LAT`, `LON`, `REVENUE`, `UTILIZATION` |
| Fields to protect or avoid overusing | Full address and phone fields are synthetic but unnecessary for most dashboard views |
| Reporting use | Organization dimension, facility context, organization-level encounter reporting |
| Modeling implication | Load as organization reference data and publish curated attributes through `gold.dim_organization` |

Columns:

```text
Id, NAME, ADDRESS, CITY, STATE, ZIP, LAT, LON, PHONE, REVENUE, UTILIZATION
```

Profiling notes:

- `Id` should be preserved as the organization source identifier.
- `NAME` and geography fields support organization-level filtering and reporting.
- `REVENUE` and `UTILIZATION` are synthetic source fields and should be used cautiously.
- `organizations.csv` can support a lightweight organization dimension without implying the data represents real Ontario or Massachusetts hospital operations.

### `providers.csv`

| Attribute | Details |
|---|---|
| Row count | 826 |
| Expected main identifier | `Id` |
| Relationship fields | `ORGANIZATION` |
| Key fields | `Id`, `ORGANIZATION`, `NAME`, `GENDER`, `SPECIALITY`, `ENCOUNTERS`, `PROCEDURES` |
| Fields to protect or avoid exposing | Provider names and address fields should be excluded or generalized in public-facing outputs unless needed |
| Reporting use | Provider reference data, provider-to-organization context, optional operational attribution |
| Modeling implication | Load as reference data and keep provider-level reporting lightweight unless a clear business use case is defined |

Columns:

```text
Id, ORGANIZATION, NAME, GENDER, SPECIALITY, ADDRESS, CITY, STATE, ZIP, LAT, LON, ENCOUNTERS, PROCEDURES
```

Profiling notes:

- `Id` should be preserved as the provider source identifier.
- `ORGANIZATION` should join to `organizations.Id`.
- `SPECIALITY` may support lightweight provider grouping.
- `ENCOUNTERS` and `PROCEDURES` appear to be source-provided aggregate fields and should not automatically replace counts derived from encounter and procedure records.
- Provider-level reporting should be treated as optional because the core project focuses on hospital operational BI rather than individual provider performance.

## Cross-Entity Observations

| Observation | Implication |
|---|---|
| Patients are the central parent entity | Most selected clinical/operational records should trace back to `patients.Id` |
| Encounters are the central operational event | Length of stay, readmission logic, service utilization, and many dashboard KPIs depend on `encounters.csv` |
| Conditions, observations, and procedures depend on patient and encounter relationships | Referential integrity checks should be created before gold modeling |
| Observations are much larger than other selected files | Ingestion, indexing, and validation design should account for volume |
| Several clinical event files lack a single source row identifier | Bronze ingestion should add technical keys, row hashes, source file names, and ingestion metadata |
| Source files include synthetic direct identifiers and names | Public-facing layers should avoid exposing unnecessary row-level identifiers |

## Data Quality Considerations

The following checks should be carried forward into SQL and Python validation work:

| Check Type | Examples |
|---|---|
| Completeness | Required IDs, patient references, encounter references, event dates, source codes |
| Uniqueness | Duplicate patient IDs, duplicate encounter IDs, duplicate organization IDs, duplicate provider IDs |
| Referential integrity | Encounters without patients, observations without patients, observations without encounters, providers without organizations |
| Temporal validity | Encounter stop before start, procedure stop before start, dates outside expected patient timeline |
| Data typing | Datetime conversion, numeric cost fields, numeric vs non-numeric observation values |
| Category consistency | Encounter classes, observation categories, procedure descriptions, provider specialties |
| Sensitive-field handling | Exclude or mask synthetic SSNs, license/passport-like fields, names, and full addresses from public outputs |
| Lineage | Preserve source identifiers, source file, ingestion batch, source row position or row hash |

## Modeling Implications

### Bronze Layer

Bronze tables should preserve the CSV structure as closely as possible while adding ingestion metadata.

Recommended bronze objects:

```text
bronze.patients
bronze.encounters
bronze.conditions
bronze.observations
bronze.procedures
bronze.organizations
bronze.providers
```

### Silver Layer

Silver tables should standardize naming, data types, derived fields, and quality flags.

Examples:

```text
silver.patient
silver.encounter
silver.condition
silver.observation
silver.procedure
silver.organization
silver.provider
```

Important silver transformations include:

- Convert source date and datetime fields.
- Derive age, age band, deceased indicator, encounter duration, and length of stay.
- Normalize encounter class, observation category, condition description, and procedure description where useful.
- Flag missing, invalid, or relationship-breaking records.
- Preserve lineage back to bronze source records.

### Gold Layer

Gold objects should support Power BI reporting through facts, dimensions, and marts.

Likely gold objects include:

```text
gold.dim_patient
gold.dim_organization
gold.dim_provider
gold.fact_encounter
gold.fact_condition
gold.fact_observation
gold.fact_procedure
gold.mart_patient_flow
gold.mart_length_of_stay
gold.mart_readmissions
gold.mart_lab_operations
gold.mart_service_utilization
```

## Assumptions and Limitations

This profile is based on the retained local Synthea generation run and the observed CSV headers and row counts.

The data is synthetic and does not contain real patient information.

The dataset does not represent Ontario patients, Ontario hospitals, Ontario demographics, Massachusetts health-system performance, or real hospital operations.

The profile does not yet include full null-rate, duplicate-rate, value-distribution, or referential-integrity results. Those checks belong in later SQL/Python data quality validation work.

Raw CSV files are local-only and should remain excluded from Git. This document records the source structure needed to understand, regenerate, ingest, and validate the selected source files.
