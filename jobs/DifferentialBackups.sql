-- =====================================================
-- Differential Backup Job 
-- Schedule: 3 times per day from 7:30 AM to 6:30 PM
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

-- Schedule: 3 times per day (7:30 AM, 1:00 PM, 6:30 PM)
EXEC dbo.sp_add_schedule
    @schedule_name = N'3 Times Daily - Business Hours',
    @freq_type = 4,                    -- Daily
    @freq_interval = 1,                -- Every day
    @freq_recurrence_factor = 1,       -- Every 1 day
    @freq_subday_type = 4,             -- Minutes
    @freq_subday_interval = 330,       -- Every 5.5 hours (330 minutes)
    @active_start_time = 073000,       -- Start at 7:30 AM
    @active_end_time = 183000          -- End at 6:30 PM
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Differential Backups',
    @schedule_name = N'3 Times Daily - Business Hours'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Differential Backups'
GO