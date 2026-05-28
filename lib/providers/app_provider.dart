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

class PacienteAtendido {
  final Paciente paciente;
  final DateTime horaAtencion;

  PacienteAtendido({required this.paciente, required this.horaAtencion});
}

class AppProvider extends ChangeNotifier {
  // ── Servicio FHIR ─────────────────────────────────────────────
  final FhirService _fhirService = FhirService();

  // ── Estado de carga ───────────────────────────────────────────
  bool _cargando = false;
  String? _error;

  bool get cargando => _cargando;
  String? get error => _error;

  // ── Listas de datos (del API + locales) ──────────────────────
  List<Paciente> _pacientes = [];
  List<Observacion> _observaciones = [];
  List<Medico> _medicos = [];
  List<Condicion> _condiciones = [];
  List<ReporteDiagnostico> _reportes = [];

  // ── Pacientes atendidos del día ───────────────────────────────
  final List<PacienteAtendido> _atendidosHoy = [];
  List<PacienteAtendido> get atendidosHoy => List.unmodifiable(_atendidosHoy);

  List<Paciente> get pacientes => List.unmodifiable(_pacientes);
  List<Observacion> get observaciones => List.unmodifiable(_observaciones);
  List<Medico> get medicos => List.unmodifiable(_medicos);
  List<Condicion> get condiciones => List.unmodifiable(_condiciones);
  List<ReporteDiagnostico> get reportes => List.unmodifiable(_reportes);

  // ── Estructuras de datos del dominio ──────────────────────────

  /// PILA: Historial de pacientes/exámenes consultados (LIFO)
  final Pila<Paciente> _pilaHistorial = Pila<Paciente>();
  Pila<Paciente> get pilaHistorial => _pilaHistorial;

  /// COLA: Sala de espera de pacientes (FIFO)
  final Cola<Paciente> _colaEspera = Cola<Paciente>();
  Cola<Paciente> get colaEspera => _colaEspera;

  /// LISTA DOBLEMENTE ENLAZADA: Resultados de laboratorio
  final ListaDoble<Observacion> _listaResultados = ListaDoble<Observacion>();
  ListaDoble<Observacion> get listaResultados => _listaResultados;

  /// ÁRBOL BST: Índice de pacientes
  final ArbolBST _arbolPacientes = ArbolBST();
  ArbolBST get arbolPacientes => _arbolPacientes;

  /// TABLA HASH: Búsqueda rápida de pacientes
  final TablaHash _hashBusqueda = TablaHash();
  TablaHash get hashBusqueda => _hashBusqueda;

  /// GRAFO: Red de médicos referidos entre especialidades
  final Grafo _grafoMedicos = Grafo();
  Grafo get grafoMedicos => _grafoMedicos;

  // ── Estructuras manuales de String (pantallas interactivas) ───
  final Pila<String> pilaManual = Pila<String>();
  final Cola<String> colaManual = Cola<String>();
  final ListaDoble<String> listaManual = ListaDoble<String>();
  final ArbolBST arbolManual = ArbolBST();
  final TablaHash hashManual = TablaHash();
  final Grafo grafoManual = Grafo();

  // ── Contador para IDs locales ─────────────────────────────────
  int _contadorIdLocal = 1;
  int _contadorIdMedico = 1;

  // ── GESTIÓN DE PACIENTES ──────────────────────────────────────

  Paciente agregarPaciente({
    required String nombre,
    required String apellido,
    required String genero,
    required String fechaNacimiento,
    required String telefono,
    required String direccion,
  }) {
    final String nuevoId = 'local-${_contadorIdLocal++}';
    final paciente = Paciente(
      id: nuevoId,
      nombre: nombre.trim(),
      apellido: apellido.trim(),
      genero: genero,
      fechaNacimiento: fechaNacimiento.trim(),
      telefono: telefono.trim().isEmpty ? 'N/A' : telefono.trim(),
      direccion: direccion.trim().isEmpty ? 'Sin dirección' : direccion.trim(),
    );

    _pacientes = [..._pacientes, paciente];
    _indexarPaciente(paciente);
    notifyListeners();
    return paciente;
  }

  /// Actualiza los datos de un paciente existente.
  bool actualizarPaciente({
    required String pacienteId,
    required String nombre,
    required String apellido,
    required String genero,
    required String fechaNacimiento,
    required String telefono,
    required String direccion,
  }) {
    final int idx = _pacientes.indexWhere((p) => p.id == pacienteId);
    if (idx == -1) return false;

    final Paciente anterior = _pacientes[idx];
    final Paciente actualizado = Paciente(
      id: pacienteId,
      nombre: nombre.trim(),
      apellido: apellido.trim(),
      genero: genero,
      fechaNacimiento: fechaNacimiento.trim(),
      telefono: telefono.trim().isEmpty ? 'N/A' : telefono.trim(),
      direccion: direccion.trim().isEmpty ? 'Sin dirección' : direccion.trim(),
      citas: anterior.citas,
    );

    final List<Paciente> nuevaLista = [..._pacientes];
    nuevaLista[idx] = actualizado;
    _pacientes = nuevaLista;

    // Re-indexar en hash
    _hashBusqueda.eliminar(anterior.nombreCompleto.toLowerCase().trim());
    _hashBusqueda.eliminar(anterior.nombre.toLowerCase().trim());
    _hashBusqueda.eliminar(anterior.apellido.toLowerCase().trim());
    _indexarPaciente(actualizado);

    notifyListeners();
    return true;
  }

  bool eliminarPaciente(String pacienteId) {
    final int antes = _pacientes.length;
    _pacientes = _pacientes.where((p) => p.id != pacienteId).toList();
    if (_pacientes.length == antes) return false;
    _arbolPacientes.eliminar(_claveNumerica(pacienteId));
    notifyListeners();
    return true;
  }

  void _indexarPaciente(Paciente paciente) {
    final int clave = _claveNumerica(paciente.id);
    _arbolPacientes.insertar(clave, paciente.nombreCompleto);
    _hashBusqueda.poner(paciente.nombreCompleto.toLowerCase().trim(), paciente);
    if (paciente.nombre.isNotEmpty) {
      _hashBusqueda.poner(paciente.nombre.toLowerCase().trim(), paciente);
    }
    if (paciente.apellido.isNotEmpty) {
      _hashBusqueda.poner(paciente.apellido.toLowerCase().trim(), paciente);
    }
  }

  // ── GESTIÓN DE CITAS ──────────────────────────────────────────

  bool agregarCita({
    required String pacienteId,
    required String fecha,
    required String hora,
    required String motivo,
  }) {
    final int idx = _pacientes.indexWhere((p) => p.id == pacienteId);
    if (idx == -1) return false;

    final String citaId = 'cita-${DateTime.now().millisecondsSinceEpoch}';
    final Cita nuevaCita = Cita(
      id: citaId,
      fecha: fecha,
      hora: hora,
      motivo: motivo.trim().isEmpty ? 'Consulta general' : motivo.trim(),
    );

    final Paciente actualizado = _pacientes[idx].conCita(nuevaCita);
    final List<Paciente> nuevaLista = [..._pacientes];
    nuevaLista[idx] = actualizado;
    _pacientes = nuevaLista;
    _hashBusqueda.poner(
        actualizado.nombreCompleto.toLowerCase().trim(), actualizado);
    notifyListeners();
    return true;
  }

  bool eliminarCita({
    required String pacienteId,
    required String citaId,
  }) {
    final int idx = _pacientes.indexWhere((p) => p.id == pacienteId);
    if (idx == -1) return false;

    final Paciente actualizado = _pacientes[idx].sinCita(citaId);
    final List<Paciente> nuevaLista = [..._pacientes];
    nuevaLista[idx] = actualizado;
    _pacientes = nuevaLista;
    notifyListeners();
    return true;
  }

  // ── GESTIÓN DE MÉDICOS ────────────────────────────────────────

  Medico agregarMedico({
    required String nombre,
    required String especialidad,
    required String telefono,
    required String email,
  }) {
    final String nuevoId = 'medico-local-${_contadorIdMedico++}';
    final medico = Medico(
      id: nuevoId,
      nombre: nombre.trim(),
      especialidad: especialidad.trim().isEmpty ? 'General' : especialidad.trim(),
      telefono: telefono.trim().isEmpty ? 'N/A' : telefono.trim(),
      email: email.trim().isEmpty ? 'N/A' : email.trim(),
    );
    _medicos = [..._medicos, medico];
    _grafoMedicos.agregarVertice(medico.nombre);
    notifyListeners();
    return medico;
  }

  bool eliminarMedico(String medicoId) {
    final int antes = _medicos.length;
    _medicos = _medicos.where((m) => m.id != medicoId).toList();
    if (_medicos.length == antes) return false;
    notifyListeners();
    return true;
  }

  // ── ATENDER PACIENTES ─────────────────────────────────────────

  /// Saca al siguiente paciente de la cola y lo registra como atendido.
  Paciente? atenderSiguiente() {
    final p = _colaEspera.desencolar();
    if (p != null) {
      _atendidosHoy.add(
        PacienteAtendido(paciente: p, horaAtencion: DateTime.now()),
      );
    }
    notifyListeners();
    return p;
  }

  // ── Acciones sobre estructuras del dominio ────────────────────

  void agregarAlHistorial(Paciente paciente) {
    _pilaHistorial.push(paciente);
    notifyListeners();
  }

  Paciente? retirarDelHistorial() {
    final p = _pilaHistorial.pop();
    notifyListeners();
    return p;
  }

  void agregarAColaEspera(Paciente paciente) {
    _colaEspera.encolar(paciente);
    notifyListeners();
  }

  void agregarResultado(Observacion obs) {
    _listaResultados.insertarAlFinal(obs);
    notifyListeners();
  }

  bool eliminarResultado(Observacion obs) {
    final result = _listaResultados.eliminar(obs);
    notifyListeners();
    return result;
  }

  // ── Acciones manuales ─────────────────────────────────────────

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

  void grafoManualAgregarArista(String desde, String hasta) {
    grafoManual.agregarArista(desde, hasta);
    notifyListeners();
  }

  bool grafoManualEliminarVertice(String vertice) {
    final ok = grafoManual.eliminarVertice(vertice);
    notifyListeners();
    return ok;
  }

  void grafoManualLimpiar() {
    grafoManual.limpiar();
    notifyListeners();
  }

  // ── Métricas ──────────────────────────────────────────────────

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

  Map<String, int> get distribucionEstadosCondicion {
    final Map<String, int> dist = {};
    for (final c in _condiciones) {
      dist[c.estado] = (dist[c.estado] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, int> get distribucionSeveridad {
    final Map<String, int> dist = {};
    for (final c in _condiciones) {
      final sev = c.severidad.isNotEmpty ? c.severidad : 'N/A';
      dist[sev] = (dist[sev] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, int> get distribucionEspecialidades {
    final Map<String, int> dist = {};
    for (final m in _medicos) {
      final esp = m.especialidad.isNotEmpty ? m.especialidad : 'General';
      dist[esp] = (dist[esp] ?? 0) + 1;
    }
    return dist;
  }

  List<MapEntry<String, int>> get top5Observaciones {
    final Map<String, int> conteo = {};
    for (final o in _observaciones) {
      conteo[o.descripcion] = (conteo[o.descripcion] ?? 0) + 1;
    }
    final sorted = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  Map<String, int> get distribucionEstadosObservacion {
    final Map<String, int> dist = {};
    for (final o in _observaciones) {
      dist[o.estado] = (dist[o.estado] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, int> get distribucionEstadosReporte {
    final Map<String, int> dist = {};
    for (final r in _reportes) {
      dist[r.estado] = (dist[r.estado] ?? 0) + 1;
    }
    return dist;
  }

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
      return MapEntry(
          paciente.nombreCompleto.isNotEmpty
              ? paciente.nombreCompleto
              : 'ID: ${e.key}',
          e.value);
    }).toList();
  }

  int get alturaBST => _arbolPacientes.altura();

  int get colisionesHash {
    int colisiones = 0;
    for (int i = 0; i < _hashBusqueda.totalCubetas; i++) {
      final n = _hashBusqueda.elementosEnCubeta(i);
      if (n > 1) colisiones += (n - 1);
    }
    return colisiones;
  }

  Map<int, int> get histogramaCubetas {
    final Map<int, int> hist = {};
    for (int i = 0; i < _hashBusqueda.totalCubetas; i++) {
      final n = _hashBusqueda.elementosEnCubeta(i);
      hist[n] = (hist[n] ?? 0) + 1;
    }
    return hist;
  }

  // ── Búsquedas ─────────────────────────────────────────────────

  /// Búsqueda ampliada: por nombre, cita (motivo), fecha y hora.
  List<Paciente> buscarPacientes(String query) {
    if (query.trim().isEmpty) return [];
    final String clave = query.trim().toLowerCase();

    // 1. Buscar exacto en hash (por nombre)
    final dynamic exacto = _hashBusqueda.obtener(clave);
    if (exacto != null) return [exacto as Paciente];

    // 2. Búsqueda ampliada en todos los campos
    return _pacientes.where((p) {
      final String nombreCompleto = p.nombreCompleto.toLowerCase();
      if (nombreCompleto.contains(clave)) return true;

      // Buscar en citas (motivo, fecha, hora)
      for (final cita in p.citas) {
        if (cita.motivo.toLowerCase().contains(clave)) return true;
        if (cita.fecha.toLowerCase().contains(clave)) return true;
        if (cita.hora.toLowerCase().contains(clave)) return true;
      }
      return false;
    }).toList();
  }

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

  // ── Carga principal de datos ──────────────────────────────────

  Future<void> cargarDatos() async {
    if (_cargando) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
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

      _poblarEstructuras();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void _poblarEstructuras() {
    _arbolPacientes.limpiar();
    _hashBusqueda.limpiar();
    _grafoMedicos.limpiar();
    _listaResultados.limpiar();

    for (final paciente in _pacientes) {
      _indexarPaciente(paciente);
    }

    final ultimas = _observaciones.length > 10
        ? _observaciones.sublist(_observaciones.length - 10)
        : _observaciones;
    for (final obs in ultimas) {
      _listaResultados.insertarAlFinal(obs);
    }

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
}
