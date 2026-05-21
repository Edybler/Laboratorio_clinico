// lib/data_structures/arbol_bst.dart
// Uso: Índice de pacientes por ID numérico (para búsqueda rápida)

/// Nodo público para poder visualizar el árbol desde fuera
class NodoArbolBST {
  int clave;
  String valor;
  NodoArbolBST? izquierdo;
  NodoArbolBST? derecho;

  NodoArbolBST(this.clave, this.valor);
}

class ArbolBST {
  NodoArbolBST? _raiz;

  /// Expone la raíz para poder dibujar el árbol visualmente
  NodoArbolBST? get raiz => _raiz;

  /// Inserta un nuevo nodo con la clave y valor dados
  void insertar(int clave, String valor) {
    _raiz = _insertarRec(_raiz, clave, valor);
  }

  NodoArbolBST _insertarRec(NodoArbolBST? nodo, int clave, String valor) {
    if (nodo == null) return NodoArbolBST(clave, valor);
    if (clave < nodo.clave) {
      nodo.izquierdo = _insertarRec(nodo.izquierdo, clave, valor);
    } else if (clave > nodo.clave) {
      nodo.derecho = _insertarRec(nodo.derecho, clave, valor);
    } else {
      // Clave duplicada: actualiza el valor
      nodo.valor = valor;
    }
    return nodo;
  }

  /// Busca y retorna el valor asociado a la clave. Retorna null si no existe.
  String? buscar(int clave) {
    return _buscarRec(_raiz, clave);
  }

  String? _buscarRec(NodoArbolBST? nodo, int clave) {
    if (nodo == null) return null;
    if (clave == nodo.clave) return nodo.valor;
    if (clave < nodo.clave) return _buscarRec(nodo.izquierdo, clave);
    return _buscarRec(nodo.derecho, clave);
  }

  /// Elimina el nodo con la clave dada. Retorna true si se eliminó.
  bool eliminar(int clave) {
    final antes = _contarNodos(_raiz);
    _raiz = _eliminarRec(_raiz, clave);
    final despues = _contarNodos(_raiz);
    return antes != despues;
  }

  NodoArbolBST? _eliminarRec(NodoArbolBST? nodo, int clave) {
    if (nodo == null) return null;

    if (clave < nodo.clave) {
      nodo.izquierdo = _eliminarRec(nodo.izquierdo, clave);
    } else if (clave > nodo.clave) {
      nodo.derecho = _eliminarRec(nodo.derecho, clave);
    } else {
      if (nodo.izquierdo == null) return nodo.derecho;
      if (nodo.derecho == null) return nodo.izquierdo;
      final sucesor = _minimoNodo(nodo.derecho!);
      nodo.clave = sucesor.clave;
      nodo.valor = sucesor.valor;
      nodo.derecho = _eliminarRec(nodo.derecho, sucesor.clave);
    }
    return nodo;
  }

  NodoArbolBST _minimoNodo(NodoArbolBST nodo) {
    NodoArbolBST actual = nodo;
    while (actual.izquierdo != null) {
      actual = actual.izquierdo!;
    }
    return actual;
  }

  /// Retorna la lista de nodos en recorrido inOrden (izq → raíz → der)
  List<Map<String, dynamic>> enOrden() {
    final lista = <Map<String, dynamic>>[];
    _enOrdenRec(_raiz, lista);
    return lista;
  }

  void _enOrdenRec(NodoArbolBST? nodo, List<Map<String, dynamic>> lista) {
    if (nodo == null) return;
    _enOrdenRec(nodo.izquierdo, lista);
    lista.add({'clave': nodo.clave, 'valor': nodo.valor});
    _enOrdenRec(nodo.derecho, lista);
  }

  /// Retorna la lista de nodos en recorrido preOrden (raíz → izq → der)
  List<Map<String, dynamic>> preOrden() {
    final lista = <Map<String, dynamic>>[];
    _preOrdenRec(_raiz, lista);
    return lista;
  }

  void _preOrdenRec(NodoArbolBST? nodo, List<Map<String, dynamic>> lista) {
    if (nodo == null) return;
    lista.add({'clave': nodo.clave, 'valor': nodo.valor});
    _preOrdenRec(nodo.izquierdo, lista);
    _preOrdenRec(nodo.derecho, lista);
  }

  /// Retorna la altura del árbol (0 si está vacío)
  int altura() {
    return _alturaRec(_raiz);
  }

  int _alturaRec(NodoArbolBST? nodo) {
    if (nodo == null) return 0;
    final altIzq = _alturaRec(nodo.izquierdo);
    final altDer = _alturaRec(nodo.derecho);
    return 1 + (altIzq > altDer ? altIzq : altDer);
  }

  int _contarNodos(NodoArbolBST? nodo) {
    if (nodo == null) return 0;
    return 1 + _contarNodos(nodo.izquierdo) + _contarNodos(nodo.derecho);
  }

  int get tamano => _contarNodos(_raiz);

  bool get estaVacio => _raiz == null;

  /// Vacía el árbol
  void limpiar() => _raiz = null;

  @override
  String toString() => 'ArbolBST(altura: ${altura()}, nodos: $tamano)';
}