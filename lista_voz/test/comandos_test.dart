import 'package:flutter_test/flutter_test.dart';
import 'package:lista_voz/comandos.dart';

void main() {
  test('Añadir con tilde', () {
    expect(interpretarComando('AÑADIR'), Comando.anadir);
  });

  test('Añadir sin tilde', () {
    expect(interpretarComando('anade'), Comando.anadir);
  });

  test('Añadir dentro de una frase', () {
    expect(interpretarComando('Por favor, añade uno'), Comando.anadir);
  });

  test('Sinónimos de borrar', () {
    expect(interpretarComando('Quiero eliminar uno'), Comando.borrar);
    expect(interpretarComando('borra el último'), Comando.borrar);
  });

  test('Leer con pregunta y tilde', () {
    expect(interpretarComando('¿Cuántos hay?'), Comando.leer);
    expect(interpretarComando('LEE la lista'), Comando.leer);
  });

  test('Ayuda y comandos', () {
    expect(interpretarComando('dime los comandos'), Comando.ayuda);
  });

  test('Frase desconocida', () {
    expect(interpretarComando('hola mundo'), Comando.desconocido);
  });

  test('Texto vacío', () {
    expect(interpretarComando('  '), Comando.desconocido);
  });

  test('No reconoce coincidencias dentro de otras palabras', () {
    expect(interpretarComando('mi listado'), Comando.desconocido);
  });
}
