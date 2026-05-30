  class Medico {
  final String id;
  final String nombre;
  final String especialidad;
  final String telefono;
  final String email;

  Medico({
    required this.id,
    required this.nombre,
    required this.especialidad,
    required this.telefono,
    required this.email,
  });

  factory Medico.fromFhir(Map<String, dynamic> json) {
    final nameList = json['name'] as List?;
    String nombre = 'Sin nombre';
    if (nameList != null && nameList.isNotEmpty) {
      final name = nameList[0] as Map<String, dynamic>;
      final given = (name['given'] as List?)?.join(' ') ?? '';
      final family = name['family'] ?? '';
      nombre = '$given $family'.trim();
      if (nombre.isEmpty) nombre = name['text'] ?? 'Sin nombre';
    }

    final qualificationList = json['qualification'] as List?;
    String especialidad = 'General';
    if (qualificationList != null && qualificationList.isNotEmpty) {
      final q = qualificationList[0] as Map<String, dynamic>;
      final code = q['code'] as Map<String, dynamic>?;
      if (code != null) {
        especialidad = code['text'] ??
            (code['coding'] as List?)?.first?['display'] ??
            'General';
      }
    }

    final telecomList = json['telecom'] as List?;
    String telefono = 'N/A';
    String email = 'N/A';
    if (telecomList != null) {
      for (final t in telecomList) {
        if (t['system'] == 'phone' && telefono == 'N/A') {
          telefono = t['value'] ?? 'N/A';
        } else if (t['system'] == 'email' && email == 'N/A') {
          email = t['value'] ?? 'N/A';
        }
      }
    }

    return Medico(
      id: json['id'] ?? '',
      nombre: nombre,
      especialidad: especialidad,
      telefono: telefono,
      email: email,
    );
  }

  String get iniciales {
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : 'M';
  }

  @override
  String toString() => 'Medico($id, $nombre, $especialidad)';
}