# Actividad 2 · Agitar para deshacer

App Flutter con notas que se pueden borrar mediante deslizamiento o botón. La última nota eliminada se recupera mediante una sacudida del móvil o tocando «Deshacer».

## Funciones

- Introducir notas mediante un campo de texto.
- Borrar con `Dismissible` o con un botón que tiene tooltip.
- Restaurar la última nota en su posición original, desde el SnackBar o desde el botón Deshacer siempre visible mientras se pueda recuperar.
- Mostrar SnackBar «Nota borrada» con «Deshacer».
- Detectar sacudidas mediante `userAccelerometerEventStream` con umbral de 15 m/s² y pausa de 1 segundo.
- Desactivar el sensor con un interruptor.
- Indicar si el sensor está activo o no en la AppBar.
- Si el flujo del sensor falla, desactivarlo e indicar «Este dispositivo no tiene acelerómetro».

## Cómo ejecutarla (Windows)

1. Tener Flutter y el Android SDK listos, además de un móvil Android con acelerómetro o un emulador con sensores virtuales.
2. Abrir esta carpeta en VS Code.
3. Ejecutar `preparar_windows.bat` una vez (genera la carpeta `android/` y pasa las pruebas).
4. Ejecutar `flutter run` con el dispositivo conectado.

O hacerlo manualmente:

```powershell
flutter create --platforms=android --project-name notas_gestos .
flutter pub get
flutter test
flutter run
```

## Pruebas unitarias

En `test/detector_agitado_test.dart` se prueban reposo, sacudida, pausa, sacudida después de la pausa y cálculo de magnitud.

## Reflexión del paso 5

### 1. Umbrales 10, 15 y 25 m/s²

**Pendiente de realizar en un móvil físico:** caminar con el móvil en la mano y comprobar si se producen falsos positivos al usar esos umbrales. La versión entregada utiliza 15 m/s², como valor predeterminado solicitado.

- Umbral 10: **[RESULTADO DE LA PRUEBA]**
- Umbral 15: **[RESULTADO DE LA PRUEBA]**
- Umbral 25: **[RESULTADO DE LA PRUEBA]**
- Valor elegido y por qué: **[COMPLETAR SEGÚN LA PRUEBA REAL]**

Para probar los otros valores, cambia `DetectorAgitado()` en `lib/main.dart` por `DetectorAgitado(umbral: 10)` o `DetectorAgitado(umbral: 25)`, guarda y vuelve a ejecutar la app.

### 2. ¿Por qué userAccelerometerEventStream?

`userAccelerometerEventStream` devuelve la aceleración del movimiento quitando el efecto de la gravedad. Con el móvil quieto suele estar cerca de 0 m/s². En cambio, `accelerometerEventStream` incluye la gravedad y, estando quieto sobre la Tierra, mide aproximadamente 9,8 m/s² de módulo. Por eso el primero es más adecuado para detectar sacudidas. Con un umbral de 15 m/s², la gravedad por sí sola no debería activar el gesto, pero suma una componente que puede interferir en su detección.

### 3. Criterio WCAG 2.2, 2.5.4

- **Alternativa sin movimiento:** la nota se puede recuperar pulsando «Deshacer» en el SnackBar.
- **Desactivación del movimiento:** existe un interruptor «Agitar para deshacer» que permite dejar de escuchar el sensor.

## Capturas para entregar

1. **Captura B1:** notas visibles y campo para añadirlas.
2. **Captura B2:** nota borrada con SnackBar «Deshacer» visible.
3. **Captura B3:** nota recuperada al agitar y aviso correspondiente (requiere móvil o emulador con sensor virtual).
4. **Captura B4 (recomendada):** `flutter test` en la terminal.

## Ampliación opcional no incluida

Pestaña Papelera y navegación por inclinación: no se pide en los pasos básicos.

## Fuentes técnicas consultadas

- https://pub.dev/packages/sensors_plus
- https://www.w3.org/WAI/WCAG22/Understanding/motion-actuation.html
