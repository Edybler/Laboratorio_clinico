class Paciente {
  final String id;
  final String nombre;
  final String apellido;
  final String genero;
  final String fechaNacimiento;
  final String telefono;
  final String direccion;

  Paciente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.genero,
    required this.fechaNacimiento,
    required this.telefono,
    required this.direccion,
  });

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

    return Paciente(
      id: json['id'] ?? '',
      nombre: (name?['given'] as List?)?.join(' ') ?? 'Sin nombre',
      apellido: name?['family'] ?? '',
      genero: json['gender'] ?? 'unknown',
      fechaNacimiento: json['birthDate'] ?? '',
      telefono: telefono,
      direccion: direccion,
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