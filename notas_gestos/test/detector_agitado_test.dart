import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/detector_agitado.dart';

void main() {
  final inicio = DateTime.utc(2026, 1, 1, 12);

  test('Reposo: no hay sacudida', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(0, 0, 0, inicio), false);
  });

  test('Sacudida: supera el umbral', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(16, 0, 0, inicio), true);
  });

  test('Segunda sacudida: ignorada dentro de la pausa', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(16, 0, 0, inicio), true);
    expect(detector.procesar(20, 0, 0, inicio.add(const Duration(milliseconds: 500))), false);
  });

  test('Nueva sacudida: aceptada después de la pausa', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(16, 0, 0, inicio), true);
    expect(detector.procesar(20, 0, 0, inicio.add(const Duration(seconds: 2))), true);
  });

  test('El umbral es estricto y se usa el módulo de los tres ejes', () {
    final detector = DetectorAgitado();
    expect(detector.procesar(9, 12, 0, inicio), false);
    expect(detector.procesar(9, 12, 1, inicio), true);
  });
}
