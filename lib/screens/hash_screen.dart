import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';

class HashScreen extends StatefulWidget {
  const HashScreen({super.key});

  @override
  State<HashScreen> createState() => _HashScreenState();
}

class _HashScreenState extends State<HashScreen> {
  final TextEditingController claveController = TextEditingController();
  final TextEditingController valorController = TextEditingController();

  @override
  void dispose() {
    claveController.dispose();
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch reconstruye la UI cada vez que el provider notifica cambios
    final provider = context.watch<AppProvider>();

    // Obtenemos la lista de claves directamente del provider
    final claves = provider.hashManual.claves();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tabla Hash"),
        backgroundColor: Colors.red,
        actions: [
          // Botón para limpiar toda la tabla
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpiar tabla',
            onPressed: claves.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Limpiar tabla'),
                        content: const Text(
                            '¿Eliminar todos los elementos de la tabla hash?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.hashManualLimpiar();
                              Navigator.pop(context);
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  },
          ),
        ],
      ),
      drawer: const NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Campos de entrada ──────────────────────────────────
            TextField(
              controller: claveController,
              decoration: const InputDecoration(
                labelText: "Clave",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valorController,
              decoration: const InputDecoration(
                labelText: "Valor",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Botón insertar ─────────────────────────────────────
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Insertar"),
              onPressed: () {
                final clave = claveController.text.trim();
                if (clave.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La clave no puede estar vacía')),
                  );
                  return;
                }
                // Llama al provider — los datos persisten en toda la sesión
                provider.hashManualPoner(clave, valorController.text.trim());
                claveController.clear();
                valorController.clear();
              },
            ),
            const SizedBox(height: 20),

            // ── Encabezado de la lista ─────────────────────────────
            Row(
              children: [
                Text(
                  'Entradas almacenadas: ${claves.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(),

            // ── Lista de entradas ──────────────────────────────────
            Expanded(
              child: claves.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay entradas.\nIngresa una clave y un valor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: claves.length,
                      itemBuilder: (context, index) {
                        final clave = claves[index];
                        final valor =
                            provider.hashManual.obtener(clave)?.toString() ?? '';
                        final indice = provider.hashManual.indiceDe(clave);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade100,
                              child: Text(
                                '$indice',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              clave,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(valor.isEmpty ? '(sin valor)' : valor),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                provider.hashManualEliminar(clave);
                              },
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