import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';

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
                          _MetricaCard(
                            titulo: 'Total Pacientes',
                            valor: '${provider.pacientes.length}',
                            icono: Icons.people_alt_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          _MetricaCard(
                            titulo: 'En Sala de Espera',
                            valor: '${provider.colaEspera.tamano}',
                            icono: Icons.access_time_outlined,
                            color: const Color(0xFF00897B),
                          ),
                          _MetricaCard(
                            titulo: 'Atendidos Hoy',
                            valor: '${provider.atendidosHoy.length}',
                            icono: Icons.check_circle_outline,
                            color: Colors.green[700]!,
                          ),
                          _MetricaCard(
                            titulo: 'Médicos',
                            valor: '${provider.medicos.length}',
                            icono: Icons.medical_services_outlined,
                            color: Colors.purple[600]!,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Pacientes Atendidos del Día ─────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pacientes Atendidos Hoy',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (provider.atendidosHoy.isNotEmpty)
                            Chip(
                              label: Text('${provider.atendidosHoy.length}'),
                              backgroundColor: Colors.green[50],
                              labelStyle: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (provider.atendidosHoy.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.medical_services_outlined,
                                      size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ningún paciente atendido aún hoy',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ...provider.atendidosHoy.reversed.map(
                          (a) => _AtendidoTile(atendido: a),
                        ),

                      // Sala de espera actual
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cola de Espera Actual',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (provider.colaEspera.tamano > 0)
                            ElevatedButton.icon(
                              onPressed: () {
                                final atendido =
                                    provider.atenderSiguiente();
                                if (context.mounted && atendido != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '✅ ${atendido.nombreCompleto} atendido'),
                                      backgroundColor: Colors.green[700],
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('Atender siguiente'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00897B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (provider.colaEspera.tamano == 0)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'Sin pacientes en espera',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        )
                      else
                        _ColaEsperaPreview(provider: provider),

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

// ── Widgets locales ───────────────────────────────────────────────

class _MetricaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _MetricaCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              titulo,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _AtendidoTile extends StatelessWidget {
  final PacienteAtendido atendido;

  const _AtendidoTile({required this.atendido});

  @override
  Widget build(BuildContext context) {
    final hora =
        '${atendido.horaAtencion.hour.toString().padLeft(2, '0')}:${atendido.horaAtencion.minute.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[50],
          child: Icon(Icons.check, color: Colors.green[700], size: 20),
        ),
        title: Text(
          atendido.paciente.nombreCompleto,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'ID: ${atendido.paciente.id}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Text(
            hora,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
          ),
        ),
      ),
    );
  }
}

class _ColaEsperaPreview extends StatelessWidget {
  final AppProvider provider;

  const _ColaEsperaPreview({required this.provider});

  @override
  Widget build(BuildContext context) {
    final elementos = provider.colaEspera.aLista();
    return Card(
      child: Column(
        children: [
          ...elementos.asMap().entries.map((entry) {
            final idx = entry.key;
            final paciente = entry.value;
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  '${idx + 1}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(paciente.nombreCompleto,
                  style: const TextStyle(fontSize: 14)),
              subtitle: Text('ID: ${paciente.id}',
                  style: const TextStyle(fontSize: 11)),
              trailing: idx == 0
                  ? const Chip(
                      label: Text('Siguiente',
                          style: TextStyle(fontSize: 11)),
                      backgroundColor: Color(0xFFE8F5E9),
                    )
                  : null,
            );
          }),
        ],
      ),
    );
  }
}
