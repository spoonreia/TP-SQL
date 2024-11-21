/*
	Asignatura: Base de datos aplicada
	Fecha de entrega: 05-11-2024
	Comision: 01-2900
	Grupo 13:
		Casas, Gonzalo Agustin		DNI:44004892
*/

USE AuroraSA
GO

-- HABILITAR LAS CONSULTAS DISTRIBUIDAS
-- Habilita opciones avanzadas
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE
GO
-- Habilita consultas distribuidas ad hoc: Permite ejecutar consultas distribuidas temporales (como OPENROWSET y OPENDATASOURCE)
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE
GO

-- Permite el procesamiento en el servidor: Configura el proveedor OLE DB 
-- (Microsoft.ACE.OLEDB.12.0, utilizado para acceder a archivos de Microsoft 
-- Access y Excel) para ejecutarse dentro del proceso de SQL Server
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
GO

-- Habilita parámetros dinámicos: Permite que el proveedor Microsoft.ACE.OLEDB.12.0 use parámetros dinámicos en consultas. 
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
GO

-- Insertar masivamente las sucursales
-- Se espera la ruta del archivo "Informacion_complementaria.xlsx" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.SucursalInsertarMasivo
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
            TRIM(TS.Ciudad),
            TRIM(TS.Direccion),
            CAST(LTRIM(RTRIM(REPLACE(TS.Telefono, '-', ''))) AS INT),  -- Eliminar el guión del teléfono
            1 -- activo por defecto
        FROM #TempSucursal TS
		WHERE NOT EXISTS (
				SELECT 1 
				FROM dbAuroraSA.Sucursal AS s
				WHERE TS.Ciudad COLLATE Modern_Spanish_CI_AI = s.ciudad
			);

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Sucursal] - ' + CAST(@reg AS VARCHAR) + N' sucursales nuevas.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

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
CREATE OR ALTER PROCEDURE spAuroraSA.EmpleadoInsertarMasivo
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
			EncryptByPassPhrase('FraseSecreta', TRIM(TE.direccion)), -- Encriptar direccion
            EncryptByPassPhrase('FraseSecreta', REPLACE(REPLACE(TE.emailEmpre, ' ', ''), CHAR(9), '')), -- Encriptar emailEmpre
			TRIM(TE.cargo),
            1 -- activo por defecto
        FROM #TempEmpleado TE
		LEFT JOIN
		dbAuroraSA.Sucursal S on S.ciudad = TE.sucursal COLLATE Modern_Spanish_CI_AI
		WHERE NOT EXISTS (
				SELECT 1 
				FROM dbAuroraSA.Empleado AS e
				WHERE TE.idEmpleado = e.idEmpleado 
			);

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Empleado] - ' + CAST(@reg AS VARCHAR) + N' empleados cargados.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

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
CREATE OR ALTER PROCEDURE spAuroraSA.CatalogoInsertarMasivo
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
        INSERT INTO dbAuroraSA.Catalogo(nombre, nombreArchivo, tipoArchivo)
        SELECT 
            tc.nombre,
			tc.nombreArchivo,
			tc.tipoArchivo
        FROM #TempCatalogo tc
		WHERE NOT EXISTS (
				SELECT 1 
				FROM dbAuroraSA.Catalogo AS c
				WHERE tc.nombre COLLATE Modern_Spanish_CI_AI = c.nombre
			);

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Catalogo] - ' + CAST(@reg AS VARCHAR) + N' catalogos cargados.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

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

-- Insertar masivamente los productos
-- Se espera la ruta de la carpeta "Productos" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.ProductoInsertarMasivo
    @rutaxls NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @precioCompra DECIMAL(10,4);
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @archivo NVARCHAR(300);
    DECLARE @archivoC NVARCHAR(300);
    DECLARE @nombre NVARCHAR(300);
    DECLARE @tipoArchivo CHAR(3);
    DECLARE @idCatalogo INT;
    DECLARE @mensaje NVARCHAR(100);
    DECLARE @reg INT;
    DECLARE @sheet NVARCHAR(50);
    DECLARE @contador INT = 0;
    DECLARE @totalCatalogos INT;

    -- Verificar el tipo de cambio
    SELECT TOP 1 @precioCompra = precioCompra
    FROM dbAuroraSA.TipoCambio
    ORDER BY Fecha DESC;

    IF @precioCompra IS NULL
    BEGIN
        PRINT 'Por favor ejecutar el PowerShell "ActualizarTC.ps1" para calcular el tipo de cambio actual';
        RETURN;
    END

    -- Crear tabla temporal
    IF OBJECT_ID('tempdb..#TempProducto') IS NOT NULL
        DROP TABLE #TempProducto;

    CREATE TABLE #TempProducto (
        categoria            VARCHAR(100),
        nombre               VARCHAR(150),
        precioUnitario       DECIMAL(10, 2),
        precioReferencia     DECIMAL(10, 2),
        unidadReferencia     VARCHAR(10),
        proveedor            VARCHAR(50),
        cantPorUnidad        VARCHAR(50)
    );

    -- Contar el número total de registros en el catálogo
    SELECT @totalCatalogos = COUNT(*)
    FROM dbAuroraSA.Catalogo;

    WHILE @contador < @totalCatalogos
    BEGIN
        SELECT 
            @idCatalogo = idCatalogo,
            @nombre = nombre,
            @archivo = nombreArchivo,
            @tipoArchivo = tipoArchivo
        FROM dbAuroraSA.Catalogo
        ORDER BY idCatalogo
        OFFSET @contador ROWS FETCH NEXT 1 ROWS ONLY;

        SET @archivoC = @rutaxls + @archivo;

        BEGIN TRY
            IF @tipoArchivo = 'CSV'
            BEGIN
                CREATE TABLE #TempProductoCSV (
                    id                 INT,
                    category           VARCHAR(100),
                    nameP              VARCHAR(150),
                    price              DECIMAL(10, 2),
                    reference_price    DECIMAL(10, 2),
                    reference_unit     VARCHAR(10),
                    dateP              VARCHAR(50)
                );

                SET @sql = N'BULK INSERT #TempProductoCSV FROM ''' + @archivoC + ''' WITH(CHECK_CONSTRAINTS,FORMAT = ''CSV'', CODEPAGE = ''65001'', FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';

                EXEC sp_executesql @sql;

                INSERT INTO #TempProducto(categoria, nombre, precioUnitario, precioReferencia, unidadReferencia, proveedor, cantPorUnidad)
                SELECT category, nameP, price, reference_price, reference_unit, 'Generico' as proveedor, 1
                FROM #TempProductoCSV;
            END
            ELSE IF @tipoArchivo = 'XLS'
            BEGIN
                IF @nombre = 'Electronicos'
                BEGIN
                    SET @sheet = '[Sheet1$]';
                    SET @sql = N'
                    INSERT INTO #TempProducto (nombre, precioUnitario)
                    SELECT 
                        [Product] as nombre,
                        CAST(REPLACE(REPLACE([Precio Unitario en dolares], '','', ''.''), ''$'', '''') AS DECIMAL(10,2)) as precioUnitario
                    FROM OPENROWSET(
                        ''Microsoft.ACE.OLEDB.12.0'',
                        ''Excel 12.0; HRD=YES; Database=' + @archivoC + ''',
                        ''SELECT * FROM ' + @sheet + '''
                    ) WHERE [Product] IS NOT NULL;';
                END
                ELSE
                BEGIN
                    SET @sheet = '[Listado de Productos$]';
                    SET @sql = N'
                    INSERT INTO #TempProducto (categoria, nombre, precioUnitario, proveedor, cantPorUnidad)
                    SELECT 
                        [Categoria] as categoria,
                        TRIM([NombreProducto]) as nombre,
                        CAST(REPLACE(REPLACE([PrecioUnidad], '','', ''.''), ''$'', '''') AS DECIMAL(10,2)) as precioUnitario,
                        TRIM([Proveedor]) as proveedor,
                        TRIM([CantidadPorUnidad]) as cantPorUnidad
                    FROM OPENROWSET(
                        ''Microsoft.ACE.OLEDB.12.0'',
                        ''Excel 12.0; Database=' + @archivoC + ''',
                        ''SELECT * FROM ' + @sheet + '''
                    ) WHERE [IdProducto] IS NOT NULL;';
                END
                
                EXEC sp_executesql @sql;
            END

            BEGIN TRANSACTION;

            -- Insertar en la tabla final
            INSERT INTO dbAuroraSA.Producto (
                idCatalogo, 
                nombre, 
                categoria, 
                precioUnitario, 
                precioReferencia, 
                unidadReferencia, 
                proveedor, 
                cantPorUnidad, 
                activo
            )
            SELECT 
                @idCatalogo,
                nombre,
                COALESCE(categoria, 'Generico'),
                precioUnitario * @precioCompra,
                COALESCE(precioReferencia * @precioCompra, NULL),
                COALESCE(unidadReferencia, NULL),
                COALESCE(proveedor, NULL),
                COALESCE(cantPorUnidad, '1'),
                1
            FROM #TempProducto AS tp
            WHERE NOT EXISTS (
                SELECT 1 
                FROM dbAuroraSA.Producto AS p
                WHERE p.nombre = tp.nombre COLLATE Modern_Spanish_CI_AI
            );

            SET @reg = @@ROWCOUNT;
            
            SET @mensaje = N'[dbAuroraSA.Producto] - ' + CAST(@reg AS VARCHAR) + N' productos cargados del catalogo ' + @nombre;
            PRINT @mensaje;

            EXEC spAuroraSA.InsertarLog 
                @texto = @mensaje, 
                @modulo = 'INSERCION';

            COMMIT TRANSACTION;

            -- Limpiar la tabla temporal para el siguiente archivo
            TRUNCATE TABLE #TempProducto;

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS PRODUCTOS';
            PRINT N'[ERROR] - Archivo: ' + @archivo;
            PRINT N'[ERROR] - [LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE();
        END CATCH

        SET @contador = @contador + 1;
    END

    -- Limpiar
    IF OBJECT_ID('tempdb..#TempProducto') IS NOT NULL
        DROP TABLE #TempProducto;

    IF OBJECT_ID('tempdb..#TempProductoCSV') IS NOT NULL
        DROP TABLE #TempProductoCSV;
	
	WITH ProductosDuplicados AS (
    SELECT 
        idProducto,         -- La clave primaria o identificador del producto
        nombre, 
        ROW_NUMBER() OVER(PARTITION BY nombre ORDER BY idProducto) AS fila_numero
    FROM dbAuroraSA.Producto
	)
	DELETE FROM ProductosDuplicados
	WHERE fila_numero > 1;


    SET NOCOUNT OFF;
END;
GO


-- Insertar masivamente los medios de pago
-- Se espera la ruta del archivo "Informacion_complementaria.xlsx" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.MedioPagoInsertarMasivo
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	CREATE TABLE #TempMediosPago (
            nombreEN VARCHAR(50),
            nombreES VARCHAR(150)
        );

    SET @sql = '
    INSERT INTO #TempMediosPago (nombreEN, nombreES)
    SELECT a.F1 as nombreEN, a.F2 as nombreES
	FROM OPENROWSET(
		''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxls + ''',
        ''SELECT * FROM [medios de pago$B2:C5]''
	) a
	WHERE a.F1 IS NOT NULL AND a.F2 IS NOT NULL';  -- Evitar filas vacías

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.MedioPago(nombreEN, nombreES, activo)
        SELECT 
            TRIM(nombreEN),
            TRIM(nombreES),
            1 -- activo por defecto
        FROM #TempMediosPago tm
		WHERE NOT EXISTS (
				SELECT 1 
				FROM dbAuroraSA.MedioPago AS m
				WHERE m.nombreEN = tm.nombreEN COLLATE Modern_Spanish_CI_AI
			);

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.MedioPago] - ' + CAST(@reg AS VARCHAR) + N' medios de pago nuevos.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS MEDIOS DE PAGO'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempMediosPago') IS NOT NULL
        DROP TABLE #TempMediosPago;

    SET NOCOUNT OFF;
END
GO

-- Insertar masivamente los tipo de clientes
-- Se espera la ruta del archivo "Informacion_complementaria.xlsx" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.ClienteInsertarMasivo
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	CREATE TABLE #TempCliente (
            tipoCliente VARCHAR(20)
        );

    SET @sql = '
    INSERT INTO dbAuroraSA.#TempCliente(tipoCliente)
	VALUES 
    (''Normal''),
    (''Member'');';

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.Cliente (tipoCliente, activo)
        SELECT 
            TRIM(TC.tipoCliente),
            1 -- activo por defecto
        FROM #TempCliente TC
		WHERE NOT EXISTS (
				SELECT 1 
				FROM dbAuroraSA.Cliente AS c
				WHERE TC.tipoCliente = c.tipoCliente COLLATE Modern_Spanish_CI_AI
			);

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.Cliente] - ' + CAST(@reg AS VARCHAR) + N' tipos de cliente nuevos.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS TIPOS DE CLIENTES'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempCliente') IS NOT NULL
        DROP TABLE #TempCliente;

    SET NOCOUNT OFF;
END
GO

-- Insertar masivamente las ventas
-- Se espera la ruta del archivo "Ventas_registradas.csv" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.VentasInsertarMasivo
    @rutaxls NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
            @reg AS INT;
    DECLARE @tcCompra as DECIMAL;

    -- Verificar el tipo de cambio
    SELECT TOP 1 @tcCompra = precioCompra
    FROM dbAuroraSA.TipoCambio
    ORDER BY Fecha DESC;

    IF @tcCompra IS NULL
    BEGIN
        PRINT 'Por favor ejecutar el PowerShell "ActualizarTC.ps1" para calcular el tipo de cambio actual';
        RETURN;
    END

    CREATE TABLE #TempVentas (
        idFactura    VARCHAR(20),
        tipoFactura  VARCHAR(20),
        ciudad       VARCHAR(20),
        tipoCliente  VARCHAR(20),
        genero       VARCHAR(20),
        producto     VARCHAR(150),
        precioUnit   VARCHAR(10),
        cant        VARCHAR(5),
        fecha       VARCHAR(10),
        hora        VARCHAR(5),
        medioPago   VARCHAR(20),
        empleado    VARCHAR(6),
        identifPago VARCHAR(50)
    );

    -- Tabla temporal para almacenar los datos de venta procesados
    CREATE TABLE #VentasAProcesar (
        idFactura VARCHAR(20),
        idCliente INT,
        idEmpleado INT,
        idSucursal INT,
        idMedioPago INT,
        fechaHora DATETIME,
        montoTotal DECIMAL(10,2)
    );

    -- Tabla temporal para almacenar la relación entre factura y venta
    CREATE TABLE #VentasGeneradas (
        idVenta INT,
        idFactura VARCHAR(20)
    );

    SET @sql = N'BULK INSERT #TempVentas FROM ''' + @rutaxls + ''' WITH(CHECK_CONSTRAINTS,FORMAT = ''CSV'', CODEPAGE = ''65001'', FIRSTROW = 2, FIELDTERMINATOR = '';'', ROWTERMINATOR = ''\n'')';

    BEGIN TRY
        BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Primero procesamos los datos y los guardamos en la tabla temporal
        INSERT INTO #VentasAProcesar (idFactura, idCliente, idEmpleado, idSucursal, idMedioPago, fechaHora, montoTotal)
        SELECT 
            tv.idFactura,
            c.idCliente,
            CAST(tv.empleado as INT),
            s.idSucursal,
            mp.idMedioPago,
            CONVERT(DATETIME, TRIM(tv.fecha)+ ' ' + TRIM(tv.hora), 120),
            CAST(tv.precioUnit as DECIMAL(10,2)) * @tcCompra * CAST(tv.cant as INT)
        FROM #TempVentas tv
        LEFT JOIN dbAuroraSA.Cliente c on c.tipoCliente = tv.tipoCliente COLLATE Modern_Spanish_CI_AI
        LEFT JOIN dbAuroraSA.Sucursal AS s 
            ON CASE 
                WHEN tv.ciudad = 'Yangon' THEN 'San Justo'
                WHEN tv.ciudad = 'Naypyitaw' THEN 'Ramos Mejia'
                WHEN tv.ciudad = 'Mandalay' THEN 'Lomas del Mirador'
                ELSE tv.ciudad
            END = s.ciudad COLLATE Modern_Spanish_CI_AI
        LEFT JOIN dbAuroraSA.MedioPago as mp on mp.nombreEN = tv.medioPago COLLATE Modern_Spanish_CI_AI
        WHERE tv.idFactura IS NOT NULL;

        -- Ahora insertamos en la tabla de Ventas y capturamos los IDs
        INSERT INTO dbAuroraSA.Venta(idCliente, idEmpleado, idSucursal, idMedioPago, fechaHora, montoTotal)
        OUTPUT 
            INSERTED.idVenta,
            INSERTED.fechaHora
        INTO #VentasGeneradas(idVenta, idFactura)
        SELECT 
            idCliente,
            idEmpleado,
            idSucursal,
            idMedioPago,
            fechaHora,
            montoTotal
        FROM #VentasAProcesar;

        -- Actualizamos los idFactura en #VentasGeneradas usando la fechaHora como referencia
        UPDATE vg
        SET vg.idFactura = vap.idFactura
        FROM #VentasGeneradas vg
        INNER JOIN #VentasAProcesar vap ON vg.idFactura = vap.fechaHora;

        SET @reg = @@ROWCOUNT;
        SET @mensaje = N'[dbAuroraSA.Venta] - ' + CAST(@reg AS VARCHAR) + N' ventas nuevas.';
        PRINT @mensaje;
        
        EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'
        
        -- Insertar las facturas usando la relación correcta
        INSERT INTO dbAuroraSA.Factura(IdVenta, tipoDoc, nroDoc, nroFactura, tipoFactura, total, iva, fechaEmision, identificaPago, estado)
        SELECT 
            vg.idVenta,
            'DNI',
            e.dni,
            TRIM(tv.idFactura),
            TRIM(tv.tipoFactura),
            CAST(tv.precioUnit as DECIMAL(10,2)) * @tcCompra * CAST(tv.cant as INT),
            CAST(tv.precioUnit as DECIMAL(10,2)) * @tcCompra * CAST(tv.cant as INT) * 1.21,
            CONVERT(DATETIME, TRIM(tv.fecha)+ ' ' + TRIM(tv.hora), 120),
            SUBSTRING(
                REPLACE(REPLACE(tv.identifPago, '''', ''), '-', ''),
                PATINDEX('%[^0]%', REPLACE(REPLACE(tv.identifPago, '''', ''), '-', '')),
                LEN(tv.identifPago)
            ),
            CASE WHEN 
                NULLIF(SUBSTRING(
                    REPLACE(REPLACE(tv.identifPago, '''', ''), '-', ''),
                    PATINDEX('%[^0]%', REPLACE(REPLACE(tv.identifPago, '''', ''), '-', '')),
                    LEN(tv.identifPago)
                ), '') IS NULL THEN 'EMITIDA'
                ELSE 'PAGADA'
            END
        FROM #TempVentas tv
        INNER JOIN #VentasGeneradas vg ON vg.idFactura = tv.idFactura
        LEFT JOIN dbAuroraSA.Empleado as e on e.idEmpleado = cast(tv.empleado as INT)
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dbAuroraSA.Factura AS v
            WHERE v.nroFactura = tv.idFactura COLLATE Modern_Spanish_CI_AI
        );
        
        SET @reg = @@ROWCOUNT;
        SET @mensaje = N'[dbAuroraSA.Factura] - ' + CAST(@reg AS VARCHAR) + N' facturas nuevas.';
        PRINT @mensaje;
        
        EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVAS VENTAS'
        PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
    END CATCH

    IF OBJECT_ID('tempdb..#TempVentas') IS NOT NULL
        DROP TABLE #TempVentas;
    
    IF OBJECT_ID('tempdb..#VentasAProcesar') IS NOT NULL
        DROP TABLE #VentasAProcesar;
        
    IF OBJECT_ID('tempdb..#VentasGeneradas') IS NOT NULL
        DROP TABLE #VentasGeneradas;

    SET NOCOUNT OFF;
END
GO

-- Insertar masivamente el detalle venta
-- Se espera la ruta del archivo "Ventas_registradas.csv" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.VentaDetalleInsertarMasivo
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @mensaje VARCHAR(100),
			@reg AS INT
	DECLARE @tcCompra as DECIMAL;

	-- Verificar el tipo de cambio
    SELECT TOP 1 @tcCompra = precioCompra
    FROM dbAuroraSA.TipoCambio
    ORDER BY Fecha DESC;

    IF @tcCompra IS NULL
    BEGIN
        PRINT 'Por favor ejecutar el PowerShell "ActualizarTC.ps1" para calcular el tipo de cambio actual';
        RETURN;
    END

	CREATE TABLE #TempVentas (
            idFactura	VARCHAR(20),
			tipoFactura	VARCHAR(20),
			ciudad		VARCHAR(20),
			tipoCliente	VARCHAR(20),
			genero		VARCHAR(20),
			producto	VARCHAR(150),
			precioUnit	VARCHAR(10),
			cant		VARCHAR(5),
			fecha		VARCHAR(10),
			hora		VARCHAR(5),
			medioPago	VARCHAR(20),
			empleado	VARCHAR(6),
			identifPago	VARCHAR(50)
        );

	SET @sql = N'BULK INSERT #TempVentas FROM ''' + @rutaxls + ''' WITH(CHECK_CONSTRAINTS,FORMAT = ''CSV'', CODEPAGE = ''65001'', FIRSTROW = 2, FIELDTERMINATOR = '';'', ROWTERMINATOR = ''\n'')';

    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @sql;

        -- Insertar datos en la tabla final, limpiando el formato del teléfono
        INSERT INTO dbAuroraSA.VentaDetalle(idVenta,idProducto,genero,cantidad,precioUnitario)
        SELECT 
            f.idVenta as idVenta,
			p.idProducto as idProducto,
			TRIM(tv.genero) as genero,
			CAST(tv.cant as INT) as cantidad,
			CAST(tv.precioUnit as DECIMAL(10,2)) * @tcCompra as precioUnitario
        FROM #TempVentas tv
		INNER JOIN dbAuroraSA.Factura f on f.nroFactura = TRIM(tv.idFactura) COLLATE Modern_Spanish_CI_AI
		INNER JOIN dbAuroraSA.Producto p ON REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(tv.producto), 'Ã©', 'é'),
               'Ã¡', 'á'),'Ã±','ñ'),'Ã³','ó'),'Ã­','í'),'Ãº','ú') LIKE '%' + p.nombre + '%' COLLATE Modern_Spanish_CI_AI
		WHERE NOT EXISTS (
			SELECT 1 
			FROM dbAuroraSA.VentaDetalle AS dv
			WHERE dv.idVenta = f.idVenta
			and dv.idProducto = p.idProducto
		);

		SET @reg = @@ROWCOUNT;

        SET @mensaje = N'[dbAuroraSA.VentaDetalle] - ' + CAST(@reg AS VARCHAR) + N' detalle ventas nuevas.';
        PRINT @mensaje;

		EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVAS VENTAS'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    END CATCH
    IF OBJECT_ID('tempdb..#TempVentas') IS NOT NULL
        DROP TABLE #TempVentas;

    SET NOCOUNT OFF;
END

GO

-- Insertar turnos masivos
CREATE OR ALTER PROCEDURE spAuroraSA.TurnoInsertarMasivo
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @mensaje VARCHAR(100),
			@reg AS INT

	SET @reg = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
            -- Validar si ya existen registros
            IF EXISTS (SELECT 1 FROM dbAuroraSA.Turno)
            BEGIN
                PRINT('Ya existen turnos registrados en la tabla.');
                RETURN;
            END

            -- Insertar turno Mañana
            INSERT INTO dbAuroraSA.Turno (nombre, horaIni, horaFin, activo)
            VALUES ('Maniana', '08:00:00', '12:00:00', 1);

			set @reg+=1;

            -- Insertar turno Tarde
            INSERT INTO dbAuroraSA.Turno (nombre, horaIni, horaFin, activo)
            VALUES ('Tarde', '12:01:00', '21:00:00', 1);

			set @reg+=1;

            -- Insertar Jornada completa
            INSERT INTO dbAuroraSA.Turno (nombre, horaIni, horaFin, activo)
            VALUES ('Jornada completa', '08:00:00', '21:00:00', 1);

			set @reg+=1;

			SET @mensaje = N'[dbAuroraSA.Turno] - ' + CAST(@reg AS VARCHAR) + N' turnos nuevos.';
			PRINT @mensaje;

			EXEC spAuroraSA.InsertarLog @texto = @mensaje, @modulo = 'INSERCION'

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

		PRINT N'[ERROR] - NO SE HA PODIDO IMPORTAR NUEVOS TURNOS'
		PRINT N'[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR)+ ' - [MSG]: ' + CAST(ERROR_MESSAGE() AS VARCHAR)

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;
GO
