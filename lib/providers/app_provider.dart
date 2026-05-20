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

} // <-- Fin temporal de la clase