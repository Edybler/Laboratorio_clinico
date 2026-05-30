import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';
import '../widgets/estructura_visualizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.biotech, size: 26),
            SizedBox(width: 8),
            Text('Laboratorio Clínico'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => provider.cargarDatos(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner de bienvenida
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🏥 Sistema de Laboratorio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Programación III — UMG\nAPI: HAPI FHIR R4',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Métricas principales
                      const Text(
                        'Resumen del sistema',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: [
                          MetricaCard(
                            titulo: 'Total Pacientes',
                            valor: '${provider.pacientes.length}',
                            icono: Icons.people_alt_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          MetricaCard(
                            titulo: 'En Espera',
                            valor: '${provider.colaEspera.tamano}',
                            icono: Icons.access_time_outlined,
                            color: const Color(0xFF00897B),
                          ),
                          MetricaCard(
                            titulo: 'Exámenes Cargados',
                            valor: '${provider.observaciones.length}',
                            icono: Icons.science_outlined,
                            color: Colors.orange[700]!,
                          ),
                          MetricaCard(
                            titulo: 'Médicos',
                            valor: '${provider.medicos.length}',
                            icono: Icons.medical_services_outlined,
                            color: Colors.purple[600]!,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Estado de las estructuras de datos
                      const Text(
                        'Estructuras de datos',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      EstructuraVisualizer(
                        titulo: 'Pila — Historial de exámenes',
                        cantidad: provider.pilaHistorial.tamano,
                        icono: Icons.layers_outlined,
                        color: Colors.deepPurple,
                        descripcion: 'Exámenes consultados (LIFO)',
                      ),
                      const SizedBox(height: 8),
                      EstructuraVisualizer(
                        titulo: 'Cola — Sala de espera',
                        cantidad: provider.colaEspera.tamano,
                        icono: Icons.queue_outlined,
                        color: const Color(0xFF00897B),
                        descripcion: 'Pacientes en espera (FIFO)',
                      ),
                      const SizedBox(height: 8),
                      EstructuraVisualizer(
                        titulo: 'Lista — Resultados de laboratorio',
                        cantidad: provider.listaResultados.tamano,
                        icono: Icons.list_alt_outlined,
                        color: Colors.orange[700]!,
                        descripcion: 'Lista doblemente enlazada',
                      ),
                      const SizedBox(height: 8),
                      EstructuraVisualizer(
                        titulo: 'Árbol BST — Índice de pacientes',
                        cantidad: provider.pacientes.length,
                        icono: Icons.account_tree_outlined,
                        color: Colors.green[700]!,
                        descripcion: 'Búsqueda por clave numérica',
                      ),
                      const SizedBox(height: 8),
                      EstructuraVisualizer(
                        titulo: 'Tabla Hash — Búsqueda rápida',
                        cantidad: provider.pacientes.length,
                        icono: Icons.tag,
                        color: Colors.blueGrey[700]!,
                        descripcion: '31 cubetas, O(1) promedio',
                      ),
                      const SizedBox(height: 8),
                      EstructuraVisualizer(
                        titulo: 'Grafo — Red médica',
                        cantidad: provider.medicos.length,
                        icono: Icons.hub_outlined,
                        color: Colors.teal[700]!,
                        descripcion: 'Vértices = médicos',
                      ),

                      // Mensaje si no hay datos cargados
                      if (provider.pacientes.isEmpty &&
                          !provider.cargando) ...[
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.cloud_download_outlined,
                                  size: 48,
                                  color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Presiona el botón para cargar\nlos datos desde HAPI FHIR R4',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Progress indicator mientras carga
              if (provider.cargando)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return FloatingActionButton.extended(
            onPressed: provider.cargando
                ? null
                : () async {
                    await provider.cargarDatos();
                    if (context.mounted && provider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${provider.error}'),
                          backgroundColor: Colors.red[700],
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Datos cargados correctamente'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF00897B),
                        ),
                      );
                    }
                  },
            icon: provider.cargando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_download_outlined),
            label: Text(
                provider.cargando ? 'Cargando...' : 'Cargar datos del API'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }
}