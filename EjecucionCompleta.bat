@echo off
:: Configuración de variables
set "SQL_SERVER=DESKTOP-RN5237S\SQLEXPRESS"
set "DATABASE=master"
set "SQL_SCRIPT1=C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\Scripts\01_CreacionBase_Tablas.sql"
set "SQL_SCRIPT2=C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\Scripts\02_CreacionSP_Comunes.sql"
set "SQL_SCRIPT3=C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\Scripts\03_CreacionSP_ImportacionMasiva.sql"
set "SQL_SCRIPT4=C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\Scripts\04_InvocarSP_1.sql"
set "SQL_SCRIPT5=C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\Scripts\06_InvocarSP_2.sql"

set "PS_SCRIPT=C:\Users\Gosa\Documents\Facultad\Base de datos aplicada\TP-SQL\Scripts\05_ActualizarTC.ps1"


echo Iniciando verificacion de archivos...

:: Verificar primer script SQL
if not exist "%SQL_SCRIPT1%" (
    echo ERROR: No se encuentra el archivo SQL: %SQL_SCRIPT1%
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Verificar segundo script SQL
if not exist "%SQL_SCRIPT2%" (
    echo ERROR: No se encuentra el archivo SQL: %SQL_SCRIPT2%
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Verificar tercer script SQL
if not exist "%SQL_SCRIPT3%" (
    echo ERROR: No se encuentra el archivo SQL: %SQL_SCRIPT3%
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Verificar cuarto script SQL
if not exist "%SQL_SCRIPT4%" (
    echo ERROR: No se encuentra el archivo SQL: %SQL_SCRIPT4%
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Verificar quinto script SQL
if not exist "%SQL_SCRIPT5%" (
    echo ERROR: No se encuentra el archivo SQL: %SQL_SCRIPT5%
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)


:: Verificar script PowerShell
if not exist "%PS_SCRIPT%" (
    echo ERROR: No se encuentra el archivo PowerShell: %PS_SCRIPT%
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

:: Ejecutar primer archivo SQL
echo Ejecutando primer SQL...
sqlcmd -S %SQL_SERVER% -d %DATABASE% -i "%SQL_SCRIPT1%"
if errorlevel 1 (
    echo ERROR: Fallo la ejecucion del primer SQL
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Ejecutar segundo archivo SQL (comentado por ahora)
echo Ejecutando segundo SQL...
sqlcmd -S %SQL_SERVER% -d %DATABASE% -i "%SQL_SCRIPT2%"
if errorlevel 1 (
    echo ERROR: Fallo la ejecucion del segundo SQL
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Ejecutar tercer archivo SQL (comentado por ahora)
echo Ejecutando tercer SQL...
sqlcmd -S %SQL_SERVER% -d %DATABASE% -i "%SQL_SCRIPT3%"
if errorlevel 1 (
    echo ERROR: Fallo la ejecucion del segundo SQL
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Ejecutar cuarto archivo SQL (comentado por ahora)
echo Ejecutando cuarto SQL...
sqlcmd -S %SQL_SERVER% -d %DATABASE% -i "%SQL_SCRIPT4%"
if errorlevel 1 (
    echo ERROR: Fallo la ejecucion del segundo SQL
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Ejecutar archivo PowerShell
echo Ejecutando PowerShell...
powershell.exe -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -serverName %SQL_SERVER% -databaseName %DATABASE%
if errorlevel 1 (
    echo ERROR: Fallo la ejecucion del PowerShell
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

:: Ejecutar quinto archivo SQL (comentado por ahora)
echo Ejecutando quinto SQL...
sqlcmd -S %SQL_SERVER% -d %DATABASE% -i "%SQL_SCRIPT5%"
if errorlevel 1 (
    echo ERROR: Fallo la ejecucion del segundo SQL
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

echo Ejecucion completada exitosamente
echo Presiona cualquier tecla para cerrar...
pause >nul