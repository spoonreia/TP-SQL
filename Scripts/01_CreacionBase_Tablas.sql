/*
	Asignatura: Base de datos aplicada
	Fecha de entrega: 05-11-2024
	Comision: 01-2900
	Grupo 13:
		Casas, Gonzalo Agustin		DNI:44004892
*/

USE master
GO
-- Creación de la base de datos y sus esquemas
-- ===========================================
IF EXISTS(SELECT 1 FROM SYS.DATABASES WHERE NAME = 'AuroraSA')
BEGIN
	ALTER DATABASE AuroraSA SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE AuroraSA
END
GO

CREATE DATABASE AuroraSA
	COLLATE Modern_Spanish_CI_AI
GO

-- Establece el nivel de compatibilidad de la base de datos a la versión de SQL Server 2017.
ALTER DATABASE AuroraSA
	SET COMPATIBILITY_LEVEL = 140

USE AuroraSA
GO


-- Esquema para todas las tablas
IF EXISTS(SELECT 1 FROM SYS.schemas WHERE name LIKE 'dbAuroraSA')
	DROP SCHEMA dbAuroraSA;
GO

CREATE SCHEMA dbAuroraSA;
GO

-- Esquema para todos los SPs
IF EXISTS(SELECT 1 FROM SYS.schemas WHERE name LIKE 'spAuroraSA')
	DROP SCHEMA spAuroraSA;
GO

CREATE SCHEMA spAuroraSA
GO


-- Esquema para la tabla de logs
IF EXISTS(SELECT 1 FROM SYS.schemas WHERE name LIKE 'logAuroraSA')
	DROP SCHEMA logAuroraSA;
GO

CREATE SCHEMA logAuroraSA
GO


-- Creación de las tablas especificadas en el DER
-- ==============================================

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
	nombre		VARCHAR (20) NOT NULL,
	horaIni		TIME NOT NULL,
	horaFin		TIME NOT NULL,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idTurno PRIMARY KEY (idTurno),

	CONSTRAINT CK_nombreTurno CHECK (
		nombre in ('Maniana','Tarde','Jornada completa')
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
	ciudad		VARCHAR (50) UNIQUE NOT NULL,
	direccion	VARCHAR (150) NOT NULL,
	telefono	INT,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idSucursal PRIMARY KEY (idSucursal),

	CONSTRAINT CK_Telefono_Longitud CHECK (
		telefono BETWEEN 10000000 AND 99999999 -- Chequea que sean 8 numeros de telefono
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
	emailEmpre	VARCHAR (100) NOT NULL,
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
	nombreEN	VARCHAR (50) NOT NULL,
	nombreES	VARCHAR (50) NOT NULL,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idMedioPago PRIMARY KEY (idMedioPago),

	CONSTRAINT CK_nombreMedioPago CHECK(
		nombreEN in ('Credit card','Cash','Ewallet')
	)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Catalogo]'))
	DROP TABLE dbAuroraSA.Catalogo;
GO

CREATE TABLE dbAuroraSA.Catalogo(
	idCatalogo		INT IDENTITY(1,1),
	nombre			VARCHAR (15) NOT NULL,
	nombreArchivo	VARCHAR (50) UNIQUE NOT NULL,
	tipoArchivo		CHAR(3) NOT NULL,

	CONSTRAINT PK_idCatalogo PRIMARY KEY (idCatalogo),

	CONSTRAINT CK_nombreCatalogo CHECK(
		nombre in ('De todo','Electronicos','Importados')
	),

	CONSTRAINT CK_tipoArchivo CHECK(
		tipoArchivo in ('CSV','XLS')
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
	proveedor			VARCHAR(50),
	cantPorUnidad		VARCHAR(50),
	activo				BIT DEFAULT 1,

	CONSTRAINT PK_idProducto PRIMARY KEY (idProducto),

	CONSTRAINT FK_idCatalogo FOREIGN KEY (idCatalogo)
	REFERENCES dbAuroraSA.Catalogo(idCatalogo)
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
	identificaPago		VARCHAR(16),
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
	genero			VARCHAR(6) NOT NULL,
	cantidad		INT NOT NULL,
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

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[NotaCredito]'))
	DROP TABLE dbAuroraSA.NotaCredito;
GO

-- Crear tabla NotaCredito
CREATE TABLE dbAuroraSA.NotaCredito (
    IdNotaCredito INT PRIMARY KEY IDENTITY(1,1),
    IdVenta INT NOT NULL,
    IdEmpleado INT NOT NULL,
    FechaEmision DATETIME DEFAULT GETDATE(),
    MontoTotal DECIMAL(18,2) NOT NULL,
    Estado CHAR(1) DEFAULT 'P', -- P: Pendiente, A: Aprobado, R: Rechazado
    Motivo VARCHAR(500) NOT NULL,
    TipoDevolucion VARCHAR(10) NOT NULL CHECK (TipoDevolucion IN ('EFECTIVO', 'PRODUCTO')),
    IdProductoNuevo INT NULL,
    CONSTRAINT FK_NotaCredito_Venta FOREIGN KEY (IdVenta) 
        REFERENCES dbAuroraSA.Venta(IdVenta) ON DELETE NO ACTION,
    CONSTRAINT FK_NotaCredito_Empleado FOREIGN KEY (IdEmpleado) 
        REFERENCES dbAuroraSA.Empleado(IdEmpleado),
    CONSTRAINT FK_NotaCredito_ProductoNuevo FOREIGN KEY (IdProductoNuevo) 
        REFERENCES dbAuroraSA.Producto(IdProducto)
);