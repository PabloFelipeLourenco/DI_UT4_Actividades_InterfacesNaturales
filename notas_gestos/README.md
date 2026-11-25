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
