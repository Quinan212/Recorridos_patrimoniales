# Recorridos Patrimoniales

**El patrimonio arquitectónico de Concordia, en un mapa para recorrerlo.**

Aplicación Flutter para descubrir edificios y sitios patrimoniales de Concordia, Entre Ríos, con fotografías, información histórica y un mapa 3D. El recorrido dedicado a Alejo Martínez reúne las obras y sus fichas en una misma experiencia.

La rama **`principal`** contiene la versión vigente con el mapa actualizado. La versión del proyecto se define en [`pubspec.yaml`](pubspec.yaml).

## Qué incluye

- **Mapa 3D nativo:** edificios en relieve y selección de puntos patrimoniales.
- **Ubicaciones verificables:** 23 puntos procedentes del KML y un punto adicional del catálogo de la app, conservando su origen.
- **Fichas de cada lugar:** fotografías, dirección, descripción, fuentes y audio cuando está disponible.
- **Búsqueda de lugares:** acceso al catálogo desde la búsqueda y el mapa.
- **Cartografía local y mapa continuo:** recursos incluidos para la zona del recorrido y carga de nuevos sectores por Internet cuando está configurado el proveedor.

La cartografía incluida no representa una descarga completa de toda la ciudad. La disponibilidad de contenido remoto y de nuevos sectores depende de la conexión y de la configuración de servicios.

## Empezar a trabajar

### Requisitos

- Flutter compatible con la restricción de Dart indicada en `pubspec.yaml` (`^3.11.4`).
- Git y, para Android, Android SDK, un JDK compatible y un emulador o dispositivo.
- Node.js para ejecutar la comprobación adicional de límites del mapa.

```sh
git clone --branch principal https://github.com/Quinan212/Recorridos_patrimoniales.git
cd Recorridos_patrimoniales
flutter pub get
flutter run
```

Android es el destino de publicación documentado. La presencia de carpetas de otras plataformas no implica que todas las funciones estén verificadas en ellas.

### Servicios y configuración

Los valores de los servicios se suministran al compilar mediante `--dart-define` o un archivo local de definiciones:

| Variable | Uso |
| --- | --- |
| `SUPABASE_URL` | Dirección del proyecto que sirve el contenido remoto. |
| `SUPABASE_ANON_KEY` | Clave de cliente para acceder al contenido según sus permisos. |
| `MAPTILER_KEY` | Acceso a la cartografía de sectores adicionales. |

Ejemplo con un archivo JSON local, excluido del repositorio:

```sh
flutter run --dart-define-from-file=android/firma-upload/release-defines.json
```

Consultar la [guía de publicación Android](docs/publicacion-android.md) para preparar ese archivo y la firma. Las contraseñas, claves administrativas y archivos de configuración privados se conservan fuera del control de versiones.

## Cómo está organizado

| Carpeta | Contenido |
| --- | --- |
| `lib/` | Interfaz, catálogo, búsqueda y servicios de la aplicación. |
| `lib/modulos/alejo_patrimonio/mapa_3d/` | Integración del mapa, catálogo geográfico y almacenamiento de teselas. |
| `assets/imagenes/` | Fotografías y recursos visuales. |
| `assets/mapa_3d/` | Cartografía local, estilos, fuentes y recursos del visor. |
| `test/` e `integration_test/` | Pruebas del catálogo, mapa, repositorios e interfaz. |
| `tool/` y `scripts/` | Utilidades de desarrollo, firma y verificación. |
| `supabase/` | Configuración y migraciones del servicio de contenido. |
| `docs/` | Documentación técnica y de publicación. |

## Verificar cambios

```sh
flutter analyze
flutter test
node test/limite_area_test.cjs
```

Las pruebas cubren, entre otros casos, la reconciliación de las coordenadas, las fichas, la carga de teselas, la búsqueda y distintos tamaños de interfaz. La prueba de límites comprueba la geometría conservada como recurso; no implica que el mapa continuo actual bloquee el desplazamiento en ese borde.

## Compilar para Android

Con los servicios y la firma configurados localmente:

```sh
flutter build apk --release --dart-define-from-file=android/firma-upload/release-defines.json
flutter build appbundle --release --dart-define-from-file=android/firma-upload/release-defines.json
```

Los resultados se generan en:

- APK: `build/app/outputs/flutter-apk/`.
- AAB para Google Play: `build/app/outputs/bundle/release/`.

El código de versión debe incrementarse antes de cada nueva subida a Google Play. La [guía de publicación](docs/publicacion-android.md) detalla el proceso y las herramientas de validación.

### Certificado y firma

- [Certificado público de subida — PEM](docs/firma/upload-certificate.pem).
- [Keystore cifrado — JKS](docs/firma/upload-keystore.jks), publicado por decisión del propietario.

El PEM identifica el certificado y no permite firmar. El JKS contiene la clave privada cifrada; para utilizarlo también hacen falta las contraseñas y la configuración local de firma. Esas contraseñas y `android/key.properties` no se publican. La copia utilizada por las herramientas de publicación permanece en `android/firma-upload/`.

## Qué se guarda en Git

Se versionan el código fuente, los recursos necesarios para la app, las pruebas, la documentación y `pubspec.lock`, para conservar las versiones resueltas de las dependencias.

Se excluyen `build/`, `.dart_tool/`, dependencias descargadas, cachés, temporales, logs y APK/AAB. Las teselas incluidas en `assets/mapa_3d/` son recursos del mapa local y se conservan en el repositorio. Los GeoJSON intermedios de edificios y sombras no utilizados por el visor quedan fuera.

## Créditos y atribuciones

Conservar las atribuciones cartográficas de **MapTiler** y **OpenStreetMap**, las licencias de las bibliotecas y fuentes incluidas, y las referencias de las fichas patrimoniales. La publicación del código no sustituye las condiciones de uso de la cartografía, fotografías y demás recursos de terceros.
