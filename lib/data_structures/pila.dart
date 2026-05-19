// lib/data_structures/pila.dart
// Uso: Historial de exámenes consultados (los más recientes arriba)

class _Nodo<T> {
  T dato;
  _Nodo<T>? siguiente;

  _Nodo(this.dato);
}

class Pila<T> {
  _Nodo<T>? _cima;
  int _tamano = 0;

  /// Agrega un elemento a la cima de la pila
  void push(T dato) {
    final nuevo = _Nodo<T>(dato);
    nuevo.siguiente = _cima;
    _cima = nuevo;
    _tamano++;
  }

  /// Retira y retorna el elemento de la cima. Retorna null si está vacía.
  T? pop() {
    if (estaVacia) return null;
    final valor = _cima!.dato;
    _cima = _cima!.siguiente;
    _tamano--;
    return valor;
  }

  /// Retorna el elemento de la cima sin retirarlo. Retorna null si está vacía.
  T? peek() {
    if (estaVacia) return null;
    return _cima!.dato;
  }

  bool get estaVacia => _cima == null;

  int get tamano => _tamano;

  /// Convierte la pila a una lista (el primer elemento es la cima)
  List<T> aLista() {
    final lista = <T>[];
    _Nodo<T>? actual = _cima;
    while (actual != null) {
      lista.add(actual.dato);
      actual = actual.siguiente;
    }
    return lista;
  }

  /// Vacía completamente la pila
  void limpiar() {
    _cima = null;
    _tamano = 0;
  }

  @override
  String toString() => 'Pila(tamano: $_tamano, cima: ${_cima?.dato})';
}
