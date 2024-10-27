USE AuroraSA
GO

CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoCatalogo
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	CREATE TABLE #TempCatalogo (
            nombre			VARCHAR(15),
			nombreArchivo	VARCHAR(50),
            tipoArchivo		CHAR(3)
        );

    SET @sql = '
    INSERT INTO #TempCatalogo (nombre, nombreArchivo, tipoArchivo)
    SELECT 
	CASE
		WHEN Productos LIKE ''%catalogo%'' THEN ''De todo''
		WHEN Productos LIKE ''%electronic%'' THEN ''Electronicos''
		WHEN Productos LIKE ''%importados%'' THEN ''Importados''
		ELSE ''ERROR''
	END as nombre,
		Productos as nombreArchivo,
	CASE WHEN
	RIGHT(Productos,4) = ''xlsx'' THEN ''XLS''
	WHEN RIGHT(Productos,4)= ''.csv'' THEN ''CSV''
	ELSE ''AAA''
	END as TipoArchivo
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxls + ''',
        ''SELECT * FROM [catalogo$]''
    ) WHERE Productos IS NOT NULL';  -- Evitar filas vacías

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.Catalogo(nombre, nombreArchivo, tipoArchivo, activo)
        SELECT 
            nombre,
			nombreArchivo,
			tipoArchivo,
            1 -- activo por defecto
        FROM #TempCatalogo;

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Catalogo] - ' + CAST(@reg AS VARCHAR) + N' catalogos cargados.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCIÓN'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS CATALOGOS'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempCatalogo') IS NOT NULL
        DROP TABLE #TempCatalogo;

    SET NOCOUNT OFF;
END
GO