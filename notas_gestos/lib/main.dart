import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'detector_agitado.dart';

void main() {
  runApp(const NotasGestosApp());
}

class NotasGestosApp extends StatelessWidget {
  const NotasGestosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notas con gestos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PantallaNotas(),
    );
  }
}

class Nota {
  final int id;
  final String texto;

  Nota(this.id, this.texto);
}

class PantallaNotas extends StatefulWidget {
  const PantallaNotas({super.key});

  @override
  State<PantallaNotas> createState() => _PantallaNotasState();
}

class _PantallaNotasState extends State<PantallaNotas> {
  final TextEditingController _controlador = TextEditingController();
  final List<Nota> _notas = [];
  DetectorAgitado _detector = DetectorAgitado();
  StreamSubscription<UserAccelerometerEvent>? _suscripcion;

  int _siguienteId = 1;
  Nota? _ultimaNotaBorrada;
  int _posicionBorrada = 0;
  bool _agitarActivado = true;
  bool _sensorDisponible = true;
  String _mensaje = 'Añade notas, bórralas y agita el móvil para recuperarlas.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _escucharSensor();
    });
  }

  void _escucharSensor() {
    _detenerSensor();
    _detector = DetectorAgitado();

    try {
      _suscripcion = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (evento) {
          if (!_agitarActivado || !mounted) return;
          final esSacudida = _detector.procesar(
            evento.x,
            evento.y,
            evento.z,
            DateTime.now(),
          );
          if (esSacudida && _ultimaNotaBorrada != null) {
            _deshacer(agitando: true);
          }
        },
        onError: (Object error) {
          _detenerSensor();
          if (!mounted) return;
          setState(() {
            _sensorDisponible = false;
            _agitarActivado = false;
            _mensaje = 'Este dispositivo no tiene acelerómetro';
          });
        },
        cancelOnError: true,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sensorDisponible = false;
        _agitarActivado = false;
        _mensaje = 'Este dispositivo no tiene acelerómetro';
      });
    }
  }

  void _detenerSensor() {
    _suscripcion?.cancel();
    _suscripcion = null;
  }

  void _cambiarInterruptor(bool activo) {
    setState(() => _agitarActivado = activo);
    if (activo) {
      _escucharSensor();
    } else {
      _detenerSensor();
    }
  }

  void _agregarNota() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _notas.add(Nota(_siguienteId++, texto));
      _mensaje = 'Nota añadida';
    });
    _controlador.clear();
    FocusScope.of(context).unfocus();
  }

  void _borrarNota(Nota nota) {
    final posicion = _notas.indexWhere((n) => n.id == nota.id);
    if (posicion == -1) return;

    setState(() {
      _ultimaNotaBorrada = nota;
      _posicionBorrada = posicion;
      _notas.removeAt(posicion);
      _mensaje = 'Nota borrada';
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nota borrada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: _deshacer,
        ),
      ),
    );
  }

  void _deshacer({bool agitando = false}) {
    final nota = _ultimaNotaBorrada;
    if (nota == null) return;

    setState(() {
      final posicion = _posicionBorrada > _notas.length
          ? _notas.length
          : _posicionBorrada;
      _notas.insert(posicion, nota);
      _ultimaNotaBorrada = null;
      _mensaje = agitando ? 'Nota recuperada al agitar' : 'Nota recuperada';
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (agitando) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota recuperada al agitar')),
      );
    }
  }

  @override
  void dispose() {
    _detenerSensor();
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis notas'),
        actions: [
          IconButton(
            tooltip: _agitarActivado
                ? 'Agitar para deshacer está activo'
                : 'Agitar para deshacer está desactivado',
            onPressed: _sensorDisponible
                ? () => _cambiarInterruptor(!_agitarActivado)
                : null,
            icon: Icon(
              _agitarActivado ? Icons.vibration : Icons.mobile_off,
              color: _agitarActivado ? Colors.teal : Colors.grey,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Agitar para deshacer'),
              subtitle: Text(_sensorDisponible
                  ? 'Puedes apagar el gesto cuando quieras'
                  : 'Este dispositivo no tiene acelerómetro'),
              value: _agitarActivado,
              onChanged: _sensorDisponible ? _cambiarInterruptor : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controlador,
                      decoration: const InputDecoration(
                        labelText: 'Escribe una nota',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _agregarNota(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _agregarNota,
                    icon: const Icon(Icons.add),
                    tooltip: 'Añadir nota',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_mensaje, textAlign: TextAlign.center),
            ),
            if (_ultimaNotaBorrada != null)
              TextButton.icon(
                onPressed: _deshacer,
                icon: const Icon(Icons.undo),
                label: const Text('Deshacer último borrado'),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _notas.isEmpty
                  ? const Center(child: Text('Todavía no tienes notas.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _notas.length,
                      itemBuilder: (context, indice) {
                        final nota = _notas[indice];
                        return Dismissible(
                          key: ValueKey(nota.id),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            color: Colors.red.shade100,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(16),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red.shade100,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(16),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                          onDismissed: (_) => _borrarNota(nota),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.note_alt_outlined),
                              title: Text(nota.texto),
                              trailing: IconButton(
                                tooltip: 'Borrar nota',
                                onPressed: () => _borrarNota(nota),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
