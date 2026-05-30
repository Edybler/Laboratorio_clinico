import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final TextEditingController controller = TextEditingController();
  String mensaje = "";

  void insertar(AppProvider provider) {
    if (controller.text.isEmpty) return;
    provider.listaManualInsertar(controller.text);
    setState(() {
      mensaje = "Dato insertado";
      controller.clear();
    });
  }

  void eliminar(AppProvider provider) {
    if (controller.text.isEmpty) return;
    provider.listaManualEliminar(controller.text);
    setState(() {
      mensaje = "Dato eliminado";
      controller.clear();
    });
  }

  void limpiar(AppProvider provider) {
    provider.listaManualLimpiar();
    setState(() => mensaje = "Lista limpiada");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final datos = provider.listaManual.aLista();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Lista Enlazada"),
            backgroundColor: Colors.orange,
          ),
          drawer: const NavDrawer(),

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
                      onPressed: () => insertar(provider),
                      child: const Text("Insertar"),
                    ),
                    ElevatedButton(
                      onPressed: () => eliminar(provider),
                      child: const Text("Eliminar"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () => limpiar(provider),
                  child: const Text("Limpiar"),
                ),

                const SizedBox(height: 20),

                Text(
                  mensaje,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

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
                              child: Center(child: Text(datos[index])),
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
      },
    );
  }
}