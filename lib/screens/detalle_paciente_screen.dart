import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/paciente.dart';
import '../models/observacion.dart';
import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';

class DetallePacienteScreen extends StatelessWidget {
  const DetallePacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Paciente paciente =
        ModalRoute.of(context)!.settings.arguments as Paciente;

    final bool esMasculino = paciente.genero.toLowerCase() == 'male';
    final bool esFemenino = paciente.genero.toLowerCase() == 'female';

    final Color colorGenero = esMasculino
        ? const Color(0xFF1565C0)
        : esFemenino
            ? const Color(0xFFAD1457)
            : Colors.grey;

    final String iniciales =
        _obtenerIniciales(paciente.nombre, paciente.apellido);

    final String generoLabel = esMasculino
        ? 'Masculino'
        : esFemenino
            ? 'Femenino'
            : 'Otro';

    return Scaffold(
      appBar: AppBar(
        title: Text('${paciente.nombre} ${paciente.apellido}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          // Observaciones del paciente
          final List<Observacion> observaciones = provider.observaciones
              .where((o) => o.pacienteId == paciente.id)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con avatar grande
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colorGenero.withOpacity(0.15),
                        child: Text(
                          iniciales,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: colorGenero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${paciente.nombre} ${paciente.apellido}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Chip(
                        label: Text(
                          generoLabel,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: colorGenero,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Datos personales
                const Text(
                  'Datos personales',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _FilaDato(
                          icono: Icons.badge_outlined,
                          etiqueta: 'ID',
                          valor: paciente.id,
                        ),
                        const Divider(height: 16),
                        _FilaDato(
                          icono: Icons.cake_outlined,
                          etiqueta: 'Fecha de nacimiento',
                          valor: paciente.fechaNacimiento.isNotEmpty
                              ? paciente.fechaNacimiento
                              : 'No registrada',
                        ),
                        const Divider(height: 16),
                        _FilaDato(
                          icono: Icons.phone_outlined,
                          etiqueta: 'Teléfono',
                          valor: paciente.telefono,
                        ),
                        const Divider(height: 16),
                        _FilaDato(
                          icono: Icons.location_on_outlined,
                          etiqueta: 'Dirección',
                          valor: paciente.direccion,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botones de acción para estructuras
                const Text(
                  'Acciones',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          provider.pilaHistorial.push(paciente);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '📚 ${paciente.nombre} agregado al historial'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.layers_outlined),
                        label: const Text('Agregar al historial'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          provider.colaEspera.encolar(paciente);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '🔄 ${paciente.nombre} en cola de espera'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor:
                                  const Color(0xFF00897B),
                            ),
                          );
                        },
                        icon: const Icon(Icons.queue_outlined),
                        label: const Text('Cola de espera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Resultados/observaciones del paciente
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Resultados de exámenes',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text('${observaciones.length}'),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (observaciones.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.science_outlined,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Sin resultados registrados\npara este paciente',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...observaciones
                      .map((obs) => _ObservacionTile(observacion: obs)),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  String _obtenerIniciales(String nombre, String apellido) {
    final String a = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final String b = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$a$b';
  }
}

class _FilaDato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _FilaDato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono,
            size: 18,
            color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500),
              ),
              Text(
                valor,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ObservacionTile extends StatelessWidget {
  final Observacion observacion;

  const _ObservacionTile({required this.observacion});

  @override
  Widget build(BuildContext context) {
    final Color estadoColor = observacion.estado == 'final'
        ? Colors.green
        : observacion.estado == 'preliminary'
            ? Colors.orange
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: estadoColor.withOpacity(0.15),
          child: Icon(Icons.science_outlined,
              color: estadoColor, size: 20),
        ),
        title: Text(
          observacion.descripcion,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          observacion.fecha.isNotEmpty
              ? observacion.fecha
              : 'Fecha no disponible',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${observacion.valor} ${observacion.unidad}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                observacion.estado,
                style: TextStyle(fontSize: 10, color: estadoColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
