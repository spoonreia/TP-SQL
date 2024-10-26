USE AuroraSA
GO

CREATE OR ALTER PROCEDURE [spAuroraSA].[InsertarDatos]
    @nombreTabla NVARCHAR(128),
    @columnas NVARCHAR(MAX),
    @valores NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(15);

    SET @SQL = N'INSERT INTO dbAuroraSA.' + QUOTENAME(@nombreTabla) +
               N' (' + @columnas + N') ' +
               N'VALUES' + @valores;

    EXEC sp_executesql @SQL;

	IF @@ROWCOUNT <> 0
	BEGIN
		PRINT('Inserción exitosa');
		SET @texto = 'Inserción de datos en la tabla: ' + @nombreTabla + '. Con: ' + @valores;
		SET @modulo = 'INSERCIÓN';
		EXEC spAuroraSA.InsertarLog @texto, @modulo;
	END
	ELSE
	BEGIN
		PRINT('Error en la Inserción.');
	END

	SET NOCOUNT OFF;
END
GO