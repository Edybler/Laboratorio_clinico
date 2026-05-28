import 'package:flutter/material.dart';
import '../models/paciente.dart';

class PacienteCard extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback? onTap;
  final VoidCallback? onEliminar;
  final VoidCallback? onVerCitas;

  const PacienteCard({
    super.key,
    required this.paciente,
    this.onTap,
    this.onEliminar,
    this.onVerCitas,
  });

  @override
  Widget build(BuildContext context) {
    final bool esMasculino = paciente.genero.toLowerCase() == 'male';
    final bool esFemenino = paciente.genero.toLowerCase() == 'female';

    final Color chipColor = esMasculino
        ? const Color(0xFF1565C0)
        : esFemenino
            ? const Color(0xFFAD1457)
            : Colors.grey;

    final String generoLabel = esMasculino
        ? 'Masculino'
        : esFemenino
            ? 'Femenino'
            : 'Otro';

    final String iniciales =
        _obtenerIniciales(paciente.nombre, paciente.apellido);

    final int totalCitas = paciente.citas.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar con iniciales
              CircleAvatar(
                radius: 28,
                backgroundColor: chipColor.withOpacity(0.15),
                child: Text(
                  iniciales,
                  style: TextStyle(
                    color: chipColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Datos del paciente
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${paciente.nombre} ${paciente.apellido}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (paciente.fechaNacimiento.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.cake_outlined,
                                  size: 13, color: Colors.grey[600]),
                              const SizedBox(width: 3),
                              Text(
                                paciente.fechaNacimiento,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        if (paciente.telefono != 'N/A')
                          Flexible(
                            child: Row(
                              children: [
                                Icon(Icons.phone_outlined,
                                    size: 13, color: Colors.grey[600]),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    paciente.telefono,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Chip de género
                        Chip(
                          label: Text(
                            generoLabel,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                          backgroundColor: chipColor,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 6),
                        // Badge de citas
                        if (totalCitas > 0)
                          Chip(
                            avatar: const Icon(Icons.calendar_today,
                                size: 12, color: Color(0xFF00897B)),
                            label: Text(
                              '$totalCitas cita${totalCitas > 1 ? 's' : ''}',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF00897B)),
                            ),
                            backgroundColor:
                                const Color(0xFF00897B).withOpacity(0.12),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botones de acción
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón citas
                  if (onVerCitas != null)
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined),
                      color: const Color(0xFF00897B),
                      tooltip: 'Ver / Agregar citas',
                      onPressed: onVerCitas,
                      visualDensity: VisualDensity.compact,
                    ),
                  // Botón eliminar
                  if (onEliminar != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red[400],
                      tooltip: 'Eliminar paciente',
                      onPressed: onEliminar,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _obtenerIniciales(String nombre, String apellido) {
    final String primeraLetraNombre =
        nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final String primeraLetraApellido =
        apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$primeraLetraNombre$primeraLetraApellido';
  }
}
