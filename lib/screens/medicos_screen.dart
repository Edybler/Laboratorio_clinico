import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/medico.dart';
import '../widgets/nav_drawer.dart';

class MedicosScreen extends StatefulWidget {
  const MedicosScreen({super.key});

  @override
  State<MedicosScreen> createState() => _MedicosScreenState();
}

class _MedicosScreenState extends State<MedicosScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _mostrarDialogoAgregarMedico(AppProvider provider) {
    final nombreCtrl = TextEditingController();
    final especialidadCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add_outlined, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Nuevo Médico'),
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
                      labelText: 'Nombre completo *',
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
                    controller: especialidadCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                      border: OutlineInputBorder(),
                      hintText: 'Ej: Hematología, Cardiología...',
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
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
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
              provider.agregarMedico(
                nombre: nombreCtrl.text,
                especialidad: especialidadCtrl.text,
                telefono: telefonoCtrl.text,
                email: emailCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '✅ Dr. ${nombreCtrl.text.trim()} registrado'),
                  backgroundColor: const Color(0xFF00897B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarMedico(Medico medico, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Médico'),
          ],
        ),
        content: Text(
            '¿Eliminar al Dr. "${medico.nombre}"?\nEsta acción no se puede deshacer.'),
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
              provider.eliminarMedico(medico.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Médico eliminado'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médicos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final medicos = _query.trim().isEmpty
              ? provider.medicos
              : provider.medicos.where((m) {
                  final q = _query.toLowerCase();
                  return m.nombre.toLowerCase().contains(q) ||
                      m.especialidad.toLowerCase().contains(q);
                }).toList();

          return Column(
            children: [
              // Barra de búsqueda
              Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBar(
                  controller: _searchCtrl,
                  hintText: 'Buscar por nombre o especialidad...',
                  leading: const Icon(Icons.search),
                  trailing: _searchCtrl.text.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        ]
                      : null,
                  onChanged: (v) => setState(() => _query = v),
                  elevation: const WidgetStatePropertyAll(2),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${medicos.length} médico(s)',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: medicos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay médicos registrados',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _mostrarDialogoAgregarMedico(provider),
                              icon: const Icon(Icons.person_add_outlined),
                              label: const Text('Agregar médico'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: medicos.length,
                        itemBuilder: (context, index) {
                          final m = medicos[index];
                          return _MedicoCard(
                            medico: m,
                            onEliminar: () =>
                                _confirmarEliminarMedico(m, provider),
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
            onPressed: () => _mostrarDialogoAgregarMedico(provider),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Agregar Médico'),
            backgroundColor: Colors.purple[700],
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }
}

class _MedicoCard extends StatelessWidget {
  final Medico medico;
  final VoidCallback onEliminar;

  const _MedicoCard({required this.medico, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[50],
          child: Text(
            medico.iniciales,
            style: TextStyle(
                color: Colors.purple[700], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'Dr. ${medico.nombre}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services_outlined,
                    size: 13, color: Colors.purple[400]),
                const SizedBox(width: 4),
                Text(medico.especialidad,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            if (medico.telefono != 'N/A')
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(medico.telefono,
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            if (medico.email != 'N/A')
              Row(
                children: [
                  Icon(Icons.email_outlined,
                      size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(medico.email,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Eliminar médico',
          onPressed: onEliminar,
        ),
      ),
    );
  }
}
