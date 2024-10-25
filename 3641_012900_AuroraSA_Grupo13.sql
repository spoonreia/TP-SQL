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
USE master;
-- Creación de la base de datos y sus esquemas
-- ===========================================
IF EXISTS(SELECT 1 FROM SYS.DATABASES WHERE NAME = 'AuroraSA')
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