/*
	GRUPO 13:
		Casas, Gonzalo Agustin		DNI:44004892		
*/

USE AuroraSA
GO

-- CREACIÓN DE STORE PROCEDURES
-- ===========================================
-- Procedures genéricos para insertar datos
CREATE OR ALTER PROCEDURE spAuroraSA.[InsertarLog]
	@texto VARCHAR(250),
	@modulo VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	IF LTRIM(RTRIM(@modulo)) = ''
		SET @texto = 'N/A'

	INSERT INTO logAuroraSA.Registro (texto, modulo)
	VALUES (@texto, @modulo)
END
GO

CREATE OR ALTER PROCEDURE [spAuroraSA].[GenericoModificarDatos]
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
		SET @modulo = 'MODIFICACION';
		EXEC spAuroraSA.InsertarLog @texto, @modulo;
	END
	ELSE
	BEGIN
		PRINT('Error en la Modificación.');
	END

	SET NOCOUNT OFF;
END
GO

CREATE OR ALTER PROCEDURE [spAuroraSA].[GenericoInsertarDatos]
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
		PRINT('Insercion exitosa');
		SET @texto = 'Insercion de datos en la tabla: ' + @nombreTabla + '. Con: ' + @valores;
		SET @modulo = 'INSERCION';
		EXEC spAuroraSA.InsertarLog @texto, @modulo;
	END
	ELSE
	BEGIN
		PRINT('Error en la INSERCION.');
	END

	SET NOCOUNT OFF;
END
GO

CREATE OR ALTER PROCEDURE [spAuroraSA].[GenericoEliminarDatos]
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
		SET @texto = 'Eliminacion de datos en la tabla: ' + @nombreTabla + '. Donde: ' + @condicion;
		SET @modulo = 'ELIMINACION';
		EXEC spAuroraSA.InsertarLog @texto, @modulo;
	END
	ELSE
	BEGIN
		PRINT('Error en la Eliminación.');
	END

	SET NOCOUNT OFF;
END
GO

-- CARGAR TIPO DE CAMBIO (HECHO CON POWERSHELL)
CREATE OR ALTER PROCEDURE spAuroraSA.[CargarTC]
	@precioVenta	DECIMAL(10,4),
	@precioCompra	DECIMAL(10,4),
	@fecha			DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(15);

	-- Verificar si la fecha ya existe en la tabla
    IF EXISTS (SELECT 1 FROM dbAuroraSA.TipoCambio WHERE Fecha = @fecha)
    BEGIN
        -- Si la fecha ya existe, actualizar precioVenta y precioCompra
        UPDATE dbAuroraSA.TipoCambio
        SET precioVenta = @precioVenta,
            precioCompra = @precioCompra
        WHERE Fecha = @fecha;

		IF @@ROWCOUNT <> 0
		BEGIN
			PRINT('Modificación exitosa');
			SET @texto = '[dbAuroraSA.TipoCambio] - Tipo de cambio modificado.';
			SET @modulo = 'MODIFICACION';
			EXEC spAuroraSA.InsertarLog @texto, @modulo;
		END
		ELSE
		BEGIN
			PRINT('Error en la Modificación.');
		END

    END
    ELSE
    BEGIN
        -- Si la fecha no existe, insertar un nuevo registro
        INSERT INTO dbAuroraSA.TipoCambio (precioVenta, precioCompra, Fecha)
        VALUES (@precioVenta, @precioCompra, @fecha);

		IF @@ROWCOUNT <> 0
		BEGIN
			PRINT('Insercion exitosa');
			SET @texto = '[dbAuroraSA.TipoCambio] - Tipo de cambio insertado.';
			SET @modulo = 'INSERCION';
			EXEC spAuroraSA.InsertarLog @texto, @modulo;
		END
		ELSE
		BEGIN
			PRINT('Error en la Insercion.');
		END

    END

	SET NOCOUNT OFF;
END
GO