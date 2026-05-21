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

  // ── Estructuras de datos del dominio (para FHIR / pacientes) ──

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

  // ── Estructuras manuales de String (pantallas interactivas) ───
  // Estas persisten mientras el AppProvider vive (toda la sesión).
  // Las pantallas PilaScreen, ColaScreen, etc. escriben/leen aquí.

  final Pila<String> pilaManual = Pila<String>();
  final Cola<String> colaManual = Cola<String>();
  final ListaDoble<String> listaManual = ListaDoble<String>();
  final ArbolBST arbolManual = ArbolBST();
  final TablaHash hashManual = TablaHash();

  // ── Acciones sobre la PILA manual ────────────────────────────

  void pilaManualPush(String dato) {
    pilaManual.push(dato);
    notifyListeners();
  }

  String? pilaManualPop() {
    final v = pilaManual.pop();
    notifyListeners();
    return v;
  }

  void pilaManualLimpiar() {
    pilaManual.limpiar();
    notifyListeners();
  }

  // ── Acciones sobre la COLA manual ────────────────────────────

  void colaManualEncolar(String dato) {
    colaManual.encolar(dato);
    notifyListeners();
  }

  String? colaManualDesencolar() {
    final v = colaManual.desencolar();
    notifyListeners();
    return v;
  }

  void colaManualLimpiar() {
    colaManual.limpiar();
    notifyListeners();
  }

  // ── Acciones sobre la LISTA manual ───────────────────────────

  void listaManualInsertar(String dato) {
    listaManual.insertarAlFinal(dato);
    notifyListeners();
  }

  void listaManualEliminar(String dato) {
    listaManual.eliminar(dato);
    notifyListeners();
  }

  void listaManualLimpiar() {
    listaManual.limpiar();
    notifyListeners();
  }

  // ── Acciones sobre el ÁRBOL manual ───────────────────────────

  void arbolManualInsertar(int clave, String valor) {
    arbolManual.insertar(clave, valor);
    notifyListeners();
  }

  bool arbolManualEliminar(int clave) {
    final ok = arbolManual.eliminar(clave);
    notifyListeners();
    return ok;
  }

  String? arbolManualBuscar(int clave) {
    return arbolManual.buscar(clave);
  }

  void arbolManualLimpiar() {
    arbolManual.limpiar();
    notifyListeners();
  }

  // ── Acciones sobre la HASH manual ────────────────────────────

  void hashManualPoner(String clave, String valor) {
    hashManual.poner(clave, valor);
    notifyListeners();
  }

  void hashManualEliminar(String clave) {
    hashManual.eliminar(clave);
    notifyListeners();
  }

  void hashManualLimpiar() {
    hashManual.limpiar();
    notifyListeners();
  }

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

  // ── Acciones sobre estructuras del dominio (expuestas a la UI) ─

  /// Agrega un paciente al historial (pila)
  void agregarAlHistorial(Paciente paciente) {
    _pilaHistorial.push(paciente);
    notifyListeners();
  }

  /// Retira el paciente más reciente del historial
  Paciente? retirarDelHistorial() {
    final p = _pilaHistorial.pop();
    notifyListeners();
    return p;
  }

  /// Agrega un paciente a la cola de espera
  void agregarAColaEspera(Paciente paciente) {
    _colaEspera.encolar(paciente);
    notifyListeners();
  }

  /// Atiende al siguiente paciente (desencola)
  Paciente? atenderSiguiente() {
    final p = _colaEspera.desencolar();
    notifyListeners();
    return p;
  }

  /// Agrega una observación a la lista de resultados
  void agregarResultado(Observacion obs) {
    _listaResultados.insertarAlFinal(obs);
    notifyListeners();
  }

  /// Elimina una observación de la lista de resultados
  bool eliminarResultado(Observacion obs) {
    final result = _listaResultados.eliminar(obs);
    notifyListeners();
    return result;
  }

  // ── Carga principal de datos ──────────────────────────────────

  /// Carga todos los datos desde la API HAPI FHIR R4 y los
  /// distribuye en las estructuras de datos correspondientes.
  Future<void> cargarDatos() async {
    if (_cargando) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      // Carga paralela de todos los recursos
      final resultados = await Future.wait([
        _fhirService.obtenerPacientes(count: 20),
        _fhirService.obtenerObservaciones(count: 30),
        _fhirService.obtenerMedicos(count: 10),
        _fhirService.obtenerCondiciones(count: 20),
        _fhirService.obtenerReportesDiagnosticos(count: 20),
      ]);

      _pacientes = resultados[0] as List<Paciente>;
      _observaciones = resultados[1] as List<Observacion>;
      _medicos = resultados[2] as List<Medico>;
      _condiciones = resultados[3] as List<Condicion>;
      _reportes = resultados[4] as List<ReporteDiagnostico>;

      // Poblar estructuras de datos
      _poblarEstructuras();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Distribuye los datos cargados en las 6 estructuras de datos.
  void _poblarEstructuras() {
    // Limpiar estructuras previas
    _arbolPacientes.limpiar();
    _hashBusqueda.limpiar();
    _grafoMedicos.limpiar();
    _listaResultados.limpiar();
    // La pila y cola de dominio conservan su estado (son interactivas)
    // Las estructuras manuales (pilaManual, colaManual, etc.) NUNCA se limpian aquí

    // ── Árbol BST: indexar pacientes por clave numérica ──────────
    for (final paciente in _pacientes) {
      final int clave = _claveNumerica(paciente.id);
      _arbolPacientes.insertar(clave, paciente.nombreCompleto);
    }

    // ── Tabla Hash: búsqueda por nombre completo ─────────────────
    for (final paciente in _pacientes) {
      final String clave = paciente.nombreCompleto.toLowerCase().trim();
      if (clave.isNotEmpty) {
        _hashBusqueda.poner(clave, paciente);
      }
      if (paciente.nombre.isNotEmpty) {
        _hashBusqueda.poner(paciente.nombre.toLowerCase().trim(), paciente);
      }
      if (paciente.apellido.isNotEmpty) {
        _hashBusqueda.poner(paciente.apellido.toLowerCase().trim(), paciente);
      }
    }

    // ── Lista doblemente enlazada: últimas 10 observaciones ──────
    final ultimas = _observaciones.length > 10
        ? _observaciones.sublist(_observaciones.length - 10)
        : _observaciones;
    for (final obs in ultimas) {
      _listaResultados.insertarAlFinal(obs);
    }

    // ── Grafo: red de médicos por especialidad ───────────────────
    for (final medico in _medicos) {
      _grafoMedicos.agregarVertice(medico.nombre);
    }
    for (int i = 0; i < _medicos.length; i++) {
      for (int j = i + 1; j < _medicos.length; j++) {
        if (_medicos[i].especialidad == _medicos[j].especialidad) {
          _grafoMedicos.agregarArista(_medicos[i].nombre, _medicos[j].nombre);
        }
      }
    }
    for (final medico in _medicos) {
      final String espVertice = 'Esp: ${medico.especialidad}';
      _grafoMedicos.agregarArista(medico.nombre, espVertice);
    }
  }

  /// Convierte un ID FHIR (alfanumérico) en una clave entera
  int _claveNumerica(String id) {
    int suma = 0;
    final chars = id.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
    for (int i = 0; i < chars.length && i < 8; i++) {
      suma += chars.codeUnitAt(i);
    }
    for (int i = 0; i < chars.length; i++) {
      suma += chars.codeUnitAt(i) * (i + 1);
    }
    return suma;
  }

  // ── Búsquedas ─────────────────────────────────────────────────

  Paciente? buscarPacienteHash(String nombre) {
    return _hashBusqueda.obtener(nombre.toLowerCase().trim()) as Paciente?;
  }

  String? buscarEnArbol(String pacienteId) {
    final int clave = _claveNumerica(pacienteId);
    return _arbolPacientes.buscar(clave);
  }

  List<String> bfsMedico(String nombreMedico) {
    return _grafoMedicos.bfs(nombreMedico);
  }

  List<String> dfsMedico(String nombreMedico) {
    return _grafoMedicos.dfs(nombreMedico);
  }
}