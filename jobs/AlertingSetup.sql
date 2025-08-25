-- =====================================================
-- Email Alerting Configuration
-- Purpose: Configure Database Mail and job notifications
-- Run: Once during initial setup, then as needed
-- =====================================================

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
EXEC sp_configure 'Database Mail XPs', 1
RECONFIGURE
GO

IF NOT EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = 'MaintenanceQueries Mail Profile')
BEGIN
    EXEC msdb.dbo.sysmail_add_profile_sp
        @profile_name = 'MaintenanceQueries Mail Profile',
        @description = 'Mail profile for database maintenance notifications'
END
GO

IF NOT EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = 'MaintenanceQueries Mail Account')
BEGIN
    EXEC msdb.dbo.sysmail_add_account_sp
        @account_name = 'MaintenanceQueries Mail Account',
        @description = 'Mail account for maintenance notifications',
        @email_address = 'alertas@facuimportaciones.com',
        @display_name = 'SQL Server Maintenance',
        @mailserver_name = 'mail.facuimportaciones.com',
        @port = 587,
        @enable_ssl = 1,
        @username = 'alertas@facuimportaciones.com',
        @password = 'F4cu@Passwd44'
END
GO

IF NOT EXISTS (
    SELECT * FROM msdb.dbo.sysmail_profileaccount pa
    INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id
    INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id
    WHERE p.name = 'MaintenanceQueries Mail Profile' 
    AND a.name = 'MaintenanceQueries Mail Account'
)
BEGIN
    DECLARE @profile_id INT, @account_id INT
    
    SELECT @profile_id = profile_id 
    FROM msdb.dbo.sysmail_profile 
    WHERE name = 'MaintenanceQueries Mail Profile'
    
    SELECT @account_id = account_id 
    FROM msdb.dbo.sysmail_account 
    WHERE name = 'MaintenanceQueries Mail Account'
    
    EXEC msdb.dbo.sysmail_add_profileaccount_sp
        @profile_id = @profile_id,
        @account_id = @account_id,
        @sequence_number = 1
END
GO

EXEC msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'MaintenanceQueries Mail Profile',
    @principal_name = 'public',
    @is_default = 1
GO

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = 'DBA Team')
BEGIN
    EXEC msdb.dbo.sp_add_operator
        @name = N'DBA Team',
        @enabled = 1,
        @weekday_pager_start_time = 80000,
        @weekday_pager_end_time = 180000,
        @saturday_pager_start_time = 80000,
        @saturday_pager_end_time = 180000,
        @pager_days = 126,
        @email_address = N'alertas@facuimportaciones.com',
        @pager_address = N'alertas@facuimportaciones.com'
END
GO

EXEC msdb.dbo.sp_set_sqlagent_properties
    @databasemail_profile = N'MaintenanceQueries Mail Profile',
    @use_databasemail = 1
GO

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'MaintenanceQueries Mail Profile',
    @recipients = 'alertas@facuimportaciones.com',
    @subject = 'SQL Server Maintenance - Test Email',
    @body = 'This is a test email from SQL Server Maintenance system. If you receive this, email alerting is configured correctly.',
    @body_format = 'TEXT'
GO

DECLARE @job_name NVARCHAR(128)
DECLARE job_cursor CURSOR FOR
SELECT name FROM msdb.dbo.sysjobs 
WHERE name LIKE 'MaintenanceQueries%'

OPEN job_cursor
FETCH NEXT FROM job_cursor INTO @job_name

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC msdb.dbo.sp_update_job
        @job_name = @job_name,
        @notify_level_email = 2,
        @notify_email_operator_name = N'DBA Team'
        
    PRINT 'Updated job: ' + @job_name + ' to send failure notifications'
    FETCH NEXT FROM job_cursor INTO @job_name
END

CLOSE job_cursor
DEALLOCATE job_cursor
GO

PRINT 'Email alerting setup completed!'
PRINT 'IMPORTANT: Update the email addresses and SMTP settings above for your environment!'
