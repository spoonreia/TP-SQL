@echo off
:: Configuración de variables
set "SQL_SERVER=JUST-GCASAS"
set "DATABASE=master"
set "SQL_SCRIPT1=C:\Users\gonza\OneDrive\Documents\Facultad\Base de datos aplicada\TP-SQL\01_3641_012900_AuroraSA_Grupo13.sql"
set "PS_SCRIPT=C:\Users\gonza\OneDrive\Documents\Facultad\Base de datos aplicada\TP-SQL\02_ActualizarTC.ps1"
set "SQL_SCRIPT2=C:\Users\gonza\OneDrive\Documents\Facultad\Base de datos aplicada\TP-SQL\03_3641_012900_AuroraSA_Grupo13.sql"

echo Iniciando verificacion de archivos...

:: Verificar segundo script SQL
if not exist "%SQL_SCRIPT2%" (
    echo ERROR: No se encuentra el archivo SQL: %SQL_SCRIPT2%
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Verificar que sqlcmd está instalado
where sqlcmd >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: No se encuentra sqlcmd. Asegurate de tener instalado SQL Server Command Line Tools.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

echo Todos los archivos verificados correctamente.
echo.
echo Iniciando ejecucion de scripts...

:: Ejecutar segundo archivo SQL (comentado por ahora)
echo Ejecutando segundo SQL...
sqlcmd -S %SQL_SERVER% -d %DATABASE% -i "%SQL_SCRIPT2%"
if errorlevel 1 (
    echo ERROR: Fallo la ejecucion del segundo SQL
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

echo Ejecucion completada exitosamente
echo Presiona cualquier tecla para cerrar...
pause >nul