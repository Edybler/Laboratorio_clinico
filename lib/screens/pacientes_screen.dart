import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/paciente.dart';
import '../widgets/nav_drawer.dart';
import '../widgets/paciente_card.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Paciente> _resultadosBusqueda = [];
  bool _buscando = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _buscar(String query, AppProvider provider) {
    if (query.trim().isEmpty) {
      setState(() {
        _buscando = false;
        _resultadosBusqueda = [];
      });
      return;
    }
    setState(() {
      _buscando = true;
      _resultadosBusqueda = provider.buscarPacientes(query);
    });
  }

  // ── Dialogo: Agregar Paciente ─────────────────────────────────

  void _mostrarDialogoAgregarPaciente(AppProvider provider) {
    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final fechaCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();
    String generoSeleccionado = 'male';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.person_add_outlined, color: Color(0xFF1565C0)),
                  SizedBox(width: 8),
                  Text('Nuevo Paciente'),
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
                  label: const Text('Guardar'),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    provider.agregarPaciente(
                      nombre: nombreCtrl.text,
                      apellido: apellidoCtrl.text,
                      genero: generoSeleccionado,
                      fechaNacimiento: fechaCtrl.text,
                      telefono: telefonoCtrl.text,
                      direccion: direccionCtrl.text,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '✅ Paciente "${nombreCtrl.text.trim()} ${apellidoCtrl.text.trim()}" agregado'),
                        backgroundColor: const Color(0xFF00897B),
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

  // ── Dialogo: Confirmar Eliminar Paciente ──────────────────────

  void _confirmarEliminarPaciente(Paciente paciente, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Paciente'),
          ],
        ),
        content: Text(
            '¿Estás seguro de eliminar a "${paciente.nombreCompleto}"?\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.eliminarPaciente(paciente.id);
              Navigator.pop(ctx);
              // Limpiar búsqueda si el eliminado estaba en resultados
              if (_buscando) {
                _buscar(_searchController.text, provider);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Paciente eliminado'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Dialogo: Ver/Gestionar Citas del Paciente ─────────────────

  void _mostrarCitasPaciente(Paciente paciente, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            // Obtener paciente actualizado del provider
            final Paciente actual = provider.pacientes.firstWhere(
              (p) => p.id == paciente.id,
              orElse: () => paciente,
            );

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.92,
              minChildSize: 0.35,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Citas de ${actual.nombre}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _agregarCitaDialog(actual, provider, () {
                              setStateSheet(() {});
                            }),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Nueva cita'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (actual.citas.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy_outlined,
                                    size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Sin citas registradas',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: actual.citas.length,
                            itemBuilder: (_, index) {
                              final cita = actual.citas[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF00897B)
                                        .withOpacity(0.15),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                          color: Color(0xFF00897B),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(
                                    '${cita.fecha} — ${cita.hora}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(cita.motivo),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    tooltip: 'Eliminar cita',
                                    onPressed: () {
                                      provider.eliminarCita(
                                        pacienteId: actual.id,
                                        citaId: cita.id,
                                      );
                                      setStateSheet(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('🗑️ Cita eliminada'),
                                          behavior:
                                              SnackBarBehavior.floating,
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _agregarCitaDialog(
      Paciente paciente, AppProvider provider, VoidCallback onAgregada) {
    final fechaCtrl = TextEditingController();
    final horaCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.event_available_outlined, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Nueva Cita'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fechaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Fecha (YYYY-MM-DD) *',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Ej: 2025-06-10',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: horaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hora (HH:mm) *',
                    prefixIcon: Icon(Icons.access_time_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Ej: 09:30',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: motivoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    prefixIcon: Icon(Icons.notes_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Análisis de sangre',
                  ),
                  maxLines: 2,
                ),
              ],
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
            label: const Text('Guardar'),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              provider.agregarCita(
                pacienteId: paciente.id,
                fecha: fechaCtrl.text.trim(),
                hora: horaCtrl.text.trim(),
                motivo: motivoCtrl.text,
              );
              Navigator.pop(ctx);
              onAgregada();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Cita registrada'),
                  backgroundColor: Color(0xFF00897B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.pacientes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay pacientes cargados',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => provider.cargarDatos(),
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: const Text('Cargar datos'),
                  ),
                ],
              ),
            );
          }

          final List<Paciente> lista =
              _buscando ? _resultadosBusqueda : provider.pacientes;

          return Column(
            children: [
              // Barra de búsqueda mejorada
              Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Buscar por nombre, cita, fecha u hora...',
                  leading: const Icon(Icons.search),
                  trailing: _searchController.text.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _buscar('', provider);
                            },
                          )
                        ]
                      : null,
                  onChanged: (value) => _buscar(value, provider),
                  elevation: const WidgetStatePropertyAll(2),
                ),
              ),

              // Contador de resultados
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _buscando
                          ? '${lista.length} resultado(s) para "${_searchController.text}"'
                          : '${lista.length} pacientes cargados',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (_buscando && lista.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.filter_alt_outlined,
                          size: 14, color: Colors.blue[600]),
                      Text(
                        ' (nombre, cita, fecha, hora)',
                        style: TextStyle(
                            fontSize: 11, color: Colors.blue[600]),
                      ),
                    ],
                  ],
                ),
              ),

              // Lista de pacientes
              Expanded(
                child: lista.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No se encontraron pacientes',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: lista.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final Paciente paciente = lista[index];
                          return PacienteCard(
                            paciente: paciente,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/detalle-paciente',
                                arguments: paciente,
                              );
                            },
                            onEliminar: () => _confirmarEliminarPaciente(
                                paciente, provider),
                            onVerCitas: () =>
                                _mostrarCitasPaciente(paciente, provider),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return FloatingActionButton.extended(
            onPressed: () => _mostrarDialogoAgregarPaciente(provider),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Agregar Paciente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }
}
