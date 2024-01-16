import base64
import time
import cv2 as cv
import cv2
import firebase_admin
from firebase_admin import db, credentials

# Autenticación a Firebase
cred = credentials.Certificate("credentials.json")
firebase_admin.initialize_app(cred, {"databaseURL": "https://dronestream-219f5-default-rtdb.europe-west1.firebasedatabase.app/"})

# Creamos una referencia a la raíz de la BBDD
ref = db.reference("/")

# Inicia la cámara
cap = cv2.VideoCapture(0)

# Declaramos resolucion de la cámara
cap.set(3, 320) # 3 -> Ancho de la imagen
cap.set(4, 240) # 4 -> Altura de la imagen
cap.set(5, 39)  # 5 -> Frames por segundo (min 5fps, intervalos de 5)

# Consultamos resolucion de la cámara y FPS
print(cap.get(3))
print(cap.get(4))
print(cap.get(5))

# Empezamos un contador
st = time.time()

# Número de imágenes
n_img = 0

# Tomamos n fotos
#for i in range(120):

# Tomamos fotos durante n tiempo
while time.time() - st < 5:
    # Escogemos la cantidad de imagenes por segundo y la invertimos
    #fps = 1/30

    # Captura una imagen
    ret, frame = cap.read()

    # Reducing resolution (e.g., to 640x480)
    #resized_frame = cv.resize(frame, (320, 240))

    _, buffer = cv.imencode('.jpg', frame)
    
    # Codificamos la imagen
    jpg_as_text = base64.b64encode(buffer).decode("utf-8")

    # Utiliza la fecha y hora actual (milisegundos) como identificador único
    timestamp = str(int(time.time() * 1000))
    ruta_imagen = f"imagenes/{timestamp}"

    # Sube la imagen codificada a la base de datos
    ref.child(ruta_imagen).set(jpg_as_text)
    n_img = n_img + 1
    print("Imagen publicada, Imagen nº", n_img, ", Tamaño:", len(jpg_as_text))
    
    # Pequeño retardo en segundos entre cada captura
    #time.sleep(fps)

# Terminanos el contador
et = time.time()

# Obtenemos el tiempo de ejecución y la cantidad de imagenes tomadas
elapsed_time = et - st
print('Tiempo de ejecución:', elapsed_time, 'seconds\nImágenes:', n_img)

# Libera los recursos de la cámara
cap.release()