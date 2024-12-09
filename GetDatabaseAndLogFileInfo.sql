-- Declaración de variables para iterar y mostrar información
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @FileName NVARCHAR(128);
DECLARE @FileType NVARCHAR(20);
DECLARE @FileSizeMB DECIMAL(10, 2);
DECLARE @SQL NVARCHAR(MAX);

-- Tabla temporal para almacenar información de las bases de datos
CREATE TABLE #DatabaseInfo (
    DatabaseName NVARCHAR(128),
    FileName NVARCHAR(128),
    FileType NVARCHAR(20),
    FileSizeMB DECIMAL(10, 2)
);

-- Poblar la tabla con información de bases de datos y sus archivos
INSERT INTO #DatabaseInfo (DatabaseName, FileName, FileType, FileSizeMB)
SELECT 
    d.name AS DatabaseName,
    mf.name AS FileName,
    mf.type_desc AS FileType,
    mf.size * 8.0 / 1024 AS FileSizeMB -- Tamaño en MB (cada página es de 8 KB)
FROM sys.databases d
JOIN sys.master_files mf ON d.database_id = mf.database_id;

-- Cursor para iterar y mostrar la información
DECLARE db_cursor CURSOR FOR
SELECT DatabaseName, FileName, FileType, FileSizeMB
FROM #DatabaseInfo;

OPEN db_cursor;

FETCH NEXT FROM db_cursor INTO @DatabaseName, @FileName, @FileType, @FileSizeMB;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Mostrar información en pantalla
    PRINT 'Base de Datos: ' + @DatabaseName;
    PRINT '  Archivo: ' + @FileName;
    PRINT '  Tipo de Archivo: ' + @FileType;
    PRINT '  Tamaño (MB): ' + CAST(@FileSizeMB AS NVARCHAR(10));
    PRINT '-------------------------------------------';

    FETCH NEXT FROM db_cursor INTO @DatabaseName, @FileName, @FileType, @FileSizeMB;
END

-- Cerrar y liberar el cursor
CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Eliminar la tabla temporal
DROP TABLE #DatabaseInfo;
