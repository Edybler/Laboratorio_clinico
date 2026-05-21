import 'package:flutter/material.dart';
import '../data_structures/cola.dart';

class ColaScreen extends StatefulWidget {

  const ColaScreen({super.key});

  @override
  State<ColaScreen> createState() => _ColaScreenState();
}

class _ColaScreenState extends State<ColaScreen> {

  final Cola<String> cola = Cola<String>();

  final TextEditingController controller = TextEditingController();

  String mensaje = "";

  void insertar() {

    if (controller.text.isEmpty) {
      return;
    }

    setState(() {

      cola.encolar(controller.text);

      mensaje = "Elemento agregado";

      controller.clear();
    });
  }

  void eliminar() {

    setState(() {

      final eliminado = cola.desencolar();

      if (eliminado == null) {

        mensaje = "Cola vacía";

      } else {

        mensaje = "Elemento eliminado: $eliminado";
      }
    });
  }

  void limpiar() {

    setState(() {

      cola.limpiar();

      mensaje = "Cola limpiada";
    });
  }

  @override
  Widget build(BuildContext context) {

    final elementos = cola.aLista();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Pantalla Cola"),
        backgroundColor: Colors.green,
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              controller: controller,

              decoration: InputDecoration(

                labelText: "Ingresar dato",

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

                  child: const Text("Enqueue"),
                ),

                ElevatedButton(

                  onPressed: eliminar,

                  child: const Text("Dequeue"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(

              onPressed: limpiar,

              child: const Text("Limpiar"),
            ),

            const SizedBox(height: 20),

            Text(

              mensaje,

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                scrollDirection: Axis.horizontal,

                itemCount: elementos.length,

                itemBuilder: (context, index) {

                  return AnimatedContainer(

                    duration: const Duration(milliseconds: 500),

                    width: 120,

                    margin: const EdgeInsets.all(10),

                    decoration: BoxDecoration(

                      color: Colors.green.shade200,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Center(

                      child: Text(

                        elementos[index],

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
