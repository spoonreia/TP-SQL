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
			SET @texto = 'Modif de datos en la tabla: TipoCambio. Donde: fecha = ' + convert(VARCHAR(10),@fecha,120);
			SET @modulo = 'MODIFICACIÓN';
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
			PRINT('Inserción exitosa');
			SET @texto = 'Inserción de datos en la tabla: TipoCambio. Donde: fecha = ' + convert(VARCHAR(10),@fecha,120);
			SET @modulo = 'INSERCIÓN';
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