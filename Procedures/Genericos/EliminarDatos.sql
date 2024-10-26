USE AuroraSA
GO

CREATE OR ALTER PROCEDURE [spAuroraSA].[EliminarDatos]
    @nombreTabla NVARCHAR(128),
    @condicion NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
	DECLARE @texto VARCHAR(250);
    DECLARE @modulo VARCHAR(15);

    SET @SQL = N'DELETE FROM dbAuroraSA.' + QUOTENAME(@nombreTabla) +
               N' WHERE ' + @condicion;

    EXEC sp_executesql @SQL;

	IF @@ROWCOUNT <> 0
	BEGIN
		PRINT('Eliminación exitosa');
		SET @texto = 'Eliminación de datos en la tabla: ' + @nombreTabla + '. Donde: ' + @condicion;
		SET @modulo = 'ELIMINACIÓN';
		EXEC spAuroraSA.InsertarLog @texto, @modulo;
	END
	ELSE
	BEGIN
		PRINT('Error en la Eliminación.');
	END

	SET NOCOUNT OFF;
END
GO