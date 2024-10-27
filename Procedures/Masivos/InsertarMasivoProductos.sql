USE AuroraSA
GO

CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoProducto
    @rutaxls NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @precioVenta DECIMAL(10,4);
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
    SELECT TOP 1 @precioVenta = precioVenta 
    FROM dbAuroraSA.TipoCambio
    ORDER BY Fecha DESC;

    IF @precioVenta IS NULL
    BEGIN
        PRINT 'Por favor ejecutar el PowerShell "ActualizarTC.ps1" para calcular el tipo de cambio actual';
        RETURN;
    END

    -- Crear tabla temporal
    IF OBJECT_ID('tempdb..#TempProducto') IS NOT NULL
        DROP TABLE #TempProducto;

    CREATE TABLE #TempProducto (
        categoria			NVARCHAR(100),
        nombre				NVARCHAR(150),
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
						category		NVARCHAR(100),
						nameP			NVARCHAR(150),
						price			DECIMAL(10, 2),
						reference_price DECIMAL(10, 2),
						reference_unit	VARCHAR(10),
						dateP			VARCHAR(50)
					);

					SET @sql = N'BULK INSERT #TempProductoCSV FROM ''' + @archivoC + ''' WITH(CHECK_CONSTRAINTS, CODEPAGE = ''1200'', FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\r\n'')';
									   
					-- Verifica cuántas filas se han insertado
					--DECLARE @RowCount INT;
					--SELECT @RowCount = COUNT(*) FROM #TempProductoCSV;
					--PRINT N'Cantidad de filas en #TempProductoCSV: ' + CAST(@RowCount AS NVARCHAR);

					INSERT INTO #TempProducto(categoria,nombre,precioUnitario,precioReferencia,unidadReferencia,proveedor,cantPorUnidad)
					SELECT category,nameP,price,reference_price,reference_unit,'Electronica' as proveedor,1
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
							''Excel 12.0; Database=' + @archivoC + ''',
							''SELECT * FROM ' + @sheet + '''
						) WHERE [Product] IS NOT NULL;';

					END
				ELSE
					BEGIN
						SET @sheet = '[Listado de Productos$]'
						
						SET @sql = N'
						INSERT INTO #TempProducto (categoria,nombre,precioUnitario,proveedor,cantPorUnidad)
						SELECT 
							[Categoría] as categoria,
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
                precioUnitario * @precioVenta,
                COALESCE(precioReferencia * @precioVenta, NULL),
                COALESCE(unidadReferencia, NULL),
                COALESCE(proveedor, NULL),
                COALESCE(cantPorUnidad, '1'),
                1
            FROM #TempProducto;

            SET @reg = @@ROWCOUNT;
            
            SET @mensaje = N'[dbAuroraSA.Producto] - ' + CAST(@reg AS VARCHAR) + N' productos cargados del catálogo ' + @nombre;
            PRINT @mensaje;

            EXEC spAuroraSA.InsertarLog 
                @texto = @mensaje, 
                @modulo = 'INSERCIÓN';

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

-- DELETE from dbAuroraSA.Producto;
EXEC spAuroraSA.InsertarMasivoProducto 'C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\TP_integrador_Archivos\Productos\'
-- GO
-- select * from dbAuroraSA.Producto
-- GO
-- select * from logAuroraSA.Registro;
-- select * from dbAuroraSA.TipoCambio;
