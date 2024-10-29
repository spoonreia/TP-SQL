USE AuroraSA
GO

CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoMedioPago
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	CREATE TABLE #TempMediosPago (
            nombreEN VARCHAR(50),
            nombreES VARCHAR(150)
        );

    SET @sql = '
    INSERT INTO #TempMediosPago (nombreEN, nombreES)
    SELECT a.F1 as nombreEN, a.F2 as nombreES
	FROM OPENROWSET(
		''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxls + ''',
        ''SELECT * FROM [medios de pago$B2:C5]''
	) a
	WHERE a.F1 IS NOT NULL AND a.F2 IS NOT NULL';  -- Evitar filas vacías

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.MedioPago(nombreEN, nombreES, activo)
        SELECT 
            TRIM(nombreEN),
            TRIM(nombreES),
            1 -- activo por defecto
        FROM #TempMediosPago tm
		WHERE NOT EXISTS (
				SELECT 1 
				FROM dbAuroraSA.MedioPago AS m
				WHERE m.nombreEN COLLATE Modern_Spanish_CI_AS = tm.nombreEN COLLATE Modern_Spanish_CI_AS
			);

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.MedioPago] - ' + CAST(@reg AS VARCHAR) + N' medios de pago nuevos.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS MEDIOS DE PAGO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempMediosPago') IS NOT NULL
        DROP TABLE #TempMediosPago;

    SET NOCOUNT OFF;
END
GO