/*
    ClinicalPulse

    Purpose:
    Create the ClinicalPulse SQL Server database used as the analytical
    backbone for the governed hospital BI platform.
*/

USE [master];
GO

IF DB_ID(N'ClinicalPulse') IS NULL
BEGIN
    CREATE DATABASE [ClinicalPulse];
    PRINT 'Database ClinicalPulse created.';
END
ELSE
BEGIN
    PRINT 'Database ClinicalPulse already exists.';
END;
GO
