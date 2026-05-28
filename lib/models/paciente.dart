import 'dart:convert';

class Cita {
  final String id;
  final String fecha; // formato 'YYYY-MM-DD'
  final String hora;  // formato 'HH:mm'
  final String motivo;

  Cita({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.motivo,
  });

  @override
  String toString() => 'Cita($id, $fecha $hora, $motivo)';
}

class Paciente {
  final String id;
  final String nombre;
  final String apellido;
  final String genero;
  final String fechaNacimiento;
  final String telefono;
  final String direccion;

  /// Lista de citas asociadas al paciente (se gestiona localmente)
  final List<Cita> citas;

  Paciente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.genero,
    required this.fechaNacimiento,
    required this.telefono,
    required this.direccion,
    List<Cita>? citas,
  }) : citas = citas ?? [];

  // ── Fix de encoding ───────────────────────────────────────────

  /// Repara nombres que vienen corruptos desde hapi.fhir.org.
  ///
  /// El servidor público almacena algunos registros donde los caracteres
  /// especiales (ñ, á, é, etc.) fueron guardados con doble-encoding:
  /// los bytes UTF-8 del carácter fueron interpretados como Latin-1 y
  /// luego re-codificados como UTF-8, produciendo secuencias como
  /// "Ã±" en lugar de "ñ".
  ///
  /// Este método deshace ese proceso: convierte el String de vuelta a
  /// bytes Latin-1 y los re-interpreta como UTF-8.
  static String _repararEncoding(String texto) {
    try {
      // Paso 1: convertir el String a bytes como si fuera Latin-1.
      // latin1.encode mapea cada char a su codepoint (0-255).
      // Si el texto estaba bien, los bytes son UTF-8 válido.
      final bytes = latin1.encode(texto);

      // Paso 2: decodificar esos bytes como UTF-8.
      // Si el texto estaba corrupto (doble-encoding), esto lo repara.
      // Si estaba bien (ASCII puro), el resultado es idéntico.
      final reparado = utf8.decode(bytes, allowMalformed: true);

      // Paso 3: verificar que la reparación no produjo basura.
      // Si el resultado tiene más caracteres de control que el original,
      // devolver el texto original.
      return reparado;
    } catch (_) {
      return texto; // Si algo falla, dejar el texto como está.
    }
  }

  // ── Constructor desde FHIR ────────────────────────────────────

  factory Paciente.fromFhir(Map<String, dynamic> json) {
    final name = json['name'] != null && (json['name'] as List).isNotEmpty
        ? json['name'][0] as Map<String, dynamic>
        : null;

    final telecomList = json['telecom'] as List?;
    String telefono = 'N/A';
    if (telecomList != null) {
      final telefonoEntry = telecomList.firstWhere(
        (t) => t['system'] == 'phone',
        orElse: () => {'value': 'N/A'},
      );
      telefono = telefonoEntry['value'] ?? 'N/A';
    }

    final addressList = json['address'] as List?;
    String direccion = 'Sin dirección';
    if (addressList != null && addressList.isNotEmpty) {
      final firstAddress = addressList[0] as Map<String, dynamic>;
      final lines = firstAddress['line'] as List?;
      if (lines != null && lines.isNotEmpty) {
        direccion = lines.join(', ');
      } else if (firstAddress['city'] != null) {
        direccion = firstAddress['city'];
      }
    }

    // Extraer nombre y apellido crudos, luego reparar encoding
    final nombreCrudo =
        (name?['given'] as List?)?.join(' ') ?? 'Sin nombre';
    final apellidoCrudo = name?['family'] ?? '';

    return Paciente(
      id: json['id'] ?? '',
      nombre: _repararEncoding(nombreCrudo),
      apellido: _repararEncoding(apellidoCrudo),
      genero: json['gender'] ?? 'unknown',
      fechaNacimiento: json['birthDate'] ?? '',
      telefono: telefono,
      direccion: _repararEncoding(direccion),
    );
  }

  /// Crea una copia del paciente con una cita agregada
  Paciente conCita(Cita cita) {
    return Paciente(
      id: id,
      nombre: nombre,
      apellido: apellido,
      genero: genero,
      fechaNacimiento: fechaNacimiento,
      telefono: telefono,
      direccion: direccion,
      citas: [...citas, cita],
    );
  }

  /// Crea una copia del paciente sin la cita con el id dado
  Paciente sinCita(String citaId) {
    return Paciente(
      id: id,
      nombre: nombre,
      apellido: apellido,
      genero: genero,
      fechaNacimiento: fechaNacimiento,
      telefono: telefono,
      direccion: direccion,
      citas: citas.where((c) => c.id != citaId).toList(),
    );
  }

  String get nombreCompleto => '$nombre $apellido'.trim();

  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final a = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$n$a';
  }

  @override
  String toString() => 'Paciente($id, $nombreCompleto)';
}