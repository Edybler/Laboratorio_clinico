import 'package:flutter/material.dart';
import '../widgets/nav_drawer.dart';
import '../data_structures/grafo.dart';

class GrafoScreen extends StatefulWidget {

  const GrafoScreen({super.key});

  @override
  State<GrafoScreen> createState() => _GrafoScreenState();
}

class _GrafoScreenState extends State<GrafoScreen> {

  final Grafo grafo = Grafo();

  final TextEditingController origenController =
      TextEditingController();

  final TextEditingController destinoController =
      TextEditingController();

  String bfsResultado = "";
  String dfsResultado = "";

  void agregarConexion() {

    setState(() {

      grafo.agregarVertice(
        origenController.text,
      );

      grafo.agregarVertice(
        destinoController.text,
      );

      grafo.agregarArista(
        origenController.text,
        destinoController.text,
      );

      origenController.clear();
      destinoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Grafo"),
        backgroundColor: Colors.teal,
      ),
      drawer: const NavDrawer(),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              controller: origenController,

              decoration: const InputDecoration(
                labelText: "Origen",
              ),
            ),

            const SizedBox(height: 10),

            TextField(

              controller: destinoController,

              decoration: const InputDecoration(
                labelText: "Destino",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: agregarConexion,

              child: const Text("Agregar Arista"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: () {

                setState(() {

                  bfsResultado =
                      grafo.bfs("A").toString();
                });
              },

              child: const Text("Mostrar BFS"),
            ),

            ElevatedButton(

              onPressed: () {

                setState(() {

                  dfsResultado =
                      grafo.dfs("A").toString();
                });
              },

              child: const Text("Mostrar DFS"),
            ),

            const SizedBox(height: 20),

            Text("BFS: $bfsResultado"),

            const SizedBox(height: 10),

            Text("DFS: $dfsResultado"),
          ],
        ),
      ),
    );
  }
}