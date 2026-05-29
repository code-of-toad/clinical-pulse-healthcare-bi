"""
ClinicalPulse database configuration utilities.

Purpose:
Centralize SQL Server connection settings for Python scripts without exposing
credentials, machine-specific values, or connection strings in source control.

Expected environment variables:
    CLINICALPULSE_SQL_SERVER
    CLINICALPULSE_SQL_DATABASE
    CLINICALPULSE_SQL_DRIVER
    CLINICALPULSE_SQL_TRUSTED_CONNECTION
    CLINICALPULSE_SQL_TRUST_SERVER_CERTIFICATE
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from urllib.parse import quote_plus

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


@dataclass(frozen=True)
class DatabaseConfig:
    """Database connection settings loaded from environment variables."""

    server: str
    database: str
    driver: str
    trusted_connection: str
    trust_server_certificate: str

    @classmethod
    def from_env(cls) -> 'DatabaseConfig':
        """Create a DatabaseConfig object from environment variables."""

        return cls(
            server=os.getenv('CLINICALPULSE_SQL_SERVER', 'localhost'),
            database=os.getenv('CLINICALPULSE_SQL_DATABASE', 'ClinicalPulse'),
            driver=os.getenv('CLINICALPULSE_SQL_DRIVER', 'ODBC Driver 18 for SQL Server'),
            trusted_connection=os.getenv('CLINICALPULSE_SQL_TRUSTED_CONNECTION', 'yes'),
            trust_server_certificate=os.getenv(
                'CLINICALPULSE_SQL_TRUST_SERVER_CERTIFICATE',
                'yes',
            ),
        )

    def to_odbc_connection_string(self) -> str:
        """Build an ODBC connection string for SQL Server."""

        return (
            f'DRIVER={{{self.driver}}};'
            f'SERVER={self.server};'
            f'DATABASE={self.database};'
            f'Trusted_Connection={self.trusted_connection};'
            f'TrustServerCertificate={self.trust_server_certificate};'
        )

    def to_sqlalchemy_url(self) -> str:
        """Build a SQLAlchemy connection URL using pyodbc."""

        quoted_connection_string = quote_plus(self.to_odbc_connection_string())
        return f'mssql+pyodbc:///?odbc_connect={quoted_connection_string}'


def get_database_config() -> DatabaseConfig:
    """Return the active ClinicalPulse database configuration."""

    return DatabaseConfig.from_env()


def get_sqlalchemy_engine() -> Engine:
    """Create a SQLAlchemy engine for the ClinicalPulse SQL Server database."""

    config = get_database_config()
    return create_engine(config.to_sqlalchemy_url(), fast_executemany=True)


def test_database_connection() -> bool:
    """
    Test whether Python can connect to the configured ClinicalPulse database.

    Returns:
        True if the connection succeeds.
    """

    engine = get_sqlalchemy_engine()

    with engine.connect() as connection:
        connection.execute(text('SELECT 1'))

    return True


if __name__ == '__main__':
    if test_database_connection():
        print('ClinicalPulse database connection succeeded.')
