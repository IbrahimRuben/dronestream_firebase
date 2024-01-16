# Firebase DroneStream

## Descripción
Esta aplicación utiliza el servicio de Google llamado Firebase para recibir en tiempo real contenido multimedia desde un cliente externo, simulado en el archivo _DummyServiceFirebase.py_.

## Instalación

**Paso 1:**

Descarga o clona este repositorio usando el siguiente enlace:
```
https://github.com/IbrahimRuben/dronestream.git
```

**Paso 2:**

Ve a la carpeta raíz del proyecto y ejecuta el siguiente comando en la consola para obtener las dependencias necesarias:

```
flutter pub get
```

**Paso 3:**

Ejecuta la aplicación con el siguiente comando en la consola:

```
flutter run lib/main.dart
```

> [!IMPORTANT]
> Recuerda seleccionar el dispositivo en el que desees ejecutar la aplicación.


# Guía de uso

- El primer paso consiste en conectarnos a la base de datos (BBDD) de nuestra elección o a la dirección en la cual sabemos que se publicará el contenido multimedia que queremos visualizar. Para ello, ingresamos esa dirección en el TextField y hacemos clic en "Conectar".

> [!NOTE]
> Si ya había contenido en la dirección que hemos seleccionado, veremos el último archivo subido a la base de datos.

- Una vez completado este paso, ejecutaremos el archivo _DummyServiceFirebase.py_ para que envíe imágenes a la mencionada dirección. Podemos ajustar la frecuencia y la duración del envío según nuestras preferencias.
- Para desconectarnos, hacemos clic en el menú desplegable en la parte superior derecha de la pantalla y seleccionamos "Desconectar".
