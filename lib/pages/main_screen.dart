// Importaciones necesarias para el funcionamiento del código
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// Clase principal que representa la pantalla principal
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Estado asociado a la pantalla principal
class _MainScreenState extends State<MainScreen> {
  // Variables necesarias en la aplicación
  late FirebaseDatabase _databaseInit;
  StreamSubscription<DatabaseEvent>? _subscription;
  String latestImageCodified = "";
  Uint8List? latestImageBytes = Uint8List(0);
  bool isConnected = false;
  late Size size;
  TextEditingController textController = TextEditingController();
  String subscriptionText = "";

  // Método para escuchar cambios en la base de datos Firebase Realtime
  void listenTo(String droneID) {
    if (isConnected == false) {
      subscriptionText = droneID;
      log("NOS CONECTAMOS");
      isConnected = true;

      // Escuchar cambios en el nodo específico en la base de datos
      _subscription = _databaseInit
          .ref()
          .child(droneID)
          .orderByKey()
          .limitToLast(1)
          .onValue
          .listen(
        (event) {
          log("INTENTAMOS ESCUCHAR");
          try {
            log("CAMBIO EN LA BBDD");
            dynamic data = event.snapshot.value;

            // Manejar el caso en que no hay datos en el nodo
            if (data.toString() == "null") {
              setState(() {
                latestImageBytes = Uint8List(0);
              });
            }

            // Procesar los datos si existen y son de tipo Map
            if (data is Map<Object?, Object?>) {
              String latestKey = data.keys.first.toString();
              log("Último frame: $latestKey");
              latestImageCodified = data[latestKey].toString();

              Uint8List imageBytes = base64.decode(latestImageCodified);

              setState(() {
                latestImageBytes = imageBytes;
              });
            }
          } catch (e, stackTrace) {
            log('Error inesperado: $e\n$stackTrace');
          }
        },
        onError: (error) {
          log('Error al recibir cambios: $error');
        },
      );
    }
  }

  // Decodificar y mostrar una imagen a partir de una cadena codificada en base64
  /*Uint8List decodeAndShow(String frame) {
    Uint8List image = base64Decode(frame);
    return image;
  }*/

  // Desconectar el cliente y actualizar el estado del widget
  void disconnect() {
    log("Nos desconectamos de '$subscriptionText'");
    if (_subscription != null) {
      _subscription!.cancel();
    }

    // Actualizar el estado del widget
    setState(() {
      subscriptionText = "";
      textController.clear;
      isConnected = false;
      latestImageBytes = Uint8List(0);
    });
  }

  @override
  void initState() {
    super.initState();
    _databaseInit = FirebaseDatabase.instance;
  }

  // Construcción de la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase DroneStream'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'disconnect') {
                disconnect();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'disconnect',
                  child: Text('Desconectar'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sección para ingresar el ID del dron y conectar/desconectar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: size.width * 0.35,
                      child: TextField(
                        autofocus: false,
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'Drone ID',
                          border: OutlineInputBorder(),
                        ),
                        onTapOutside: (event) {
                          // Para desenfocar en el widget de TextField
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 60,
                      width: size.width * 0.25,
                      child: !isConnected
                          ? ElevatedButton(
                              onPressed: () {
                                if (textController.text.isNotEmpty &&
                                    !isConnected) {
                                  listenTo(textController.text);
                                }
                              },
                              child: const Text("Conectar"),
                            )
                          : Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.green[200],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text("Conectado"),
                            ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Sección para mostrar la transmisión de video
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          color: Colors.grey[300],
                        ),
                        if (isConnected == false)
                          const Text("Cliente desconectado"),
                        if (latestImageBytes!.isEmpty && isConnected == true)
                          const Text('No hay contenido disponible'),
                        if (latestImageBytes!.isNotEmpty)
                          Image.memory(
                            latestImageBytes!,
                            fit: BoxFit.fill,
                            width: size.width,
                            height: size.height,
                            gaplessPlayback: true,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
