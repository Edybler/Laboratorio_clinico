import 'package:flutter/material.dart';
import '../data_structures/lista_enlazada.dart';

class ListaScreen extends StatefulWidget {

  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {

  final ListaEnlazada<String> lista = ListaEnlazada<String>();

  final TextEditingController controller = TextEditingController();

  String mensaje = "";

  void insertar() {

    if (controller.text.isEmpty) {
      return;
    }

    setState(() {

      lista.insertar(controller.text);

      mensaje = "Dato insertado";

      controller.clear();
    });
  }

  void eliminar() {

    setState(() {

      lista.eliminar(controller.text);

      mensaje = "Dato eliminado";

      controller.clear();
    });
  }

  void limpiar() {

    setState(() {

      lista.clear();

      mensaje = "Lista limpiada";
    });
  }

  @override
  Widget build(BuildContext context) {

    final datos = lista.obtenerDatos();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Lista Enlazada"),
        backgroundColor: Colors.orange,
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
                  child: const Text("Insertar"),
                ),

                ElevatedButton(
                  onPressed: eliminar,
                  child: const Text("Eliminar"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: limpiar,
              child: const Text("Limpiar"),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                itemCount: datos.length,

                itemBuilder: (context, index) {

                  return Row(

                    children: [

                      Expanded(

                        child: AnimatedContainer(

                          duration: const Duration(milliseconds: 500),

                          margin: const EdgeInsets.all(10),

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(

                            color: Colors.orange.shade200,

                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: Center(
                            child: Text(datos[index]),
                          ),
                        ),
                      ),

                      if (index != datos.length - 1)
                        const Icon(Icons.arrow_forward),
                    ],
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