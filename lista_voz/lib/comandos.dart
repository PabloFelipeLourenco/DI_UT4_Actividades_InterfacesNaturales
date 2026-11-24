enum Comando { anadir, borrar, leer, ayuda, desconocido }

Comando interpretarComando(String texto) {
  final normalizado = texto.toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');

  final palabras = normalizado.split(RegExp(r'[^a-z0-9]+'));

  if (palabras.any((p) => ['anadir', 'anade', 'nuevo', 'crear'].contains(p))) {
    return Comando.anadir;
  }
  if (palabras.any((p) => ['borrar', 'borra', 'eliminar', 'quitar'].contains(p))) {
    return Comando.borrar;
  }
  if (palabras.any((p) => ['leer', 'lee', 'cuantos', 'lista'].contains(p))) {
    return Comando.leer;
  }
  if (palabras.any((p) => ['ayuda', 'comandos'].contains(p))) {
    return Comando.ayuda;
  }
  return Comando.desconocido;
}
