USE AuroraSA
GO

-- Creación de las tablas especificadas en el DER
-- ==============================================

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Registro]'))
	DROP TABLE logCureSA.Registro;
GO

CREATE TABLE dbAuroraSA.Registro(
	id		INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	fecha	DATE DEFAULT GETDATE(),
	hora	TIME DEFAULT GETDATE(),
	texto	VARCHAR(250),
	modulo	VARCHAR(10)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects
	WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[TipoCambio]'))
	DROP TABLE dbAuroraSA.TipoCambio;
GO

CREATE TABLE dbAuroraSA.TipoCambio(
	idTC			INT IDENTITY(1,1),
	precioVenta		DECIMAL(10,4) NOT NULL,
	precioCompra	DECIMAL(10,4) NOT NULL,
	Fecha			date,
	
	CONSTRAINT PK_idTipoCambio PRIMARY KEY (idTC)
)
GO

IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE type = 'U' AND object_id = OBJECT_ID('[dbAuroraSA].[Turno]'))
	DROP TABLE logCureSA.Turno;
GO

CREATE TABLE dbAuroraSA.Turno(
	idTurno				INT IDENTITY(1,1),
	nombre				VARCHAR (50) NOT NULL,
	horaIni				TIME NOT NULL,
	horaFin				TIME NOT NULL,
	activo				BIT DEFAULT 1,
	fechaCreacion		DATE NOT NULL,
	fechaModificacion	DATE NOT NULL,
	usuarioCreacion		VARCHAR(20) NOT NULL,
	usuarioModificacion	VARCHAR(20) NOT NULL,

	CONSTRAINT PK_idTurno PRIMARY KEY (idTurno),
	CONSTRAINT CK_nombre CHECK (
		nombre in ('Mañana','Tarde','Noche')
	)
)
GO



-- EJECUTAR POWERSHELL ".\ActualizarTC.ps1" PARA CARGAR TIPO DE CAMBIO BLUE

