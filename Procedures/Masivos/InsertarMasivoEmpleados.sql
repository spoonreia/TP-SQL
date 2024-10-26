USE AuroraSA
GO

-- dbAuroraSA.Empleado(
-- 	idEmpleado	INT,
-- 	idSucursal	INT NOT NULL,
-- 	nombre		VARCHAR (50) NOT NULL,
-- 	apellido	VARCHAR (50) NOT NULL,
-- 	dni			INT NOT NULL,
-- 	direccion	VARCHAR (100) NOT NULL,
-- 	emailEmpre	VARCHAR (100) NOT NULL,
-- 	cargo		VARCHAR (20) NOT NULL,
-- 	activo		BIT DEFAULT 1

CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoEmpleado 
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	CREATE TABLE #TempEmpleado (
            idEmpleado	INT,
            nombre		VARCHAR(50),
            apellido	VARCHAR(50),
            dni			INT,
			direccion	VARCHAR(100),
			emailEmpre	VARCHAR(100),
			cargo		VARCHAR(20),
			sucursal	VARCHAR(30)
        );

    SET @sql = '
    INSERT INTO #TempEmpleado (idEmpleado, nombre, apellido, dni, direccion, emailEmpre, cargo, sucursal)
    SELECT [Legajo/ID] as idEmpleado, nombre, apellido, dni, direccion, [email empresa] as emailEmpre, cargo, sucursal
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxls + ''',
        ''SELECT * FROM [Empleados$]''
    ) WHERE [Legajo/ID] IS NOT NULL';  -- Evitar filas vacías

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.Empleado (idEmpleado, idSucursal, nombre, apellido, dni, direccion, emailEmpre, cargo, activo)
        SELECT 
            TE.idEmpleado,
			CAST(S.idSucursal AS INT),
			TRIM(TE.nombre),
			TRIM(TE.apellido),
			TE.dni,
			TRIM(TE.direccion),
			REPLACE(REPLACE(TE.emailEmpre, ' ', ''), CHAR(9), ''),
			TRIM(TE.cargo),
            1 -- activo por defecto
        FROM #TempEmpleado TE
		LEFT JOIN
		dbAuroraSA.Sucursal S on S.ciudad = TE.sucursal;

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Empleado] - ' + CAST(@reg AS VARCHAR) + N' empleados cargados.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCIÓN'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS EMPLEADOS'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempEmpleado') IS NOT NULL
        DROP TABLE #TempEmpleado;

    SET NOCOUNT OFF;
END
GO

-- EXEC spAuroraSA.InsertarMasivoEmpleado 'C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\TP_integrador_Archivos\Informacion_complementaria.xlsx'
-- GO
-- select * from dbAuroraSA.Empleado
-- GO
-- select * from logAuroraSA.Registro;
-- select * from dbAuroraSA.TipoCambio;