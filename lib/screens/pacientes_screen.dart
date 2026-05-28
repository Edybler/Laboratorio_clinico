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

    final String clave = query.trim().toLowerCase();
    final dynamic resultado = provider.hashBusqueda.obtener(clave);

    setState(() {
      _buscando = true;
      if (resultado != null) {
        _resultadosBusqueda = [resultado as Paciente];
      } else {
        _resultadosBusqueda = provider.pacientes.where((p) {
          final String nombreCompleto =
              '${p.nombre} ${p.apellido}'.toLowerCase();
          return nombreCompleto.contains(clave);
        }).toList();
      }
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
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Paciente'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar a\n"${paciente.nombreCompleto}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.eliminarPaciente(paciente.id);
              Navigator.pop(ctx);
              // Limpiar búsqueda si el paciente eliminado estaba en resultados
              if (_buscando) {
                _buscar(_searchController.text, provider);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '🗑️ Paciente "${paciente.nombreCompleto}" eliminado'),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Dialogo: Agregar Cita ─────────────────────────────────────

  void _mostrarDialogoAgregarCita(Paciente paciente, AppProvider provider) {
    final motivoCtrl = TextEditingController();
    String fechaSeleccionada = '';
    String horaSeleccionada = '';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF00897B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nueva Cita\n${paciente.nombreCompleto}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Selector de fecha
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.date_range_outlined),
                        title: Text(
                          fechaSeleccionada.isEmpty
                              ? 'Seleccionar fecha *'
                              : fechaSeleccionada,
                          style: TextStyle(
                            color: fechaSeleccionada.isEmpty
                                ? Colors.grey[600]
                                : Colors.black87,
                          ),
                        ),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              fechaSeleccionada =
                                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                      const Divider(height: 1),
                      // Selector de hora
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time_outlined),
                        title: Text(
                          horaSeleccionada.isEmpty
                              ? 'Seleccionar hora *'
                              : horaSeleccionada,
                          style: TextStyle(
                            color: horaSeleccionada.isEmpty
                                ? Colors.grey[600]
                                : Colors.black87,
                          ),
                        ),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              horaSeleccionada =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: motivoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Motivo de la cita',
                          prefixIcon: Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Control mensual',
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
                  icon: const Icon(Icons.check_outlined),
                  label: const Text('Agendar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (fechaSeleccionada.isEmpty ||
                        horaSeleccionada.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor selecciona fecha y hora'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    provider.agregarCita(
                      pacienteId: paciente.id,
                      fecha: fechaSeleccionada,
                      hora: horaSeleccionada,
                      motivo: motivoCtrl.text,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '📅 Cita agendada para $fechaSeleccionada a las $horaSeleccionada'),
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

  // ── Dialogo: Ver y gestionar citas del paciente ───────────────

  void _mostrarCitasPaciente(Paciente paciente, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<AppProvider>(
          builder: (ctx, prov, _) {
            // Obtener la versión actualizada del paciente
            final Paciente actual = prov.pacientes.firstWhere(
              (p) => p.id == paciente.id,
              orElse: () => paciente,
            );
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.55,
              minChildSize: 0.3,
              maxChildSize: 0.85,
              builder: (_, scrollCtrl) {
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
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: Color(0xFF00897B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Citas de ${actual.nombreCompleto}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar'),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _mostrarDialogoAgregarCita(actual, provider);
                            },
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
                                  'No hay citas registradas',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            controller: scrollCtrl,
                            itemCount: actual.citas.length,
                            itemBuilder: (_, index) {
                              final Cita cita = actual.citas[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4),
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
                                      prov.eliminarCita(
                                        pacienteId: actual.id,
                                        citaId: cita.id,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('🗑️ Cita eliminada'),
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
              // Barra de búsqueda
              Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Buscar paciente por nombre...',
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
      // FAB con opciones
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
