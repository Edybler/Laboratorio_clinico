import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';

class ColaScreen extends StatefulWidget {
  const ColaScreen({super.key});

  @override
  State<ColaScreen> createState() => _ColaScreenState();
}

class _ColaScreenState extends State<ColaScreen> {
  final TextEditingController controller = TextEditingController();
  String mensaje = "";

  void insertar(AppProvider provider) {
    if (controller.text.isEmpty) return;
    provider.colaManualEncolar(controller.text);
    setState(() {
      mensaje = "Elemento agregado";
      controller.clear();
    });
  }

  void eliminar(AppProvider provider) {
    final eliminado = provider.colaManualDesencolar();
    setState(() {
      mensaje = eliminado == null ? "Cola vacía" : "Elemento eliminado: $eliminado";
    });
  }

  void limpiar(AppProvider provider) {
    provider.colaManualLimpiar();
    setState(() => mensaje = "Cola limpiada");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final elementos = provider.colaManual.aLista();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Sala de Espera"),
            backgroundColor: Colors.green,
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
                      child: const Text("Agregar"),
                    ),
                    ElevatedButton(
                      onPressed: () => eliminar(provider),
                      child: const Text("Atender"),
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
      },
    );
  }
}