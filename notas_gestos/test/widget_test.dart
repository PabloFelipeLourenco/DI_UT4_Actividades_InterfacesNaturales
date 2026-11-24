import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/detector_agitado.dart';

void main() {
  test('El detector funciona sin sensores nativos', () {
    expect(DetectorAgitado().procesar(0, 0, 0, DateTime.utc(2026)), false);
  });
}
