@echo off
chcp 65001 >nul
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter no esta en el PATH. Abre una terminal donde funcione flutter --version.
  pause
  exit /b 1
)
echo [1/4] Generando archivos nativos Android...
call flutter create --platforms=android --project-name lista_voz .
if errorlevel 1 goto fallo
echo [2/4] Configurando el AndroidManifest...
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\configurar_android.ps1"
if errorlevel 1 goto fallo
echo [3/4] Descargando dependencias...
call flutter pub get
if errorlevel 1 goto fallo
echo [4/4] Ejecutando pruebas...
call flutter test
if errorlevel 1 goto fallo
echo.
echo Preparado. Para abrir en el movil, ejecuta: flutter run
pause
exit /b 0
:fallo
echo.
echo Hubo un error. Copia el mensaje y revisa flutter doctor.
pause
exit /b 1
