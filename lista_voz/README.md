# Actividad 1 · Lista controlada por voz

App Flutter para gestionar una lista usando órdenes habladas o botones. Está pensada para Android.

## Funciones

- Reconoce «añadir», «borrar», «leer» y «ayuda» con sinónimos, frases y variaciones de tildes.
- Muestra la transcripción mientras escucha, la última orden y una respuesta visible.
- Responde con voz en español (TTS) si el servicio del dispositivo está disponible.
- Desactiva el micrófono si no hay permiso o servicio, pero los botones siguen funcionando.
- Detiene el reconocimiento y la síntesis al cerrar la pantalla.

## Cómo ejecutarla (Windows)

1. Tener Flutter, Android Studio/Android SDK y un móvil Android o emulador configurado.
2. Abrir esta carpeta en VS Code.
3. Ejecutar `preparar_windows.bat` una vez (genera la carpeta `android/`, configura permisos y pasa las pruebas).
4. Ejecutar `flutter run` con el dispositivo conectado.

Si no quieres usar el BAT, ejecuta:

```powershell
flutter create --platforms=android --project-name lista_voz .
powershell -ExecutionPolicy Bypass -File scripts/configurar_android.ps1
flutter pub get
flutter test
flutter run
```

## Pruebas unitarias

`test/comandos_test.dart` comprueba tildes, mayúsculas, sinónimos, frases, texto vacío y órdenes desconocidas.

## Reflexión del paso 5 (completar después de probar)

### 1. ¿El reconocimiento funciona sin Internet?

**Prueba pendiente de realizar en un móvil real:** primero probar «añadir» con conexión; después poner el modo avión y repetir.

- Móvil y versión de Android: **[COMPLETAR]**
- Con Internet: **[FUNCIONA / NO FUNCIONA]**
- En modo avión: **[FUNCIONA / NO FUNCIONA]**
- Conclusión: **[INDICAR SI EN ESTE DISPOSITIVO USA RECONOCIMIENTO LOCAL O NECESITA RED; SI NO SE PUEDE SABER SOLO CON ESTA PRUEBA, DECIRLO]**

Para analizarlo: si necesita red, puede enviar audio/datos a servicios externos, consumir datos y añadir latencia. Si funciona offline, puede ser más privado, tener menor coste de conexión y menos dependencia de la cobertura, pero el comportamiento depende del motor de voz instalado y de la plataforma. **La prueba de modo avión por sí sola no confirma dónde se procesa el audio cuando hay Internet.**

### 2. Dos situaciones donde no se puede usar la voz

- En una biblioteca o en clase, hablar puede molestar. Se pueden pulsar Añadir, Borrar y Leer.
- Si se deniega el permiso de micrófono o falla el reconocimiento, se usan los mismos botones sin necesidad de voz.

## Capturas para entregar

1. **Captura A1:** lista con al menos 3 elementos añadidos y botones visibles.
2. **Captura A2:** reconocimiento de «leer» o «añadir», con transcripción y última orden. (Hay que hacerlo en el dispositivo).
3. **Captura A3 (recomendada):** resultado de `flutter test` en la terminal.

## Ampliación opcional no incluida

Dropdown para cambiar idioma: no es un requisito básico del enunciado.

## Fuentes técnicas consultadas

- https://pub.dev/packages/speech_to_text
- https://pub.dev/packages/flutter_tts
