# Lightweight SQL Server Maintenance Solution

## Maintenance Schedule

| Job | Frequency | Time | Duration | Purpose |
|-----|-----------|------|----------|---------|
| **Backups** | Daily | 9:30 AM | 15-20 min | Full database backup during morning setup |
| **Weekly Maintenance** | Monday | 4:30 PM | 25 min | Integrity check + light index maintenance |
| **Cleanup** | Daily | 3:00 PM | 5 min | Remove old files and space check |


## Backup Strategy
- **Full backups only** (no differential complexity)
- **No compression** to reduce CPU load
- **48-hour retention** to conserve disk space
- **Small buffer counts** (5) for limited RAM
- **Reduced transfer size** (1MB) for slower storage

## Maintenance Approach  
- **Physical-only integrity checks** (faster, less CPU intensive)
- **Index reorganize only** (no rebuilds to save resources)
- **Single-threaded processing** (`@MaxDOP = 1`) for Celeron CPUs
- **Skip small indexes** (<1000 pages) to save time
- **Minimal statistics updates** (columns only)

## Recovery Model Recommendation
Set all databases to **SIMPLE recovery model** to eliminate transaction log maintenance:
```sql
ALTER DATABASE [YourDatabase] SET RECOVERY SIMPLE
```
