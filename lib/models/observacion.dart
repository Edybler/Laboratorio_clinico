class Observacion {
  final String id;
  final String descripcion;
  final String valor;
  final String unidad;
  final String estado;
  final String fecha;
  final String pacienteId;

  Observacion({
    required this.id,
    required this.descripcion,
    required this.valor,
    required this.unidad,
    required this.estado,
    required this.fecha,
    required this.pacienteId,
  });

  factory Observacion.fromFhir(Map<String, dynamic> json) {
    final code = json['code'] as Map<String, dynamic>?;
    String descripcion = 'Examen';
    if (code != null) {
      if (code['text'] != null) {
        descripcion = code['text'];
      } else {
        final coding = code['coding'] as List?;
        if (coding != null && coding.isNotEmpty) {
          descripcion = coding[0]['display'] ?? 'Examen';
        }
      }
    }

    final valueQuantity = json['valueQuantity'] as Map<String, dynamic>?;
    String valor = 'N/A';
    String unidad = '';
    if (valueQuantity != null) {
      valor = valueQuantity['value']?.toString() ?? 'N/A';
      unidad = valueQuantity['unit'] ?? '';
    } else if (json['valueString'] != null) {
      valor = json['valueString'].toString();
    } else if (json['valueCodeableConcept'] != null) {
      final vcc = json['valueCodeableConcept'] as Map<String, dynamic>;
      valor = vcc['text'] ?? 'N/A';
    }

    final subject = json['subject'] as Map<String, dynamic>?;
    String pacienteId = '';
    if (subject != null && subject['reference'] != null) {
      pacienteId =
          (subject['reference'] as String).replaceAll('Patient/', '');
    }

    return Observacion(
      id: json['id'] ?? '',
      descripcion: descripcion,
      valor: valor,
      unidad: unidad,
      estado: json['status'] ?? 'unknown',
      fecha: json['effectiveDateTime'] ?? json['issued'] ?? '',
      pacienteId: pacienteId,
    );
  }

  String get valorConUnidad =>
      unidad.isNotEmpty ? '$valor $unidad' : valor;

  @override
  String toString() => 'Observacion($id, $descripcion, $valorConUnidad)';
}