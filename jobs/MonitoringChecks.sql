-- =====================================================
-- Database Monitoring with Email Alerts
-- Purpose: Monitor system health and send email alerts
-- Schedule: Every 2 hours during business hours Mon-Sat
-- =====================================================

USE [msdb]
GO

EXEC dbo.sp_add_job
    @job_name = N'MaintenanceQueries - Monitoring Checks'
GO

EXEC dbo.sp_add_jobstep
    @job_name = N'MaintenanceQueries - Monitoring Checks',
    @step_name = N'Health Checks with Alerts',
    @command = N'
DECLARE @AlertSubject NVARCHAR(255)
DECLARE @AlertBody NVARCHAR(MAX) = ''''
DECLARE @HasAlerts BIT = 0

-- Check 1: Disk Space
DECLARE @LowDiskAlert NVARCHAR(MAX) = ''''
-- (Disk space check code - simplified for space)
IF EXISTS (SELECT 1 FROM sys.dm_os_volume_stats(1,1) WHERE available_bytes < total_bytes * 0.15)
BEGIN
    SET @LowDiskAlert = ''Low disk space detected on one or more drives.''
    SET @AlertBody = @AlertBody + ''DISK SPACE WARNING: '' + @LowDiskAlert + CHAR(13) + CHAR(10)
    SET @HasAlerts = 1
END

-- Check 2: Failed Jobs
DECLARE @FailedJobs NVARCHAR(MAX) = ''''
SELECT @FailedJobs = @FailedJobs + j.name + '', ''
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobhistory jh ON j.job_id = jh.job_id
WHERE jh.run_status = 0 AND jh.step_id = 0 
  AND CONVERT(DATETIME, CAST(jh.run_date AS VARCHAR(8)) + '' '' + 
      STUFF(STUFF(RIGHT(''000000'' + CAST(jh.run_time AS VARCHAR(6)), 6), 5, 0, '':''), 3, 0, '':'')) 
      >= DATEADD(HOUR, -2, GETDATE())

IF @FailedJobs <> ''''
BEGIN
    SET @FailedJobs = LEFT(@FailedJobs, LEN(@FailedJobs) - 2)
    SET @AlertBody = @AlertBody + ''FAILED JOBS: '' + @FailedJobs + CHAR(13) + CHAR(10)
    SET @HasAlerts = 1
END

-- Check 3: Database Status
DECLARE @OfflineDbs NVARCHAR(MAX) = ''''
SELECT @OfflineDbs = @OfflineDbs + name + '', ''
FROM sys.databases WHERE state_desc <> ''ONLINE'' AND database_id > 4

IF @OfflineDbs <> ''''
BEGIN
    SET @OfflineDbs = LEFT(@OfflineDbs, LEN(@OfflineDbs) - 2)
    SET @AlertBody = @AlertBody + ''OFFLINE DATABASES: '' + @OfflineDbs + CHAR(13) + CHAR(10)
    SET @HasAlerts = 1
END

IF @HasAlerts = 1
BEGIN
    SET @AlertSubject = ''SQL Server Alert - '' + @@SERVERNAME + '' - '' + FORMAT(GETDATE(), ''yyyy-MM-dd HH:mm'')
    SET @AlertBody = ''AUTOMATED SQL SERVER ALERT'' + CHAR(13) + CHAR(10) + 
                    ''Server: '' + @@SERVERNAME + CHAR(13) + CHAR(10) +
                    ''Time: '' + FORMAT(GETDATE(), ''yyyy-MM-dd HH:mm:ss'') + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    @AlertBody
    
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = ''MaintenanceQueries Mail Profile'',
        @recipients = ''dba-team@company.com'',
        @subject = @AlertSubject,
        @body = @AlertBody,
        @body_format = ''TEXT''
        
    PRINT ''Alert email sent''
END
ELSE
BEGIN
    PRINT ''All health checks passed - no alerts''
END
',
    @database_name = N'master',
    @notify_level_email = 2,
    @notify_email_operator_name = N'DBA Team'
GO

EXEC dbo.sp_add_schedule
    @schedule_name = N'Every 2 Hours - Business Hours Mon-Sat',
    @freq_type = 8,
    @freq_interval = 126,
    @freq_subday_type = 8,
    @freq_subday_interval = 2,
    @active_start_time = 080000,
    @active_end_time = 200000
GO

EXEC dbo.sp_attach_schedule
    @job_name = N'MaintenanceQueries - Monitoring Checks',
    @schedule_name = N'Every 2 Hours - Business Hours Mon-Sat'
GO

EXEC dbo.sp_add_jobserver
    @job_name = N'MaintenanceQueries - Monitoring Checks'
GO
