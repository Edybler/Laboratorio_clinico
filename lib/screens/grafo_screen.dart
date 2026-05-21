import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';

class GrafoScreen extends StatefulWidget {
  const GrafoScreen({super.key});

  @override
  State<GrafoScreen> createState() => _GrafoScreenState();
}

class _GrafoScreenState extends State<GrafoScreen> {
  final TextEditingController origenController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  final TextEditingController inicioController = TextEditingController();

  String bfsResultado = "";
  String dfsResultado = "";

  @override
  void dispose() {
    origenController.dispose();
    destinoController.dispose();
    inicioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usa el AppProvider para que los datos persistan entre navegaciones
    final provider = context.watch<AppProvider>();
    final grafo = provider.grafoManual;
    final vertices = grafo.vertices();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Grafo"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpiar grafo',
            onPressed: vertices.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Limpiar grafo'),
                        content: const Text('¿Eliminar todos los vértices y aristas?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.grafoManualLimpiar();
                              setState(() {
                                bfsResultado = "";
                                dfsResultado = "";
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Limpiar'),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Agregar arista ─────────────────────────────────────
              const Text(
                'Agregar conexión',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: origenController,
                decoration: const InputDecoration(
                  labelText: "Origen",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: destinoController,
                decoration: const InputDecoration(
                  labelText: "Destino",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Agregar Arista"),
                onPressed: () {
                  final origen = origenController.text.trim();
                  final destino = destinoController.text.trim();
                  if (origen.isEmpty || destino.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Ingresa tanto Origen como Destino')),
                    );
                    return;
                  }
                  provider.grafoManualAgregarArista(origen, destino);
                  origenController.clear();
                  destinoController.clear();
                },
              ),

              const SizedBox(height: 20),
              const Divider(),

              // ── Vértices actuales ──────────────────────────────────
              Text(
                'Vértices (${vertices.length}): ${vertices.isEmpty ? "ninguno" : vertices.join(", ")}',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // ── BFS / DFS ──────────────────────────────────────────
              const Text(
                'Recorrido desde nodo:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: inicioController,
                decoration: const InputDecoration(
                  labelText: "Nodo de inicio",
                  hintText: "Escribe el vértice de inicio",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final inicio = inicioController.text.trim();
                        if (inicio.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ingresa el nodo de inicio')),
                          );
                          return;
                        }
                        final resultado = grafo.bfs(inicio);
                        setState(() {
                          bfsResultado = resultado.isEmpty
                              ? 'Nodo "$inicio" no existe en el grafo'
                              : resultado.join(' → ');
                        });
                      },
                      child: const Text("Mostrar BFS"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final inicio = inicioController.text.trim();
                        if (inicio.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ingresa el nodo de inicio')),
                          );
                          return;
                        }
                        final resultado = grafo.dfs(inicio);
                        setState(() {
                          dfsResultado = resultado.isEmpty
                              ? 'Nodo "$inicio" no existe en el grafo'
                              : resultado.join(' → ');
                        });
                      },
                      child: const Text("Mostrar DFS"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Resultados ─────────────────────────────────────────
              if (bfsResultado.isNotEmpty)
                Card(
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BFS:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(bfsResultado),
                      ],
                    ),
                  ),
                ),

              if (dfsResultado.isNotEmpty) ...[
                const SizedBox(height: 10),
                Card(
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DFS:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(dfsResultado),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Eliminar vértice ───────────────────────────────────
              if (vertices.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Eliminar vértice',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: vertices.map((v) {
                    return Chip(
                      label: Text(v),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        provider.grafoManualEliminarVertice(v);
                        setState(() {
                          bfsResultado = "";
                          dfsResultado = "";
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}