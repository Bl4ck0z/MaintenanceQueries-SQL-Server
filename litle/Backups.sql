-- =====================================================
-- Quick Backup Job - LITE VERSION
-- Purpose: Fast daily backups during morning setup
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'Backups'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'Backups',
    @step_name = N'Backups',
    @command = N'EXECUTE [dbo].[DatabaseBackup]
        @Databases = ''USER_DATABASES'',
        @Directory = ''C:\SQLBackups'',
        @BackupType = ''FULL'',
        @Verify = ''Y'',
        @CleanupTime = 48,
        @CleanupMode = ''AFTER_BACKUP'',
        @Compress = ''N'',
        @CheckSum = ''Y'',
        @BufferCount = 5,
        @MaxTransferSize = 1048576,
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Backups - 9:30 AM',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_recurrence_factor = 1,
    @active_start_time = 093000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'Backups',
    @schedule_name = N'Backups - 9:30 AM'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'Backups'
GO
