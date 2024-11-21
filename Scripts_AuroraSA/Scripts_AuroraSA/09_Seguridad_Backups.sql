/*
	Asignatura: Base de datos aplicada
	Fecha de entrega: 05-11-2024
	Comision: 01-2900
	Grupo 13:
		Casas, Gonzalo Agustin		DNI:44004892

---------------- !IMPORTANTE! ------------------
Antes de ejecutar este script cambiar la siguiente variable '@path'
del archivo para realizar el backup de la base de datos.

	@path		

*/
USE AuroraSA;
GO

-- Desconectar usuarios activos antes de eliminar
-- Primero, cerrar todas las sesiones activas
-- IMPORTANTE: Ejecutar esto con mucho cuidado en un entorno de producción
ALTER DATABASE AuroraSA SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AuroraSA SET MULTI_USER;
GO

-- Eliminar miembros de los roles antes de eliminarlos
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Supervisor')
BEGIN
    -- Eliminar miembros del rol Supervisor
    EXEC sp_droprolemember 'Supervisor', 'supervisor_user';
END
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Vendedor')
BEGIN
    -- Eliminar miembros del rol Vendedor
    EXEC sp_droprolemember 'Vendedor', 'vendedor_user';
END
GO

-- Eliminar roles si ya existen
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Supervisor')
    DROP ROLE Supervisor;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Vendedor')
    DROP ROLE Vendedor;
GO

-- Crear roles de seguridad
CREATE ROLE Supervisor;
CREATE ROLE Vendedor;
GO

-- Eliminar logins si ya existen
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'supervisor_login')
    DROP LOGIN supervisor_login;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'vendedor_login')
    DROP LOGIN vendedor_login;
GO

-- Crear login para Supervisor
CREATE LOGIN supervisor_login WITH PASSWORD = '1234', DEFAULT_DATABASE = AuroraSA,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

-- Crear login para Vendedor
CREATE LOGIN vendedor_login WITH PASSWORD = '1234', DEFAULT_DATABASE = AuroraSA,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

-- Eliminar usuarios si ya existen
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'supervisor_user')
    DROP USER supervisor_user;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'vendedor_user')
    DROP USER vendedor_user;
GO

-- Crear usuario para el rol Supervisor
CREATE USER supervisor_user FOR LOGIN supervisor_login;
ALTER ROLE Supervisor ADD MEMBER supervisor_user;
GO

-- Crear usuario para el rol Vendedor
CREATE USER vendedor_user FOR LOGIN vendedor_login;
ALTER ROLE Vendedor ADD MEMBER vendedor_user;
GO

USE AuroraSA;
GO

-- Denegar permisos de DELETE, INSERT, UPDATE en todas las tablas para Supervisor y Vendedor
-- Asegurarse de que las tablas estén en el esquema dbAuroraSA
GRANT SELECT ON SCHEMA::dbAuroraSA TO Supervisor;
GRANT SELECT ON SCHEMA::dbAuroraSA TO Vendedor;

DENY DELETE ON SCHEMA::dbAuroraSA TO Supervisor;
DENY INSERT ON SCHEMA::dbAuroraSA TO Supervisor;
DENY UPDATE ON SCHEMA::dbAuroraSA TO Supervisor;
DENY DELETE ON SCHEMA::dbAuroraSA TO Vendedor;
DENY INSERT ON SCHEMA::dbAuroraSA TO Vendedor;
DENY UPDATE ON SCHEMA::dbAuroraSA TO Vendedor;
GO

-- Denegar ejecución del procedimiento NotaCreditoInsertar al rol Vendedor
-- Asegurarse de que el procedimiento esté en el esquema spAuroraSA
GRANT EXECUTE ON SCHEMA::spAuroraSA TO Supervisor;
GRANT EXECUTE ON SCHEMA::spAuroraSA TO Vendedor;

DENY EXECUTE ON OBJECT::spAuroraSA.NotaCreditoInsertar TO Vendedor;
GO

-- Backup SP (REVISAR LA RUTA ESPECIFICADA PARA EL BKP) - AGREGUE EL PERMISO DE "USUARIOS AUTENTIFICADOS" EN LA CARPETA PARA QUE ME DEJE HACER EL BKP
CREATE OR ALTER PROCEDURE spAuroraSA.BackupAuroraSA
AS
BEGIN
    DECLARE @fecha VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112)
    DECLARE @path VARCHAR(256) = 'C:\Users\Gosa\Documents\Facultad\BDDA\TP-SQL\Backups\' + @fecha + '_AuroraSA.bak'
    
    BACKUP DATABASE AuroraSA
    TO DISK = @path
    WITH FORMAT, -- Fuerza a SQL Server a sobrescribir cualquier archivo de respaldo anterior en la ubicación especificada
         -- COMPRESSION, -- Comprime el archivo de respaldo para reducir el tamaño de almacenamiento
         STATS = 10; -- Muestra el progreso del respaldo cada 10% completado
END;
GO

EXEC spAuroraSA.BackupAuroraSA;
GO

-- Crear job para backup diario
USE msdb;
GO

-- Eliminar el trabajo existente si ya existe
IF EXISTS (SELECT job_id FROM dbo.sysjobs WHERE name = N'Daily_Ventas_Backup')
BEGIN
    EXEC msdb.dbo.sp_delete_job
        @job_name = N'Daily_Ventas_Backup';
END

-- Eliminar el schedule existente si ya existe
IF EXISTS (SELECT name FROM dbo.sysschedules WHERE name = N'DailyBackupSchedule')
BEGIN
    EXEC msdb.dbo.sp_delete_schedule
        @schedule_name = N'DailyBackupSchedule';
END


EXEC dbo.sp_add_job
    @job_name = N'Daily_Ventas_Backup'; -- defino nombre del trabajo

EXEC sp_add_jobstep
    @job_name = N'Daily_Ventas_Backup', 
    @step_name = N'Execute Backup', -- descripción de lo que hace.
    @subsystem = N'TSQL',	-- Es el lenguaje de consultas extendido de SQL Server, 
							-- que incluye características adicionales como variables, 
							-- control de flujo, procedimientos almacenados, entre otros. 
							-- Al establecer @subsystem = N'TSQL', se indica que el paso 
							-- de este trabajo se ejecutará como una consulta o procedimiento T-SQL.
    @command = N'USE AuroraSA; EXEC spAuroraSA.BackupAuroraSA'; -- realiza la operación de respaldo para los datos de AuroraSA

EXEC dbo.sp_add_schedule
    @schedule_name = N'DailyBackupSchedule',
    @freq_type = 4, -- Daily
    @freq_interval = 1, -- Define que el trabajo se ejecute cada 1 día.
    @active_start_time = 230000; -- 11:00 PM

EXEC sp_attach_schedule
    @job_name = N'Daily_Ventas_Backup',
    @schedule_name = N'DailyBackupSchedule'; -- vincula el trabajo con el horario de ejecución, para que se ejecute diariamente a las 11:00 PM.



-- SI QUISIERAMOS DESACTIVAR EL JOB:
-- EXEC sp_update_job @job_name = 'Daily_Ventas_Backup', @enabled = 0;

-- VERIFICAMOS SI SE ACTIVO EL JOB DE BACKUP
SELECT job_id, name, enabled
FROM dbo.sysjobs
WHERE name = 'Daily_Ventas_Backup';

-- VERIFICAMOS HISTORIAL DE EJECUCIONES
EXEC dbo.sp_help_jobhistory 
    @job_name = N'Daily_Ventas_Backup';

-- VERIFICAMOS LOS PARAMETROS CARGADOS:
SELECT 
    j.name AS JobName,
    s.name AS ScheduleName,
    s.freq_type,
    s.freq_interval,
    s.active_start_time
FROM 
    dbo.sysjobs AS j
JOIN 
    dbo.sysjobschedules AS js ON j.job_id = js.job_id
JOIN 
    dbo.sysschedules AS s ON js.schedule_id = s.schedule_id
WHERE 
    j.name = 'Daily_Ventas_Backup';