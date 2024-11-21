USE AuroraSA
GO
-- 1. Reporte Mensual (sin cambios)
CREATE OR ALTER PROCEDURE spAuroraSA.ReporteMensual
    @mes INT,
    @anio INT
AS
BEGIN
    SELECT 
        DATENAME(WEEKDAY, v.fechaHora) as DiaSemana,
        SUM(v.montoTotal) as TotalFacturado
    FROM dbAuroraSA.Venta v
    WHERE MONTH(v.fechaHora) = @mes 
    AND YEAR(v.fechaHora) = @anio
    GROUP BY DATENAME(WEEKDAY, v.fechaHora)
    ORDER BY 
        CASE DATENAME(WEEKDAY, v.fechaHora)
            WHEN 'Domingo' THEN 1
            WHEN 'Lunes' THEN 2
            WHEN 'Martes' THEN 3
            WHEN 'Miércoles' THEN 4
            WHEN 'Jueves' THEN 5
            WHEN 'Viernes' THEN 6
            WHEN 'Sábado' THEN 7
        END
    FOR XML PATH('Dia'), ROOT('ReporteMensual')
END
GO

-- 2. Reporte Trimestral (actualizado para incluir Medio de Pago):
CREATE OR ALTER PROCEDURE spAuroraSA.ReporteTrimestral
    @anio INT,
    @trimestre INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        MONTH(v.fechaHora) as Mes,
        mp.nombreES as MedioPago,
        t.nombre as Turno,
        SUM(v.montoTotal) as TotalFacturado
    FROM dbAuroraSA.Venta v
    INNER JOIN dbAuroraSA.Empleado e ON v.idEmpleado = e.idEmpleado
    INNER JOIN dbAuroraSA.Turno t ON 
        CAST(FORMAT(v.fechaHora, 'HH:mm:ss') AS TIME) >= t.horaIni AND 
        CAST(FORMAT(v.fechaHora, 'HH:mm:ss') AS TIME) <= t.horaFin
    INNER JOIN dbAuroraSA.MedioPago mp ON v.idMedioPago = mp.idMedioPago
    WHERE YEAR(v.fechaHora) = @anio
        AND DATEPART(QUARTER, v.fechaHora) = @trimestre
        AND t.activo = 1
    GROUP BY 
        MONTH(v.fechaHora), 
        mp.nombreES,
        t.nombre
    ORDER BY 
        Mes, 
        TotalFacturado DESC
    FOR XML PATH('Facturacion'), ROOT('ReporteTrimestral');
END;
GO

-- 3. Reporte por Rango de Fechas (cantidad de productos):
CREATE OR ALTER PROCEDURE spAuroraSA.ReporteProductosRango
    @fechaInicio DATE,
    @fechaFin DATE
AS
BEGIN
    SELECT 
        p.nombre as Producto,
        vd.genero as Genero,
        SUM(vd.cantidad) as CantidadVendida
    FROM dbAuroraSA.VentaDetalle vd
    INNER JOIN dbAuroraSA.Producto p ON vd.idProducto = p.idProducto
    INNER JOIN dbAuroraSA.Venta v ON vd.idVenta = v.idVenta
    WHERE v.fechaHora BETWEEN @fechaInicio AND @fechaFin
    GROUP BY p.nombre, vd.genero
    ORDER BY CantidadVendida DESC
    FOR XML PATH('Producto'), ROOT('ReporteVentas')
END
GO

-- 4. Reporte por Rango de Fechas por Sucursal:
CREATE OR ALTER PROCEDURE spAuroraSA.ReporteSucursalRango
    @fechaInicio DATE,
    @fechaFin DATE
AS
BEGIN
    SELECT 
        s.ciudad as Sucursal,
        SUM(vd.cantidad) as CantidadVendida
    FROM dbAuroraSA.VentaDetalle vd
    INNER JOIN dbAuroraSA.Venta v ON vd.idVenta = v.idVenta
    INNER JOIN dbAuroraSA.Sucursal s ON v.idSucursal = s.idSucursal
    WHERE v.fechaHora BETWEEN @fechaInicio AND @fechaFin
    GROUP BY s.ciudad
    ORDER BY CantidadVendida DESC
    FOR XML PATH('Sucursal'), ROOT('ReporteVentasSucursal')
END
GO

-- 5. Top 5 Productos más y menos vendidos del mes:
CREATE OR ALTER PROCEDURE spAuroraSA.ReporteTopProductosMes
    @mes INT,
    @anio INT
AS
BEGIN
    -- Top 5 más vendidos por semana
    SELECT TOP 5
        p.nombre as Producto,
        vd.genero as Genero,
        SUM(vd.cantidad) as CantidadVendida,
        DATEPART(WEEK, v.fechaHora) as NumeroSemana
    FROM dbAuroraSA.VentaDetalle vd
    INNER JOIN dbAuroraSA.Producto p ON vd.idProducto = p.idProducto
    INNER JOIN dbAuroraSA.Venta v ON vd.idVenta = v.idVenta
    WHERE MONTH(v.fechaHora) = @mes 
    AND YEAR(v.fechaHora) = @anio
    GROUP BY p.nombre, vd.genero, DATEPART(WEEK, v.fechaHora)
    ORDER BY CantidadVendida DESC
    FOR XML PATH('ProductoTop'), ROOT('ProductosMasVendidos');

    -- Top 5 menos vendidos
    SELECT TOP 5
        p.nombre as Producto,
        vd.genero as Genero,
        SUM(vd.cantidad) as CantidadVendida
    FROM dbAuroraSA.VentaDetalle vd
    INNER JOIN dbAuroraSA.Producto p ON vd.idProducto = p.idProducto
    INNER JOIN dbAuroraSA.Venta v ON vd.idVenta = v.idVenta
    WHERE MONTH(v.fechaHora) = @mes 
    AND YEAR(v.fechaHora) = @anio
    GROUP BY p.nombre, vd.genero
    ORDER BY CantidadVendida ASC
    FOR XML PATH('ProductoBottom'), ROOT('ProductosMenosVendidos')
END
GO

-- 6. Total acumulado por fecha y sucursal (actualizado para incluir información de Factura):
CREATE OR ALTER PROCEDURE spAuroraSA.ReporteVentasFechaSucursal
    @fecha DATE,
    @idSucursal INT
AS
BEGIN
    SELECT 
        f.nroFactura as NumeroFactura,
        v.fechaHora,
        p.nombre as Producto,
        vd.genero as Genero,
        vd.cantidad,
        vd.precioUnitario,
        (vd.cantidad * vd.precioUnitario) as Subtotal,
        SUM(vd.cantidad * vd.precioUnitario) OVER (ORDER BY v.fechaHora) as Acumulado
    FROM dbAuroraSA.Venta v
    INNER JOIN dbAuroraSA.VentaDetalle vd ON v.idVenta = vd.idVenta
    INNER JOIN dbAuroraSA.Producto p ON vd.idProducto = p.idProducto
    INNER JOIN dbAuroraSA.Factura f ON v.idVenta = f.IdVenta
    WHERE CAST(v.fechaHora AS DATE) = @fecha
    AND v.idSucursal = @idSucursal
    ORDER BY v.fechaHora
    FOR XML PATH('Venta'), ROOT('ReporteVentasAcumulado')
END
GO