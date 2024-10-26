/*
	GRUPO 13:
		Casas, Gonzalo Agustin		DNI:44004892
		Chicchi, Romina				DNI:41450508
		
*/

/*
---------------- !IMPORTANTE! ------------------
Antes de ejecutar este script cambiar la siguiente variable '@RUTA'
del archivo para realizar la carga de datos masiva, indique el path 
correcto con sus archivos de carga.

	@rutaventas		
	@rutacatalogo 	
	@rutaelectronic_accesories
	@rutaproductos_importados 	
	@rutainfocomplementaria

*/
USE master
GO
-- Creación de la base de datos y sus esquemas
-- ===========================================
IF EXISTS(SELECT 1 FROM SYS.DATABASES WHERE NAME = 'AuroraSA')
	ALTER DATABASE AuroraSA SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE AuroraSA;
GO

CREATE DATABASE AuroraSA
GO

ALTER DATABASE AuroraSA
	SET COMPATIBILITY_LEVEL = 140

USE AuroraSA
GO



IF EXISTS(SELECT 1 FROM SYS.schemas WHERE name LIKE 'dbAuroraSA')
	DROP SCHEMA dbAuroraSA;
GO

CREATE SCHEMA dbAuroraSA;
GO

IF EXISTS(SELECT 1 FROM SYS.schemas WHERE name LIKE 'spAuroraSA')
	DROP SCHEMA spAuroraSA;
GO

CREATE SCHEMA spAuroraSA
GO

IF EXISTS(SELECT 1 FROM SYS.schemas WHERE name LIKE 'logAuroraSA')
	DROP SCHEMA logAuroraSA;
GO

CREATE SCHEMA logAuroraSA
GO


-- Creación de las tablas especificadas en el DER
-- ==============================================
IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[SucursalProducto]'))
	DROP TABLE dbAuroraSA.SucursalProducto;
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[VentaDetalle]'))
	DROP TABLE dbAuroraSA.VentaDetalle;
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Producto]'))
	DROP TABLE dbAuroraSA.Producto;
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Venta]'))
	DROP TABLE dbAuroraSA.Venta;
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[logAuroraSA].[Registro]'))
	DROP TABLE logAuroraSA.Registro;
GO

CREATE TABLE logAuroraSA.Registro(
	id		INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	fecha	DATE DEFAULT GETDATE(),
	hora	TIME DEFAULT GETDATE(),
	texto	VARCHAR(250),
	modulo	VARCHAR(15)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[TipoCambio]'))
	DROP TABLE dbAuroraSA.TipoCambio;
GO

CREATE TABLE dbAuroraSA.TipoCambio(
	idTC			INT IDENTITY(1,1),
	precioVenta		DECIMAL(10,4) NOT NULL,
	precioCompra	DECIMAL(10,4) NOT NULL,
	Fecha			DATE NOT NULL,
	
	CONSTRAINT PK_idTipoCambio PRIMARY KEY (idTC)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Turno]'))
	DROP TABLE dbAuroraSA.Turno;
GO

CREATE TABLE dbAuroraSA.Turno(
	idTurno		INT IDENTITY(1,1),
	nombre		VARCHAR (50) NOT NULL,
	horaIni		TIME NOT NULL,
	horaFin		TIME NOT NULL,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idTurno PRIMARY KEY (idTurno),

	CONSTRAINT CK_nombreTurno CHECK (
		nombre in ('Mañana','Tarde','Jornada completa')
	)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Empleado]'))
	DROP TABLE dbAuroraSA.Empleado;
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Sucursal]'))
	DROP TABLE dbAuroraSA.Sucursal;
GO

CREATE TABLE dbAuroraSA.Sucursal(
	idSucursal	INT IDENTITY(1,1),
	ciudad		VARCHAR (50) NOT NULL,
	direccion	VARCHAR (50) NOT NULL,
	telefono	INT,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idSucursal PRIMARY KEY (idSucursal),

	CONSTRAINT CK_Telefono_Longitud CHECK (
		telefono BETWEEN 1000000000 AND 9999999999 -- Chequea que sean 10 numeros de telefono
	),

	CONSTRAINT CK_ciudad CHECK(
		ciudad in ('San Justo', 'Ramos Mejia','Lomas del Mirador')
	)
)
GO

CREATE TABLE dbAuroraSA.Empleado(
	idEmpleado	INT,
	idSucursal	INT NOT NULL,
	nombre		VARCHAR (50) NOT NULL,
	apellido	VARCHAR (50) NOT NULL,
	dni			INT NOT NULL,
	direccion	VARCHAR (100) NOT NULL,
	emailEmpre	VARCHAR (50) NOT NULL,
	cargo		VARCHAR (20) NOT NULL,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idEmpleado PRIMARY KEY (idEmpleado),

	CONSTRAINT FK_idSucursalEmpleado FOREIGN KEY (idSucursal)
	REFERENCES dbAuroraSA.Sucursal(idSucursal),

	CONSTRAINT CK_dni CHECK (
		dni between 10000000 and 99999999 -- DNI de 8 digitos
	),

	CONSTRAINT CK_cargo CHECK(
		cargo in ('Cajero','Supervisor','Gerente de sucursal')
	)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Cliente]'))
	DROP TABLE dbAuroraSA.Cliente;
GO

CREATE TABLE dbAuroraSA.Cliente(
	idCliente	INT IDENTITY(1,1),
	tipoCliente	VARCHAR (50) NOT NULL,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idCliente PRIMARY KEY (idCliente),

	CONSTRAINT CK_tipoCliente CHECK(
		tipoCliente in ('Normal','Member')
	)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[MedioPago]'))
	DROP TABLE dbAuroraSA.MedioPago;
GO

CREATE TABLE dbAuroraSA.MedioPago(
	idMedioPago	INT IDENTITY(1,1),
	nombre		VARCHAR (50) NOT NULL,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idMedioPago PRIMARY KEY (idMedioPago),

	CONSTRAINT CK_nombreMedioPago CHECK(
		nombre in ('Credit card','Cash','Ewallet')
	)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Catalogo]'))
	DROP TABLE dbAuroraSA.Catalogo;
GO

CREATE TABLE dbAuroraSA.Catalogo(
	idCatalogo	INT IDENTITY(1,1),
	nombre		VARCHAR (15) NOT NULL,
	tipoArchivo CHAR(3) NOT NULL,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idCatalogo PRIMARY KEY (idCatalogo),

	CONSTRAINT CK_nombreCatalogo CHECK(
		nombre in ('De todo','Electronicos','Importados')
	),

	CONSTRAINT CK_tipoArchivo CHECK(
		nombre in ('CSV','XLS')
	)
)
GO

CREATE TABLE dbAuroraSA.Producto(
	idProducto			INT IDENTITY(1,1),
	idCatalogo			INT,
	nombre				VARCHAR(150) NOT NULL,
	categoria			VARCHAR(100) NOT NULL,
	precioUnitario		DECIMAL(10,2),
	precioReferencia	DECIMAL(10,2),
	unidadReferencia	VARCHAR(10),
	proveedor			VARCHAR(20),
	cantPorUnidad		INT,
	activo				BIT DEFAULT 1,

	CONSTRAINT PK_idProducto PRIMARY KEY (idProducto),

	CONSTRAINT FK_idCatalogo FOREIGN KEY (idCatalogo)
	REFERENCES dbAuroraSA.Catalogo(idCatalogo),

	CONSTRAINT CK_cantPorUnidad CHECK(
		cantPorUnidad > 0
	)
)
GO

CREATE TABLE dbAuroraSA.Venta(
	idVenta				INT IDENTITY(1,1),
	idFactura			CHAR(11) UNIQUE NOT NULL,
	tipoFactura			CHAR(1) NOT NULL,
	idCliente			INT NOT NULL,
	idEmpleado			INT NOT NULL,
	idSucursal			INT NOT NULL,
	idMedioPago			INT NOT NULL,
	identificaPago		CHAR(16),
	fechaHora			DATETIME NOT NULL,
	montoTotal			DECIMAL(10,2) NOT NULL,

	CONSTRAINT PK_idVenta PRIMARY KEY (idVenta),

	CONSTRAINT FK_idCliente FOREIGN KEY (idCliente)
	REFERENCES dbAuroraSA.Cliente(idCliente),

	CONSTRAINT FK_idEmpleado FOREIGN KEY (idEmpleado)
	REFERENCES dbAuroraSA.Empleado(idEmpleado),

	CONSTRAINT FK_idSucursal FOREIGN KEY (idSucursal)
	REFERENCES dbAuroraSA.Sucursal(idSucursal),

	CONSTRAINT FK_idMedioPago FOREIGN KEY (idMedioPago)
	REFERENCES dbAuroraSA.MedioPago(idMedioPago),

	CONSTRAINT CK_tipoFactura CHECK(
		tipoFactura in ('A','B','C')
	)
)
GO

CREATE TABLE dbAuroraSA.VentaDetalle(
	idVentaDetalle	INT IDENTITY(1,1),
	idVenta			INT NOT NULL,
	idProducto		INT NOT NULL,
	cantidad		INT NOT NULL,
	genero			VARCHAR(6) NOT NULL,
	precioUnitario	DECIMAL(10,2) NOT NULL,

	CONSTRAINT PK_idVentaDetalle PRIMARY KEY (idVentaDetalle),

	CONSTRAINT FK_idVenta FOREIGN KEY (idVenta)
	REFERENCES dbAuroraSA.Venta(idVenta),

	CONSTRAINT FK_idProducto FOREIGN KEY (idProducto)
	REFERENCES dbAuroraSA.Producto(idProducto),

	CONSTRAINT CK_generoCli CHECK(
		genero in ('Male','Female')
	)
)
GO

CREATE TABLE dbAuroraSA.SucursalProducto(
	idSucursalProducto	INT IDENTITY(1,1),
	idSucursal			INT NOT NULL,
	idProducto			INT NOT NULL,

	CONSTRAINT PK_idSucursalProducto PRIMARY KEY (idSucursalProducto),

	CONSTRAINT FK_idSucursal2 FOREIGN KEY (idSucursal)
	REFERENCES dbAuroraSA.Sucursal(idSucursal),

	CONSTRAINT FK_idProducto2 FOREIGN KEY (idProducto)
	REFERENCES dbAuroraSA.Producto(idProducto)
)
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
			PRINT('Error en la Modificación.');
		END

    END

	SET NOCOUNT OFF;
END
GO
-- ============================================================================================================
-- EJECUTAR POWERSHELL ".\ActualizarTC.ps1" PARA CARGAR TIPO DE CAMBIO BLUE (OJO CON serverName Y databaseName)
-- ============================================================================================================