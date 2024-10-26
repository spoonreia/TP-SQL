USE AuroraSA
GO

-- dbAuroraSA.Sucursal(
-- 	idSucursal	INT IDENTITY(1,1),
-- 	ciudad		VARCHAR (50) NOT NULL,
-- 	direccion	VARCHAR (150) NOT NULL,
-- 	telefono	INT,
-- 	activo		BIT DEFAULT 1,

CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoSucursal
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@ilog AS NVARCHAR(250),
			@reg AS INT

	CREATE TABLE #TempSucursal (
            Ciudad VARCHAR(50),
            Direccion VARCHAR(150),
            Horario VARCHAR(100),
            Telefono VARCHAR(20)  -- Lo pongo como VARCHAR para manejar el formato "5555-5551"
        );

    SET @sql = '
    INSERT INTO #TempSucursal (Ciudad, Direccion, Horario, Telefono)
    SELECT [Reemplazar por] as Ciudad, direccion, Horario, Telefono
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxls + ''',
        ''SELECT * FROM [sucursal$]''
    ) WHERE Ciudad IS NOT NULL';  -- Evitar filas vacías

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.Sucursal (ciudad, direccion, telefono, activo)
        SELECT 
            TRIM(Ciudad),
            TRIM(Direccion),
            CAST(LTRIM(RTRIM(REPLACE(Telefono, '-', ''))) AS INT),  -- Eliminar el guión del teléfono
            1 -- activo por defecto
        FROM #TempSucursal;

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Sucursal] - ' + CAST(@reg AS VARCHAR) + N' sucursales nuevas.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCIÓN'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS MÉDICOS'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempSucursal') IS NOT NULL
        DROP TABLE #TempSucursal;

    SET NOCOUNT OFF;
END
GO

-- EXEC spAuroraSA.InsertarMasivoSucursal 'C:\Users\gonza\OneDrive\Documents\Facultad\Base de datos aplicada\TP-SQL\TP_integrador_Archivos\Informacion_complementaria.xlsx'
-- GO
-- select * from dbAuroraSA.Sucursal
-- GO
-- select * from logAuroraSA.Registro;
