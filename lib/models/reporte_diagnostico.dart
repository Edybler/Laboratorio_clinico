class ReporteDiagnostico {
  final String id;
  final String titulo;
  final String estado;
  final String fecha;
  final String pacienteId;
  final String medicoId;
  final List<String> conclusiones;

  ReporteDiagnostico({
    required this.id,
    required this.titulo,
    required this.estado,
    required this.fecha,
    required this.pacienteId,
    required this.medicoId,
    required this.conclusiones,
  });

  factory ReporteDiagnostico.fromFhir(Map<String, dynamic> json) {
    final code = json['code'] as Map<String, dynamic>?;
    String titulo = 'Reporte Diagnóstico';
    if (code != null) {
      if (code['text'] != null) {
        titulo = code['text'];
      } else {
        final coding = code['coding'] as List?;
        if (coding != null && coding.isNotEmpty) {
          titulo = coding[0]['display'] ?? 'Reporte Diagnóstico';
        }
      }
    }

    final subject = json['subject'] as Map<String, dynamic>?;
    String pacienteId = '';
    if (subject != null && subject['reference'] != null) {
      pacienteId =
          (subject['reference'] as String).replaceAll('Patient/', '');
    }

    final performers = json['performer'] as List?;
    String medicoId = '';
    if (performers != null && performers.isNotEmpty) {
      final ref = performers[0]['reference'] as String?;
      if (ref != null) {
        medicoId = ref
            .replaceAll('Practitioner/', '')
            .replaceAll('PractitionerRole/', '');
      }
    }

    final presentedForm = json['presentedForm'] as List?;
    List<String> conclusiones = [];
    if (json['conclusion'] != null) {
      conclusiones = [json['conclusion'].toString()];
    } else if (presentedForm != null && presentedForm.isNotEmpty) {
      conclusiones = ['Ver documento adjunto'];
    }

    return ReporteDiagnostico(
      id: json['id'] ?? '',
      titulo: titulo,
      estado: json['status'] ?? 'unknown',
      fecha: json['effectiveDateTime'] ??
          json['issued'] ??
          json['effectivePeriod']?['start'] ??
          '',
      pacienteId: pacienteId,
      medicoId: medicoId,
      conclusiones: conclusiones,
    );
  }

  @override
  String toString() => 'ReporteDiagnostico($id, $titulo, $estado)';
}