import 'package:flutter/foundation.dart';

import '../data_structures/pila.dart';
import '../data_structures/cola.dart';
import '../data_structures/lista_enlazada.dart';
import '../data_structures/arbol_bst.dart';
import '../data_structures/tabla_hash.dart';
import '../data_structures/grafo.dart';

import '../models/paciente.dart';
import '../models/observacion.dart';
import '../models/medico.dart';
import '../models/condicion.dart';
import '../models/reporte_diagnostico.dart';

import '../services/fhir_service.dart';

class AppProvider extends ChangeNotifier {
  // ── Servicio FHIR ─────────────────────────────────────────────
  final FhirService _fhirService = FhirService();

  // ── Estado de carga ───────────────────────────────────────────
  bool _cargando = false;
  String? _error;

  bool get cargando => _cargando;
  String? get error => _error;

  // ── Listas de datos (del API) ─────────────────────────────────
  List<Paciente> _pacientes = [];
  List<Observacion> _observaciones = [];
  List<Medico> _medicos = [];
  List<Condicion> _condiciones = [];
  List<ReporteDiagnostico> _reportes = [];

  List<Paciente> get pacientes => List.unmodifiable(_pacientes);
  List<Observacion> get observaciones => List.unmodifiable(_observaciones);
  List<Medico> get medicos => List.unmodifiable(_medicos);
  List<Condicion> get condiciones => List.unmodifiable(_condiciones);
  List<ReporteDiagnostico> get reportes => List.unmodifiable(_reportes);

  // ── Estructuras de datos ──────────────────────────────────────

  /// PILA: Historial de pacientes/exámenes consultados (LIFO)
  final Pila<Paciente> _pilaHistorial = Pila<Paciente>();
  Pila<Paciente> get pilaHistorial => _pilaHistorial;

  /// COLA: Sala de espera de pacientes (FIFO)
  final Cola<Paciente> _colaEspera = Cola<Paciente>();
  Cola<Paciente> get colaEspera => _colaEspera;

  /// LISTA DOBLEMENTE ENLAZADA: Resultados de laboratorio
  final ListaDoble<Observacion> _listaResultados = ListaDoble<Observacion>();
  ListaDoble<Observacion> get listaResultados => _listaResultados;

  /// ÁRBOL BST: Índice de pacientes por clave numérica derivada del ID
  final ArbolBST _arbolPacientes = ArbolBST();
  ArbolBST get arbolPacientes => _arbolPacientes;

  /// TABLA HASH: Búsqueda rápida de pacientes por nombre completo
  final TablaHash _hashBusqueda = TablaHash();
  TablaHash get hashBusqueda => _hashBusqueda;

  /// GRAFO: Red de médicos referidos entre especialidades
  final Grafo _grafoMedicos = Grafo();
  Grafo get grafoMedicos => _grafoMedicos;

  // ── Métricas de análisis ──────────────────────────────────────

  /// Distribución de géneros: {'male': n, 'female': n, 'other': n}
  Map<String, int> get distribucionGenero {
    final Map<String, int> dist = {'male': 0, 'female': 0, 'other': 0};
    for (final p in _pacientes) {
      final g = p.genero.toLowerCase();
      if (g == 'male') {
        dist['male'] = (dist['male'] ?? 0) + 1;
      } else if (g == 'female') {
        dist['female'] = (dist['female'] ?? 0) + 1;
      } else {
        dist['other'] = (dist['other'] ?? 0) + 1;
      }
    }
    return dist;
  }

  /// Distribución de estados de condiciones: {'active': n, 'resolved': n, ...}
  Map<String, int> get distribucionEstadosCondicion {
    final Map<String, int> dist = {};
    for (final c in _condiciones) {
      dist[c.estado] = (dist[c.estado] ?? 0) + 1;
    }
    return dist;
  }

  /// Distribución de severidades de condiciones
  Map<String, int> get distribucionSeveridad {
    final Map<String, int> dist = {};
    for (final c in _condiciones) {
      final sev = c.severidad.isNotEmpty ? c.severidad : 'N/A';
      dist[sev] = (dist[sev] ?? 0) + 1;
    }
    return dist;
  }

  /// Distribución de especialidades médicas
  Map<String, int> get distribucionEspecialidades {
    final Map<String, int> dist = {};
    for (final m in _medicos) {
      final esp = m.especialidad.isNotEmpty ? m.especialidad : 'General';
      dist[esp] = (dist[esp] ?? 0) + 1;
    }
    return dist;
  }

  /// Top 5 observaciones más frecuentes por descripción
  List<MapEntry<String, int>> get top5Observaciones {
    final Map<String, int> conteo = {};
    for (final o in _observaciones) {
      conteo[o.descripcion] = (conteo[o.descripcion] ?? 0) + 1;
    }
    final sorted = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  /// Distribución de estados de observaciones
  Map<String, int> get distribucionEstadosObservacion {
    final Map<String, int> dist = {};
    for (final o in _observaciones) {
      dist[o.estado] = (dist[o.estado] ?? 0) + 1;
    }
    return dist;
  }

  /// Distribución de estados de reportes diagnósticos
  Map<String, int> get distribucionEstadosReporte {
    final Map<String, int> dist = {};
    for (final r in _reportes) {
      dist[r.estado] = (dist[r.estado] ?? 0) + 1;
    }
    return dist;
  }

  /// Pacientes con más observaciones (top 5)
  List<MapEntry<String, int>> get top5PacientesObservaciones {
    final Map<String, int> conteo = {};
    for (final o in _observaciones) {
      if (o.pacienteId.isNotEmpty) {
        conteo[o.pacienteId] = (conteo[o.pacienteId] ?? 0) + 1;
      }
    }
    final sorted = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    return top.map((e) {
      final paciente = _pacientes.firstWhere(
        (p) => p.id == e.key,
        orElse: () => Paciente(
          id: e.key,
          nombre: 'ID: ${e.key}',
          apellido: '',
          genero: '',
          fechaNacimiento: '',
          telefono: '',
          direccion: '',
        ),
      );
      return MapEntry(paciente.nombreCompleto.isNotEmpty
          ? paciente.nombreCompleto
          : 'ID: ${e.key}', e.value);
    }).toList();
  }

  /// Altura actual del árbol BST
  int get alturaBST => _arbolPacientes.altura();

  /// Total de colisiones en la tabla hash (cubetas con > 1 elemento)
  int get colisionesHash {
    int colisiones = 0;
    for (int i = 0; i < _hashBusqueda.totalCubetas; i++) {
      final n = _hashBusqueda.elementosEnCubeta(i);
      if (n > 1) colisiones += (n - 1);
    }
    return colisiones;
  }

  /// Distribución de ocupación de la tabla hash (histograma de cubetas)
  Map<int, int> get histogramaCubetas {
    final Map<int, int> hist = {};
    for (int i = 0; i < _hashBusqueda.totalCubetas; i++) {
      final n = _hashBusqueda.elementosEnCubeta(i);
      hist[n] = (hist[n] ?? 0) + 1;
    }
    return hist;
  }
}