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
  Widget build(BuildContext context) {
    // Usa el AppProvider para que los datos persistan entre navegaciones
    final provider = context.watch<AppProvider>();
    final claves = provider.hashManual.claves();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tabla Hash"),
        backgroundColor: Colors.red,
      ),
      drawer: const NavDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: claveController,
              decoration: const InputDecoration(
                labelText: "Clave",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: valorController,
              decoration: const InputDecoration(
                labelText: "Valor",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (claveController.text.isEmpty) return;
                // Llama al provider — los datos persisten en toda la sesión
                provider.hashManualPoner(
                  claveController.text,
                  valorController.text,
                );
                claveController.clear();
                valorController.clear();
              },
              child: const Text("Insertar"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: claves.map((clave) {
                  final valor =
                      provider.hashManual.obtener(clave)?.toString() ?? '';

                  return Card(
                    child: ListTile(
                      title: Text(clave),
                      subtitle: Text(valor),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          provider.hashManualEliminar(clave);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}