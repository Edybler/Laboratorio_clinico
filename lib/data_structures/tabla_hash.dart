// lib/data_structures/tabla_hash.dart
// Uso: Búsqueda de paciente por nombre (O(1) promedio)
// Tamaño: 31 cubetas (número primo). Colisiones por encadenamiento.

class _EntradaHash {
  String clave;
  dynamic valor;

  _EntradaHash(this.clave, this.valor);
}

class TablaHash {
  static const int _TAMANO = 31;
  final List<List<_EntradaHash>> _cubetas;

  TablaHash() : _cubetas = List.generate(_TAMANO, (_) => []);

  /// Función hash: suma de charCodes % 31
  int _hashCode(String clave) {
    int suma = 0;
    for (int i = 0; i < clave.length; i++) {
      suma += clave.codeUnitAt(i);
    }
    return suma % _TAMANO;
  }

  /// Inserta o actualiza un par clave-valor
  void poner(String clave, dynamic valor) {
    final indice = _hashCode(clave);
    final cubeta = _cubetas[indice];
    // Buscar si ya existe la clave para actualizar
    for (final entrada in cubeta) {
      if (entrada.clave == clave) {
        entrada.valor = valor;
        return;
      }
    }
    // No existe: agregar nueva entrada
    cubeta.add(_EntradaHash(clave, valor));
  }

  /// Retorna el valor asociado a la clave. Retorna null si no existe.
  dynamic obtener(String clave) {
    final indice = _hashCode(clave);
    final cubeta = _cubetas[indice];
    for (final entrada in cubeta) {
      if (entrada.clave == clave) return entrada.valor;
    }
    return null;
  }

  /// Elimina la entrada con la clave dada. Retorna true si se eliminó.
  bool eliminar(String clave) {
    final indice = _hashCode(clave);
    final cubeta = _cubetas[indice];
    for (int i = 0; i < cubeta.length; i++) {
      if (cubeta[i].clave == clave) {
        cubeta.removeAt(i);
        return true;
      }
    }
    return false;
  }

  /// Retorna todas las claves almacenadas en la tabla
  List<String> claves() {
    final resultado = <String>[];
    for (final cubeta in _cubetas) {
      for (final entrada in cubeta) {
        resultado.add(entrada.clave);
      }
    }
    return resultado;
  }

  /// Retorna todos los valores almacenados en la tabla
  List<dynamic> valores() {
    final resultado = <dynamic>[];
    for (final cubeta in _cubetas) {
      for (final entrada in cubeta) {
        resultado.add(entrada.valor);
      }
    }
    return resultado;
  }

  /// Retorna el número total de entradas en la tabla
  int get tamano {
    int total = 0;
    for (final cubeta in _cubetas) {
      total += cubeta.length;
    }
    return total;
  }

  /// Retorna el índice de hash calculado para una clave (útil para visualización)
  int indiceDe(String clave) => _hashCode(clave);

  /// Retorna cuántos elementos hay en la cubeta del índice dado
  int elementosEnCubeta(int indice) {
    if (indice < 0 || indice >= _TAMANO) return 0;
    return _cubetas[indice].length;
  }

  /// Retorna las entradas de una cubeta específica
  List<Map<String, dynamic>> entradasEnCubeta(int indice) {
    if (indice < 0 || indice >= _TAMANO) return [];
    return _cubetas[indice]
        .map((e) => {'clave': e.clave, 'valor': e.valor})
        .toList();
  }

  /// Retorna el número total de cubetas
  int get totalCubetas => _TAMANO;

  /// Vacía la tabla hash
  void limpiar() {
    for (final cubeta in _cubetas) {
      cubeta.clear();
    }
  }

  @override
  String toString() => 'TablaHash(entradas: $tamano, cubetas: $_TAMANO)';
}
