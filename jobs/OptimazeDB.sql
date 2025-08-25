-- =====================================================
-- Index Optimization + Statistics Update Job
-- Schedule: Daily at 6:00 AM
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'MaintenanceQueries - Optimize Indexes'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - Optimize Indexes',
    @step_name = N'Run Index Optimization and Statistics',
    @command = N'EXECUTE [dbo].[IndexOptimize]
        @Databases = ''USER_DATABASES'',
        @FragmentationLow = NULL,
        @FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',
        @FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',
        @FragmentationLevel1 = 5,
        @FragmentationLevel2 = 30,
        @UpdateStatistics = ''ALL'',
        @OnlyModifiedStatistics = ''Y'',
        @LogToTable = ''Y'',
        @Execute = ''Y''',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Daily Index Optimization',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 060000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Optimize Indexes',
    @schedule_name = N'Daily Index Optimization'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Optimize Indexes'
GO
