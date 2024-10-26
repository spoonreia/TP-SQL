USE AuroraSA
GO

-- dbAuroraSA.Empleado(
-- 	idEmpleado	INT,
-- 	idSucursal	INT NOT NULL,
-- 	nombre		VARCHAR (50) NOT NULL,
-- 	apellido	VARCHAR (50) NOT NULL,
-- 	dni			INT NOT NULL,
-- 	direccion	VARCHAR (100) NOT NULL,
-- 	emailEmpre	VARCHAR (50) NOT NULL,
-- 	cargo		VARCHAR (20) NOT NULL,
-- 	activo		BIT DEFAULT 1

CREATE OR ALTER PROCEDURE spAuroraSA.InsertarMasivoEmpleado 
	@rutaxls NVARCHAR(300)
AS
BEGIN
	SET NOCOUNT ON;



	SET NOCOUNT OFF;
END
GO