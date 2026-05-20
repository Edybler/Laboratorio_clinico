// lib/data_structures/cola.dart
// Uso: Cola de espera de pacientes (orden de llegada)

class _Nodo<T> {
  T dato;
  _Nodo<T>? siguiente;

  _Nodo(this.dato);
}

class Cola<T> {
  _Nodo<T>? _frente;
  _Nodo<T>? _final;
  int _tamano = 0;

  /// Agrega un elemento al final de la cola
  void encolar(T dato) {
    final nuevo = _Nodo<T>(dato);
    if (estaVacia) {
      _frente = nuevo;
      _final = nuevo;
    } else {
      _final!.siguiente = nuevo;
      _final = nuevo;
    }
    _tamano++;
  }

  /// Retira y retorna el elemento del frente. Retorna null si está vacía.
  T? desencolar() {
    if (estaVacia) return null;
    final valor = _frente!.dato;
    _frente = _frente!.siguiente;
    if (_frente == null) _final = null;
    _tamano--;
    return valor;
  }

  /// Retorna el elemento del frente sin retirarlo. Retorna null si está vacía.
  T? frente() {
    if (estaVacia) return null;
    return _frente!.dato;
  }

  bool get estaVacia => _frente == null;

  int get tamano => _tamano;

  /// Convierte la cola a una lista (el primer elemento es el frente)
  List<T> aLista() {
    final lista = <T>[];
    _Nodo<T>? actual = _frente;
    while (actual != null) {
      lista.add(actual.dato);
      actual = actual.siguiente;
    }
    return lista;
  }

  /// Vacía completamente la cola
  void limpiar() {
    _frente = null;
    _final = null;
    _tamano = 0;
  }

  @override
  String toString() => 'Cola(tamano: $_tamano, frente: ${_frente?.dato})';
}
