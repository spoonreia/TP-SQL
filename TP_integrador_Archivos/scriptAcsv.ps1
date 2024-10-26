# Definir rutas de archivos
$excelFile = "C:\Users\gonza\OneDrive\Documents\Facultad\Base de datos aplicada\TP-SQL\TP_integrador_Archivos\Informacion_complementaria.xlsx"
$csvFile = "C:\Users\gonza\OneDrive\Documents\Facultad\Base de datos aplicada\TP-SQL\TP_integrador_Archivos\sucursal.csv"

# Función para limpiar recursos de Excel
function Clean-ExcelResources {
    param($excel, $workbook)
    try {
        if ($workbook) {
            $workbook.Close($false)
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
        }
        if ($excel) {
            $excel.Quit()
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
        }
    }
    catch {
        Write-Host "Error al limpiar recursos: $_"
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

try {
    if (-not (Test-Path $excelFile)) {
        throw "El archivo Excel no existe en la ruta especificada: $excelFile"
    }

    if (Test-Path $csvFile) {
        Remove-Item $csvFile -Force
    }

    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    $workbook = $excel.Workbooks.Open($excelFile)
    
    # Seleccionar la hoja correcta y guardarla como CSV
    $workbook.Sheets.Item("sucursal").Activate()
    $workbook.SaveAs($csvFile, 6) # 6 es el código para formato CSV
}
catch {
    Write-Host "ERROR: $_"
    throw $_.Exception
}
finally {
    Clean-ExcelResources -excel $excel -workbook $workbook
}

if (Test-Path $csvFile) {
    Write-Host "Archivo CSV creado exitosamente"
}
else {
    Write-Host "Error: No se pudo crear el archivo CSV"
}