/*
	GRUPO 13:
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
            tc.nombre,
			tc.nombreArchivo,
			tc.tipoArchivo,
            1 -- activo por defecto
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
CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoProducto
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
        categoria			VARCHAR(100),
        nombre				VARCHAR(150),
        precioUnitario		DECIMAL(10, 2),
        precioReferencia	DECIMAL(10, 2),
        unidadReferencia	VARCHAR(10),
        proveedor			VARCHAR(50),
        cantPorUnidad		VARCHAR(50)
    );

    -- Declarar el cursor
    DECLARE catalogo_cursor CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
    FOR 
        SELECT 
            idCatalogo,
            nombre,
            nombreArchivo,
            tipoArchivo
        FROM dbAuroraSA.Catalogo
        WHERE activo = 1;

    OPEN catalogo_cursor;

    FETCH NEXT FROM catalogo_cursor 
    INTO @idCatalogo, @nombre, @archivo, @tipoArchivo;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @archivoC = @rutaxls + @archivo;

        BEGIN TRY
            IF @tipoArchivo = 'CSV'
				BEGIN
					CREATE TABLE #TempProductoCSV (
						id				INT,
						category		VARCHAR(100),
						nameP			VARCHAR(150),
						price			DECIMAL(10, 2),
						reference_price DECIMAL(10, 2),
						reference_unit	VARCHAR(10),
						dateP			VARCHAR(50)
					);

					SET @sql = N'BULK INSERT #TempProductoCSV FROM ''' + @archivoC + ''' WITH(CHECK_CONSTRAINTS,FORMAT = ''CSV'', CODEPAGE = ''65001'', FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';

					EXEC sp_executesql @sql;

					INSERT INTO #TempProducto(categoria,nombre,precioUnitario,precioReferencia,unidadReferencia,proveedor,cantPorUnidad)
					SELECT category,nameP,price,reference_price,reference_unit,'Generico' as proveedor,1
					FROM #TempProductoCSV;

				END
            ELSE IF @tipoArchivo = 'XLS'
            BEGIN
                IF @nombre = 'Electronicos'
					BEGIN
						SET @sheet = '[Sheet1$]'

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
						SET @sheet = '[Listado de Productos$]'
						
						SET @sql = N'
						INSERT INTO #TempProducto (categoria,nombre,precioUnitario,proveedor,cantPorUnidad)
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
						)WHERE [IdProducto] is not NULL;';

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

        FETCH NEXT FROM catalogo_cursor 
        INTO @idCatalogo, @nombre, @archivo, @tipoArchivo;
    END

    CLOSE catalogo_cursor;
    DEALLOCATE catalogo_cursor;

    -- Limpiar
    IF OBJECT_ID('tempdb..#TempProducto') IS NOT NULL
        DROP TABLE #TempProducto;

	IF OBJECT_ID('tempdb..#TempProductoCSV') IS NOT NULL
        DROP TABLE #TempProductoCSV;

    SET NOCOUNT OFF;
END;
GO

-- Insertar masivamente los medios de pago
-- Se espera la ruta del archivo "Informacion_complementaria.xlsx" para ejecutar el SP en @RUTA
CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoMedioPago
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