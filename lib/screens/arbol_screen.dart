import 'package:flutter/material.dart';
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

  String recorrido = "";

  void insertar() {

    if (claveController.text.isEmpty || valorController.text.isEmpty) {
      return;
    }

    setState(() {

      arbol.insertar(
        int.parse(claveController.text),
        valorController.text,
      );

      recorrido = arbol.enOrden().map((e) => '${e['clave']}: ${e['valor']}').join(', ');

      claveController.clear();
      valorController.clear();
    });
  }

  void limpiar() {

    setState(() {

      arbol.limpiar();

      recorrido = "";
    });
  }

  @override
  Widget build(BuildContext context) {

    final datos = arbol.enOrden();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Árbol BST"),
        backgroundColor: Colors.purple,
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              controller: claveController,

              keyboardType: TextInputType.number,

              decoration: InputDecoration(

                labelText: "Clave (número)",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(

              controller: valorController,

              decoration: InputDecoration(

                labelText: "Valor (texto)",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                ElevatedButton(
                  onPressed: insertar,
                  child: const Text("Insertar"),
                ),

                ElevatedButton(
                  onPressed: limpiar,
                  child: const Text("Limpiar"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              "Recorrido InOrden: $recorrido",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                itemCount: datos.length,

                itemBuilder: (context, index) {

                  return AnimatedContainer(

                    duration: const Duration(
                      milliseconds: 500,
                    ),

                    margin: const EdgeInsets.all(10),

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(

                      color: Colors.purple.shade200,

                      borderRadius:
                          BorderRadius.circular(15),
                    ),

                    child: Center(
                      child: Text(
                        'Clave: ${datos[index]['clave']} → ${datos[index]['valor']}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
