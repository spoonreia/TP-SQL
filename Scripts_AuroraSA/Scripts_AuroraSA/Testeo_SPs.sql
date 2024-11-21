/*
	Asignatura: Base de datos aplicada
	Fecha de entrega: 05-11-2024
	Comision: 01-2900
	Grupo 13:
		Casas, Gonzalo Agustin		DNI:44004892
*/


USE AuroraSA
GO


-- TEST CATALOGO
select * from dbAuroraSA.Catalogo;
-- INSERCION
	-- DA OK
EXEC spAuroraSA.CatalogoInsertar @nombre = 'NUEVO CATALOGO', @nombreArchivo = 'archivo.pdf', @tipoArchivo = 'CSV';
	-- FALLA POR DUPLICADO
EXEC spAuroraSA.CatalogoInsertar @nombre = 'NUEVO CATALOGO', @nombreArchivo = 'otroArchivo.pdf', @tipoArchivo = 'CSV';


	-- ELIMINACION
	-- DA OK
EXEC spAuroraSA.CatalogoEliminar @nombre = 'NUEVO CATALOGO';
	-- FALLA PORQUE NO EXISTE NOMBRE
EXEC spAuroraSA.CatalogoEliminar @nombre = 'NUEVO CATALOGO';


	-- ACTUALIZACION
	-- DA OK
EXEC spAuroraSA.CatalogoActualizar @id = 3, @nombre = 'CATALOGO ACTUALIZADO', @nombreArchivo = 'nuevoArchivo.pdf', @tipoArchivo = 'XLS';
	-- FALLA PORQUE NO EXISTE ID
EXEC spAuroraSA.CatalogoActualizar @id = 9999, @nombre = 'CATALOGO NO EXISTENTE', @nombreArchivo = 'archivo.pdf', @tipoArchivo = 'XLS';

-- ============================================================================================================================

-- TEST CLIENTE
select * from dbAuroraSA.Cliente;
-- INSERCION
	-- DA OK
EXEC spAuroraSA.ClienteInsertar @tipoCliente = 'Vip';
	-- FALLA POR DUPLICADO
EXEC spAuroraSA.ClienteInsertar @tipoCliente = 'Vip';


	-- ELIMINACION
	-- DA OK
EXEC spAuroraSA.ClienteEliminar @tipoCliente = 'Vip';
	-- FALLA PORQUE YA ESTA DADO DE BAJA
EXEC spAuroraSA.ClienteEliminar @tipoCliente = 'Vip';


	-- ACTUALIZACION
	-- DA OK (DADO DE ALTA)
EXEC spAuroraSA.ClienteActualizar @id = 3, @activo = 1;
	-- FALLA PORQUE NO EXISTE ID
EXEC spAuroraSA.ClienteActualizar @id = 9999, @tipoCliente = 'Normal';

-- ============================================================================================================================

-- TEST SUCURSAL
select * from dbAuroraSA.Sucursal;
	-- INSERCION
	-- DA OK
EXEC spAuroraSA.SucursalInsertar @ciudad = 'Polvorines', @direccion = 'AAA 123';
	-- FALLA POR DUPLICADO
EXEC spAuroraSA.SucursalInsertar @ciudad = 'Polvorines', @direccion = 'AAA 123';


	-- ELIMINACION
	-- DA OK
EXEC spAuroraSA.SucursalEliminar @id = 1;
	-- FALLA PORQUE YA ESTA DADO DE BAJA
EXEC spAuroraSA.SucursalEliminar @id = 1;


	-- ACTUALIZACION
	-- DA OK (DADO DE ALTA)
EXEC spAuroraSA.SucursalActualizar @id = 1, @activo = 1;
	-- FALLA PORQUE NO EXISTE ID
EXEC spAuroraSA.SucursalActualizar @id = 9999, @ciudad = 'Avellaneda';

-- ============================================================================================================================

-- TEST EMPLEADO
select * from dbAuroraSA.Empleado;
-- INSERCION
	-- DA OK
EXEC spAuroraSA.EmpleadoInsertar @idSucursal = 1, @nombre = 'Gonzalo', @apellido = 'Casas',@dni = 44004892,	@direccion = 'AAA 123', 
								@emailEmpre = 'AAA@aaa.com',@cargo = 'Supervisor';
	-- VER DATOS ENCRIPTADOS
	select * from dbAuroraSA.Empleado;
	-- VER DATOS DESENCRIPTADOS
	select idEmpleado,idSucursal,nombre,apellido,dni,
	CONVERT(varchar(100), DecryptByPassPhrase('FraseSecreta', direccion)) as direccion,
	CONVERT(varchar(100), DecryptByPassPhrase('FraseSecreta', emailEmpre)) as emailEmpre,
	cargo,activo from dbAuroraSA.Empleado;
	-- FALLA POR DUPLICADO
EXEC spAuroraSA.EmpleadoInsertar @idSucursal = 1, @nombre = 'Gonzalo', @apellido = 'Casas',@dni = 44004892,	@direccion = 'AAA 123', 
								@emailEmpre = 'AAA@aaa.com',@cargo = 'Supervisor';
	-- FALLA POR SUCURSAL NO EXISTENTE
EXEC spAuroraSA.EmpleadoInsertar @idSucursal = 5, @nombre = 'Gonzalo', @apellido = 'Casas',@dni = 44004892,	@direccion = 'AAA 123', 
								@emailEmpre = 'AAA@aaa.com',@cargo = 'Supervisor';


	-- ELIMINACION
	-- DA OK
EXEC spAuroraSA.EmpleadoEliminar @dni = 44004892;
	-- FALLA PORQUE YA ESTA DADO DE BAJA O PORQUE NO EXISTE.
EXEC spAuroraSA.EmpleadoEliminar @dni = 44004892;


	-- ACTUALIZACION
	-- DA OK (DADO DE ALTA)
EXEC spAuroraSA.EmpleadoActualizar @dni = 44004892, @activo = 1;
	-- FALLA PORQUE NO EXISTE DNI
EXEC spAuroraSA.EmpleadoActualizar @dni = 44003829, @activo = 1;
	-- FALLA PORQUE NO EXISTE SUCURSAL
EXEC spAuroraSA.EmpleadoActualizar @dni = 44004892, @idSucursal = 5,@activo = 1;


-- ============================================================================================================================

-- TEST MEDIO DE PAGO
select * from dbAuroraSA.MedioPago;
-- INSERCION
	-- DA OK
EXEC spAuroraSA.MedioPagoInsertar @nombreEN = 'Cash2', @nombreES = 'Efectivo';
	-- FALLA POR DUPLICADO
EXEC spAuroraSA.MedioPagoInsertar @nombreEN = 'Cash2', @nombreES = 'Efectivo';

	-- ELIMINACION
	-- DA OK
EXEC spAuroraSA.MedioPagoEliminar @id = 1;
	-- FALLA PORQUE YA ESTA DADO DE BAJA O PORQUE NO EXISTE.
EXEC spAuroraSA.MedioPagoEliminar @id = 1;


	-- ACTUALIZACION
	-- DA OK (DADO DE ALTA)
EXEC spAuroraSA.MedioPagoActualizar @id = 1, @activo = 1;
	-- FALLA PORQUE NO EXISTE MEDIO DE PAGO
EXEC spAuroraSA.MedioPagoActualizar @id = 5, @activo = 1;


-- ============================================================================================================================

-- TEST PRODUCTO
select * from dbAuroraSA.Catalogo;
select * from dbAuroraSA.Producto;
-- INSERCION
	-- DA OK
EXEC spAuroraSA.ProductoInsertar @idCatalogo = 1, @nombre = 'Leche',@categoria = 'Lacteo',@precioUnitario = 10.5,
	@precioReferencia = 12.6, @unidadReferencia = 'LT',@proveedor = 'Carlos',@cantPorUnidad = '1';
	-- FALLA POR DUPLICADO
EXEC spAuroraSA.ProductoInsertar @idCatalogo = 1, @nombre = 'Leche',@categoria = 'Lacteo',@precioUnitario = 10.5,
	@precioReferencia = 12.6, @unidadReferencia = 'LT',@proveedor = 'Carlos',@cantPorUnidad = '1';
	-- FALLA POR CATALOGO NO EXISTENTE
EXEC spAuroraSA.ProductoInsertar @idCatalogo = 6, @nombre = 'Leche',@categoria = 'Lacteo',@precioUnitario = 10.5,
	@precioReferencia = 12.6, @unidadReferencia = 'LT',@proveedor = 'Carlos',@cantPorUnidad = '1';

	-- ELIMINACION
	-- DA OK
EXEC spAuroraSA.ProductoEliminar @id = 1;
	-- FALLA PORQUE YA ESTA DADO DE BAJA O PORQUE NO EXISTE.
EXEC spAuroraSA.ProductoEliminar @id = 1;


	-- ACTUALIZACION
	-- DA OK (DADO DE ALTA)
EXEC spAuroraSA.ProductoActualizar @id = 1, @activo = 1;
	-- FALLA PORQUE NO EXISTE PRODUCTO.
EXEC spAuroraSA.ProductoActualizar @id = 53442, @activo = 1;
	-- FALLA PORQUE NO EXISTE CATALOGO.
EXEC spAuroraSA.ProductoActualizar @id = 1,@idCatalogo = 6, @activo = 1;


-- ============================================================================================================================

-- TEST TURNO
select * from dbAuroraSA.Turno;
-- INSERCION
	-- DA OK
EXEC spAuroraSA.TurnoInsertar @nombre = 'Noche', @horaIni = '21:00:00', @horaFin = '03:00:00';
	-- FALLA POR DUPLICADO
EXEC spAuroraSA.TurnoInsertar @nombre = 'Noche', @horaIni = '21:00:00', @horaFin = '03:00:00';

	-- ELIMINACION
	-- DA OK
EXEC spAuroraSA.TurnoEliminar @id = 1;
	-- FALLA PORQUE YA ESTA DADO DE BAJA O PORQUE NO EXISTE.
EXEC spAuroraSA.TurnoEliminar @id = 1;


	-- ACTUALIZACION
	-- DA OK (DADO DE ALTA)
EXEC spAuroraSA.TurnoActualizar @id = 1, @nombre = 'Tarde', @horaIni = '14:00:00', @horaFin = '18:00:00', @activo = 1;
	-- FALLA PORQUE NO EXISTE TURNO.
EXEC spAuroraSA.TurnoActualizar @id = 999, @nombre = 'Tarde', @horaIni = '14:00:00', @horaFin = '18:00:00', @activo = 1;

-- ============================================================================================================================

-- TEST VENTA
select * from dbAuroraSA.Venta order by idVenta DESC;
select * from dbAuroraSA.VentaDetalle order by idVentaDetalle DESC;
select * from dbAuroraSA.TipoCambio;
select * from dbAuroraSA.MedioPago;
select * from dbAuroraSA.Producto where idProducto in (101,102,103);
select * from dbAuroraSA.Factura order by idFactura DESC;



-- INSERCION
	-- DA OK
EXEC spAuroraSA.VentaInsertar	@idFactura = '011-011-111', @tipoFactura = 'A', 
								@idCliente = 2, @idEmpleado = 257032, @idSucursal = 1, 
								@idMedioPago = 1, @identificaPago = 'Pago01', 
								@productos = '101-Male-2;102-Female-1;103-Male-3;';
	-- FALLA POR CLIENTE INEXISTENTE
EXEC spAuroraSA.VentaInsertar	@idFactura = '011-011-111', @tipoFactura = 'A', 
								@idCliente = 5, @idEmpleado = 257032, @idSucursal = 1, 
								@idMedioPago = 1, @identificaPago = 'Pago01', 
								@productos = '101-Male-2;102-Female-1;103-Male-3;';
	-- FALLA POR EMPLEADO INEXISTENTE
EXEC spAuroraSA.VentaInsertar	@idFactura = '011-011-111', @tipoFactura = 'A', 
								@idCliente = 2, @idEmpleado = 3, @idSucursal = 1, 
								@idMedioPago = 1, @identificaPago = 'Pago01',
								@productos = '101-Male-2;102-Female-1;103-Male-3;';
	-- FALLA POR MEDIO DE PAGO INEXISTENTE
EXEC spAuroraSA.VentaInsertar	@idFactura = '011-011-111', @tipoFactura = 'A', 
								@idCliente = 2, @idEmpleado = 257032, @idSucursal = 1, 
								@idMedioPago = 5, @identificaPago = 'Pago01', 
								@productos = '101-Male-2;102-Female-1;103-Male-3;';
	-- FALLA POR FACTURA EXISTENTE
EXEC spAuroraSA.VentaInsertar	@idFactura = '011-011-111', @tipoFactura = 'A', 
								@idCliente = 2, @idEmpleado = 257032, @idSucursal = 1, 
								@idMedioPago = 1, @identificaPago = 'Pago01', 
								@productos = '101-Male-2;102-Female-1;103-Male-3;';


	-- ELIMINACION
	-- DA OK
EXEC spAuroraSA.VentaEliminar @idVenta = 1001, @motivo = 'Cancelación de pedido';
	-- FALLA PORQUE NO EXISTE LA VENTA.
EXEC spAuroraSA.VentaEliminar @idVenta = 1111, @motivo = 'Error en facturación';


	-- ACTUALIZACION
	-- DA OK - Actualiza el medio de pago en una venta existente y registra en log el cambio.
EXEC spAuroraSA.VentaActualizar @idFactura = '011-011-111', @idMedioPago = 1, @identificaPago = 'PagoNuevo', @motivo = 'Cambio de medio de pago';
	-- DA OK - Aumenta la cantidad de un producto existente en una venta (cantExistente = cantExistente + nueva), ajusta el monto total y registra en el log.
EXEC spAuroraSA.VentaActualizar @idFactura = '011-011-111', @idProducto = 1, @cantidadAjuste = 2, @motivo = 'Ajuste de inventario';
	-- DA OK - Disminuye la cantidad de un producto existente en una venta (cantExistente = cantExistente + nueva), ajusta el monto total y registra en el log.
EXEC spAuroraSA.VentaActualizar @idFactura = '011-011-111', @idProducto = 1, @cantidadAjuste = -2, @motivo = 'Corrección de cantidad';
	-- DA OK - Si la cantidad del producto llega a 0, elimina la venta y ventaDetalle y lo registra en el log.
EXEC spAuroraSA.VentaActualizar @idFactura = '011-011-111', @idProducto = 1, @cantidadAjuste = -5, @motivo = 'Venta eliminada';
	-- FALLA - Intenta actualizar una venta que no existe en la base de datos.
EXEC spAuroraSA.VentaActualizar @idFactura = 'F999', @idProducto = 1, @cantidadAjuste = 2, @motivo = 'Ajuste';
	-- FALLA - Intenta actualizar una venta que no existe en la base de datos.
EXEC spAuroraSA.VentaActualizar @idFactura = '011-011-111', @idProducto = 999, @cantidadAjuste = 1, @motivo = 'Producto no encontrado en venta';


select * from dbAuroraSA.Venta;
select * from dbAuroraSA.VentaDetalle;

SELECT * FROM logAuroraSA.Registro;

-- ============================================================================================================================

-- TEST NOTA DE CREDITO
select * from dbAuroraSA.NotaCredito;


-- INSERCION
	-- DA OK
EXEC spAuroraSA.NotaCreditoInsertar @IdFactura = 1001, @IdEmpleado = 257020, @MontoTotal = 100.50, 
									@Motivo = 'Producto defectuoso', @TipoDevolucion = 'PRODUCTO';

	-- FALLA PORQUE FACTURA NO EXISTE
EXEC spAuroraSA.NotaCreditoInsertar @IdFactura = 1500, @IdEmpleado = 257020, @MontoTotal = 100.50, 
									@Motivo = 'Producto defectuoso', @TipoDevolucion = 'PRODUCTO';

	-- FALLA PORQUE EMPLEADO NO EXISTE
EXEC spAuroraSA.NotaCreditoInsertar @IdFactura = 1001, @IdEmpleado = 5, @MontoTotal = 100.50, 
									@Motivo = 'Producto defectuoso', @TipoDevolucion = 'PRODUCTO';

	-- FALLA PORQUE LA FACTURA NO ESTA PAGADA
EXEC spAuroraSA.NotaCreditoInsertar @IdFactura = 1000, @IdEmpleado = 257020, @MontoTotal = 100.50, 
									@Motivo = 'Producto defectuoso', @TipoDevolucion = 'PRODUCTO';
