-- =====================================================
-- Transaction Log Cleanup Job
-- Schedule: Monthly at 6:30 PM (1st day of month)
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'MaintenanceQueries - Log Cleanup'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - Log Cleanup',
    @step_name = N'Clean Transaction Logs',
    @command = N'
DECLARE @sql NVARCHAR(MAX) = ''''
DECLARE @dbname NVARCHAR(128)

DECLARE db_cursor CURSOR FOR
SELECT name 
FROM sys.databases 
WHERE database_id > 4 
  AND state = 0 
  AND recovery_model_desc = ''SIMPLE''

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @dbname

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = ''USE ['' + @dbname + '']; DBCC SHRINKFILE(2, 10)''
    PRINT ''Shrinking log for database: '' + @dbname
    EXEC sp_executesql @sql
    
    FETCH NEXT FROM db_cursor INTO @dbname
END

CLOSE db_cursor
DEALLOCATE db_cursor
',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Monthly Log Cleanup',
    @freq_type = 16,
    @freq_interval = 1,
    @freq_recurrence_factor = 1,
    @active_start_time = 183000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Log Cleanup',
    @schedule_name = N'Monthly Log Cleanup'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Log Cleanup'
GO
