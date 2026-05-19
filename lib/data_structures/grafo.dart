// lib/data_structures/grafo.dart
// Uso: Red de médicos referidos entre especialidades

class Grafo {
  final Map<String, List<String>> _adyacencia = {};

  /// Agrega un vértice al grafo. Si ya existe, no hace nada.
  void agregarVertice(String vertice) {
    _adyacencia.putIfAbsent(vertice, () => []);
  }

  /// Agrega una arista no dirigida entre dos vértices.
  /// Si alguno de los vértices no existe, lo crea automáticamente.
  void agregarArista(String desde, String hasta) {
    agregarVertice(desde);
    agregarVertice(hasta);
    if (!_adyacencia[desde]!.contains(hasta)) {
      _adyacencia[desde]!.add(hasta);
    }
    if (!_adyacencia[hasta]!.contains(desde)) {
      _adyacencia[hasta]!.add(desde);
    }
  }

  /// Retorna la lista de vecinos (vértices adyacentes) de un vértice.
  List<String> vecinos(String vertice) {
    return List.unmodifiable(_adyacencia[vertice] ?? []);
  }

  /// Recorrido BFS (Breadth-First Search) desde un vértice inicial.
  /// Retorna la lista de vértices visitados en orden de visita.
  List<String> bfs(String inicio) {
    if (!_adyacencia.containsKey(inicio)) return [];

    final visitados = <String>{};
    final cola = <String>[];
    final resultado = <String>[];

    visitados.add(inicio);
    cola.add(inicio);

    while (cola.isNotEmpty) {
      final actual = cola.removeAt(0);
      resultado.add(actual);

      for (final vecino in (_adyacencia[actual] ?? [])) {
        if (!visitados.contains(vecino)) {
          visitados.add(vecino);
          cola.add(vecino);
        }
      }
    }

    return resultado;
  }

  /// Recorrido DFS (Depth-First Search) desde un vértice inicial.
  /// Retorna la lista de vértices visitados en orden de visita.
  List<String> dfs(String inicio) {
    if (!_adyacencia.containsKey(inicio)) return [];

    final visitados = <String>{};
    final resultado = <String>[];
    _dfsRec(inicio, visitados, resultado);
    return resultado;
  }

  void _dfsRec(String vertice, Set<String> visitados, List<String> resultado) {
    visitados.add(vertice);
    resultado.add(vertice);
    for (final vecino in (_adyacencia[vertice] ?? [])) {
      if (!visitados.contains(vecino)) {
        _dfsRec(vecino, visitados, resultado);
      }
    }
  }

  /// Verifica si existe un camino entre dos vértices usando BFS.
  bool existeCamino(String desde, String hasta) {
    if (!_adyacencia.containsKey(desde) || !_adyacencia.containsKey(hasta)) {
      return false;
    }
    if (desde == hasta) return true;

    final visitados = <String>{};
    final cola = <String>[desde];
    visitados.add(desde);

    while (cola.isNotEmpty) {
      final actual = cola.removeAt(0);
      for (final vecino in (_adyacencia[actual] ?? [])) {
        if (vecino == hasta) return true;
        if (!visitados.contains(vecino)) {
          visitados.add(vecino);
          cola.add(vecino);
        }
      }
    }

    return false;
  }

  /// Retorna la lista de todos los vértices del grafo
  List<String> vertices() {
    return List.unmodifiable(_adyacencia.keys.toList());
  }

  /// Elimina un vértice y todas sus aristas del grafo.
  /// Retorna true si el vértice existía y fue eliminado.
  bool eliminarVertice(String vertice) {
    if (!_adyacencia.containsKey(vertice)) return false;
    // Eliminar el vértice de las listas de adyacencia de sus vecinos
    for (final vecino in (_adyacencia[vertice] ?? [])) {
      _adyacencia[vecino]?.remove(vertice);
    }
    _adyacencia.remove(vertice);
    return true;
  }

  /// Retorna el número de vértices en el grafo
  int get totalVertices => _adyacencia.length;

  /// Retorna el número de aristas en el grafo (no dirigido, cada arista se cuenta una vez)
  int get totalAristas {
    int suma = 0;
    for (final lista in _adyacencia.values) {
      suma += lista.length;
    }
    return suma ~/ 2;
  }

  /// Retorna el grado (número de conexiones) de un vértice
  int grado(String vertice) {
    return _adyacencia[vertice]?.length ?? 0;
  }

  /// Vacía el grafo
  void limpiar() => _adyacencia.clear();

  @override
  String toString() =>
      'Grafo(vértices: $totalVertices, aristas: $totalAristas)';
}
