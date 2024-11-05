/*
	GRUPO 13:
		Casas, Gonzalo Agustin		DNI:44004892		
*/

USE AuroraSA
GO

-- EJECUCION DE REPORTES XML
-- =========================


EXEC spAuroraSA.ReporteMensual @mes = 1, @anio = 2019;

EXEC spAuroraSA.ReporteTrimestral @anio = 2019, @trimestre = 1;

EXEC spAuroraSA.ReporteProductosRango @fechaInicio = '2019-01-01', @fechaFin = '2019-12-31';

EXEC spAuroraSA.ReporteSucursalRango @fechaInicio = '2019-01-01', @fechaFin = '2019-12-31';

EXEC spAuroraSA.ReporteTopProductosMes @mes = 1, @anio = 2019;

EXEC spAuroraSA.ReporteVentasFechaSucursal @fecha = '2019-01-05', @idSucursal = 1;
	
