/*
	GRUPO 13:
		Casas, Gonzalo Agustin		DNI:44004892		
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
USE AuroraSA
GO

-- ============================================================================================================
-- EJECUTAR POWERSHELL ".\ActualizarTC.ps1" PARA CARGAR TIPO DE CAMBIO (OJO CON serverName Y databaseName) 
-- SINO SE EJECUTA, NO FUNCIONARA LA CARGA DE PRODUCTOS.
-- ============================================================================================================

-- CARGA DE DATOS INICIALES
-- =====================================

BEGIN TRY
	BEGIN TRANSACTION

	SET NOCOUNT ON;
	DECLARE @RUTA				VARCHAR(100) = 'C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\TP_integrador_Archivos\';
	DECLARE @rutainfoC 			VARCHAR(300) = @RUTA + 'Informacion_complementaria.xlsx';
	DECLARE @rutaproductos 		VARCHAR(300) = @RUTA + 'Productos\';
	DECLARE @rutaventas 		VARCHAR(300) = @RUTA + 'Ventas_registradas.csv';

	EXEC spAuroraSA.ProductoInsertarMasivo @rutaxls = @rutaproductos;
	EXEC spAuroraSA.MedioPagoInsertarMasivo @rutaxls = @rutainfoC;
	EXEC spAuroraSA.VentasInsertarMasivo @rutaxls = @rutaventas;
	EXEC spAuroraSA.VentaDetalleInsertarMasivo @rutaxls = @rutaventas;

	PRINT 'Carga de datos inicial numero 2 COMPLETA'
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT '[ERROR] - NO SE HA PODIDO IMPORTAR SATISFACTORIAMENTE UNO DE LOS ARCHIVOS'
	PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
	
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

END CATCH

SET NOCOUNT OFF;