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
        @Compress = ''Y'',
        @CheckSum = ''Y'',
	@FileName = ''{BackupType}_{Year}{Month}{Day}_{Hour}{Minute}.{FileExtension}'',
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'3 Times Daily - Business Hours',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_recurrence_factor = 1,
    @freq_subday_type = 4,
    @freq_subday_interval = 330,
    @active_start_time = 073000,
    @active_end_time = 183000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Differential Backups',
    @schedule_name = N'3 Times Daily - Business Hours'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Differential Backups'
GO
