/*
	Asignatura: Base de datos aplicada
	Fecha de entrega: 05-11-2024
	Comision: 01-2900
	Grupo 13:
		Casas, Gonzalo Agustin		DNI:44004892
*/

USE AuroraSA
GO

-- SPs de ABM
-- ===========
-- CATALOGO
CREATE OR ALTER PROCEDURE spAuroraSA.CatalogoInsertar
    @nombre varchar(15),
    @nombreArchivo varchar(50),
    @tipoArchivo char(3)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			SET @nombre = UPPER(@nombre);

			IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Catalogo WHERE UPPER(nombre) = @nombre)
			BEGIN
				INSERT INTO dbAuroraSA.Catalogo (nombre, nombreArchivo, tipoArchivo)
				VALUES (@nombre, @nombreArchivo, @tipoArchivo);
            
				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] INSERCION DE CATALOGO ' + @nombre + ' CORRECTA';

					SET @texto = '[dbAuroraSA.Catalogo] - Inserción de catalogo: ' + @nombre;
					SET @modulo = 'INSERCION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END 
			ELSE
			BEGIN
				PRINT '[ERROR] - CATALOGO ' + @nombre + ' YA EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR EL NUEVO CATALOGO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE spAuroraSA.CatalogoEliminar 
	@nombre AS VARCHAR(15)
AS
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(10);

	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM dbAuroraSA.Catalogo WHERE UPPER(nombre) = UPPER(@nombre))
			BEGIN
				DELETE FROM dbAuroraSA.Catalogo WHERE UPPER(nombre) = UPPER(@nombre)

				DECLARE @reg INT = @@ROWCOUNT
				IF @reg <> 0
				BEGIN
					PRINT 'Se ha eliminado el catalogo: ' + @nombre
		
					SET @texto = '[dbAuroraSA.Catalogo] - ' + @nombre;
					EXEC spAuroraSA.InsertarLog @texto = @texto, @modulo = 'ELIMINACION'

				END
				ELSE
					PRINT '[ERROR] - NO SE PUDO ELIMINAR EL CATALOGO'
			END
			ELSE
				PRINT '[ERROR] - EL CATALOGO ' + @nombre + ' NO EXISTE';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT '[ERROR] - NO SE HA PODIDO BORRAR EL CATALOGO SOLICITADO'
		PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

	END CATCH
GO

CREATE OR ALTER PROCEDURE spAuroraSA.CatalogoActualizar
	@id INT,
	@nombre VARCHAR(15) = NULL,
	@nombreArchivo VARCHAR(50) = NULL,
	@tipoArchivo CHAR(3) = NULL
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			IF EXISTS (SELECT 1 FROM dbAuroraSA.Catalogo WHERE idCatalogo = @id)
			BEGIN
				SET @nombre = ISNULL(@nombre, (SELECT TOP 1 nombre FROM dbAuroraSA.Catalogo WHERE idCatalogo = @id));
					
				SET @nombreArchivo = ISNULL(@nombreArchivo, (SELECT TOP 1 nombreArchivo FROM dbAuroraSA.Catalogo WHERE idCatalogo = @id));
		
				SET @tipoArchivo = ISNULL(@tipoArchivo, (SELECT TOP 1 tipoArchivo FROM dbAuroraSA.Catalogo WHERE idCatalogo = @id));

				UPDATE dbAuroraSA.Catalogo
				SET nombre = @nombre, nombreArchivo = @nombreArchivo, tipoArchivo = @tipoArchivo
				WHERE idCatalogo = @id

				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] ACTUALIZACION DE CATALOGO ' + @nombre + ' CORRECTA';

					SET @texto = '[dbAuroraSA.Catalogo] - Actualización de catalogo: ' + @nombre;
					SET @modulo = 'ACTUALIZACION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END
			ELSE
			BEGIN
				PRINT '[ERROR] - CATALOGO ' + CAST(@id AS VARCHAR) + ' NO EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO ACTUALIZAR EL CATALOGO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END
GO


-- CLIENTE
CREATE OR ALTER PROCEDURE spAuroraSA.ClienteInsertar
    @tipoCliente varchar(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			SET @tipoCliente = UPPER(@tipoCliente);

			IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Cliente WHERE UPPER(tipoCliente) = @tipoCliente)
			BEGIN
				INSERT INTO dbAuroraSA.Cliente (tipoCliente, activo)
				VALUES (@tipoCliente, 1);
            
				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] INSERCION DE CLIENTE ' + @tipoCliente + ' CORRECTA';

					SET @texto = '[dbAuroraSA.Cliente] - Insercion de cliente: ' + @tipoCliente;
					SET @modulo = 'INSERCION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END 
			ELSE
			BEGIN
				PRINT '[ERROR] - CLIENTE ' + @tipoCliente + ' YA EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR EL NUEVO CLIENTE'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE spAuroraSA.ClienteEliminar 
	@tipoCliente AS VARCHAR(15)
AS
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(10);

	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM dbAuroraSA.Cliente WHERE UPPER(tipoCliente) = UPPER(@tipoCliente) AND Activo = 1)
			BEGIN
				UPDATE dbAuroraSA.Cliente SET activo = 0 WHERE UPPER(tipoCliente) = UPPER(@tipoCliente)

				DECLARE @reg INT = @@ROWCOUNT
				IF @reg <> 0
				BEGIN
					PRINT 'Se ha eliminado el cliente: ' + @tipoCliente
		
					SET @texto = '[dbAuroraSA.Cliente] - ' + @tipoCliente;
					EXEC spAuroraSA.InsertarLog @texto = @texto, @modulo = 'ELIMINACION'

				END
				ELSE
					PRINT '[ERROR] - NO SE PUDO ELIMINAR EL CLIENTE'
			END
			ELSE
				PRINT '[ERROR] - EL CLIENTE ' + @tipoCliente + ' NO EXISTE O ESTA DADO DE BAJA.';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT '[ERROR] - NO SE HA PODIDO BORRAR EL CLIENTE SOLICITADO'
		PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

	END CATCH
GO

CREATE OR ALTER PROCEDURE spAuroraSA.ClienteActualizar
	@id INT,
	@tipoCliente VARCHAR(50) = NULL,
	@activo BIT = NULL
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			IF EXISTS (SELECT 1 FROM dbAuroraSA.Cliente WHERE idCliente = @id)
			BEGIN
				SET @tipoCliente = ISNULL(@tipoCliente, (SELECT TOP 1 tipoCliente FROM dbAuroraSA.Cliente WHERE idCliente = @id));
		
				SET @activo = ISNULL(@activo, (SELECT TOP 1 activo FROM dbAuroraSA.Cliente WHERE idCliente = @id));

				UPDATE dbAuroraSA.Cliente
				SET tipoCliente = @tipoCliente, activo = @activo
				WHERE idCliente = @id

				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] ACTUALIZACION DE CLIENTE ' + @tipoCliente + ' CORRECTA';

					SET @texto = '[dbAuroraSA.Cliente] - Actualización de cliente: ' + @tipoCliente;
					SET @modulo = 'ACTUALIZACION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END
			ELSE
			BEGIN
				PRINT '[ERROR] - CLIENTE ' + CAST(@id AS VARCHAR) + ' NO EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO ACTUALIZAR EL CLIENTE'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END
GO


-- EMPLEADO
CREATE OR ALTER PROCEDURE spAuroraSA.EmpleadoInsertar
    @idSucursal INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @direccion VARCHAR(100),
    @emailEmpre VARCHAR(100),
    @cargo VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @texto VARCHAR(250);
            DECLARE @modulo VARCHAR(10);
            DECLARE @idEmpleado INT;

            SET @idEmpleado = (SELECT ISNULL(MAX(idEmpleado), 399999) + 1 FROM dbAuroraSA.Empleado);

            -- Validaciones básicas
            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Sucursal WHERE idSucursal = @idSucursal)
                THROW 50001, 'La sucursal especificada no existe.', 1;

            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Empleado WHERE dni = @dni)
            BEGIN
                INSERT INTO dbAuroraSA.Empleado (idEmpleado, idSucursal, nombre, apellido, dni, direccion, emailEmpre, cargo, activo)
                VALUES (
                    @idEmpleado,
                    @idSucursal,
                    @nombre,
                    @apellido,
                    @dni,
                    EncryptByPassPhrase('FraseSecreta', @direccion), -- dirección encriptada
                    EncryptByPassPhrase('FraseSecreta', @emailEmpre), -- email encriptado
                    @cargo,
                    1
                );

                DECLARE @reg INT = @@ROWCOUNT;

                IF @reg <> 0
                BEGIN
                    PRINT '[AVISO] INSERCION DE EMPLEADO DNI ' + CAST(@dni AS VARCHAR) +  ' APELLIDO ' + @apellido + '  CORRECTA';

                    SET @texto = '[dbAuroraSA.Empleado] - Insercion de empleado: ' + CAST(@dni AS VARCHAR);
                    SET @modulo = 'INSERCION';
                    EXEC spAuroraSA.InsertarLog @texto, @modulo;
                END
            END 
            ELSE
            BEGIN
                PRINT '[ERROR] - EMPLEADO DNI ' + CAST(@dni AS VARCHAR) + ' YA EXISTE';
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR EL NUEVO EMPLEADO';
        PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE();

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE spAuroraSA.EmpleadoEliminar 
	@dni AS int
AS
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(10);

	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM dbAuroraSA.Empleado WHERE dni= @dni AND activo = 1)
			BEGIN
				UPDATE dbAuroraSA.Empleado SET activo = 0 WHERE dni= @dni

				DECLARE @reg INT = @@ROWCOUNT
				IF @reg <> 0
				BEGIN
					PRINT 'Se ha eliminado el empleado: ' + CAST(@dni AS VARCHAR);
		
					SET @texto = '[dbAuroraSA.Empleado] - ' + CAST(@dni AS VARCHAR);
					EXEC spAuroraSA.InsertarLog @texto = @texto, @modulo = 'ELIMINACION'

				END
				ELSE
					PRINT '[ERROR] - NO SE PUDO ELIMINAR EL EMPLEADO'
			END
			ELSE
				PRINT '[ERROR] - EL EMPLEADO ' + CAST(@dni AS VARCHAR) + ' NO EXISTE O ESTA DADO DE BAJA.';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT '[ERROR] - NO SE HA PODIDO BORRAR EL EMPLEADO SOLICITADO'
		PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

	END CATCH
GO

CREATE OR ALTER PROCEDURE spAuroraSA.EmpleadoActualizar
    @dni INT,
    @idSucursal INT = NULL,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
    @direccion VARCHAR(100) = NULL,
    @emailEmpre VARCHAR(100) = NULL,
    @cargo VARCHAR(20) = NULL,
    @activo BIT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @texto VARCHAR(250);
            DECLARE @modulo VARCHAR(10);

            SET @idSucursal = ISNULL(@idSucursal, (SELECT TOP 1 idSucursal FROM dbAuroraSA.Empleado WHERE dni = @dni));

            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Empleado WHERE dni = @dni)
                THROW 50000, 'El empleado no existe.', 1;

            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Sucursal WHERE idSucursal = @idSucursal AND activo = 1)
                THROW 50001, 'La sucursal especificada no existe o esta dada de baja.', 1;

            IF EXISTS (SELECT 1 FROM dbAuroraSA.Empleado WHERE dni = @dni)
            BEGIN
                UPDATE dbAuroraSA.Empleado
                SET idSucursal = @idSucursal,
                    nombre = ISNULL(@nombre, nombre),
                    apellido = ISNULL(@apellido, apellido),
                    direccion = CASE WHEN @direccion IS NOT NULL THEN EncryptByPassPhrase('FraseSecreta', @direccion) ELSE direccion END,
                    emailEmpre = CASE WHEN @emailEmpre IS NOT NULL THEN EncryptByPassPhrase('FraseSecreta', @emailEmpre) ELSE emailEmpre END,
                    cargo = ISNULL(@cargo, cargo),
                    activo = ISNULL(@activo, activo)
                WHERE dni = @dni;

                DECLARE @reg INT = @@ROWCOUNT;

                IF @reg <> 0
                BEGIN
                    PRINT '[AVISO] ACTUALIZACION DE EMPLEADO DNI ' + CAST(@dni AS VARCHAR) + ' CORRECTA';

                    SET @texto = '[dbAuroraSA.Empleado] - Actualización de empleado: ' + CAST(@dni AS VARCHAR);
                    SET @modulo = 'ACTUALIZACION';
                    EXEC spAuroraSA.InsertarLog @texto, @modulo;
                END
            END
            ELSE
            BEGIN
                PRINT '[ERROR] - EMPLEADO DNI ' + CAST(@dni AS VARCHAR) + ' NO EXISTE';
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO ACTUALIZAR EL EMPLEADO';
        PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE();

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;
GO


-- MEDIO DE PAGO
CREATE OR ALTER PROCEDURE spAuroraSA.MedioPagoInsertar
    @nombreEN varchar(50),
	@nombreES varchar(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			SET @nombreEN = UPPER(@nombreEN);

			IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.MedioPago WHERE UPPER(nombreEN) = @nombreEN)
			BEGIN
				INSERT INTO dbAuroraSA.MedioPago (nombreEN,nombreES,activo)
				VALUES (@nombreEN,@nombreES,1);
            
				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] INSERCION DE MEDIO PAGO ' + @nombreEN + '  CORRECTA';

					SET @texto = '[dbAuroraSA.MedioPago] - Insercion de medio de pago: ' + @nombreEN;
					SET @modulo = 'INSERCION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END 
			ELSE
			BEGIN
				PRINT '[ERROR] - Medio de pago ' + @nombreEN + ' YA EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR EL NUEVO MEDIO DE PAGO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE spAuroraSA.MedioPagoEliminar 
	@id AS int
AS
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(10);

	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM dbAuroraSA.MedioPago WHERE idMedioPago = @id AND Activo = 1)
			BEGIN
				UPDATE dbAuroraSA.MedioPago SET activo = 0 WHERE idMedioPago = @id

				DECLARE @reg INT = @@ROWCOUNT
				IF @reg <> 0
				BEGIN
					PRINT 'Se ha eliminado el medio de pago: ' + CAST(@id AS VARCHAR)
		
					SET @texto = '[dbAuroraSA.MedioPago] - ' + CAST(@id AS VARCHAR);
					EXEC spAuroraSA.InsertarLog @texto = @texto, @modulo = 'ELIMINACION'

				END
				ELSE
					PRINT '[ERROR] - NO SE PUDO ELIMINAR EL MEDIO DE PAGO'
			END
			ELSE
				PRINT '[ERROR] - EL MEDIO DE PAGO ' + CAST(@id AS VARCHAR) + ' NO EXISTE O ESTA DADO DE BAJA.';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT '[ERROR] - NO SE HA PODIDO BORRAR EL MEDIO DE PAGO SOLICITADO'
		PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

	END CATCH
GO

CREATE OR ALTER PROCEDURE spAuroraSA.MedioPagoActualizar
	@id int,
	@nombreEN varchar(50) = NULL,
    @nombreES varchar(50) = NULL,
	@activo BIT = NULL
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			IF EXISTS (SELECT 1 FROM dbAuroraSA.MedioPago WHERE idMedioPago = @id)
			BEGIN
				SET @nombreEN = ISNULL(@nombreEN, (SELECT TOP 1 nombreEN FROM dbAuroraSA.MedioPago WHERE idMedioPago = @id));

				SET @nombreES = ISNULL(@nombreES, (SELECT TOP 1 nombreES FROM dbAuroraSA.MedioPago WHERE idMedioPago = @id));

				SET @activo = ISNULL(@activo, (SELECT TOP 1 activo FROM dbAuroraSA.MedioPago WHERE idMedioPago = @id));

				UPDATE dbAuroraSA.MedioPago
				SET nombreEN = @nombreEN,
				nombreES = @nombreES,
				activo = @activo
				WHERE idMedioPago = @id

				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] ACTUALIZACION DE MEDIO DE PAGO ' + CAST(@id AS VARCHAR) + ' CORRECTA';

					SET @texto = '[dbAuroraSA.MedioPago] - Actualización de medio pago: ' + CAST(@id AS VARCHAR);
					SET @modulo = 'ACTUALIZACION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END
			ELSE
			BEGIN
				PRINT '[ERROR] - MEDIO DE PAGO ' + CAST(@id AS VARCHAR) + ' NO EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO ACTUALIZAR EL MEDIO DE PAGO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END
GO


-- PRODUCTO
CREATE OR ALTER PROCEDURE spAuroraSA.ProductoInsertar
    @idCatalogo int,
	@nombre varchar(150),
	@categoria varchar(100),
	@precioUnitario decimal(10,2) = NULL,
	@precioReferencia decimal(10,2) = NULL,
	@unidadReferencia varchar(10) = NULL,
	@proveedor varchar(50) = NULL,
	@cantPorUnidad varchar(50) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			-- Validaciones básicas
            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Catalogo WHERE idCatalogo = @idCatalogo)
                THROW 50001, 'El catalogo especificado no existe.', 1;

			SET @nombre = UPPER(@nombre);

			IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Producto WHERE UPPER(nombre) = @nombre)
			BEGIN
				INSERT INTO dbAuroraSA.Producto(idCatalogo,nombre,categoria,precioUnitario,precioReferencia,unidadReferencia,proveedor,cantPorUnidad,activo)
				VALUES (@idCatalogo,@nombre,@categoria,@precioUnitario,@precioReferencia,@unidadReferencia,@proveedor,@cantPorUnidad,1);
            
				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] INSERCION DE PRODUCTO ' + @nombre + '  CORRECTA';

					SET @texto = '[dbAuroraSA.Producto] - Insercion de producto: ' + @nombre;
					SET @modulo = 'INSERCION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END 
			ELSE
			BEGIN
				PRINT '[ERROR] - PRODUCTO ' + @nombre + ' YA EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR EL NUEVO PRODUCTO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE spAuroraSA.ProductoEliminar 
	@id AS int
AS
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(10);

	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM dbAuroraSA.Producto WHERE idProducto = @id and Activo = 1)
			BEGIN
				UPDATE dbAuroraSA.Producto SET activo = 0 WHERE idProducto = @id

				DECLARE @reg INT = @@ROWCOUNT
				IF @reg <> 0
				BEGIN
					PRINT 'Se ha eliminado el producto: ' + CAST(@id AS VARCHAR)
		
					SET @texto = '[dbAuroraSA.Producto] - ' + CAST(@id AS VARCHAR);
					EXEC spAuroraSA.InsertarLog @texto = @texto, @modulo = 'ELIMINACION'

				END
				ELSE
					PRINT '[ERROR] - NO SE PUDO ELIMINAR EL PRODUCTO'
			END
			ELSE
				PRINT '[ERROR] - EL PRODUCTO ' + CAST(@id AS VARCHAR) + ' NO EXISTE O ESTA DADO DE BAJA.';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT '[ERROR] - NO SE HA PODIDO BORRAR EL PRODUCTO SOLICITADO'
		PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

	END CATCH
GO

CREATE OR ALTER PROCEDURE spAuroraSA.ProductoActualizar
	@id int,
	@idCatalogo int = NULL,
	@nombre varchar(150) = NULL,
	@categoria varchar(100) = NULL,
	@precioUnitario decimal(10,2) = NULL,
	@precioReferencia decimal(10,2) = NULL,
	@unidadReferencia varchar(10) = NULL,
	@proveedor varchar(50) = NULL,
	@cantPorUnidad varchar(50) = NULL,
	@activo bit = NULL
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Producto WHERE idProducto = @id)
				THROW 50001, 'El producto especificado no existe.', 1;

			SET @idCatalogo = ISNULL(@idCatalogo, (SELECT TOP 1 idCatalogo FROM dbAuroraSA.Producto WHERE idProducto = @id));

			IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Catalogo WHERE idCatalogo = @idCatalogo)
				THROW 50001, 'El catalogo especificado no existe.', 1;


			IF EXISTS (SELECT 1 FROM dbAuroraSA.Producto WHERE idProducto = @id)
			BEGIN
				
				SET @nombre = ISNULL(@nombre, (SELECT TOP 1 nombre FROM dbAuroraSA.Producto WHERE idProducto = @id));

				SET @categoria = ISNULL(@categoria, (SELECT TOP 1 categoria FROM dbAuroraSA.Producto WHERE idProducto = @id));

				SET @precioUnitario = ISNULL(@precioUnitario, (SELECT TOP 1 precioUnitario FROM dbAuroraSA.Producto WHERE idProducto = @id));

				SET @precioReferencia = ISNULL(@precioReferencia, (SELECT TOP 1 precioReferencia FROM dbAuroraSA.Producto WHERE idProducto = @id));

				SET @unidadReferencia = ISNULL(@unidadReferencia, (SELECT TOP 1 unidadReferencia FROM dbAuroraSA.Producto WHERE idProducto = @id));

				SET @proveedor = ISNULL(@proveedor, (SELECT TOP 1 proveedor FROM dbAuroraSA.Producto WHERE idProducto = @id));

				SET @cantPorUnidad = ISNULL(@cantPorUnidad, (SELECT TOP 1 cantPorUnidad FROM dbAuroraSA.Producto WHERE idProducto = @id));

				SET @activo = ISNULL(@activo, (SELECT TOP 1 activo FROM dbAuroraSA.Producto WHERE idProducto = @id));

				UPDATE dbAuroraSA.Producto
				SET idCatalogo = @idCatalogo,
				nombre = @nombre,
				categoria = @categoria,
				precioUnitario = @precioUnitario,
				precioReferencia = @precioReferencia,
				unidadReferencia = @unidadReferencia,
				proveedor = @proveedor,
				cantPorUnidad = @cantPorUnidad,
				activo = @activo
				WHERE idProducto = @id

				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] ACTUALIZACION DE PRODUCTO ' + CAST(@id AS VARCHAR) + ' CORRECTA';

					SET @texto = '[dbAuroraSA.Producto] - Actualización de producto: ' + CAST(@id AS VARCHAR);
					SET @modulo = 'ACTUALIZACION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END
			ELSE
			BEGIN
				PRINT '[ERROR] - PRODUCTO ' + CAST(@id AS VARCHAR) + ' NO EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO ACTUALIZAR EL PRODUCTO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END
GO


-- SUCURSAL
CREATE OR ALTER PROCEDURE spAuroraSA.SucursalInsertar
    @ciudad varchar(50),
	@direccion varchar(150),
	@telefono int = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			SET @ciudad = UPPER(@ciudad);

			IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Sucursal WHERE UPPER(ciudad) = @ciudad)
			BEGIN
				INSERT INTO dbAuroraSA.Sucursal(ciudad,direccion,telefono,activo)
				VALUES (@ciudad,@direccion,@telefono,1);
            
				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] INSERCION DE SUCURSAL ' + @ciudad + '  CORRECTA';

					SET @texto = '[dbAuroraSA.Sucursal] - Insercion de sucursal: ' + @ciudad;
					SET @modulo = 'INSERCION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END 
			ELSE
			BEGIN
				PRINT '[ERROR] - SUCURSAL ' + @ciudad + ' YA EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR LA NUEVA SUCURSAL'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE spAuroraSA.SucursalEliminar 
	@id AS int
AS
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(10);

	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM dbAuroraSA.Sucursal WHERE idSucursal = @id AND activo = 1)
			BEGIN
				UPDATE dbAuroraSA.Sucursal SET activo = 0 WHERE idSucursal = @id

				DECLARE @reg INT = @@ROWCOUNT
				IF @reg <> 0
				BEGIN
					PRINT 'Se ha eliminado la sucursal: ' + CAST(@id AS VARCHAR);
		
					SET @texto = '[dbAuroraSA.Sucursal] - ' + CAST(@id AS VARCHAR);
					EXEC spAuroraSA.InsertarLog @texto = @texto, @modulo = 'ELIMINACION'

				END
				ELSE
					PRINT '[ERROR] - NO SE PUDO ELIMINAR LA SUCURSAL'
			END
			ELSE
				PRINT '[ERROR] - LA SUCURSAL ' + CAST(@id AS VARCHAR) + ' NO EXISTE O ESTA DADA DE BAJA.';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT '[ERROR] - NO SE HA PODIDO BORRAR LA SUCURSAL SOLICITADA'
		PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

	END CATCH
GO

CREATE OR ALTER PROCEDURE spAuroraSA.SucursalActualizar
	@id int,
	@ciudad varchar(50) = NULL,
	@direccion varchar(150) = NULL,
	@telefono int = NULL,
	@activo bit = NULL
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			IF EXISTS (SELECT 1 FROM dbAuroraSA.Sucursal WHERE idSucursal = @id)
			BEGIN
				SET @ciudad = ISNULL(@ciudad, (SELECT TOP 1 ciudad FROM dbAuroraSA.Sucursal WHERE idSucursal = @id));

				SET @direccion = ISNULL(@direccion, (SELECT TOP 1 direccion FROM dbAuroraSA.Sucursal WHERE idSucursal = @id));

				SET @telefono = ISNULL(@telefono, (SELECT TOP 1 telefono FROM dbAuroraSA.Sucursal WHERE idSucursal = @id));

				SET @activo = ISNULL(@activo, (SELECT TOP 1 activo FROM dbAuroraSA.Sucursal WHERE idSucursal = @id));

				UPDATE dbAuroraSA.Sucursal
				SET ciudad = @ciudad,
				direccion = @direccion,
				telefono = @telefono,
				activo = @activo
				WHERE idSucursal = @id

				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] ACTUALIZACION DE SUCURSAL ' + CAST(@id AS VARCHAR) + ' CORRECTA';

					SET @texto = '[dbAuroraSA.Sucursal] - Actualización de sucursal: ' + CAST(@id AS VARCHAR);
					SET @modulo = 'ACTUALIZACION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END
			ELSE
			BEGIN
				PRINT '[ERROR] - SUCURSAL ' + CAST(@id AS VARCHAR) + ' NO EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO ACTUALIZAR LA SUCURSAL'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END
GO


-- TURNO
CREATE OR ALTER PROCEDURE spAuroraSA.TurnoInsertar
    @nombre varchar(20),
	@horaIni time(7),
	@horaFin time(7)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			SET @nombre = UPPER(@nombre);

			IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Turno WHERE UPPER(nombre) = @nombre)
			BEGIN
				INSERT INTO dbAuroraSA.Turno(nombre,horaIni,horaFin,activo)
				VALUES (@nombre,@horaIni,@horaFin,1);
            
				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] INSERCION DE TURNO ' + @nombre + '  CORRECTA';

					SET @texto = '[dbAuroraSA.Turno] - Insercion de turno: ' + @nombre;
					SET @modulo = 'INSERCION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END 
			ELSE
			BEGIN
				PRINT '[ERROR] - TURNO ' + @nombre + ' YA EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR EL NUEVO TURNO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE spAuroraSA.TurnoEliminar 
	@id AS int
AS
	DECLARE @texto VARCHAR(250);
	DECLARE @modulo VARCHAR(10);

	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM dbAuroraSA.Turno WHERE idTurno = @id AND Activo = 1)
			BEGIN
				UPDATE dbAuroraSA.Turno SET activo = 0 WHERE idTurno = @id

				DECLARE @reg INT = @@ROWCOUNT
				IF @reg <> 0
				BEGIN
					PRINT 'Se ha eliminado el turno: ' + CAST(@id AS VARCHAR)
		
					SET @texto = '[dbAuroraSA.Turno] - ' + CAST(@id AS VARCHAR);
					EXEC spAuroraSA.InsertarLog @texto = @texto, @modulo = 'ELIMINACION'

				END
				ELSE
					PRINT '[ERROR] - NO SE PUDO ELIMINAR EL TURNO'
			END
			ELSE
				PRINT '[ERROR] - EL TURNO ' + CAST(@id AS VARCHAR) + ' NO EXISTE O ESTA DADO DE BAJA';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT '[ERROR] - NO SE HA PODIDO BORRAR EL TURNO SOLICITADO'
		PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

	END CATCH
GO

CREATE OR ALTER PROCEDURE spAuroraSA.TurnoActualizar
	@id int,
	@nombre varchar(20) = NULL,
	@horaIni time(7) = NULL,
	@horaFin time(7) = NULL,
	@activo bit = NULL
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @texto VARCHAR(250);
			DECLARE @modulo VARCHAR(10);

			IF EXISTS (SELECT 1 FROM dbAuroraSA.Turno WHERE idTurno = @id)
			BEGIN
				SET @nombre = ISNULL(@nombre, (SELECT TOP 1 nombre FROM dbAuroraSA.Turno WHERE idTurno = @id));

				SET @horaIni = ISNULL(@horaIni, (SELECT TOP 1 horaIni FROM dbAuroraSA.Turno WHERE idTurno = @id));

				SET @horaFin = ISNULL(@horaFin, (SELECT TOP 1 horaFin FROM dbAuroraSA.Turno WHERE idTurno = @id));

				SET @activo = ISNULL(@activo, (SELECT TOP 1 activo FROM dbAuroraSA.Turno WHERE idTurno = @id));

				UPDATE dbAuroraSA.Turno
				SET nombre = @nombre,
				horaIni = @horaIni,
				horaFin = @horaFin,
				activo = @activo
				WHERE idTurno = @id

				DECLARE @reg INT =  @@ROWCOUNT;

				IF @reg <> 0
				BEGIN
					PRINT '[AVISO] ACTUALIZACION DE TURNO ' + CAST(@id AS VARCHAR) + ' CORRECTA';

					SET @texto = '[dbAuroraSA.Turno] - Actualización de turno: ' + CAST(@id AS VARCHAR);
					SET @modulo = 'ACTUALIZACION';
					EXEC spAuroraSA.InsertarLog @texto, @modulo;
				END
			END
			ELSE
			BEGIN
				PRINT '[ERROR] - TURNO ' + CAST(@id AS VARCHAR) + ' NO EXISTE';
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO ACTUALIZAR EL TURNO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
    END CATCH;
END
GO


-- VENTA
CREATE OR ALTER PROCEDURE spAuroraSA.VentaInsertar
    @idFactura char(11),
    @tipoFactura char(1),
    @idCliente int,
    @idEmpleado int,
    @idSucursal int,
    @idMedioPago int,
    @identificaPago varchar(16),
    @productos varchar(MAX) -- Cadena delimitada de productos
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @texto VARCHAR(250);
            DECLARE @modulo VARCHAR(10);
            DECLARE @idVenta int;
            DECLARE @montoTotal decimal(10,2) = 0;
            DECLARE @tipoCambio decimal(10,2);
			DECLARE @dniEmpleado int;

            -- Validaciones básicas
            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Cliente WHERE idCliente = @idCliente)
                THROW 50001, 'El cliente especificado no existe.', 1;
            
            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Empleado WHERE idEmpleado = @idEmpleado)
                THROW 50002, 'El empleado especificado no existe.', 1;

            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Sucursal WHERE idSucursal = @idSucursal)
                THROW 50003, 'La sucursal especificada no existe.', 1;

            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.MedioPago WHERE idMedioPago = @idMedioPago)
                THROW 50004, 'El medio de pago especificado no existe.', 1;

			IF EXISTS (SELECT 1 FROM dbAuroraSA.Factura WHERE nroFactura = @idFactura)
                THROW 50005, 'El idFactura ya existe.', 1;

			SET @dniEmpleado = (SELECT dni FROM dbAuroraSA.Empleado where idEmpleado = @idEmpleado);


            -- Insertar la venta
            INSERT INTO dbAuroraSA.Venta
            (
                idCliente,
                idEmpleado,
                idSucursal,
                idMedioPago,
                fechaHora,
                montoTotal
            )
            VALUES
            (
                @idCliente,
                @idEmpleado,
                @idSucursal,
                @idMedioPago,
                GETDATE(),
                0 -- Se actualizará después de calcular el total
            );

            SET @idVenta = SCOPE_IDENTITY();

            -- Procesar la cadena de productos
            DECLARE @productoStr NVARCHAR(MAX) = @productos;
            DECLARE @idProducto INT;
            DECLARE @genero VARCHAR(6);
            DECLARE @cantidad INT;
            DECLARE @precioUnitario DECIMAL(10,2);

            WHILE CHARINDEX(';', @productoStr) > 0
            BEGIN
                DECLARE @item NVARCHAR(MAX) = LEFT(@productoStr, CHARINDEX(';', @productoStr) - 1);
                SET @productoStr = SUBSTRING(@productoStr, CHARINDEX(';', @productoStr) + 1, LEN(@productoStr));

                SET @idProducto = CAST(PARSENAME(REPLACE(@item, '-', '.'), 3) AS INT);
                SET @genero = PARSENAME(REPLACE(@item, '-', '.'), 2);
                SET @cantidad = CAST(PARSENAME(REPLACE(@item, '-', '.'), 1) AS INT);

                -- Obtener el precio unitario y convertirlo
                SET @precioUnitario = (SELECT precioUnitario FROM dbAuroraSA.Producto WHERE idProducto = @idProducto);

                -- Insertar el detalle de venta
                INSERT INTO dbAuroraSA.VentaDetalle
                (
                    idVenta,
                    idProducto,
                    genero,
                    cantidad,
                    precioUnitario
                )
                VALUES
                (
                    @idVenta,
                    @idProducto,
                    @genero,
                    @cantidad,
                    @precioUnitario
                );

                -- Acumular el monto total
                SET @montoTotal += @precioUnitario * @cantidad;
            END

            -- Actualizar el monto total en la tabla Venta
            UPDATE dbAuroraSA.Venta
            SET montoTotal = @montoTotal
            WHERE idVenta = @idVenta;

			INSERT INTO dbAuroraSA.Factura
            (
                idVenta,
                tipoDoc,
				nroDoc,
				nroFactura,
				tipoFactura,
				total,
				iva,
				fechaEmision,
				identificaPago,
				estado
            )
            VALUES
            (
                @idVenta,
                'DNI',
                @dniEmpleado,
				@idFactura,
                @tipoFactura,
				@montoTotal,
				@montoTotal * 1.21,
                GETDATE(),
				@identificaPago,
				CASE WHEN 
					NULLIF(@identificaPago,'') IS NULL THEN 'EMITIDA'
                ELSE 'PAGADA'
				END
            );

            -- Registrar en el log
            SET @texto = '[dbAuroraSA.Venta] - Factura: ' + @idFactura + ' - Monto: ' + CAST(@montoTotal AS VARCHAR);
            SET @modulo = 'INSERCION';
            EXEC spAuroraSA.InsertarLog @texto, @modulo;

            PRINT '[AVISO] INSERCIÓN DE VENTA ' + @idFactura + ' CORRECTA';

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR LA VENTA';
        PRINT N'[ERROR] - ' + '[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE();
        
        THROW;
    END CATCH;
END;
GO

-- CREATE OR ALTER PROCEDURE spAuroraSA.VentaEliminar
--     @idVenta int,
--     @motivo varchar(100)  -- Nuevo parámetro para el motivo
-- AS
-- BEGIN
--     BEGIN TRY
--         BEGIN TRANSACTION
--             DECLARE @texto VARCHAR(250);
--             DECLARE @modulo VARCHAR(10);
--             DECLARE @idFactura char(11);
--             DECLARE @montoTotal decimal(10,2);
-- 
--             -- Verificar que la venta existe
--             IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Venta WHERE idVenta = @idVenta)
--                 THROW 50001, 'La venta especificada no existe.', 1;
-- 
--             -- Obtener datos para el log antes de eliminar
--             SELECT 
--                 @idFactura = idFactura,
--                 @montoTotal = montoTotal
--             FROM dbAuroraSA.Venta 
--             WHERE idVenta = @idVenta;
-- 
--             -- Eliminar primero los detalles (por FK)
--             DELETE FROM dbAuroraSA.VentaDetalle
--             WHERE idVenta = @idVenta;
-- 
--             -- Eliminar la venta
--             DELETE FROM dbAuroraSA.Venta
--             WHERE idVenta = @idVenta;
-- 
--             -- Registrar en el log (ahora incluye el motivo)
--             SET @texto = '[dbAuroraSA.Venta] - Factura: ' + @idFactura + ' - Monto: ' + CAST(@montoTotal AS VARCHAR) + ' - Motivo: ' + @motivo;
--             SET @modulo = 'ELIMINACION';
--             EXEC spAuroraSA.InsertarLog @texto, @modulo = 'ELIMINACION';
-- 
--             PRINT '[AVISO] ELIMINACIÓN DE VENTA ' + @idFactura + ' CORRECTA';
-- 
--         COMMIT TRANSACTION
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--             
--         PRINT N'[ERROR] - NO SE HA PODIDO ELIMINAR LA VENTA'
--         PRINT N'[ERROR] - ' + '[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE();
--         
--         THROW;
--     END CATCH;
-- END;
-- GO

-- CREATE OR ALTER PROCEDURE spAuroraSA.VentaActualizar
--     @idFactura char(11),
--     @idMedioPago int = NULL,
--     @identificaPago varchar(16) = NULL,
--     @idProducto int = NULL,
--     @cantidadAjuste int = NULL,
--     @motivo varchar(100)
-- AS
-- BEGIN
--     BEGIN TRY
--         BEGIN TRANSACTION
--             DECLARE @texto VARCHAR(250);
--             DECLARE @modulo VARCHAR(10);
--             DECLARE @idVenta int;
--             DECLARE @cantidadActual int;
--             DECLARE @cantidadNueva int;
-- 			DECLARE @precioUnitario decimal(10,2);
-- 			DECLARE @tipoCambio decimal(10,2);
-- 
-- 			SET @tipoCambio = (SELECT TOP 1 precioCompra FROM dbAuroraSA.TipoCambio order by Fecha DESC);
-- 
-- 			SET @precioUnitario = (SELECT precioUnitario FROM dbAuroraSA.Producto where idProducto = @idProducto) * @tipoCambio;
--             
--             -- Obtener el idVenta a partir de la factura
--             SELECT @idVenta = idVenta 
--             FROM dbAuroraSA.Venta 
--             WHERE idFactura = @idFactura;
-- 
--             IF @idVenta IS NULL
--                 THROW 50001, 'La factura especificada no existe.', 1;
-- 
--             -- Si viene información de medio de pago, actualizarla
--             IF @idMedioPago IS NOT NULL
--             BEGIN
--                 -- Verificar que el medio de pago existe
--                 IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.MedioPago WHERE idMedioPago = @idMedioPago)
--                     THROW 50002, 'El medio de pago especificado no existe.', 1;
-- 
--                 UPDATE dbAuroraSA.Venta
--                 SET 
--                     idMedioPago = @idMedioPago,
--                     identificaPago = @identificaPago
--                 WHERE idVenta = @idVenta;
-- 
--                 SET @texto = '[dbAuroraSA.Venta] - Factura: ' + @idFactura + 
--                             ' - Nuevo medio pago: ' + CAST(@idMedioPago AS VARCHAR) + 
--                             ' - Nuevo identif. pago: ' + ISNULL(@identificaPago, 'N/A') +
--                             ' - Motivo: ' + @motivo;
--                 
--                 EXEC spAuroraSA.InsertarLog @texto, 'VENTA';
--             END
-- 
--             -- Si viene información de producto y cantidad, actualizarla
--             IF @idProducto IS NOT NULL AND @cantidadAjuste IS NOT NULL
--             BEGIN
--                 -- Obtener la cantidad actual y precio unitario
--                 SELECT 
--                     @cantidadActual = cantidad,
--                     @precioUnitario = precioUnitario
--                 FROM dbAuroraSA.VentaDetalle
--                 WHERE idVenta = @idVenta AND idProducto = @idProducto;
-- 
--                 IF @cantidadActual IS NULL
--                     THROW 50003, 'El producto especificado no existe en esta venta.', 1;
-- 
--                 SET @cantidadNueva = @cantidadActual + @cantidadAjuste;
-- 
--                 -- Si la cantidad nueva es <= 0, eliminar el detalle y la venta
--                 IF @cantidadNueva <= 0
--                 BEGIN
--                     DELETE FROM dbAuroraSA.VentaDetalle
--                     WHERE idVenta = @idVenta AND idProducto = @idProducto;
-- 
--                     -- Actualizar el montoTotal en Venta
--                     DELETE FROM dbAuroraSA.Venta
--                     WHERE idVenta = @idVenta;
-- 
--                     SET @texto = '[dbAuroraSA.Venta] - Producto eliminado de venta - Factura: ' + @idFactura + 
--                                 ' - Producto: ' + CAST(@idProducto AS VARCHAR) +
--                                 ' - Cantidad eliminada: ' + CAST(@cantidadActual AS VARCHAR) +
--                                 ' - Motivo: ' + @motivo;
--                 END
--                 ELSE
--                 BEGIN
--                     -- Actualizar la cantidad
--                     UPDATE dbAuroraSA.VentaDetalle
--                     SET cantidad = @cantidadNueva
--                     WHERE idVenta = @idVenta AND idProducto = @idProducto;
-- 
--                     -- Actualizar el montoTotal en Venta
--                     UPDATE dbAuroraSA.Venta
--                     SET montoTotal = montoTotal + (@cantidadAjuste * @precioUnitario)
--                     WHERE idVenta = @idVenta;
-- 
--                     SET @texto = '[dbAuroraSA.Venta] - Cantidad actualizada en venta - Factura: ' + @idFactura + 
--                                 ' - Producto: ' + CAST(@idProducto AS VARCHAR) +
--                                 ' - Cantidad anterior: ' + CAST(@cantidadActual AS VARCHAR) +
--                                 ' - Cantidad nueva: ' + CAST(@cantidadNueva AS VARCHAR) +
--                                 ' - Motivo: ' + @motivo;
--                 END
-- 
--                 EXEC spAuroraSA.InsertarLog @texto, 'ACTUALIZACION';
--             END
-- 
--             PRINT '[AVISO] ACTUALIZACIÓN DE VENTA ' + @idFactura + ' CORRECTA';
-- 
--         COMMIT TRANSACTION
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0
--             ROLLBACK TRANSACTION;
--             
--         PRINT N'[ERROR] - NO SE HA PODIDO ACTUALIZAR LA VENTA'
--         PRINT N'[ERROR] - ' + '[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE();
--         
--         THROW;
--     END CATCH;
-- END;
-- GO


-- NOTACREDITO
CREATE OR ALTER PROCEDURE spAuroraSA.NotaCreditoInsertar
    @IdFactura INT,
    @IdEmpleado INT,
    @MontoTotal DECIMAL(18,2),
    @Motivo VARCHAR(500),
    @TipoDevolucion VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @texto VARCHAR(250);
            DECLARE @modulo VARCHAR(10);
            
            -- Validación de tipo de devolución
            IF @TipoDevolucion NOT IN ('EFECTIVO', 'PRODUCTO')
            BEGIN
                PRINT '[ERROR] - Tipo de devolución inválido';
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Validar que la factura exista
            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Factura WHERE IdFactura = @IdFactura)
            BEGIN
                PRINT '[ERROR] - La factura no existe';
                ROLLBACK TRANSACTION;
                RETURN;
            END

			-- Verificar si la venta existe y está pagada
			IF NOT EXISTS (
				SELECT 1 
				FROM dbAuroraSA.Factura 
				WHERE idFactura = @IdFactura 
				AND identificaPago <> ''
			)
			BEGIN
				PRINT '[ERROR] - La venta debe existir y estar pagada';
				ROLLBACK TRANSACTION;
				RETURN;
			END

            -- Validar que el empleado exista
            IF NOT EXISTS (SELECT 1 FROM dbAuroraSA.Empleado WHERE IdEmpleado = @IdEmpleado)
            BEGIN
                PRINT '[ERROR] - El empleado no existe';
                ROLLBACK TRANSACTION;
                RETURN;
            END

			-- Validar que la nota de credito para la factura no exista
            IF EXISTS (SELECT 1 FROM dbAuroraSA.NotaCredito WHERE IdFactura = @IdFactura)
            BEGIN
                PRINT '[ERROR] - La factura ya tiene una nota de credito asociada.';
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Insertar Nota de Crédito
            INSERT INTO dbAuroraSA.NotaCredito 
            (IdFactura, IdEmpleado, MontoTotal, Motivo, TipoDevolucion, Estado)
            VALUES 
            (@IdFactura, @IdEmpleado, @MontoTotal, @Motivo, @TipoDevolucion, 'P');
            
            DECLARE @reg INT = @@ROWCOUNT;
            IF @reg <> 0
            BEGIN
                PRINT '[AVISO] INSERCION DE NOTA DE CREDITO CORRECTA';
                SET @texto = '[dbAuroraSA.NotaCredito] - Insercion de Nota de Credito para Factura: ' + CAST(@IdFactura AS VARCHAR);
                SET @modulo = 'INSERCION';
                EXEC spAuroraSA.InsertarLog @texto, @modulo;
            END

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO INSERTAR LA NOTA DE CREDITO'
        PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
    END CATCH;
END;
GO