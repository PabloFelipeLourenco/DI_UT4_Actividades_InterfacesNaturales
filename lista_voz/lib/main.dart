import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'comandos.dart';

void main() {
  runApp(const ListaVozApp());
}

class ListaVozApp extends StatelessWidget {
  const ListaVozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista controlada por voz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PantallaLista(),
    );
  }
}

class PantallaLista extends StatefulWidget {
  const PantallaLista({super.key});

  @override
  State<PantallaLista> createState() => _PantallaListaState();
}

class _PantallaListaState extends State<PantallaLista> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final List<int> _elementos = [];

  int _siguienteNumero = 1;
  bool _vozDisponible = false;
  bool _inicializando = true;
  bool _escuchando = false;
  bool _resultadoProcesado = false;
  String _transcripcion = 'Todavía no has hablado.';
  String _ultimaOrden = 'Ninguna';
  String _estadoMicrofono = 'Preparando el reconocimiento de voz...';

  @override
  void initState() {
    super.initState();
    _iniciarVoz();
  }

  Future<void> _iniciarVoz() async {
    try {
      // No se necesita permiso Bluetooth para este ejercicio.
      final disponible = await _speech.initialize(
        options: [SpeechToText.androidNoBluetooth],
        onStatus: (estado) {
          if (!mounted) return;
          setState(() {
            _escuchando = estado == 'listening';
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _escuchando = false;
            _estadoMicrofono = 'Error de reconocimiento: ${error.errorMsg}';
          });
        },
      );
      try {
        await _tts.setLanguage('es-ES');
      } catch (_) {
        // Los botones y el reconocimiento siguen funcionando sin TTS.
      }
      if (!mounted) return;
      setState(() {
        _vozDisponible = disponible;
        _inicializando = false;
        _estadoMicrofono = disponible
            ? 'Pulsa el micrófono y habla durante un máximo de 5 segundos.'
            : 'No hay permiso de micrófono o servicio de voz. Usa los botones.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _inicializando = false;
        _vozDisponible = false;
        _estadoMicrofono = 'No se pudo activar el micrófono. Usa los botones.';
      });
    }
  }

  Future<void> _pulsarMicrofono() async {
    if (!_vozDisponible) return;

    if (_speech.isListening) {
      await _speech.stop();
      if (mounted) setState(() => _escuchando = false);
      return;
    }

    try {
      await _tts.stop();
    } catch (_) {
      // El micrófono puede funcionar aunque no haya servicio de voz TTS.
    }
    _resultadoProcesado = false;
    if (mounted) {
      setState(() {
        _transcripcion = 'Escuchando...';
        _estadoMicrofono = 'Escuchando tu orden...';
      });
    }

    try {
      await _speech.listen(
        localeId: 'es_ES',
        listenFor: const Duration(seconds: 5),
        listenOptions: SpeechListenOptions(partialResults: true),
        onResult: _alReconocer,
      );
      if (mounted) setState(() => _escuchando = _speech.isListening);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _escuchando = false;
        _estadoMicrofono = 'No se pudo iniciar la escucha. Prueba con los botones.';
      });
    }
  }

  void _alReconocer(SpeechRecognitionResult resultado) {
    if (!mounted) return;
    setState(() => _transcripcion = resultado.recognizedWords);

    if (resultado.finalResult && !_resultadoProcesado) {
      _resultadoProcesado = true;
      _ejecutar(interpretarComando(resultado.recognizedWords),
          reconocido: resultado.recognizedWords);
    }
  }

  Future<void> _decir(String mensaje) async {
    try {
      await _tts.stop();
      await _tts.speak(mensaje);
    } catch (_) {
      // Si el móvil no tiene TTS, la app sigue funcionando visualmente.
    }
  }

  Future<void> _ejecutar(Comando comando, {String reconocido = ''}) async {
    String respuesta;
    switch (comando) {
      case Comando.anadir:
        final numero = _siguienteNumero++;
        setState(() {
          _elementos.add(numero);
          _ultimaOrden = 'Añadir';
        });
        respuesta = 'Añadido el elemento $numero';
        break;
      case Comando.borrar:
        if (_elementos.isEmpty) {
          respuesta = 'La lista está vacía';
        } else {
          final numero = _elementos.last;
          setState(() => _elementos.removeLast());
          respuesta = 'Borrado el elemento $numero';
        }
        setState(() => _ultimaOrden = 'Borrar');
        break;
      case Comando.leer:
        setState(() => _ultimaOrden = 'Leer');
        respuesta = 'Hay ${_elementos.length} elementos';
        break;
      case Comando.ayuda:
        setState(() => _ultimaOrden = 'Ayuda');
        respuesta = 'Puedes decir añadir, borrar, leer o ayuda';
        break;
      case Comando.desconocido:
        setState(() => _ultimaOrden = 'No reconocida');
        respuesta = 'No he entendido la orden';
        final texto = reconocido.isEmpty ? '(sin palabras)' : reconocido;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No he entendido «$texto». Di «ayuda» para oír las órdenes.')),
        );
        break;
    }
    if (!mounted) return;
    setState(() => _estadoMicrofono = respuesta);
    await _decir(respuesta);
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi lista por voz')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Control por voz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      IconButton.filled(
                        iconSize: 36,
                        tooltip: _escuchando ? 'Detener escucha' : 'Escuchar orden',
                        onPressed: (_vozDisponible && !_inicializando) ? _pulsarMicrofono : null,
                        style: IconButton.styleFrom(
                          backgroundColor: _escuchando ? Colors.red : Colors.indigo,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        icon: Icon(_escuchando ? Icons.stop_circle : Icons.mic),
                      ),
                      const SizedBox(height: 10),
                      Text(_estadoMicrofono, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text('Transcripción: $_transcripcion'),
                      const SizedBox(height: 6),
                      Text('Última orden: $_ultimaOrden', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => _ejecutar(Comando.anadir),
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _ejecutar(Comando.borrar),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Borrar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _ejecutar(Comando.leer),
                    icon: const Icon(Icons.record_voice_over),
                    label: const Text('Leer'),
                  ),
                  TextButton.icon(
                    onPressed: () => _ejecutar(Comando.ayuda),
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Ayuda'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Elementos (${_elementos.length})', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (_elementos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Tu lista está vacía. Di «añadir» o pulsa el botón.', textAlign: TextAlign.center),
                )
              else
                ..._elementos.map((numero) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text('Elemento $numero'),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
