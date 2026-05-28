import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/paciente.dart';
import '../models/observacion.dart';
import '../widgets/nav_drawer.dart';

class DetallePacienteScreen extends StatelessWidget {
  const DetallePacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Paciente pacienteInicial =
        ModalRoute.of(context)!.settings.arguments as Paciente;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // Siempre usar la versión más actualizada del paciente desde el provider
        final Paciente paciente = provider.pacientes.firstWhere(
          (p) => p.id == pacienteInicial.id,
          orElse: () => pacienteInicial,
        );

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

        final List<Observacion> observaciones = provider.observaciones
            .where((o) => o.pacienteId == paciente.id)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('${paciente.nombre} ${paciente.apellido}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar datos del paciente',
                onPressed: () =>
                    _mostrarDialogoEditarPaciente(context, paciente, provider),
              ),
            ],
          ),
          drawer: const NavDrawer(),
          body: SingleChildScrollView(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Datos personales',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () => _mostrarDialogoEditarPaciente(
                          context, paciente, provider),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Editar'),
                    ),
                  ],
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

                // Citas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Citas',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text('${paciente.citas.length}'),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (paciente.citas.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Sin citas registradas',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  )
                else
                  ...paciente.citas.map((cita) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF00897B).withOpacity(0.1),
                            child: const Icon(Icons.event_outlined,
                                color: Color(0xFF00897B), size: 20),
                          ),
                          title: Text('${cita.fecha} — ${cita.hora}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          subtitle: Text(cita.motivo),
                        ),
                      )),

                const SizedBox(height: 20),

                // Botones de acción
                const Text(
                  'Acciones rápidas',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          provider.agregarAlHistorial(paciente);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '📋 ${paciente.nombre} agregado al historial'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.history_outlined),
                        label: const Text('Al historial'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          provider.agregarAColaEspera(paciente);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '🏥 ${paciente.nombre} en sala de espera'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF00897B),
                            ),
                          );
                        },
                        icon: const Icon(Icons.queue_outlined),
                        label: const Text('Sala de espera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Resultados/observaciones
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
                              style: TextStyle(color: Colors.grey[600]),
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
          ),
        );
      },
    );
  }

  String _obtenerIniciales(String nombre, String apellido) {
    final String a = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final String b = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$a$b';
  }

  void _mostrarDialogoEditarPaciente(
      BuildContext context, Paciente paciente, AppProvider provider) {
    final nombreCtrl = TextEditingController(text: paciente.nombre);
    final apellidoCtrl = TextEditingController(text: paciente.apellido);
    final fechaCtrl =
        TextEditingController(text: paciente.fechaNacimiento);
    final telefonoCtrl = TextEditingController(
        text: paciente.telefono == 'N/A' ? '' : paciente.telefono);
    final direccionCtrl = TextEditingController(
        text: paciente.direccion == 'Sin dirección'
            ? ''
            : paciente.direccion);
    String generoSeleccionado = paciente.genero;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.edit_outlined, color: Color(0xFF1565C0)),
                  SizedBox(width: 8),
                  Text('Editar Paciente'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nombreCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre *',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Campo requerido'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: apellidoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Apellido *',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Campo requerido'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: generoSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Género',
                            prefixIcon: Icon(Icons.wc_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'male', child: Text('Masculino')),
                            DropdownMenuItem(
                                value: 'female', child: Text('Femenino')),
                            DropdownMenuItem(
                                value: 'other', child: Text('Otro')),
                          ],
                          onChanged: (v) {
                            setStateDialog(() {
                              generoSeleccionado = v ?? 'male';
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: fechaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Fecha de Nacimiento (YYYY-MM-DD)',
                            prefixIcon: Icon(Icons.cake_outlined),
                            border: OutlineInputBorder(),
                            hintText: 'Ej: 1990-05-15',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: direccionCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Dirección',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar cambios'),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    provider.actualizarPaciente(
                      pacienteId: paciente.id,
                      nombre: nombreCtrl.text,
                      apellido: apellidoCtrl.text,
                      genero: generoSeleccionado,
                      fechaNacimiento: fechaCtrl.text,
                      telefono: telefonoCtrl.text,
                      direccion: direccionCtrl.text,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Datos actualizados'),
                        backgroundColor: Color(0xFF00897B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
            size: 18, color: Theme.of(context).colorScheme.primary),
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
          child: Icon(Icons.science_outlined, color: estadoColor, size: 20),
        ),
        title: Text(
          observacion.descripcion,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
