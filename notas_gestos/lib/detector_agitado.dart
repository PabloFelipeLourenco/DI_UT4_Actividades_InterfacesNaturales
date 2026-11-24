import 'dart:math';

class DetectorAgitado {
  final double umbral;
  final Duration pausa;
  DateTime? _ultimaSacudida;

  DetectorAgitado({
    this.umbral = 15,
    this.pausa = const Duration(seconds: 1),
  });

  bool procesar(double x, double y, double z, DateTime instante) {
    final magnitud = sqrt(x * x + y * y + z * z);

    if (magnitud <= umbral) return false;

    if (_ultimaSacudida != null &&
        instante.difference(_ultimaSacudida!) < pausa) {
      return false;
    }

    _ultimaSacudida = instante;
    return true;
  }
}
