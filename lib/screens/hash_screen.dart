import 'package:flutter/material.dart';
import '../data_structures/tabla_hash.dart';

class HashScreen extends StatefulWidget {

  const HashScreen({super.key});

  @override
  State<HashScreen> createState() => _HashScreenState();
}

class _HashScreenState extends State<HashScreen> {

  final TablaHash tabla = TablaHash();

  final TextEditingController claveController =
      TextEditingController();

  final TextEditingController valorController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    final datos = tabla.obtenerTodo();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Tabla Hash"),
        backgroundColor: Colors.red,
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              controller: claveController,

              decoration: const InputDecoration(
                labelText: "Clave",
              ),
            ),

            const SizedBox(height: 10),

            TextField(

              controller: valorController,

              decoration: const InputDecoration(
                labelText: "Valor",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: () {

                setState(() {

                  tabla.insertar(
                    claveController.text,
                    valorController.text,
                  );

                  claveController.clear();
                  valorController.clear();
                });
              },

              child: const Text("Insertar"),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView(

                children: datos.entries.map((e) {

                  return Card(

                    child: ListTile(

                      title: Text(e.key),

                      subtitle: Text(e.value),

                      trailing: IconButton(

                        icon: const Icon(Icons.delete),

                        onPressed: () {

                          setState(() {
                            tabla.eliminar(e.key);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}