-- =====================================================
-- System Maintenance Job  
-- Purpose: Clean up system tables and logs
-- Schedule: Weekly on Sundays at 3:00 AM
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'MaintenanceQueries - System Maintenance'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - System Maintenance',
    @step_name = N'Clean Job History',
    @command = N'
-- Clean job history older than 30 days
DECLARE @cutoff_date DATETIME = DATEADD(day, -30, GETDATE())
EXEC msdb.dbo.sp_purge_jobhistory @oldest_date = @cutoff_date
PRINT ''Job history cleanup completed''
',
    @database_name = N'msdb'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - System Maintenance',
    @step_name = N'Clean Backup History',
    @command = N'
-- Clean backup/restore history older than 60 days  
DECLARE @cutoff_date DATETIME = DATEADD(day, -60, GETDATE())
EXEC msdb.dbo.sp_delete_backuphistory @oldest_date = @cutoff_date
PRINT ''Backup history cleanup completed''
',
    @database_name = N'msdb'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - System Maintenance',
    @step_name = N'Clean Database Mail Log',
    @command = N'
-- Clean database mail logs older than 30 days
IF EXISTS (SELECT * FROM sys.objects WHERE name = ''sysmail_delete_mailitems_sp'')
BEGIN
    DECLARE @cutoff_date DATETIME = DATEADD(day, -30, GETDATE())
    EXEC msdb.dbo.sysmail_delete_mailitems_sp @sent_before = @cutoff_date
    EXEC msdb.dbo.sysmail_delete_log_sp @logged_before = @cutoff_date
    PRINT ''Database mail cleanup completed''
END
ELSE
BEGIN
    PRINT ''Database Mail not configured - skipping mail cleanup''
END
',
    @database_name = N'msdb'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - System Maintenance',
    @step_name = N'Cycle Error Log',
    @command = N'
-- Cycle the SQL Server error log (creates new log file)
EXEC sp_cycle_errorlog
PRINT ''SQL Server error log cycled''
',
    @database_name = N'master'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - System Maintenance',
    @step_name = N'Update System Statistics',
    @command = N'
USE master
UPDATE STATISTICS WITH FULLSCAN
PRINT ''Master database statistics updated''

USE msdb  
UPDATE STATISTICS WITH FULLSCAN
PRINT ''MSDB database statistics updated''
',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Weekly System Maintenance',
    @freq_type = 8,
    @freq_interval = 1,
    @freq_recurrence_factor = 1,
    @active_start_time = 030000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - System Maintenance',
    @schedule_name = N'Weekly System Maintenance'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - System Maintenance'
GO
