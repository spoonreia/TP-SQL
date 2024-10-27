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
COLLATE Modern_Spanish_CI_AS
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
	idCatalogo		INT IDENTITY(1,1),
	nombre			VARCHAR (15) NOT NULL,
	nombreArchivo	VARCHAR (50) UNIQUE NOT NULL,
	tipoArchivo		CHAR(3) NOT NULL,
	activo			BIT DEFAULT 1,

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
			SET @texto = '[dbAuroraSA.TipoCambio] - Tipo de cambio modificado.';
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
			SET @texto = '[dbAuroraSA.TipoCambio] - Tipo de cambio insertado.';
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
-- ============================================================================================================
-- EJECUTAR POWERSHELL ".\ActualizarTC.ps1" PARA CARGAR TIPO DE CAMBIO BLUE (OJO CON serverName Y databaseName)
-- ============================================================================================================

-- HABILITAR LAS CONSULTAS DISTRIBUIDAS
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE
GO
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE
GO

EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
GO
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
GO

-- Insertar masivamente las sucursales
-- Se espera la ruta del archivo "Informacion_complementaria.xlsx" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoSucursal
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	CREATE TABLE #TempSucursal (
            Ciudad VARCHAR(50),
            Direccion VARCHAR(150),
            Horario VARCHAR(100),
            Telefono VARCHAR(20)  -- Lo pongo como VARCHAR para manejar el formato "5555-5551"
        );

    SET @sql = '
    INSERT INTO #TempSucursal (Ciudad, Direccion, Horario, Telefono)
    SELECT [Reemplazar por] as Ciudad, direccion, Horario, Telefono
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxls + ''',
        ''SELECT * FROM [sucursal$]''
    ) WHERE Ciudad IS NOT NULL';  -- Evitar filas vacías

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.Sucursal (ciudad, direccion, telefono, activo)
        SELECT 
            TRIM(Ciudad),
            TRIM(Direccion),
            CAST(LTRIM(RTRIM(REPLACE(Telefono, '-', ''))) AS INT),  -- Eliminar el guión del teléfono
            1 -- activo por defecto
        FROM #TempSucursal;

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Sucursal] - ' + CAST(@reg AS VARCHAR) + N' sucursales nuevas.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCIÓN'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVAS SUCURSALES'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempSucursal') IS NOT NULL
        DROP TABLE #TempSucursal;

    SET NOCOUNT OFF;
END
GO

-- Insertar masivamente los empleados
-- Se espera la ruta del archivo "Informacion_complementaria.xlsx" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoEmpleado 
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	CREATE TABLE #TempEmpleado (
            idEmpleado	INT,
            nombre		VARCHAR(50),
            apellido	VARCHAR(50),
            dni			INT,
			direccion	VARCHAR(100),
			emailEmpre	VARCHAR(100),
			cargo		VARCHAR(20),
			sucursal	VARCHAR(30)
        );

    SET @sql = '
    INSERT INTO #TempEmpleado (idEmpleado, nombre, apellido, dni, direccion, emailEmpre, cargo, sucursal)
    SELECT [Legajo/ID] as idEmpleado, nombre, apellido, dni, direccion, [email empresa] as emailEmpre, cargo, sucursal
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxls + ''',
        ''SELECT * FROM [Empleados$]''
    ) WHERE [Legajo/ID] IS NOT NULL';  -- Evitar filas vacías

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.Empleado (idEmpleado, idSucursal, nombre, apellido, dni, direccion, emailEmpre, cargo, activo)
        SELECT 
            TE.idEmpleado,
			CAST(S.idSucursal AS INT),
			TRIM(TE.nombre),
			TRIM(TE.apellido),
			TE.dni,
			TRIM(TE.direccion),
			REPLACE(REPLACE(TE.emailEmpre, ' ', ''), CHAR(9), ''),
			TRIM(TE.cargo),
            1 -- activo por defecto
        FROM #TempEmpleado TE
		LEFT JOIN
		dbAuroraSA.Sucursal S on S.ciudad = TE.sucursal;

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Empleado] - ' + CAST(@reg AS VARCHAR) + N' empleados cargados.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCIÓN'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS EMPLEADOS'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempEmpleado') IS NOT NULL
        DROP TABLE #TempEmpleado;

    SET NOCOUNT OFF;
END
GO

-- Insertar masivamente los catalogos
-- Se espera la ruta del archivo "Informacion_complementaria.xlsx" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoCatalogo
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	CREATE TABLE #TempCatalogo (
            nombre			VARCHAR(15),
			nombreArchivo	VARCHAR(50),
            tipoArchivo		CHAR(3)
        );

    SET @sql = '
    INSERT INTO #TempCatalogo (nombre, nombreArchivo, tipoArchivo)
    SELECT 
	CASE
		WHEN Productos LIKE ''%catalogo%'' THEN ''De todo''
		WHEN Productos LIKE ''%electronic%'' THEN ''Electronicos''
		WHEN Productos LIKE ''%importados%'' THEN ''Importados''
		ELSE ''ERROR''
	END as nombre,
		Productos as nombreArchivo,
	CASE WHEN
	RIGHT(Productos,4) = ''xlsx'' THEN ''XLS''
	WHEN RIGHT(Productos,4)= ''.csv'' THEN ''CSV''
	ELSE ''AAA''
	END as TipoArchivo
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxls + ''',
        ''SELECT * FROM [catalogo$]''
    ) WHERE Productos IS NOT NULL';  -- Evitar filas vacías

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.Catalogo(nombre, nombreArchivo, tipoArchivo, activo)
        SELECT 
            nombre,
			nombreArchivo,
			tipoArchivo,
            1 -- activo por defecto
        FROM #TempCatalogo;

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Catalogo] - ' + CAST(@reg AS VARCHAR) + N' catalogos cargados.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCIÓN'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS CATALOGOS'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempCatalogo') IS NOT NULL
        DROP TABLE #TempCatalogo;

    SET NOCOUNT OFF;
END
GO


-- CARGA DE DATOS INICIALES
-- =====================================

BEGIN TRY
	BEGIN TRANSACTION

	SET NOCOUNT ON;
	DECLARE @RUTA				VARCHAR(100) = 'C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\TP_integrador_Archivos\';
	DECLARE @rutainfoC 			VARCHAR(300) = @RUTA + 'Informacion_complementaria.xlsx';
	DECLARE @rutaproductos 		VARCHAR(300) = @RUTA + 'Productos\';

	EXEC spAuroraSA.InsertarMasivoSucursal @rutaxls = @rutainfoC;
	EXEC spAuroraSA.InsertarMasivoEmpleado @rutaxls = @rutainfoC;
	EXEC spAuroraSA.InsertarMasivoCatalogo @rutaxls = @rutainfoC;
	
	PRINT 'Carga de datos inicial COMPLETA'
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT '[ERROR] - NO SE HA PODIDO IMPORTAR SATISFACTORIAMENTE UNO DE LOS ARCHIVOS'
	PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
	
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

END CATCH

SET NOCOUNT OFF;

select * from dbAuroraSA.Catalogo;
select * from dbAuroraSA.Sucursal;
select * from dbAuroraSA.Empleado;
-- select * from dbAuroraSA.Producto;