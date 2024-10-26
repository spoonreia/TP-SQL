# Parámetros de conexión SQL Server
$serverName = "JUST-GCASAS"
$databaseName = "master"  # Primero conectamos a master para verificar si existe AuroraSA
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True;Encrypt=False;"

Write-Host "Iniciando script de obtencion de tipo de cambio..." -ForegroundColor Green

# Verificar si existe la base de datos
try {
    Write-Host "Verificando conexion y base de datos..." -ForegroundColor Yellow
    $checkDbQuery = "SELECT COUNT(*) FROM sys.databases WHERE name = 'AuroraSA'"
    $dbExists = Invoke-Sqlcmd -ConnectionString $connectionString -Query $checkDbQuery -ErrorAction Stop
    
    if ($dbExists.Column1 -eq 0) {
        Write-Host "La base de datos 'AuroraSA' no existe. Por favor, creala primero." -ForegroundColor Red
        Write-Host "`nPresiona cualquier tecla para cerrar..." -ForegroundColor Cyan
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
    
    Write-Host "Base de datos encontrada!" -ForegroundColor Green
    # Actualizar conexión para usar AuroraSA
    $connectionString = "Server=$serverName;Database=AuroraSA;Integrated Security=True;Encrypt=False;"
}
catch {
    Write-Host "Error al conectar a SQL Server:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nPresiona cualquier tecla para cerrar..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

try {
    Write-Host "`nIntentando conectar a dolarhoy.com..." -ForegroundColor Yellow
    $response = Invoke-WebRequest -Uri "https://dolarhoy.com/cotizaciondolarblue" -UseBasicParsing
    Write-Host "Conexion exitosa!" -ForegroundColor Green

    $content = $response.Content
    $compraMatch = [regex]::Match($content, 'Compra\D*(\d+,\d+)')
    $ventaMatch = [regex]::Match($content, 'Venta\D*(\d+,\d+)')

    if ($compraMatch.Success -and $ventaMatch.Success) {
        $precioCompra = [decimal]::Parse($compraMatch.Groups[1].Value.Replace(",", "."))
        $precioVenta = [decimal]::Parse($ventaMatch.Groups[1].Value.Replace(",", "."))
        $fecha = Get-Date -Format "yyyy-MM-dd"

        Write-Host "`nValores obtenidos:" -ForegroundColor Cyan
        Write-Host "Compra: $precioCompra" -ForegroundColor White
        Write-Host "Venta: $precioVenta" -ForegroundColor White
        Write-Host "Fecha: $fecha" -ForegroundColor White

        $query = @"
        INSERT INTO dbAuroraSA.TipoCambio (precioVenta, precioCompra, Fecha)
        VALUES ($precioVenta, $precioCompra, '$fecha')
"@

        Write-Host "`nIntentando insertar datos..." -ForegroundColor Yellow
        Invoke-Sqlcmd -ConnectionString $connectionString -Query $query -ErrorAction Stop
        Write-Host "Datos insertados correctamente!" -ForegroundColor Green
    }
    else {
        Write-Host "No se pudieron encontrar los valores del dolar en la pagina" -ForegroundColor Red
    }
}
catch {
    Write-Host "Error al procesar la solicitud:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`nPresiona cualquier tecla para cerrar..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")