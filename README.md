# Plan de Mantenimiento de Bases de Datos

## Introducción

- **Objetivo**: Describir las tareas de mantenimiento requeridas para garantizar el correcto funcionamiento, integridad, seguridad y rendimiento de las bases de datos en el sistema.

- **Alcance**: Este plan abarca todas las bases de datos administradas en el servidor, incluyendo tareas relacionadas con respaldos, recuperación, optimización y limpieza.

---

## Plan de Mantenimiento

Referencia: El plan se basa en scripts de mantenimiento proporcionados por [Ola Hallengren](https://ola.hallengren.com/), reconocidos por su eficiencia y flexibilidad.

### 1. **Verificación de Integridad de las Bases de Datos**  

Frecuencia: Diario

Descripción: Ejecuta un chequeo integral utilizando ```DBCC CHECKDB``` para garantizar la consistencia de las estructuras internas de las bases de datos.

```sql
EXECUTE [dbo].[DatabaseIntegrityCheck]
@Databases = 'USER_DATABASES',
@CheckCommands = 'CHECKDB',
@LogToTable = 'Y'
```

### 2. **Optimización de Índices**  

Frecuencia: Diario.

Descripción: Reorganiza y reconstruye índices con niveles de fragmentación específicos para mejorar el rendimiento de las consultas.

```sql
EXECUTE dbo.IndexOptimize
@Databases = 'ALL_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@Indexes = 'ALL_INDEXES';
```

### 3. **Actualización de Estadísticas**

Frecuencia: Diario.

Descripción: Actualiza las estadísticas de todas las bases de datos para optimizar la selección de planes de ejecución en SQL Server.

```sql
EXECUTE dbo.IndexOptimize
@Databases = 'USER_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = NULL,
@FragmentationHigh = NULL,
@UpdateStatistics = 'ALL'
```

### 4. **Respaldos de Bases de Datos**

Frecuencia: Diario.

Descripción: Genera respaldos completos de todas las bases de datos en una ubicación definida.

```sql
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
(N'--'),
(N'--'),
(N'--');

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
```

### 5. **Reducción de Logs**

Frecuencia: Mensual.

Descripción: Optimiza los archivos de log mediante la reducción controlada de su tamaño, previa configuración al modelo de recuperación SIMPLE y posterior restauración al modelo FULL.

```sql
-- Declaración de tabla para bases de datos y logs
DECLARE @Databases TABLE (
    DatabaseName NVARCHAR(128),
    LogFileName NVARCHAR(128),
    DesiredSizeMB INT
);

-- Agregar bases de datos y logs a la lista
INSERT INTO @Databases (DatabaseName, LogFileName, DesiredSizeMB)
VALUES

    ('---', '---_log', 500), -- Ajusta el tamaño deseado
    ('---', '---_log', 500),
    ('---', '---_log', 500), 

-- Declaración de variables
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @LogFileName NVARCHAR(128);
DECLARE @DesiredSizeMB INT;
DECLARE @Query NVARCHAR(MAX);

-- Cursor para recorrer la lista
DECLARE db_cursor CURSOR FOR
SELECT DatabaseName, LogFileName, DesiredSizeMB
FROM @Databases;

OPEN db_cursor;

FETCH NEXT FROM db_cursor INTO @DatabaseName, @LogFileName, @DesiredSizeMB;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        -- Validar existencia de la base de datos
        IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
        BEGIN
            PRINT 'Procesando base de datos: ' + @DatabaseName + ' y log: ' + @LogFileName;

            -- Cambiar al modelo de recuperación SIMPLE
            SET @Query = 'USE [master]; ALTER DATABASE [' + @DatabaseName + '] SET RECOVERY SIMPLE;';
            EXEC sp_executesql @Query;

            -- Reducir el tamaño del archivo de log
            SET @Query = 'USE [' + @DatabaseName + ']; DBCC SHRINKFILE (N''' + @LogFileName + ''', ' + CAST(@DesiredSizeMB AS NVARCHAR) + ');';
            EXEC sp_executesql @Query;

            -- Restaurar el modelo de recuperación original (FULL)
            SET @Query = 'USE [master]; ALTER DATABASE [' + @DatabaseName + '] SET RECOVERY FULL;';
            EXEC sp_executesql @Query;

            PRINT 'Finalizado: ' + @DatabaseName;
        END
        ELSE
        BEGIN
            PRINT 'Base de datos no encontrada: ' + @DatabaseName;
        END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        PRINT 'Error procesando la base de datos: ' + @DatabaseName + '. Mensaje: ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DatabaseName, @LogFileName, @DesiredSizeMB;
END

-- Cerrar y liberar el cursor
CLOSE db_cursor;
DEALLOCATE db_cursor;
```
