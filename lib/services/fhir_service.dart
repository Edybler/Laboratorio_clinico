import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/paciente.dart';
import '../models/observacion.dart';
import '../models/reporte_diagnostico.dart';
import '../models/medico.dart';
import '../models/condicion.dart';

class FhirService {
  static const String _baseUrl = 'https://hapi.fhir.org/baseR4';

  static const Map<String, String> _headers = {
    'Accept': 'application/fhir+json',
    'Content-Type': 'application/fhir+json',
  };

  // ── Helper: decodificación correcta ───────────────────────────

  /// El servidor hapi.fhir.org devuelve JSON con charset=utf-8 en el
  /// Content-Type, pero los bytes reales son UTF-8 válido. El problema
  /// es que `http.Response.body` en Dart usa Latin-1 por defecto cuando
  /// no puede determinar el charset, corrompiendo los caracteres.
  /// La solución es leer los bytes crudos y decodificar explícitamente
  /// con UTF-8, ignorando bytes malformados (allowMalformed: true) para
  /// que nunca lance excepción.
  String _decodificar(http.Response response) {
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  // ── Pacientes ─────────────────────────────────────────────────

  Future<List<Paciente>> obtenerPacientes({int count = 20}) async {
    final uri = Uri.parse('$_baseUrl/Patient?_count=$count&_format=json');
    try {
      final response = await http.get(uri, headers: _headers);
      _validarRespuesta(response);
      final json = jsonDecode(_decodificar(response)) as Map<String, dynamic>;
      final recursos = _parsearBundle(json);
      return recursos.map((r) => Paciente.fromFhir(r)).toList();
    } catch (e) {
      throw _manejarError('obtenerPacientes', e);
    }
  }

  Future<Paciente> obtenerPaciente(String id) async {
    final uri = Uri.parse('$_baseUrl/Patient/$id?_format=json');
    try {
      final response = await http.get(uri, headers: _headers);
      _validarRespuesta(response);
      final json = jsonDecode(_decodificar(response)) as Map<String, dynamic>;
      return Paciente.fromFhir(json);
    } catch (e) {
      throw _manejarError('obtenerPaciente', e);
    }
  }

  Future<List<Paciente>> buscarPacientesPorNombre(String nombre) async {
    final uri = Uri.parse(
        '$_baseUrl/Patient?name=${Uri.encodeComponent(nombre)}&_format=json');
    try {
      final response = await http.get(uri, headers: _headers);
      _validarRespuesta(response);
      final json = jsonDecode(_decodificar(response)) as Map<String, dynamic>;
      final recursos = _parsearBundle(json);
      return recursos.map((r) => Paciente.fromFhir(r)).toList();
    } catch (e) {
      throw _manejarError('buscarPacientesPorNombre', e);
    }
  }

  // ── Observaciones ─────────────────────────────────────────────

  Future<List<Observacion>> obtenerObservaciones({int count = 20}) async {
    final uri =
        Uri.parse('$_baseUrl/Observation?_count=$count&_format=json');
    try {
      final response = await http.get(uri, headers: _headers);
      _validarRespuesta(response);
      final json = jsonDecode(_decodificar(response)) as Map<String, dynamic>;
      final recursos = _parsearBundle(json);
      return recursos.map((r) => Observacion.fromFhir(r)).toList();
    } catch (e) {
      throw _manejarError('obtenerObservaciones', e);
    }
  }

  Future<List<Observacion>> obtenerObservacionesPaciente(
      String pacienteId) async {
    final uri = Uri.parse(
        '$_baseUrl/Observation?patient=$pacienteId&_format=json');
    try {
      final response = await http.get(uri, headers: _headers);
      _validarRespuesta(response);
      final json = jsonDecode(_decodificar(response)) as Map<String, dynamic>;
      final recursos = _parsearBundle(json);
      return recursos.map((r) => Observacion.fromFhir(r)).toList();
    } catch (e) {
      throw _manejarError('obtenerObservacionesPaciente', e);
    }
  }

  // ── Reportes Diagnósticos ────────────────────────────────────

  Future<List<ReporteDiagnostico>> obtenerReportesDiagnosticos(
      {int count = 20}) async {
    final uri = Uri.parse(
        '$_baseUrl/DiagnosticReport?_count=$count&_format=json');
    try {
      final response = await http.get(uri, headers: _headers);
      _validarRespuesta(response);
      final json = jsonDecode(_decodificar(response)) as Map<String, dynamic>;
      final recursos = _parsearBundle(json);
      return recursos.map((r) => ReporteDiagnostico.fromFhir(r)).toList();
    } catch (e) {
      throw _manejarError('obtenerReportesDiagnosticos', e);
    }
  }

  // ── Médicos ───────────────────────────────────────────────────

  Future<List<Medico>> obtenerMedicos({int count = 10}) async {
    final uri =
        Uri.parse('$_baseUrl/Practitioner?_count=$count&_format=json');
    try {
      final response = await http.get(uri, headers: _headers);
      _validarRespuesta(response);
      final json = jsonDecode(_decodificar(response)) as Map<String, dynamic>;
      final recursos = _parsearBundle(json);
      return recursos.map((r) => Medico.fromFhir(r)).toList();
    } catch (e) {
      throw _manejarError('obtenerMedicos', e);
    }
  }

  // ── Condiciones ───────────────────────────────────────────────

  Future<List<Condicion>> obtenerCondiciones({int count = 20}) async {
    final uri =
        Uri.parse('$_baseUrl/Condition?_count=$count&_format=json');
    try {
      final response = await http.get(uri, headers: _headers);
      _validarRespuesta(response);
      final json = jsonDecode(_decodificar(response)) as Map<String, dynamic>;
      final recursos = _parsearBundle(json);
      return recursos.map((r) => Condicion.fromFhir(r)).toList();
    } catch (e) {
      throw _manejarError('obtenerCondiciones', e);
    }
  }

  // ── Helpers privados ──────────────────────────────────────────

  List<Map<String, dynamic>> _parsearBundle(Map<String, dynamic> json) {
    if (json['resourceType'] != 'Bundle') {
      return [json];
    }
    final entries = json['entry'] as List? ?? [];
    return entries
        .where((e) => e['resource'] != null)
        .map((e) => e['resource'] as Map<String, dynamic>)
        .toList();
  }

  void _validarRespuesta(http.Response response) {
    if (response.statusCode == 200) return;

    String mensaje;
    switch (response.statusCode) {
      case 400:
        mensaje = 'Solicitud inválida al servidor FHIR (400).';
        break;
      case 401:
        mensaje = 'No autorizado para acceder al recurso (401).';
        break;
      case 404:
        mensaje = 'Recurso no encontrado en el servidor FHIR (404).';
        break;
      case 500:
        mensaje = 'Error interno del servidor FHIR (500).';
        break;
      default:
        mensaje = 'Error inesperado del servidor: ${response.statusCode}.';
    }
    throw Exception(mensaje);
  }

  Exception _manejarError(String metodo, Object e) {
    if (e is Exception) return e;
    return Exception('Error en FhirService.$metodo: $e');
  }
}