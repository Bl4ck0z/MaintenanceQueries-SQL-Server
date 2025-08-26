-- =====================================================
-- Weekly Maintenance Job
-- Purpose: Light integrity check and index maintenance
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'Weekly Maintenance'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'Weekly Maintenance',
    @step_name = N'Database Integrity Check',
    @command = N'EXECUTE [dbo].[DatabaseIntegrityCheck]
        @Databases = ''USER_DATABASES'',
        @CheckCommands = ''CHECKDB'',
        @PhysicalOnly = ''Y'',
        @NoIndex = ''Y'',
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'Weekly Maintenance',
    @step_name = N'Index Maintenance',
    @command = N'EXECUTE [dbo].[IndexOptimize]
        @Databases = ''USER_DATABASES'',
        @FragmentationLow = NULL,
        @FragmentationMedium = ''INDEX_REORGANIZE'',
        @FragmentationHigh = ''INDEX_REORGANIZE'',
        @FragmentationLevel1 = 10,
        @FragmentationLevel2 = 30,
        @MinNumberOfPages = 1000,
        @MaxDOP = 1,
        @UpdateStatistics = ''COLUMNS'',
        @OnlyModifiedStatistics = ''Y'',
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Weekly Maintenance - 4:30 PM',
    @freq_type = 8,
    @freq_interval = 2,
    @freq_recurrence_factor = 1,
    @active_start_time = 163000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'Weekly Maintenance',
    @schedule_name = N'Weekly Maintenance - 4:30 PM'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'Weekly Maintenance'
GO
