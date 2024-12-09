DECLARE @DatabaseName NVARCHAR(MAX)
DECLARE @BackupPath NVARCHAR(MAX)
DECLARE @SQL NVARCHAR(MAX)

-- Define la ruta base donde se almacenarán los respaldos
SET @BackupPath = 'C:\backups\'

-- Tabla temporal para almacenar los nombres de las bases de datos
CREATE TABLE #Databases (DatabaseName NVARCHAR(MAX))

-- Inserta los nombres de las bases de datos en la tabla temporal
INSERT INTO #Databases (DatabaseName)
VALUES 
(N'db_1'),
(N'db_2'),
(N'db_3');

-- Cursor para recorrer las bases de datos
DECLARE DatabaseCursor CURSOR FOR 
SELECT DatabaseName FROM #Databases

OPEN DatabaseCursor
FETCH NEXT FROM DatabaseCursor INTO @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Construye el comando BACKUP DATABASE
    SET @SQL = N'BACKUP DATABASE [' + @DatabaseName + N'] ' +
               N'TO DISK = N''' + @BackupPath + @DatabaseName + N'.BAK'' ' +
               N'WITH NOFORMAT, NOINIT, NAME = N''' + @DatabaseName + N'-Full Database Backup'', ' +
               N'SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10;'

    -- Ejecuta el comando
    PRINT @SQL -- Muestra el comando en el log para validación
    EXEC sp_executesql @SQL

    FETCH NEXT FROM DatabaseCursor INTO @DatabaseName
END

-- Cierra y libera el cursor
CLOSE DatabaseCursor
DEALLOCATE DatabaseCursor

-- Elimina la tabla temporal
DROP TABLE #Databases