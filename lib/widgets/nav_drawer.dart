import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute =
        ModalRoute.of(context)?.settings.name ?? '/';

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.biotech,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Laboratorio Clínico',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Programación III — UMG',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: '🏠',
                  label: 'Inicio',
                  route: '/',
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: '👥',
                  label: 'Pacientes',
                  route: '/pacientes',
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: '👨‍⚕️',
                  label: 'Médicos',
                  route: '/medicos',
                  currentRoute: currentRoute,
                ),
                const Divider(indent: 16, endIndent: 16),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'GESTIÓN CLÍNICA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                _DrawerItem(
                  icon: '📋',
                  label: 'Historial de Consultas',
                  route: '/pila',
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: '🏥',
                  label: 'Sala de Espera',
                  route: '/cola',
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: '🔬',
                  label: 'Resultados de Laboratorio',
                  route: '/lista',
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: '🗂️',
                  label: 'Índice de Pacientes',
                  route: '/arbol',
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: '🔍',
                  label: 'Búsqueda Rápida',
                  route: '/hash',
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: '🕸️',
                  label: 'Red de Referencias Médicas',
                  route: '/grafo',
                  currentRoute: currentRoute,
                ),
                const Divider(indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: '⚙️',
                  label: 'Prueba de Procesos',
                  route: '/simulacion',
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: '📊',
                  label: 'Estadísticas y Análisis',
                  route: '/analisis',
                  currentRoute: currentRoute,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'v2.0.0 — HAPI FHIR R4',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String icon;
  final String label;
  final String route;
  final String currentRoute;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentRoute == route;

    return ListTile(
      selected: isSelected,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
      leading: Text(icon, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: TextStyle(
          fontWeight:
              isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
