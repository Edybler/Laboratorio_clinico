import 'package:flutter/material.dart';
import '../data_structures/pila.dart';

class PilaScreen extends StatefulWidget {

  const PilaScreen({super.key});

  @override
  State<PilaScreen> createState() => _PilaScreenState();
}

class _PilaScreenState extends State<PilaScreen> {

  final Pila<String> pila = Pila<String>();

  final TextEditingController controller = TextEditingController();

  String mensaje = "";

  // INSERTAR
  void insertar() {

    if (controller.text.isEmpty) {
      return;
    }

    setState(() {

      pila.push(controller.text);

      mensaje = "Dato insertado";

      controller.clear();
    });
  }

  // ELIMINAR
  void eliminar() {

    setState(() {

      final eliminado = pila.pop();

      if (eliminado == null) {

        mensaje = "La pila está vacía";

      } else {

        mensaje = "Eliminado: $eliminado";
      }
    });
  }

  // LIMPIAR
  void limpiar() {

    setState(() {

      pila.clear();

      mensaje = "Pila limpiada";
    });
  }

  @override
  Widget build(BuildContext context) {

    final elementos = pila.getItems();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Pantalla Pila"),
        backgroundColor: Colors.blue,
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

                  child: const Text("Push"),
                ),

                ElevatedButton(

                  onPressed: eliminar,

                  child: const Text("Pop"),
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

            const Text(

              "Visualización de Pila",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                itemCount: elementos.length,

                itemBuilder: (context, index) {

                  return AnimatedContainer(

                    duration: const Duration(milliseconds: 500),

                    margin: const EdgeInsets.symmetric(vertical: 10),

                    decoration: BoxDecoration(

                      color: Colors.blue.shade100,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: ListTile(

                      leading: CircleAvatar(
                        child: Text("${index + 1}"),
                      ),

                      title: Text(elementos[index]),

                      subtitle: const Text("Elemento de la pila"),
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