-- =====================================================
-- Emergency Database Recovery Script
-- Purpose: Recover database from SUSPECT state
-- WARNING: This script can cause data loss - use only in emergencies
-- =====================================================

-- Replace 'DATABASE_NAME' with actual database name

EXEC sp_resetstatus 'DATABASE_NAME'
ALTER DATABASE DATABASE_NAME SET EMERGENCY

DBCC CHECKDB('DATABASE_NAME')

ALTER DATABASE DATABASE_NAME SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DBCC CHECKDB ('DATABASE_NAME', REPAIR_ALLOW_DATA_LOSS)
DBCC CHECKDB ('DATABASE_NAME')
ALTER DATABASE DATABASE_NAME SET MULTI_USER
