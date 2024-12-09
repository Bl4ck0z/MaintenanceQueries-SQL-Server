EXECUTE [dbo].[DatabaseIntegrityCheck]
@Databases = 'USER_DATABASES',
@CheckCommands = 'CHECKDB',
@LogToTable = 'Y'