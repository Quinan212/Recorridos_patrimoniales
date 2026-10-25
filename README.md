# Recorridos Patrimoniales

Aplicación Flutter para explorar el patrimonio arquitectónico de Concordia. Esta rama contiene la versión actual con mapa 3D nativo, cartografía local y carga de sectores por Internet.

## Desarrollo

```sh
flutter pub get
flutter run
flutter test
flutter analyze
node test/limite_area_test.cjs
```

La versión y las dependencias reproducibles se definen en `pubspec.yaml` y `pubspec.lock`. Las opciones `SUPABASE_URL`, `SUPABASE_ANON_KEY` y `MAPTILER_KEY` se suministran mediante `--dart-define` o el archivo local de definiciones indicado en la guía de publicación. No guardar credenciales privadas en el repositorio.

## Mapa y recursos

`assets/mapa_3d/` contiene la cartografía, fuentes, estilos y bibliotecas necesarias para el visor. Las teselas locales son recursos de la app, no la caché generada durante su ejecución. Conservar las atribuciones a MapTiler y OpenStreetMap, así como las licencias incluidas. Las coordenadas del catálogo se reconcilian con los puntos del KML.

## Publicación Android

Ver [guía de publicación](docs/publicacion-android.md). El [certificado público de subida](docs/firma/upload-certificate.pem) identifica la firma; no contiene la clave privada ni permite firmar una aplicación.

Los keystores y sus contraseñas permanecen en `android/firma-upload/` y `android/key.properties`, excluidos de Git. Los APK/AAB, cachés y dependencias descargadas tampoco se versionan. Las exportaciones GeoJSON intermedias de edificios y sombras se conservan solo localmente; el visor usa los recursos optimizados.
