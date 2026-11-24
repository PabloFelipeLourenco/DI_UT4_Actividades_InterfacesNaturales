import 'package:flutter_test/flutter_test.dart';
import 'package:lista_voz/comandos.dart';

void main() {
  test('El enum de comandos está disponible', () {
    expect(interpretarComando('crear'), Comando.anadir);
  });
}
