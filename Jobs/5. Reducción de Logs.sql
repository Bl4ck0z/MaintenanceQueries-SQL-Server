-- Declaración de tabla para bases de datos y logs
DECLARE @Databases TABLE (
    DatabaseName NVARCHAR(128),
    LogFileName NVARCHAR(128),
    DesiredSizeMB INT
);

-- Agregar bases de datos y logs a la lista
INSERT INTO @Databases (DatabaseName, LogFileName, DesiredSizeMB)
VALUES

    ('C2020032', 'C2020032_log', 500), -- Ajusta el tamaño deseado
    ('Conta_Facu_Borrar', 'C2022002_log', 500),
    ('SINICIALESMONA17', 'SINICIALESMONA17_log', 500), 
    ('C_g_AGAJE_22024', 'C_g_AGAJE_22024_log', 500),
    ('c_ITSA', 'c_ITSA_log', 500),
    ('c_ITSA2017', 'c_ITSA2017_log', 500),
    ('c_ML22017', 'c_ML22017_log', 500),
    ('C_PB_FACU_2020', 'C_PB_FACU_2020_log', 500),
    ('C_PB_TRICOLOR2019', 'C_PB_TRICOLOR2019_log', 500),
    ('C_PR_ITSA', 'C_PR_ITSA_log', 500),
    ('C_PR_TRICOLOR', 'C_PR_TRICOLOR_log', 500),
    ('C_Tricolor2019', 'C_Tricolor2019_log', 500),
    ('c2016facu', 'c2016facu_log', 500),
    ('c2017', 'c2017_log', 500),
    ('cb2017', 'cb2017_log', 500),
    ('cBD1_2017', 'cBD1_2017_log', 500),
    ('Conta_Agaje_Pruebas', 'Conta_Agaje_Pruebas_log', 500),
    ('C2022002', 'C2022002_log', 500),
    ('Conta_FacuP', 'Conta_FacuP_log', 500),
    ('Conta_FacuP2', 'Conta_FacuP2_log', 500),
    ('Conta_g_AGAJE2023', 'Conta_g_AGAJE2023_log', 500),
    ('Conta_g_ITSA2023', 'Conta_g_ITSA2023_log', 500),
    ('Conta_g_TRICOLOR2023', 'Conta_g_TRICOLOR2023_log', 500),
    ('cP_FACU', 'cP_FACU_log', 500),
    ('cp_ML2', 'cp_ML2_log', 500),
    ('cp_TRICOLOR', 'cp_TRICOLOR_log', 500),
    ('cSALDOSINICIALES15', 'cSALDOSINICIALES15_log', 500),
    ('cSALDOSINICIALES2013', 'cSALDOSINICIALES2013_log', 500),
    ('cSALDOSINICIALES2014', 'cSALDOSINICIALES2014_log', 500),
    ('cSALDOSINICIALES2017', 'cSALDOSINICIALES2017_log', 500),
    ('GPRUEBAMERCA', 'GPRUEBAMERCA_log', 500),
    ('H', 'C2022002_log', 500),
    ('SICOMPRA2016', 'SICOMPRA2016_log', 500),
    ('SINICIALESITSA', 'SINICIALESITSA_log', 500),
    ('SINICIALESMONA17', 'SINICIALESMONA17_log', 500);

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