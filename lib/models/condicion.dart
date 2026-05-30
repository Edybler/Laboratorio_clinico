class Condicion {
  final String id;
  final String descripcion;
  final String estado;
  final String severidad;
  final String fechaRegistro;
  final String pacienteId;

  Condicion({
    required this.id,
    required this.descripcion,
    required this.estado,
    required this.severidad,
    required this.fechaRegistro,
    required this.pacienteId,
  });

  factory Condicion.fromFhir(Map<String, dynamic> json) {
    final code = json['code'] as Map<String, dynamic>?;
    String descripcion = 'Condición sin descripción';
    if (code != null) {
      if (code['text'] != null) {
        descripcion = code['text'];
      } else {
        final coding = code['coding'] as List?;
        if (coding != null && coding.isNotEmpty) {
          descripcion = coding[0]['display'] ?? 'Condición';
        }
      }
    }

    final clinicalStatus = json['clinicalStatus'] as Map<String, dynamic>?;
    String estado = 'unknown';
    if (clinicalStatus != null) {
      final coding = clinicalStatus['coding'] as List?;
      if (coding != null && coding.isNotEmpty) {
        estado = coding[0]['code'] ?? 'unknown';
      }
    }

    final severity = json['severity'] as Map<String, dynamic>?;
    String severidad = 'N/A';
    if (severity != null) {
      if (severity['text'] != null) {
        severidad = severity['text'];
      } else {
        final coding = severity['coding'] as List?;
        if (coding != null && coding.isNotEmpty) {
          severidad = coding[0]['display'] ?? 'N/A';
        }
      }
    }

    final subject = json['subject'] as Map<String, dynamic>?;
    String pacienteId = '';
    if (subject != null && subject['reference'] != null) {
      pacienteId =
          (subject['reference'] as String).replaceAll('Patient/', '');
    }

    String fechaRegistro = '';
    if (json['onsetDateTime'] != null) {
      fechaRegistro = json['onsetDateTime'];
    } else if (json['recordedDate'] != null) {
      fechaRegistro = json['recordedDate'];
    } else if (json['onsetPeriod'] != null) {
      fechaRegistro = json['onsetPeriod']['start'] ?? '';
    }

    return Condicion(
      id: json['id'] ?? '',
      descripcion: descripcion,
      estado: estado,
      severidad: severidad,
      fechaRegistro: fechaRegistro,
      pacienteId: pacienteId,
    );
  }

  bool get esActiva => estado == 'active';

  @override
  String toString() => 'Condicion($id, $descripcion, $estado)';
}