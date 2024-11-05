/*
	Asignatura: Base de datos aplicada
	Fecha de entrega: 05-11-2024
	Comision: 01-2900
	Grupo 13:
		Casas, Gonzalo Agustin		DNI:44004892
*/

USE AuroraSA;
GO

-- Crear roles de seguridad
CREATE ROLE Supervisor;
CREATE ROLE Vendedor;
GO

-- Encriptación de datos sensibles de empleados
-- ALTER TABLE dbAuroraSA.Empleado
-- ADD CONSTRAINT EncryptPersonalData
--     CHECK (
--         CONNECTIONPROPERTY('ENCRYPTIONENABLED') = 1
--     );

-- Cifrar columnas sensibles
-- ALTER TABLE dbAuroraSA.Empleado
-- ALTER COLUMN nombre varbinary(256);
-- ALTER TABLE dbAuroraSA.Empleado
-- ALTER COLUMN apellido varbinary(256);
-- ALTER TABLE dbAuroraSA.Empleado
-- ALTER COLUMN emailEmpre varbinary(256);

GO

-- Permitir ejecución de todos los SPs en el esquema dbo
GRANT EXECUTE ON SCHEMA::spAuroraSA TO Public CASCADE;
GO

-- Denegar ejecución de sp_InsertarNotaCredito al rol Vendedor
DENY EXECUTE ON OBJECT::spAuroraSA.NotaCreditoInsertar TO Vendedor;
GO

-- Restringir operaciones de modificación de datos a nivel de base de datos
DENY INSERT, UPDATE, DELETE ON DATABASE::AuroraSA TO Public;
GO

-- Backup SP (REVISAR LA RUTA ESPECIFICADA PARA EL BKP) - AGREGUE EL PERMISO DE "USUARIOS AUTENTIFICADOS" EN LA CARPETA PARA QUE ME DEJE HACER EL BKP
CREATE OR ALTER PROCEDURE spAuroraSA.BackupAuroraSA
AS
BEGIN
    DECLARE @fecha VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112)
    DECLARE @path VARCHAR(256) = 'C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\Backups\' + @fecha + '_AuroraSA.bak'
    
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

EXEC dbo.sp_add_job
    @job_name = N'Daily_Ventas_Backup'; -- defino nombre del trabajo

EXEC sp_add_jobstep
    @job_name = N'Daily_Ventas_Backup', 
    @step_name = N'Execute Backup', -- descripción de lo que hace.
    @subsystem = N'TSQL', -- Define que el paso ejecutará un comando T-SQL (Transact-SQL)
    @command = N'USE AuroraSA; EXEC spAuroraSA.BackupAuroraSA'; -- realiza la operación de respaldo para los datos de AuroraSA

EXEC dbo.sp_add_schedule
    @schedule_name = N'DailyBackupSchedule',
    @freq_type = 4, -- Daily
    @freq_interval = 1, -- Define que el trabajo se ejecute cada 1 día.
    @active_start_time = 230000; -- 11:00 PM

EXEC sp_attach_schedule
    @job_name = N'Daily_Ventas_Backup',
    @schedule_name = N'DailyBackupSchedule'; -- vincula el trabajo con el horario de ejecución, para que se ejecute diariamente a las 11:00 PM.