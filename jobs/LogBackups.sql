-- =====================================================
-- Transaction Log Backup Job
-- Purpose: Backup transaction logs for FULL recovery databases
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'MaintenanceQueries - Transaction Log Backups'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - Transaction Log Backups',
    @step_name = N'Run Transaction Log Backups',
    @command = N'EXECUTE [dbo].[DatabaseBackup]
        @Databases = ''USER_DATABASES'',
        @Directory = ''C:\SQLBackups\Log'',
        @BackupType = ''LOG'',
        @ChangeBackupType = ''Y'',
        @Verify = ''Y'',
        @CleanupTime = 48,
        @CleanupMode = ''AFTER_BACKUP'',
        @CheckSum = ''Y'',
        @Compress = ''Y'',
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Every 30 Min - Business Hours Mon-Sat',
    @freq_type = 8,
    @freq_interval = 126,
    @freq_recurrence_factor = 1,
    @freq_subday_type = 4,
    @freq_subday_interval = 30,
    @active_start_time = 080000,
    @active_end_time = 200000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Transaction Log Backups',
    @schedule_name = N'Every 30 Min - Business Hours Mon-Sat'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Transaction Log Backups'
GO
