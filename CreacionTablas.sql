USE AuroraSA
GO

-- Creación de las tablas especificadas en el DER
-- ==============================================

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Registro]'))
	DROP TABLE dbAuroraSA.Registro;
GO

CREATE TABLE dbAuroraSA.Registro(
	id		INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	fecha	DATE DEFAULT GETDATE(),
	hora	TIME DEFAULT GETDATE(),
	texto	VARCHAR(250),
	modulo	VARCHAR(10)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[TipoCambio]'))
	DROP TABLE dbAuroraSA.TipoCambio;
GO

CREATE TABLE dbAuroraSA.TipoCambio(
	idTC			INT IDENTITY(1,1),
	precioVenta		DECIMAL(10,4) NOT NULL,
	precioCompra	DECIMAL(10,4) NOT NULL,
	Fecha			date NOT NULL,
	
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
		nombre in ('Mañana','Tarde','Noche')
	)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Empleado]'))
	DROP TABLE dbAuroraSA.Empleado;
GO

CREATE TABLE dbAuroraSA.Empleado(
	idEmpleado	INT IDENTITY(1000,1),
	nombre		VARCHAR (50) NOT NULL,
	apellido	VARCHAR (50) NOT NULL,
	sexo		CHAR(1) NOT NULL,
	activo		BIT DEFAULT 1,

	CONSTRAINT PK_idEmpleado PRIMARY KEY (idEmpleado),

	CONSTRAINT CK_sexo CHECK (
		sexo in ('M','F')
	)
)
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

	CONSTRAINT chk_Telefono_Longitud CHECK (
		telefono BETWEEN 1000000000 AND 9999999999 -- Chequea que sean 10 numeros de telefono
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

-- EJECUTAR POWERSHELL ".\ActualizarTC.ps1" PARA CARGAR TIPO DE CAMBIO BLUE

