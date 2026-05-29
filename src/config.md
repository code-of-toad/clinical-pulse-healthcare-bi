# Local SQL Server Connection Configuration

## Purpose

This document defines the local SQL Server connection configuration for ClinicalPulse.

The goal is to let SQL Server Management Studio, Azure Data Studio, and Python scripts connect to the local `ClinicalPulse` database without committing credentials, local machine paths, or environment-specific secrets.

## Local Database Target

| Setting | Value |
|---|---|
| Database | `ClinicalPulse` |
| SQL Server role | Local development database |
| Primary access tools | SSMS or Azure Data Studio, Python ingestion/validation scripts |
| Credential handling | Local authentication only; no credentials committed to Git |

## Recommended Local Connection Pattern

Use Windows Authentication for local development when possible.

Recommended SSMS or Azure Data Studio settings:

| Field | Recommended Value |
|---|---|
| Server type | Database Engine |
| Server name | `localhost` or your local SQL Server instance name |
| Authentication | Windows Authentication |
| Database | `ClinicalPulse` |
| Trust server certificate | Enabled if required by the local SQL Server driver |

Common local server name examples:

```text
localhost
localhost\SQLEXPRESS
.\SQLEXPRESS
```

Use the server name that matches the installed local SQL Server instance.

## Python Configuration Pattern

Python scripts should read database configuration from environment variables, not hard-coded values.

Expected local environment variables:

```text
CLINICALPULSE_SQL_SERVER=localhost
CLINICALPULSE_SQL_DATABASE=ClinicalPulse
CLINICALPULSE_SQL_DRIVER=ODBC Driver 18 for SQL Server
CLINICALPULSE_SQL_TRUSTED_CONNECTION=yes
CLINICALPULSE_SQL_TRUST_SERVER_CERTIFICATE=yes
```

If the local SQL Server instance is SQL Server Express, use:

```text
CLINICALPULSE_SQL_SERVER=localhost\SQLEXPRESS
```

## Local `.env` Handling

A local `.env` file may be used during development, but it must not be committed to Git.

Example local `.env` content:

```text
CLINICALPULSE_SQL_SERVER=localhost
CLINICALPULSE_SQL_DATABASE=ClinicalPulse
CLINICALPULSE_SQL_DRIVER=ODBC Driver 18 for SQL Server
CLINICALPULSE_SQL_TRUSTED_CONNECTION=yes
CLINICALPULSE_SQL_TRUST_SERVER_CERTIFICATE=yes
```

The project `.gitignore` should exclude:

```text
.env
```

Do not store usernames, passwords, access tokens, database backups, raw data files, or machine-specific secrets in committed files.

## SQL Authentication

Windows Authentication is preferred for local development.

If SQL Authentication is needed later, credentials should still be provided through environment variables and kept out of Git.

Do not hard-code values such as:

```text
username
password
connection string with password
```

inside Python scripts, SQL scripts, notebooks, markdown documentation, or Power BI notes.

## Expected Python Connection Behavior

Python ingestion and validation scripts should:

1. Read SQL Server settings from environment variables.
2. Connect to the `ClinicalPulse` database.
3. Fail clearly if required connection variables are missing.
4. Avoid printing secrets or full credential-bearing connection strings.
5. Use the configured SQL Server connection for ingestion, row-count validation, and audit logging.

## Validation Steps

Use SSMS or Azure Data Studio to confirm the database exists:

```sql
SELECT name
FROM sys.databases
WHERE name = N'ClinicalPulse';
```

Then confirm the required schemas exist:

```sql
USE [ClinicalPulse];

SELECT name AS schema_name
FROM sys.schemas
WHERE name IN (
    N'bronze',
    N'silver',
    N'gold',
    N'governance',
    N'audit',
    N'api'
)
ORDER BY name;
```

Expected result: six rows, one for each required schema.

## Assumptions and Limitations

- This configuration is for local development only.
- The local machine is expected to have SQL Server installed and running.
- The local machine is expected to have an appropriate ODBC Driver for SQL Server installed.
- Windows Authentication is the preferred local authentication method.
- Connection values may differ by machine, especially the SQL Server instance name.
- This document does not create the database or schemas; it only defines the safe local connection configuration.
- Production deployment, cloud hosting, and multi-user access control are outside the scope of this local configuration.
