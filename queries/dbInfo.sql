-- =====================================================
-- Database Information Query
-- Purpose: Get detailed database file information
-- =====================================================

SELECT 
    d.name AS [Database_Name],
    mf.name AS [Logical_Name],
    mf.type_desc AS [File_Type],
    mf.physical_name AS [Physical_Path],
    CAST(mf.size * 8.0 / 1024 AS DECIMAL(10,2)) AS [Size_MB],
    CAST(FILEPROPERTY(mf.name, 'SpaceUsed') * 8.0 / 1024 AS DECIMAL(10,2)) AS [Used_MB],
    CAST((mf.size - FILEPROPERTY(mf.name, 'SpaceUsed')) * 8.0 / 1024 AS DECIMAL(10,2)) AS [Free_MB]
FROM sys.databases d
INNER JOIN sys.master_files mf ON d.database_id = mf.database_id
WHERE d.database_id > 4
ORDER BY d.name, mf.type_desc;
