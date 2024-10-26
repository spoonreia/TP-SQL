USE AuroraSA
GO

CREATE OR ALTER PROCEDURE [spAuroraSA].[ModificarDatos]
    @nombreTabla NVARCHAR(128),
    @columnasAActualizar NVARCHAR(MAX),
    @valoresNuevos NVARCHAR(MAX),
    @condicion NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(15);

    SET @SQL = N'UPDATE dbAuroraSA.' + QUOTENAME(@nombreTabla) +
               N' SET ' + @columnasAActualizar +
               N' = ' + @valoresNuevos +
               N' WHERE ' + @condicion;

    EXEC sp_executesql @SQL;

	IF @@ROWCOUNT <> 0
	BEGIN
		PRINT('Modificación exitosa');
		SET @texto = 'Modificación de datos en la tabla: ' + @nombreTabla + '. Donde: ' + @condicion;
		SET @modulo = 'MODIFICACIÓN';
		EXEC spAuroraSA.InsertarLog @texto, @modulo;
	END
	ELSE
	BEGIN
		PRINT('Error en la Modificación.');
	END

	SET NOCOUNT OFF;
END
GO