import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/nav_drawer.dart';

class PilaScreen extends StatefulWidget {
  const PilaScreen({super.key});

  @override
  State<PilaScreen> createState() => _PilaScreenState();
}

class _PilaScreenState extends State<PilaScreen> {
  final TextEditingController controller = TextEditingController();
  String mensaje = "";

  // INSERTAR — usa el provider para persistir entre navegaciones
  void insertar(AppProvider provider) {
    if (controller.text.isEmpty) return;
    provider.pilaManualPush(controller.text);
    setState(() {
      mensaje = "Dato insertado";
      controller.clear();
    });
  }

  // ELIMINAR
  void eliminar(AppProvider provider) {
    final eliminado = provider.pilaManualPop();
    setState(() {
      mensaje = eliminado == null ? "La pila está vacía" : "Eliminado: $eliminado";
    });
  }

  // LIMPIAR
  void limpiar(AppProvider provider) {
    provider.pilaManualLimpiar();
    setState(() => mensaje = "Pila limpiada");
  }

  @override
  Widget build(BuildContext context) {
    // Consumer reconstruye la vista cada vez que el provider notifica cambios
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final elementos = provider.pilaManual.aLista();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Pantalla Pila"),
            backgroundColor: Colors.blue,
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
                      child: const Text("Push"),
                    ),
                    ElevatedButton(
                      onPressed: () => eliminar(provider),
                      child: const Text("Pop"),
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

                const Text(
                  "Visualización de Pila",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
      },
    );
  }
}