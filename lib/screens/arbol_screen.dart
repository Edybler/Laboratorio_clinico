// lib/screens/arbol_screen.dart
import 'package:flutter/material.dart';
import '../widgets/nav_drawer.dart';
import '../data_structures/arbol_bst.dart';

class ArbolScreen extends StatefulWidget {
  const ArbolScreen({super.key});

  @override
  State<ArbolScreen> createState() => _ArbolScreenState();
}

class _ArbolScreenState extends State<ArbolScreen> {
  final ArbolBST arbol = ArbolBST();
  final TextEditingController claveController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController buscarController = TextEditingController();

  String mensaje = '';
  int? claveResaltada;

  void insertar() {
    if (claveController.text.isEmpty || valorController.text.isEmpty) {
      setState(() => mensaje = '⚠️ Ingresa clave y valor.');
      return;
    }
    final clave = int.tryParse(claveController.text);
    if (clave == null) {
      setState(() => mensaje = '⚠️ La clave debe ser un número entero.');
      return;
    }
    setState(() {
      arbol.insertar(clave, valorController.text);
      claveResaltada = clave;
      mensaje = '✅ Nodo $clave insertado.';
      claveController.clear();
      valorController.clear();
    });
    // Quitar resaltado después de 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => claveResaltada = null);
    });
  }

  void eliminar() {
    if (claveController.text.isEmpty) {
      setState(() => mensaje = '⚠️ Ingresa la clave a eliminar.');
      return;
    }
    final clave = int.tryParse(claveController.text);
    if (clave == null) return;
    setState(() {
      final ok = arbol.eliminar(clave);
      mensaje = ok ? '🗑️ Nodo $clave eliminado.' : '❌ Clave $clave no encontrada.';
      claveResaltada = null;
      claveController.clear();
      valorController.clear();
    });
  }

  void buscar() {
    final clave = int.tryParse(buscarController.text);
    if (clave == null) {
      setState(() => mensaje = '⚠️ Ingresa una clave numérica para buscar.');
      return;
    }
    final resultado = arbol.buscar(clave);
    setState(() {
      if (resultado != null) {
        claveResaltada = clave;
        mensaje = '🔍 Encontrado: $clave → "$resultado"';
      } else {
        claveResaltada = null;
        mensaje = '❌ Clave $clave no encontrada.';
      }
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => claveResaltada = null);
    });
  }

  void limpiar() {
    setState(() {
      arbol.limpiar();
      claveResaltada = null;
      mensaje = '🧹 Árbol limpiado.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = Colors.purple;
    final inOrden = arbol.enOrden();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Árbol BST'),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
      ),
      drawer: const NavDrawer(),
      body: Column(
        children: [
          // Panel de controles
          Container(
            color: Colors.purple.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Insertar / Eliminar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: claveController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Clave (número)',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: valorController,
                        decoration: InputDecoration(
                          labelText: 'Valor (texto)',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _boton('Insertar', Icons.add_circle_outline, Colors.purple, insertar),
                    _boton('Eliminar', Icons.remove_circle_outline, Colors.red, eliminar),
                    _boton('Limpiar', Icons.delete_sweep, Colors.grey, limpiar),
                  ],
                ),
                const SizedBox(height: 10),
                // Buscar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: buscarController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Buscar por clave',
                          isDense: true,
                          prefixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: buscar,
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text('Buscar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Mensaje de estado
                if (mensaje.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      mensaje,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                // Stats
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _chip('Nodos: ${arbol.tamano}', Icons.circle, Colors.purple),
                      const SizedBox(width: 8),
                      _chip('Altura: ${arbol.altura()}', Icons.vertical_align_top, Colors.indigo),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Visualización del árbol
          Expanded(
            child: arbol.estaVacio
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_tree_outlined, size: 64, color: Colors.purple.shade200),
                        const SizedBox(height: 12),
                        Text(
                          'El árbol está vacío.\nInserta nodos para visualizarlo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(40),
                    minScale: 0.3,
                    maxScale: 2.5,
                    child: CustomPaint(
                      painter: ArbolBSTPainter(
                        raiz: arbol.raiz,
                        altura: arbol.altura(),
                        claveResaltada: claveResaltada,
                      ),
                      size: Size(
                        // Ancho: hasta 2^(altura-1) nodos en la última fila, 80px c/u
                        _calcularAncho(arbol.altura()),
                        // Alto: niveles × 90px + margen
                        arbol.altura() * 90.0 + 40,
                      ),
                    ),
                  ),
          ),
          // Recorrido inOrden
          if (inOrden.isNotEmpty)
            Container(
              color: Colors.purple.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'InOrden (ascendente):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: inOrden
                          .map((e) => Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: e['clave'] == claveResaltada
                                      ? Colors.amber
                                      : Colors.purple.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${e['clave']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  double _calcularAncho(int altura) {
    if (altura <= 0) return 400;
    final nodos = (1 << altura); // 2^altura
    return (nodos * 80.0).clamp(400.0, 4000.0);
  }

  Widget _boton(String texto, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _chip(String texto, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(texto, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      backgroundColor: color.withOpacity(0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter que dibuja el árbol BST como estructura jerárquica real
// ---------------------------------------------------------------------------
class ArbolBSTPainter extends CustomPainter {
  final NodoArbolBST? raiz;
  final int altura;
  final int? claveResaltada;

  // Posiciones calculadas para cada nodo (por clave)
  final Map<int, Offset> _posiciones = {};

  ArbolBSTPainter({
    required this.raiz,
    required this.altura,
    this.claveResaltada,
  });

  static const double _radioNodo = 26.0;
  static const double _alturaFila = 90.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (raiz == null) return;

    // Calcular posiciones de todos los nodos
    _calcularPosiciones(raiz, 0, 0, size.width);

    // Primero dibujar las líneas (aristas)
    _dibujarAristas(canvas, raiz);

    // Luego dibujar los nodos encima
    _dibujarNodos(canvas, raiz);
  }

  /// Calcula recursivamente la posición X,Y de cada nodo.
  /// Divide el espacio horizontal de forma binaria.
  void _calcularPosiciones(
    NodoArbolBST? nodo,
    int nivel,
    double xMin,
    double xMax,
  ) {
    if (nodo == null) return;

    final x = (xMin + xMax) / 2;
    final y = nivel * _alturaFila + _radioNodo + 20;

    _posiciones[nodo.clave] = Offset(x, y);

    _calcularPosiciones(nodo.izquierdo, nivel + 1, xMin, x);
    _calcularPosiciones(nodo.derecho, nivel + 1, x, xMax);
  }

  void _dibujarAristas(Canvas canvas, NodoArbolBST? nodo) {
    if (nodo == null) return;

    final paintLinea = Paint()
      ..color = Colors.purple.shade200
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final origen = _posiciones[nodo.clave];
    if (origen == null) return;

    if (nodo.izquierdo != null) {
      final destino = _posiciones[nodo.izquierdo!.clave];
      if (destino != null) {
        canvas.drawLine(origen, destino, paintLinea);
      }
      _dibujarAristas(canvas, nodo.izquierdo);
    }

    if (nodo.derecho != null) {
      final destino = _posiciones[nodo.derecho!.clave];
      if (destino != null) {
        canvas.drawLine(origen, destino, paintLinea);
      }
      _dibujarAristas(canvas, nodo.derecho);
    }
  }

  void _dibujarNodos(Canvas canvas, NodoArbolBST? nodo) {
    if (nodo == null) return;

    final pos = _posiciones[nodo.clave];
    if (pos == null) return;

    final esResaltado = nodo.clave == claveResaltada;
    final esRaiz = nodo.clave == raiz?.clave;

    // Sombra
    final paintSombra = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(pos + const Offset(2, 3), _radioNodo, paintSombra);

    // Relleno del círculo
    final colorFondo = esResaltado
        ? Colors.amber
        : esRaiz
            ? Colors.purple.shade700
            : Colors.purple.shade400;

    final paintFondo = Paint()..color = colorFondo;
    canvas.drawCircle(pos, _radioNodo, paintFondo);

    // Borde
    final paintBorde = Paint()
      ..color = esResaltado ? Colors.orange : Colors.purple.shade900
      ..strokeWidth = esResaltado ? 3 : 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(pos, _radioNodo, paintBorde);

    // Texto de la clave dentro del nodo
    final textoPainter = TextPainter(
      text: TextSpan(
        text: '${nodo.clave}',
        style: TextStyle(
          color: Colors.white,
          fontSize: nodo.clave.toString().length > 3 ? 11 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textoPainter.layout();
    textoPainter.paint(
      canvas,
      pos - Offset(textoPainter.width / 2, textoPainter.height / 2),
    );

    // Texto del valor debajo del nodo (abreviado si es muy largo)
    final valor = nodo.valor.length > 8 ? '${nodo.valor.substring(0, 7)}…' : nodo.valor;
    final valorPainter = TextPainter(
      text: TextSpan(
        text: valor,
        style: TextStyle(
          color: Colors.purple.shade900,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    valorPainter.layout(maxWidth: 80);
    valorPainter.paint(
      canvas,
      Offset(
        pos.dx - valorPainter.width / 2,
        pos.dy + _radioNodo + 3,
      ),
    );

    // Recursivo
    _dibujarNodos(canvas, nodo.izquierdo);
    _dibujarNodos(canvas, nodo.derecho);
  }

  @override
  bool shouldRepaint(ArbolBSTPainter oldDelegate) =>
      oldDelegate.raiz != raiz ||
      oldDelegate.claveResaltada != claveResaltada ||
      oldDelegate.altura != altura;
}