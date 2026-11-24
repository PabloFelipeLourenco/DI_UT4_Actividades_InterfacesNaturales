@echo off
chcp 65001 >nul
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter no esta en el PATH. Abre una terminal donde funcione flutter --version.
  pause
  exit /b 1
)
echo [1/3] Generando archivos nativos Android...
call flutter create --platforms=android --project-name notas_gestos .
if errorlevel 1 goto fallo
echo [2/3] Descargando dependencias...
call flutter pub get
if errorlevel 1 goto fallo
echo [3/3] Ejecutando pruebas...
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
