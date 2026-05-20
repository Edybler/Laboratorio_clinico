import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

class AnalisisScreen extends StatefulWidget {
  const AnalisisScreen({super.key});

  @override
  State<AnalisisScreen> createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de datos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Pacientes'),
            Tab(text: 'Condiciones'),
            Tab(text: 'Exámenes'),
            Tab(text: 'Estructuras'),
          ],
        ),
      ),
      drawer: const NavDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.pacientes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sin datos para analizar',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.cargarDatos,
                    child: const Text('Cargar datos'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _TabPacientes(provider: provider),
              _TabCondiciones(provider: provider),
              _TabExamenes(provider: provider),
              _TabEstructuras(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — PACIENTES
// ─────────────────────────────────────────────────────────────────────────────

class _TabPacientes extends StatelessWidget {
  final AppProvider provider;
  const _TabPacientes({required this.provider});

  @override
  Widget build(BuildContext context) {
    final genero = provider.distribucionGenero;
    final total = provider.pacientes.length;
    final male = genero['male'] ?? 0;
    final female = genero['female'] ?? 0;
    final other = genero['other'] ?? 0;

    final top5 = provider.top5PacientesObservaciones;
    final maxTop5 = top5.isEmpty
        ? 1
        : top5.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Totales simples ──────────────────────────────────────
          Text('Total de pacientes: $total'),
          Text('Masculino: $male'),
          Text('Femenino: $female'),
          Text('Otro: $other'),
          const SizedBox(height: 24),

          // ── PieChart — géneros ───────────────────────────────────
          const Text(
            'Distribución por género',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 48,
                sections: [
                  if (male > 0)
                    PieChartSectionData(
                      value: male.toDouble(),
                      title: 'M\n$male',
                      color: Colors.blue[600]!,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (female > 0)
                    PieChartSectionData(
                      value: female.toDouble(),
                      title: 'F\n$female',
                      color: Colors.pink[400]!,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (other > 0)
                    PieChartSectionData(
                      value: other.toDouble(),
                      title: 'O\n$other',
                      color: Colors.grey[400]!,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── BarChart horizontal — top 5 pacientes ────────────────
          const Text(
            'Top 5 pacientes con más exámenes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          if (top5.isEmpty)
            const Text('Sin datos de observaciones')
          else
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxTop5 * 1.3).toDouble(),
                  barGroups: top5.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: Colors.blue[600]!,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= top5.length) {
                            return const SizedBox.shrink();
                          }
                          final nombre = top5[idx].key;
                          final corto = nombre.length > 8
                              ? nombre.substring(0, 8)
                              : nombre;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              corto,
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — CONDICIONES
// ─────────────────────────────────────────────────────────────────────────────

class _TabCondiciones extends StatelessWidget {
  final AppProvider provider;
  const _TabCondiciones({required this.provider});

  @override
  Widget build(BuildContext context) {
    final estados = provider.distribucionEstadosCondicion;
    final severidades = provider.distribucionSeveridad;
    final totalCondiciones = provider.condiciones.length;

    final estadosEntradas = estados.entries.toList();
    final maxEstado = estadosEntradas.isEmpty
        ? 1
        : estadosEntradas
            .map((e) => e.value)
            .reduce((a, b) => a > b ? a : b);

    final severidadesEntradas = severidades.entries.toList();
    final totalSev =
        severidadesEntradas.fold(0, (sum, e) => sum + e.value);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Total ────────────────────────────────────────────────
          Text('Total condiciones: $totalCondiciones'),
          const SizedBox(height: 24),

          // ── BarChart — estados de condición ──────────────────────
          const Text(
            'Estado de condiciones',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          if (estadosEntradas.isEmpty)
            const Text('Sin datos de condiciones')
          else
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxEstado * 1.3).toDouble(),
                  barGroups: estadosEntradas.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: Colors.green[600]!,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= estadosEntradas.length) {
                            return const SizedBox.shrink();
                          }
                          final label = estadosEntradas[idx].key;
                          final corto = label.length > 8
                              ? label.substring(0, 8)
                              : label;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              corto,
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // ── PieChart — severidades ───────────────────────────────
          const Text(
            'Severidad de condiciones',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          if (severidadesEntradas.isEmpty || totalSev == 0)
            const Text('Sin datos de severidad')
          else
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 48,
                  sections: severidadesEntradas.asMap().entries.map((entry) {
                    final colors = [
                      Colors.red[600]!,
                      Colors.orange[600]!,
                      Colors.yellow[700]!,
                      Colors.blue[400]!,
                      Colors.grey[400]!,
                    ];
                    final color = colors[entry.key % colors.length];
                    final pct = entry.value.value / totalSev * 100;
                    return PieChartSectionData(
                      value: entry.value.value.toDouble(),
                      title: '${pct.toStringAsFixed(0)}%',
                      color: color,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Leyenda de severidades en texto
          ...severidadesEntradas.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${e.key}: ${e.value}'),
            ),
          ),
        ],
      ),
    );
  }


}