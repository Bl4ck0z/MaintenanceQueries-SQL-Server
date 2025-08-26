-- =====================================================
-- Daily Cleanup Job - LITE VERSION
-- Purpose: Remove old files and basic cleanup
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'Cleanup'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'Cleanup',
    @step_name = N'Clean Old Backup Files',
    @command = N'

DECLARE @cutoff_date DATETIME = DATEADD(hour, -48, GETDATE())
EXEC msdb.dbo.sp_delete_backuphistory @oldest_date = @cutoff_date
  
DECLARE @job_cutoff DATETIME = DATEADD(day, -7, GETDATE())
EXEC msdb.dbo.sp_purge_jobhistory @oldest_date = @job_cutoff

PRINT ''File cleanup completed''
',
    @database_name = N'msdb'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'Cleanup',
    @step_name = N'Quick Space Check',
    @command = N'

DECLARE @FreeSpacePercent DECIMAL(5,2)
DECLARE @AlertMessage NVARCHAR(500)

SELECT @FreeSpacePercent = 
    CAST((SUM(size - FILEPROPERTY(name, ''SpaceUsed'')) * 8.0 / 1024) AS DECIMAL(10,2)) * 100.0 / 
    CAST((SUM(size) * 8.0 / 1024) AS DECIMAL(10,2))
FROM sys.master_files 
WHERE database_id = DB_ID()

IF @FreeSpacePercent < 10
BEGIN
    SET @AlertMessage = ''WARNING: Low disk space detected. Free space: '' + CAST(@FreeSpacePercent AS VARCHAR(10)) + ''%''
    RAISERROR(@AlertMessage, 16, 1)
END
ELSE
BEGIN
    PRINT ''Disk space check passed''
END
',
    @database_name = N'master'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Cleanup - 3:00 PM',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_recurrence_factor = 1,
    @active_start_time = 150000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'Cleanup',
    @schedule_name = N'Cleanup - 3:00 PM'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'Cleanup'
GO
