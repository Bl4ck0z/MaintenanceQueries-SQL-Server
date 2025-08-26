# MaintenanceQueries-SQL-Server

**Enterprise-level SQL Server Maintenance Solution** using Ola Hallengren procedures with automated jobs for backup, optimization, and integrity checks.

![SQL Server Maintenance](images/2025-08-26-2014-29-58.png)

## Overview

This repository provides a complete maintenance solution for SQL Server databases, featuring:

- **Automated database maintenance** using proven Ola Hallengren procedures
- **Comprehensive backup strategy** (Full, Differential, Transaction Log)
- **Performance optimization** through index maintenance and statistics updates
- **Database integrity checks** with DBCC CHECKDB
- **Emergency recovery procedures** for critical situations

## Repository Structure

```
MaintenanceQueries-SQL-Server/
├── jobs/
│   ├── FullBackups.sql                # Full backups
│   ├── DiffBackups.sql                # Differential backups
│   ├── IntegrityCheck.sql             # Database integrity
│   ├── LogBackups.sql                 # Transaction log backups
│   ├── LogsCleanup.sql                # Log cleanup
│   ├── OptimazeDB.sql                 # Index optimization
│   ├── SystemMaintenance.sql          # System cleanup
│   └── TransactionLogBackups.sql      # Additional log backup configuration
├── queries/                           
│   ├── dbInfo.sql                     # Database file information
│   └── EmergencydbRecovery.sql        # Emergency recovery procedures
├── MaintenanceSolution.sql            # Ola Hallengren main script
├── images
├── LICENSE
└── README.md
```

## Quick Start

### Prerequisites

- SQL Server 2008 R2 or later
- `sysadmin` privileges
- Adequate backup directory space
- FULL recovery model for transaction log backups

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Bl4ck0z/MaintenanceQueries-SQL-Server.git
   cd MaintenanceQueries-SQL-Server
   ```

2. **Install Ola Hallengren Solution:**
   - Download the latest `MaintenanceSolution.sql` from [https://ola.hallengren.com/](https://ola.hallengren.com/)
   - Execute it in SQL Server Management Studio

3. **Create backup directories:**
   ```sql
   EXEC xp_cmdshell 'mkdir C:\SQLBackups'
   EXEC xp_cmdshell 'mkdir C:\SQLBackups\Full'
   EXEC xp_cmdshell 'mkdir C:\SQLBackups\Diff'
   EXEC xp_cmdshell 'mkdir C:\SQLBackups\Log'
   ```

4. **Deploy maintenance jobs:**
   - Execute each job script in the `jobs/` folder
   - Jobs will be created with pre-configured schedules

## Maintenance Schedule

| Job | Frequency | Time | Purpose |
|-----|-----------|------|---------|
| **Integrity Check** | Daily | 5:00 AM | Verify database consistency |
| **Index Optimization** | Daily | 6:00 AM | Rebuild/reorganize indexes + update statistics |
| **Differential Backups** | 3 times daily | 7:30 AM, 1:00 PM, 6:30 PM | Incremental backups during business hours |
| **Full Database Backups** | Daily | 8:00 PM | Complete database backups |
| **Transaction Log Backups** | Every 30 min | 8 AM - 8 PM, Mon-Sat | Point-in-time recovery during business hours |
| **System Maintenance** | Weekly | Sunday 3:00 AM | Clean job history, logs, statistics |
| **Log Cleanup** | Monthly | 1st day, 6:30 PM | Shrink transaction logs |

## Configuration

### Backup Paths
Default backup directory: `C:\SQLBackups`

To change backup paths, update the `@Directory` parameter in:
- `FullBackups.sql`
- `DiffBackups.sql` 
- `LogBackups.sql`

### Retention Settings
Modify the `@CleanupTime` parameter in backup jobs:
- Full backups: 168 hours (7 days)
- Differential: 72 hours (3 days)
- Transaction logs: 48 hours (2 days)

### Business Hours
Default: Monday-Saturday, 8 AM - 8 PM

Update schedules in job files to match your business hours.

## Database Recovery

### Point-in-Time Recovery
With this backup strategy, you can restore to any point in time during business hours:
1. **Last Full Backup** + **Latest Differential** + **Transaction Logs since differential**

### Fast Recovery
For faster recovery with minimal data loss:
1. **Last Full Backup** + **Latest Differential Backup**

### Emergency Recovery
Use `queries/EmergencydbRecovery.sql` for databases in SUSPECT state:

```sql
-- Replace 'DATABASE_NAME' with your database name
EXEC sp_resetstatus 'DATABASE_NAME'
ALTER DATABASE DATABASE_NAME SET EMERGENCY
-- ... (follow script instructions)
```

**Warning:** This procedure may cause data loss. Use only as a last resort.

## Customization

### Adding Databases
Jobs automatically target `USER_DATABASES` (excludes system databases).

### Modifying Schedules
Edit the `@active_start_time` and frequency parameters in each job script.

### Changing Retention
Update `@CleanupTime` parameter in backup jobs (time in hours).

## Resources

- [Ola Hallengren's Maintenance Solution](https://ola.hallengren.com/)
- [SQL Server Backup Best Practices](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/)
- [Index Maintenance Guidelines](https://docs.microsoft.com/en-us/sql/relational-databases/indexes/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Ola Hallengren** - For the excellent SQL Server Maintenance Solution
- **Microsoft** - For SQL Server documentation and best practices

---

**Star this repository if it helped you maintain your SQL Server databases!**
