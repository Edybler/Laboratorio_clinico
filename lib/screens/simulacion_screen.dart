import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/paciente.dart';
import '../widgets/nav_drawer.dart';

/// Pantalla de prueba de procesos que simula el flujo completo del laboratorio.
class SimulacionScreen extends StatefulWidget {
  const SimulacionScreen({super.key});

  @override
  State<SimulacionScreen> createState() => _SimulacionScreenState();
}

class _SimulacionScreenState extends State<SimulacionScreen> {
  final List<_LogEntry> _log = [];
  bool _simulandoAuto = false;

  void _agregarLog(String mensaje, {bool esError = false, bool esExito = false}) {
    setState(() {
      _log.insert(
        0,
        _LogEntry(
          mensaje: mensaje,
          hora: DateTime.now(),
          esError: esError,
          esExito: esExito,
        ),
      );
    });
  }

  // Paso 1: Registrar un paciente de prueba
  void _paso1RegistrarPaciente(AppProvider provider) {
    final paciente = provider.agregarPaciente(
      nombre: 'Carlos',
      apellido: 'García',
      genero: 'male',
      fechaNacimiento: '1985-03-22',
      telefono: '5555-1234',
      direccion: 'Zona 10, Guatemala',
    );
    _agregarLog(
      '👤 Paso 1 — Paciente registrado: ${paciente.nombreCompleto} (ID: ${paciente.id})',
      esExito: true,
    );
  }

  // Paso 2: Agregar una cita
  void _paso2AgregarCita(AppProvider provider) {
    final pacientes = provider.pacientes;
    if (pacientes.isEmpty) {
      _agregarLog(
          '⚠️ Paso 2 — No hay pacientes. Ejecute el Paso 1 primero.',
          esError: true);
      return;
    }
    final paciente = pacientes.last;
    final ahora = DateTime.now();
    final fecha =
        '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${(ahora.day + 1).toString().padLeft(2, '0')}';
    provider.agregarCita(
      pacienteId: paciente.id,
      fecha: fecha,
      hora: '09:00',
      motivo: 'Análisis de sangre completo',
    );
    _agregarLog(
      '📅 Paso 2 — Cita registrada para ${paciente.nombre} el $fecha a las 09:00',
      esExito: true,
    );
  }

  // Paso 3: Agregar a sala de espera
  void _paso3AgregarColaEspera(AppProvider provider) {
    final pacientes = provider.pacientes;
    if (pacientes.isEmpty) {
      _agregarLog(
          '⚠️ Paso 3 — No hay pacientes. Ejecute el Paso 1 primero.',
          esError: true);
      return;
    }
    final paciente = pacientes.last;
    provider.agregarAColaEspera(paciente);
    _agregarLog(
      '🏥 Paso 3 — ${paciente.nombre} ingresó a sala de espera. En espera: ${provider.colaEspera.tamano}',
      esExito: true,
    );
  }

  // Paso 4: Registrar un médico
  void _paso4RegistrarMedico(AppProvider provider) {
    final medico = provider.agregarMedico(
      nombre: 'Ana Martínez',
      especialidad: 'Hematología',
      telefono: '5555-9876',
      email: 'ana.martinez@laboratorio.gt',
    );
    _agregarLog(
      '👨‍⚕️ Paso 4 — Médico registrado: Dr. ${medico.nombre} — ${medico.especialidad}',
      esExito: true,
    );
  }

  // Paso 5: Atender al siguiente paciente
  void _paso5AtenderPaciente(AppProvider provider) {
    if (provider.colaEspera.tamano == 0) {
      _agregarLog(
          '⚠️ Paso 5 — La sala de espera está vacía. Ejecute el Paso 3 primero.',
          esError: true);
      return;
    }
    final atendido = provider.atenderSiguiente();
    if (atendido != null) {
      _agregarLog(
        '✅ Paso 5 — Paciente atendido: ${atendido.nombreCompleto}. Total atendidos hoy: ${provider.atendidosHoy.length}',
        esExito: true,
      );
    }
  }

  // Paso 6: Agregar al historial de consultas
  void _paso6AgregarHistorial(AppProvider provider) {
    final pacientes = provider.pacientes;
    if (pacientes.isEmpty) {
      _agregarLog(
          '⚠️ Paso 6 — No hay pacientes. Ejecute el Paso 1 primero.',
          esError: true);
      return;
    }
    final paciente = pacientes.last;
    provider.agregarAlHistorial(paciente);
    _agregarLog(
      '📋 Paso 6 — ${paciente.nombre} agregado al historial de consultas (PILA). Tamaño: ${provider.pilaHistorial.tamano}',
      esExito: true,
    );
  }

  // Simulación automática completa
  Future<void> _simulacionAutomatica(AppProvider provider) async {
    setState(() {
      _simulandoAuto = true;
      _log.clear();
    });

    _agregarLog('🚀 Iniciando simulación automática del flujo completo...');
    await Future.delayed(const Duration(milliseconds: 600));

    _paso1RegistrarPaciente(provider);
    await Future.delayed(const Duration(milliseconds: 800));

    _paso4RegistrarMedico(provider);
    await Future.delayed(const Duration(milliseconds: 800));

    _paso2AgregarCita(provider);
    await Future.delayed(const Duration(milliseconds: 800));

    _paso3AgregarColaEspera(provider);
    await Future.delayed(const Duration(milliseconds: 800));

    _paso6AgregarHistorial(provider);
    await Future.delayed(const Duration(milliseconds: 800));

    _paso5AtenderPaciente(provider);
    await Future.delayed(const Duration(milliseconds: 600));

    _agregarLog(
      '🎉 Simulación completada. El paciente pasó por todo el flujo del laboratorio.',
      esExito: true,
    );

    setState(() => _simulandoAuto = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Procesos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_log.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Limpiar log',
              onPressed: () => setState(() => _log.clear()),
            ),
        ],
      ),
      drawer: const NavDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Banner explicativo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blueGrey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Simula el flujo completo de un paciente en el laboratorio: registro → cita → espera → atención.',
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resumen de estado actual
                      _ResumenEstado(provider: provider),

                      const SizedBox(height: 20),

                      // Pasos del flujo
                      const Text(
                        'Pasos del flujo de laboratorio',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      _PasoCard(
                        numero: 1,
                        titulo: 'Registrar Paciente',
                        descripcion:
                            'Crea un paciente de prueba "Carlos García" en el sistema.',
                        icono: Icons.person_add_outlined,
                        color: const Color(0xFF1565C0),
                        onPresionar: _simulandoAuto
                            ? null
                            : () => _paso1RegistrarPaciente(provider),
                      ),
                      _PasoCard(
                        numero: 2,
                        titulo: 'Registrar Médico',
                        descripcion:
                            'Agrega la Dra. Ana Martínez (Hematología) al directorio.',
                        icono: Icons.medical_services_outlined,
                        color: Colors.purple[700]!,
                        onPresionar: _simulandoAuto
                            ? null
                            : () => _paso4RegistrarMedico(provider),
                      ),
                      _PasoCard(
                        numero: 3,
                        titulo: 'Agregar Cita',
                        descripcion:
                            'Programa una cita para el último paciente registrado.',
                        icono: Icons.event_available_outlined,
                        color: Colors.teal[700]!,
                        onPresionar: _simulandoAuto
                            ? null
                            : () => _paso2AgregarCita(provider),
                      ),
                      _PasoCard(
                        numero: 4,
                        titulo: 'Ingresar a Sala de Espera',
                        descripcion:
                            'Coloca al último paciente en la cola de espera (FIFO).',
                        icono: Icons.queue_outlined,
                        color: const Color(0xFF00897B),
                        onPresionar: _simulandoAuto
                            ? null
                            : () => _paso3AgregarColaEspera(provider),
                      ),
                      _PasoCard(
                        numero: 5,
                        titulo: 'Agregar al Historial',
                        descripcion:
                            'Registra la consulta en el historial (PILA).',
                        icono: Icons.history_outlined,
                        color: Colors.deepPurple,
                        onPresionar: _simulandoAuto
                            ? null
                            : () => _paso6AgregarHistorial(provider),
                      ),
                      _PasoCard(
                        numero: 6,
                        titulo: 'Atender Paciente',
                        descripcion:
                            'Saca al siguiente de la sala de espera y lo registra como atendido.',
                        icono: Icons.check_circle_outline,
                        color: Colors.green[700]!,
                        onPresionar: _simulandoAuto
                            ? null
                            : () => _paso5AtenderPaciente(provider),
                      ),

                      const SizedBox(height: 16),

                      // Botón simulación automática
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _simulandoAuto
                              ? null
                              : () => _simulacionAutomatica(provider),
                          icon: _simulandoAuto
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.play_circle_outline),
                          label: Text(_simulandoAuto
                              ? 'Simulando...'
                              : '▶  Ejecutar flujo completo automáticamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(14),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Log de eventos
                      if (_log.isNotEmpty) ...[
                        const Text(
                          'Registro de eventos',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._log.map((entry) => _LogTile(entry: entry)),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────

class _ResumenEstado extends StatelessWidget {
  final AppProvider provider;
  const _ResumenEstado({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estado actual del sistema',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _EstadoChip(
                    label: 'Pacientes',
                    valor: '${provider.pacientes.length}',
                    color: const Color(0xFF1565C0)),
                const SizedBox(width: 8),
                _EstadoChip(
                    label: 'En espera',
                    valor: '${provider.colaEspera.tamano}',
                    color: const Color(0xFF00897B)),
                const SizedBox(width: 8),
                _EstadoChip(
                    label: 'Atendidos',
                    valor: '${provider.atendidosHoy.length}',
                    color: Colors.green[700]!),
                const SizedBox(width: 8),
                _EstadoChip(
                    label: 'Médicos',
                    valor: '${provider.medicos.length}',
                    color: Colors.purple[700]!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  const _EstadoChip(
      {required this.label, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(valor,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: TextStyle(fontSize: 10, color: color),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PasoCard extends StatelessWidget {
  final int numero;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color color;
  final VoidCallback? onPresionar;

  const _PasoCard({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.onPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            '$numero',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Text(titulo,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(descripcion,
            style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: Icon(icono, color: onPresionar != null ? color : Colors.grey),
          tooltip: titulo,
          onPressed: onPresionar,
        ),
      ),
    );
  }
}

class _LogEntry {
  final String mensaje;
  final DateTime hora;
  final bool esError;
  final bool esExito;

  _LogEntry({
    required this.mensaje,
    required this.hora,
    required this.esError,
    required this.esExito,
  });
}

class _LogTile extends StatelessWidget {
  final _LogEntry entry;
  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final Color color = entry.esError
        ? Colors.red
        : entry.esExito
            ? Colors.green
            : Colors.blueGrey;
    final hora =
        '${entry.hora.hour.toString().padLeft(2, '0')}:${entry.hora.minute.toString().padLeft(2, '0')}:${entry.hora.second.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hora,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'monospace')),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.mensaje,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
