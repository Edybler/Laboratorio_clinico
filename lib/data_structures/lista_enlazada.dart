// lib/data_structures/lista_enlazada.dart
// Uso: Lista de resultados de laboratorio por paciente

class _Nodo<T> {
  T dato;
  _Nodo<T>? anterior;
  _Nodo<T>? siguiente;

  _Nodo(this.dato);
}

class ListaDoble<T> {
  _Nodo<T>? _cabeza;
  _Nodo<T>? _cola;
  int _tamano = 0;

  /// Inserta un elemento al inicio de la lista
  void insertarAlInicio(T dato) {
    final nuevo = _Nodo<T>(dato);
    if (estaVacia) {
      _cabeza = nuevo;
      _cola = nuevo;
    } else {
      nuevo.siguiente = _cabeza;
      _cabeza!.anterior = nuevo;
      _cabeza = nuevo;
    }
    _tamano++;
  }

  /// Inserta un elemento al final de la lista
  void insertarAlFinal(T dato) {
    final nuevo = _Nodo<T>(dato);
    if (estaVacia) {
      _cabeza = nuevo;
      _cola = nuevo;
    } else {
      nuevo.anterior = _cola;
      _cola!.siguiente = nuevo;
      _cola = nuevo;
    }
    _tamano++;
  }

  /// Elimina la primera ocurrencia del dato. Retorna true si se eliminó.
  bool eliminar(T dato) {
    _Nodo<T>? actual = _cabeza;
    while (actual != null) {
      if (actual.dato == dato) {
        // Es el único nodo
        if (actual.anterior == null && actual.siguiente == null) {
          _cabeza = null;
          _cola = null;
        }
        // Es la cabeza
        else if (actual.anterior == null) {
          _cabeza = actual.siguiente;
          _cabeza!.anterior = null;
        }
        // Es la cola
        else if (actual.siguiente == null) {
          _cola = actual.anterior;
          _cola!.siguiente = null;
        }
        // Es un nodo intermedio
        else {
          actual.anterior!.siguiente = actual.siguiente;
          actual.siguiente!.anterior = actual.anterior;
        }
        _tamano--;
        return true;
      }
      actual = actual.siguiente;
    }
    return false;
  }

  /// Retorna true si el dato existe en la lista
  bool contiene(T dato) {
    _Nodo<T>? actual = _cabeza;
    while (actual != null) {
      if (actual.dato == dato) return true;
      actual = actual.siguiente;
    }
    return false;
  }

  /// Convierte la lista a una lista Dart (de cabeza a cola)
  List<T> aLista() {
    final lista = <T>[];
    _Nodo<T>? actual = _cabeza;
    while (actual != null) {
      lista.add(actual.dato);
      actual = actual.siguiente;
    }
    return lista;
  }

  /// Convierte la lista a una lista Dart en orden inverso (de cola a cabeza)
  List<T> aListaInversa() {
    final lista = <T>[];
    _Nodo<T>? actual = _cola;
    while (actual != null) {
      lista.add(actual.dato);
      actual = actual.anterior;
    }
    return lista;
  }

  bool get estaVacia => _cabeza == null;

  int get tamano => _tamano;

  /// Vacía completamente la lista
  void limpiar() {
    _cabeza = null;
    _cola = null;
    _tamano = 0;
  }

  @override
  String toString() => 'ListaDoble(tamano: $_tamano)';
}
