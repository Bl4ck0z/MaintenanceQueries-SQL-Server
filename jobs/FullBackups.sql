-- =====================================================
-- Database Backup Job
-- Schedule: Daily at 8:00 PM
-- =====================================================
USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'MaintenanceQueries - Database Backups'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - Database Backups',
    @step_name = N'Run Database Backups',
    @command = N'EXECUTE [dbo].[DatabaseBackup]
        @Databases = ''USER_DATABASES'',
        @Directory = ''C:\SQLBackups\Full'',
        @BackupType = ''FULL'',
        @Verify = ''Y'',
        @CleanupTime = 168,
        @CleanupMode = ''AFTER_BACKUP'',
        @Compress = ''Y'',
        @CheckSum = ''Y'',
	@DirectoryStructure = ''{DatabaseName}'',
	@FileName = ''{Year}{Month}{Day}.{FileExtemsion}'',
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Daily Database Backup',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_recurrence_factor = 1,
    @active_start_time = 200000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Database Backups',
    @schedule_name = N'Daily Database Backup'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Database Backups'
GO
