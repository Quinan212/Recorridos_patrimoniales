# Firma y publicación de Android

El proyecto completo está en `C:/Users/alan/Desktop/Recorridos_patrimoniales-principal`.

La clave de subida creada el 24/10/2026 está **dentro de este proyecto**:

- `android/firma-upload/upload-keystore.jks`: clave privada.
- `android/firma-upload/credenciales.properties`: contraseñas y alias.
- `android/firma-upload/upload-certificate.pem`: certificado público para Play Console.
- `android/firma-upload/solicitud-google-play.png`: comprobante de la solicitud enviada.

`android/key.properties` usa `storeFile=../firma-upload/upload-keystore.jks`, relativo a `android/app`. La carpeta completa del proyecto se puede trasladar sin cambiar esa ruta. Los archivos privados están excluidos de Git y tienen acceso restringido al usuario de Windows y SYSTEM.

La solicitud de cambio de clave de subida de **Recorridos Patrimoniales** se envió con la cuenta `thanos3280@gmail.com`. La consola muestra el cambio como pendiente. La fecha efectiva que muestra la consola es anterior a la fecha local de esta revisión; comprobar la activación en Play Console antes de subir un bundle nuevo.

## Generar un AAB

Desde la carpeta raíz del proyecto:

```powershell
flutter build appbundle --release --build-name=1.0.5 --build-number=387 --dart-define-from-file=android/firma-upload/release-defines.json
python tool/verificar_aab_publicacion.py
```

La configuración local del mapa se conserva en el archivo de defines, dentro de la carpeta ignorada de firma. No contiene claves administrativas de Supabase.

El AAB se genera en `build/app/outputs/bundle/release/app-release.aab`. El verificador comprueba paquete, versión, firma, recursos cartográficos y bibliotecas nativas, y deja una copia en Descargas.

El código 387 sigue al 386 que figura como mayor código cargado en Play Console al hacer esta revisión. Una vez utilizado 387, incrementar el código para la siguiente publicación y ajustar la validación correspondiente.

Conservar un respaldo privado del keystore y sus credenciales. El certificado PEM público no permite recuperar la clave privada si se pierde.

## Respaldo separado

Se guardó una segunda copia en `C:/Users/alan/Documents/Recorridos-Patrimoniales-Respaldo-Firma/2026-10-24/`, fuera del proyecto y en el mismo equipo. Incluye el keystore, las credenciales, el PEM, la configuración de Gradle y los comprobantes públicos. Se comprobaron los hashes SHA-256 y el uso de la clave privada de la copia; su certificado coincide con el PEM enviado y el AAB 387. Los permisos se limitaron al usuario y SYSTEM.

`LEEME-RESTAURAR.txt` explica cómo recuperar la firma. `verificacion-respaldo.json` conserva los hashes y el resultado. Para guardar y verificar otro respaldo local, ejecutar `python tool/respaldar_firma_upload.py` desde el proyecto.
