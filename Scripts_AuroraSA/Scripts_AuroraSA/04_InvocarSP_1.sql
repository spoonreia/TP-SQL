/*
	Asignatura: Base de datos aplicada
	Fecha de entrega: 05-11-2024
	Comision: 01-2900
	Grupo 13:
		Casas, Gonzalo Agustin		DNI:44004892
*/

/*
---------------- !IMPORTANTE! ------------------
Antes de ejecutar este script cambiar la siguiente variable '@RUTA'
del archivo para realizar la carga de datos masiva, indique el path 
correcto con sus archivos de carga.

	@rutainfoC		
	@rutaproductos

*/

USE AuroraSA
GO

-- CARGA DE DATOS INICIALES
-- =====================================

BEGIN TRY
	BEGIN TRANSACTION

	SET NOCOUNT ON;
	DECLARE @RUTA				VARCHAR(100) = 'C:\Users\Gosa\Documents\Facultad\BDDA\TP-SQL\TP_integrador_Archivos\';
	DECLARE @rutainfoC 			VARCHAR(300) = @RUTA + 'Informacion_complementaria.xlsx';
	DECLARE @rutaproductos 		VARCHAR(300) = @RUTA + 'Productos\';

	EXEC spAuroraSA.SucursalInsertarMasivo @rutaxls = @rutainfoC;
	EXEC spAuroraSA.EmpleadoInsertarMasivo @rutaxls = @rutainfoC;
	EXEC spAuroraSA.CatalogoInsertarMasivo @rutaxls = @rutainfoC;
	EXEC spAuroraSA.ClienteInsertarMasivo;
	
	PRINT 'Carga de datos inicial numero 1 COMPLETA'
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT '[ERROR] - NO SE HA PODIDO IMPORTAR SATISFACTORIAMENTE UNO DE LOS ARCHIVOS'
	PRINT '[ERROR] - ' +'[LINE]: ' + CAST(ERROR_LINE() AS VARCHAR) + ' - [MSG]: ' + ERROR_MESSAGE()
	
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

END CATCH

SET NOCOUNT OFF;