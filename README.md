# Sistema de Laboratorio Clínico

**Programación III — Universidad Mariano Gálvez de Guatemala**

Aplicación móvil desarrollada en **Flutter + Dart** que implementa un sistema completo de gestión de laboratorio clínico, integrando datos reales de salud a través de la API estándar **HAPI FHIR R4** y demostrando el uso práctico de **6 estructuras de datos** implementadas desde cero.


## Descripción del proyecto

El **Sistema de Laboratorio Clínico** es una aplicación Flutter que permite gestionar pacientes, exámenes de laboratorio, reportes diagnósticos y médicos de un centro de salud. La aplicación consume datos reales del servidor público HAPI FHIR R4 y los distribuye en seis estructuras de datos personalizadas para demostrar sus propiedades y operaciones de forma visual e interactiva.

Cada estructura de datos cuenta con su propia pantalla dedicada donde el usuario puede ejecutar operaciones CRUD en tiempo real y observar el comportamiento de la estructura. El panel de análisis presenta estadísticas, gráficas y métricas derivadas de los datos cargados del API.

---

## Tecnologías utilizadas

- **Flutter 3.x** — Framework de desarrollo multiplataforma
- **Dart 3.x** — Lenguaje de programación
- **Provider 6.1.x** — Gestión de estado global con ChangeNotifier
- **HTTP 1.2.x** — Cliente HTTP para consumo de la API REST
- **FL Chart 0.68.x** — Gráficas de barras y circulares para el panel de análisis
- **Cached Network Image 3.3.x** — Carga y caché de imágenes
- **Material Design 3** — Sistema de diseño visual

---

## API utilizada — HAPI FHIR R4

**Base URL:** `https://hapi.fhir.org/baseR4`

HAPI FHIR es un servidor de referencia que implementa el estándar **HL7 FHIR R4** (Fast Healthcare Interoperability Resources), ampliamente utilizado en sistemas de salud para el intercambio de información clínica. No requiere autenticación y devuelve respuestas en formato JSON.

**Header requerido en todas las peticiones:**
```
Accept: application/fhir+json
```

**Endpoints consumidos por la aplicación:**

```
GET /Patient?_count=20&_format=json
    → Lista de pacientes del laboratorio

GET /Patient/{id}?_format=json
    → Detalle completo de un paciente

GET /Patient?name={nombre}&_format=json
    → Búsqueda de paciente por nombre

GET /Observation?_count=20&_format=json
    → Resultados de exámenes de laboratorio

GET /Observation?patient={id}&_format=json
    → Observaciones/resultados de un paciente específico

GET /DiagnosticReport?_count=20&_format=json
    → Reportes diagnósticos completos

GET /Practitioner?_count=10&_format=json
    → Médicos y especialistas

GET /Condition?_count=20&_format=json
    → Condiciones y diagnósticos de pacientes
```

**Estructura de respuesta Bundle FHIR:**

```json
{
  "resourceType": "Bundle",
  "entry": [
    {
      "resource": {
        "resourceType": "Patient",
        "id": "592442",
        "name": [{ "family": "Pérez", "given": ["Juan"] }],
        "gender": "male",
        "birthDate": "1985-03-15",
        "telecom": [{ "system": "phone", "value": "+502-5555-0000" }],
        "address": [{ "line": ["5ta Avenida Zona 1"] }]
      }
    }
  ]
}
```

---

## Estructuras de datos implementadas

Todas las estructuras están implementadas **desde cero en Dart puro**, sin utilizar las colecciones nativas del lenguaje (`List`, `Map`, `Queue`, etc.) para la lógica interna de cada estructura.

### Pila (Stack) — Historial de exámenes

Estructura LIFO (Last In, First Out). Se utiliza para mantener el historial de exámenes y pacientes consultados recientemente, mostrando siempre el más reciente en la cima.

```
        ┌─────────────────┐
 CIMA → │  Hemograma      │ ← push / pop / peek
        ├─────────────────┤
        │  Glucosa        │
        ├─────────────────┤
        │  Colesterol     │
        ├─────────────────┤
        │  Uroanálisis    │
        └─────────────────┘
             BASE

  push(x) → agrega en la cima        O(1)
  pop()   → retira de la cima        O(1)
  peek()  → consulta la cima         O(1)
```

**Implementación:** nodos enlazados `_Nodo<T>` con puntero `siguiente`. La cima es el primer nodo de la cadena.

---

### Cola (Queue) — Sala de espera

Estructura FIFO (First In, First Out). Modela la sala de espera del laboratorio: el primer paciente en llegar es el primero en ser atendido.

```
  FRENTE                                  FINAL
    │                                       │
    ▼                                       ▼
┌───────┐    ┌───────┐    ┌───────┐    ┌───────┐
│  P-01 │ →  │  P-02 │ →  │  P-03 │ →  │  P-04 │
└───────┘    └───────┘    └───────┘    └───────┘
   ↑ desencolar()                    encolar() ↑

  encolar(p)   → agrega al final     O(1)
  desencolar() → retira del frente   O(1)
  frente()     → consulta el frente  O(1)
```

**Implementación:** nodos enlazados con punteros `_frente` y `_final` para operaciones O(1) en ambos extremos.

---

### Lista Doblemente Enlazada — Resultados de laboratorio

Permite recorrido bidireccional. Almacena los resultados de exámenes de laboratorio y soporta inserción y eliminación en cualquier posición.

```
         ┌──────────────────────────────────────────┐
  CABEZA │                                          │ COLA
    ↓    │                                          ↓
┌──────┐ │  ┌──────┐      ┌──────┐      ┌──────┐
│ Obs1 │◄──►│ Obs2 │◄────►│ Obs3 │◄────►│ Obs4 │
│      │    │      │      │      │      │      │
└──────┘    └──────┘      └──────┘      └──────┘
  ant=null                               sig=null

  insertarAlInicio(x)  O(1)
  insertarAlFinal(x)   O(1)
  eliminar(x)          O(n)
  contiene(x)          O(n)
  aListaInversa()      O(n)  ← recorre desde la cola
```

**Implementación:** cada `_Nodo<T>` tiene punteros `anterior` y `siguiente`, con referencias `_cabeza` y `_cola` en la clase.

---

### Árbol Binario de Búsqueda (BST) — Índice de pacientes

Permite búsqueda, inserción y eliminación eficientes por clave numérica. Cada paciente se indexa usando una clave derivada de su ID FHIR.

```
                    [450]
                   /     \
               [312]     [612]
              /    \     /    \
           [201]  [380][521]  [730]
           /                  \
         [155]                [810]

  insertar(k,v)   O(log n) promedio
  buscar(k)       O(log n) promedio
  eliminar(k)     O(log n) promedio
  enOrden()       O(n)  → claves ascendentes
  preOrden()      O(n)  → raíz primero
  altura()        O(n)
```

**Implementación:** `_NodoArbol` con campos `clave (int)`, `valor (String)`, `izquierdo` y `derecho`. Eliminación con sucesor inorden.

---

### Tabla Hash — Búsqueda rápida de pacientes

Permite búsqueda en O(1) promedio por nombre de paciente. Usa **31 cubetas** (número primo) y manejo de colisiones por **encadenamiento** (chaining).

```
  Función hash: suma de charCodes % 31

  Índice  │ Cubeta
  ────────┼─────────────────────────────────
     0    │ [ ]
     1    │ ["juan perez" → Paciente#1]
     2    │ [ ]
     3    │ ["ana gomez" → Paciente#2] → ["carlos gomez" → Paciente#7]
     4    │ [ ]
     ...  │ ...
    14    │ ["maria lopez" → Paciente#3]
     ...  │ ...
    30    │ ["pedro solis" → Paciente#5]

  poner(clave, valor)   O(1) promedio
  obtener(clave)        O(1) promedio
  eliminar(clave)       O(1) promedio
  Colisiones → encadenamiento (listas en cada cubeta)
```

**Implementación:** `List<List<_EntradaHash>>` de tamaño 31. Cada `_EntradaHash` almacena clave y valor. Actualización in-place si la clave ya existe.

---

### Grafo — Red de referencias médicas

Grafo no dirigido que modela la red de médicos del sistema. Los vértices son médicos y las aristas representan relaciones de referencia entre especialidades.

```
       [Dr. García]─────────[Dr. Méndez]
           │    \                │
           │     \               │
    [Esp: Cardio] \        [Esp: Neurol]
                   \
              [Dr. López]────[Dr. Pérez]
                    │
              [Esp: General]

  agregarVertice(v)          O(1)
  agregarArista(v1, v2)      O(1)
  vecinos(v)                 O(1)
  bfs(inicio) → visita por niveles
  dfs(inicio) → visita en profundidad
  existeCamino(v1, v2)       O(V + E)
```

**Implementación:** `Map<String, List<String>>` de listas de adyacencia. Grafo no dirigido: cada arista se agrega en ambas direcciones.

---

## Pantallas de la aplicación

**Inicio** — Dashboard con métricas del sistema (total pacientes, en espera, exámenes, médicos), estado de las 6 estructuras de datos y botón para cargar datos desde el API.

**Pacientes** — Lista completa de pacientes con barra de búsqueda que consulta la Tabla Hash en O(1). Cada tarjeta muestra iniciales, nombre, género (con chip de color) y fecha de nacimiento.

**Detalle de paciente** — Perfil completo del paciente con todos sus datos personales, lista de observaciones/resultados cargados del API y botones para agregar al historial (Pila) o a la sala de espera (Cola).

**Pila — Historial de exámenes** — Visualización de la pila como torre de tarjetas apiladas. Operaciones PUSH, POP y PEEK con indicador visual de la cima. Contador de elementos.

**Cola — Sala de espera** — Visualización horizontal tipo fila con flechas de dirección. El primer elemento está resaltado en verde. Operaciones ENCOLAR, DESENCOLAR y VER FRENTE.

**Lista enlazada — Resultados** — Visualización de nodos conectados con flechas bidireccionales. CRUD completo: insertar al inicio/final, eliminar por descripción, buscar. Muestra tamaño actual.

**Árbol BST — Índice de pacientes** — Visualización gráfica del árbol. Botones para insertar, buscar y eliminar nodos. Muestra recorridos inOrden y preOrden como texto e indicador de altura.

**Tabla Hash — Búsqueda rápida** — Grid de 31 celdas numeradas. Celdas vacías en gris, celdas con dato en azul. Badge con número de elementos por cubeta en caso de colisión. Búsqueda en tiempo real.

**Grafo — Red médica** — Visualización con CustomPaint: círculos para médicos, líneas para conexiones en layout circular. BFS y DFS desde cualquier nodo, con resultado como lista de visita ordenada.

**Análisis de datos** — Gráfica de barras de distribución de géneros, gráfica circular de estados de observaciones, tarjetas estadísticas (paciente más joven/mayor, observación más frecuente, médico con más conexiones) y tabla resumen de operaciones por estructura.

---

## Estructura del proyecto

```
laboratorio_clinico/
│
├── pubspec.yaml
├── README.md
├── analysis_options.yaml
│
└── lib/
    ├── main.dart
    │
    ├── models/
    │   ├── paciente.dart
    │   ├── observacion.dart
    │   ├── reporte_diagnostico.dart
    │   ├── medico.dart
    │   └── condicion.dart
    │
    ├── data_structures/
    │   ├── pila.dart
    │   ├── cola.dart
    │   ├── lista_enlazada.dart
    │   ├── arbol_bst.dart
    │   ├── tabla_hash.dart
    │   └── grafo.dart
    │
    ├── services/
    │   └── fhir_service.dart
    │
    ├── providers/
    │   └── app_provider.dart
    │
    ├── screens/
    │   ├── home_screen.dart
    │   ├── pacientes_screen.dart
    │   ├── detalle_paciente_screen.dart
    │   ├── pila_screen.dart
    │   ├── cola_screen.dart
    │   ├── lista_screen.dart
    │   ├── arbol_screen.dart
    │   ├── hash_screen.dart
    │   ├── grafo_screen.dart
    │   └── analisis_screen.dart
    │
    └── widgets/
        ├── nav_drawer.dart
        ├── paciente_card.dart
        └── estructura_visualizer.dart
```

---

## Instrucciones para correr el proyecto

**Requisitos previos:**
- Flutter SDK 3.x instalado y configurado
- Dart SDK 3.x
- Android Studio o VS Code con extensión Flutter
- Dispositivo físico o emulador Android/iOS
- Conexión a Internet (para consumir el API HAPI FHIR R4)

**Pasos para ejecutar:**

```bash
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/laboratorio-clinico-prog3.git

# Entrar al directorio del proyecto
cd laboratorio-clinico-prog3

# Instalar dependencias
flutter pub get

# Verificar que el entorno esté configurado correctamente
flutter doctor

# Ejecutar la aplicación en modo debug
flutter run

# Compilar APK de release para Android
flutter build apk --release

# Compilar para iOS (requiere macOS y Xcode)
flutter build ios --release
```

**Dependencias principales del pubspec.yaml:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  http: ^1.2.1
  fl_chart: ^0.68.0
  cached_network_image: ^3.3.1
  cupertino_icons: ^1.0.8
```

**Nota sobre el API:** La aplicación consume el servidor público `https://hapi.fhir.org/baseR4`. No se requiere ninguna clave de API ni configuración adicional. El servidor puede tener tiempos de respuesta variables dependiendo de la carga. Si una petición falla, la aplicación muestra el error en un SnackBar y puede reintentarse presionando el botón "Cargar datos del API".

---

## Diseño visual

- **Sistema de diseño:** Material Design 3
- **Color primario:** `#1565C0` (Azul médico)
- **Color secundario:** `#00897B` (Verde teal)
- **Fondo:** `#F5F7FF` (Gris azulado claro)
- **Cards:** Elevación 2, border radius 12px
- **Tipografía:** Roboto (predeterminada de Material 3)

---

## Capturas de pantalla


## Navegación del sistema

```
Drawer lateral
│
├── 🔬  Inicio
├── 👥  Pacientes
│       └── Detalle de paciente
│
├── ── ESTRUCTURAS DE DATOS ──
├── 📚  Pila — Historial de exámenes
├── 🔄  Cola — Sala de espera
├── 🔗  Lista enlazada — Resultados
├── 🌳  Árbol BST — Índice de pacientes
├── #️⃣  Tabla Hash — Búsqueda rápida
├── 🕸️  Grafo — Red médica
│
└── 📊  Análisis de datos
```

---



---

