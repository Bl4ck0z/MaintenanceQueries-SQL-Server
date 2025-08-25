-- =====================================================
-- Database Integrity Check Job
-- Schedule: Daily at 5:00 AM
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'MaintenanceQueries - Integrity Check'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - Integrity Check',
    @step_name = N'Run Integrity Check',
    @command = N'EXECUTE [dbo].[DatabaseIntegrityCheck]
        @Databases = ''USER_DATABASES'',
        @CheckCommands = ''CHECKDB'',
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Daily Integrity Check',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 050000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Integrity Check',
    @schedule_name = N'Daily Integrity Check'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Integrity Check'
GO
