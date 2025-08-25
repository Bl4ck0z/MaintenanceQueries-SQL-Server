-- =====================================================
-- Differential Backup Job
-- Purpose: Backup changes since last full backup
-- Schedule: Every 6 hours (4 times daily)
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'MaintenanceQueries - Differential Backups'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - Differential Backups',
    @step_name = N'Run Differential Backups',
    @command = N'EXECUTE [dbo].[DatabaseBackup]
        @Databases = ''USER_DATABASES'',
        @Directory = ''C:\SQLBackups\Diff'',
        @BackupType = ''DIFF'',
        @Verify = ''Y'',
        @CleanupTime = 72,
        @CheckSum = ''Y'',
        @Compress = ''Y'',
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Every 6 Hours - Differential',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 8,
    @freq_subday_interval = 6,
    @active_start_time = 020000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Differential Backups',
    @schedule_name = N'Every 6 Hours - Differential'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Differential Backups'
GO
