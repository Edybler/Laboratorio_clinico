import 'package:flutter/material.dart';
import '../data_structures/arbol_bst.dart';

class ArbolScreen extends StatefulWidget {

  const ArbolScreen({super.key});

  @override
  State<ArbolScreen> createState() => _ArbolScreenState();
}

class _ArbolScreenState extends State<ArbolScreen> {

  final ArbolBST arbol = ArbolBST();

  final TextEditingController controller =
      TextEditingController();

  String recorrido = "";

  void insertar() {

    if (controller.text.isEmpty) {
      return;
    }

    setState(() {

      arbol.insertar(
        int.parse(controller.text),
      );

      recorrido = arbol.inorder().toString();

      controller.clear();
    });
  }

  void limpiar() {

    setState(() {

      arbol.clear();

      recorrido = "";
    });
  }

  @override
  Widget build(BuildContext context) {

    final datos = arbol.inorder();

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

              controller: controller,

              keyboardType: TextInputType.number,

              decoration: InputDecoration(

                labelText: "Ingresar número",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,

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
              "Recorrido Inorder: $recorrido",
              style: const TextStyle(
                fontSize: 18,
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
                        datos[index].toString(),
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