# Correcciones R03, R06, R07 y pruebas R13

Trabajo sobre la copia local `Recorridos_patrimoniales-principal`, 29/09/2026.

## R03: distancias

Descubrir muestra la dirección de la obra destacada. Se retiraron los valores fijos 211 m y 610 m. El mapa muestra «Ubicación no disponible» hasta recibir una posición real. Las distancias calculadas indican «≈ … en línea recta»; no representan una ruta peatonal. Al fallar la consulta o perderse el servicio/permiso de ubicación, se descarta el origen anterior. La frecuencia y el ciclo de vida del seguimiento siguen pendientes en R10.

## R06: edición y fuentes

Se normalizó la ortografía del catálogo local y los textos públicos de Inicio, Descubrir, Información, publicaciones y búsqueda. Cada ficha local incluye una referencia a la ficha correspondiente del catálogo de la UTN, con páginas físicas del PDF, fecha y alcance de revisión. Las fuentes y los créditos aparecen en el detalle.

Fuente consultada: [Movimiento moderno en Concordia. Catálogo de obras de Alejo Martínez, Bruno, Cáseres y Sota, UTN/edUTecNe](https://ria.utn.edu.ar/handle/20.500.12272/4215). [PDF del repositorio institucional](https://ria.utn.edu.ar/bitstreams/7b43486f-e3df-4349-aa45-98380479ab0e/download).

- Péndola Díaz: año 1925 y dirección Güemes 27–35 cotejados con la ficha, páginas 20–21 del PDF. La interpretación como primera construcción moderna del país se atribuye a los autores y remite a la presentación, página 11. La tarjeta destacada usa «Obra destacada», válido para cualquier selección.
- Liga Argentina de Préstamos Mutuos: el uso original se completó como viviendas y locales comerciales. Su dirección se corrigió a Entre Ríos 487, entre Roque Sáenz Peña y Carriego, según página 56 del PDF. Las coordenadas existentes ya ubican la obra en esa zona.
- Las demás fichas recibieron revisión ortográfica y referencia bibliográfica; no se las presenta como íntegramente verificadas. La revisión histórica completa y la documentación de autoría/fecha de las fotografías siguen siendo trabajo editorial.
- Para contenido remoto sin metadatos, el detalle informa que la fuente no está documentada; no atribuye automáticamente la bibliografía de un texto local a otro texto. No se modificó la base de datos ni su esquema.

## R07: imágenes

Las vistas de las fachadas estaban correctamente asignadas a las viviendas; los nombres de sus carpetas estaban cruzados. La identificación se cotejó visualmente con las fichas de la UTN, páginas 38–41 del PDF.

| Ficha | Recursos correctos |
| --- | --- |
| Suburo, Mitre 237 | `Screenshot_1776825146.jpg` y `Screenshot_1776825148.jpg`, ahora en `casa-suburo/` |
| Masvernat, Mitre 259 | `Screenshot_1776823895.jpg` y `Screenshot_1776823897.jpg`, ahora en `casa-masvernat/` |
| Plano de Masvernat | `Screenshot_1776825150.jpg`, parcela 2636, trasladado de la ficha Suburo a Masvernat; corresponde al plano de ubicación de la página 41 del PDF |

La imagen negra de 23 × 10 píxeles, `Screenshot_1776823898.jpg`, se retiró de los recursos y de la ficha. Se conservó el original en `%TEMP%/recorridos-fuentes/Screenshot_1776823898-original-negro.jpg`.

## R13: alcance de las pruebas

Se sustituyó la prueba que construía su propio título por verificaciones de los componentes y flujos reales. Las pruebas usan tipografías locales, un reproductor simulado y respuestas de ubicación/carga controladas, sin conectarse al servidor.

- Inicio, Descubrir, Información, publicaciones y detalle de publicación a 411 × 891 y 320 × 568, texto normal y ampliado.
- Carga de puntos/publicaciones, estado de carga, respaldo ante respuestas vacías y fallos; filas de puntos incompletas.
- Navegación principal real, búsqueda y apertura de ficha sin fotografía; audio ausente.
- Mapa con GPS apagado, permisos denegados y denegación permanente; origen real y pérdida de ubicación.
- Fallo de reproducción: aviso al usuario, limpieza del estado y reintento. La corrección evita dejar un reproductor con una URL que no pudo cargarse.
- Fuentes y distancia en una columna estrecha con letra ampliada; interpretación histórica y dirección corregidas.
- Identificadores, referencias y decodificación de todas las imágenes locales, descartando imágenes uniformes/vacías.
- Sin configuración de servidor no se concede permiso editorial local.

Estas pruebas no certifican las políticas desplegadas de Supabase. La autorización real del servidor permanece pendiente en R01/R02. La restricción global del tamaño de texto permanece pendiente en R11.

Comandos de verificación: `flutter test --no-pub` y `dart analyze`. Compilación Android: `flutter build apk --debug --no-pub`.

Resultado: 46 pruebas aprobadas; analizador sin hallazgos. APK debug compilado e instalado en `Recorridos_API_36`. Se verificó en el emulador la tarjeta de Suburo sin GPS y su fotografía/fuente; el APK incluye las cinco imágenes reubicadas y no incluye la imagen negra.

Los restantes hallazgos del informe original quedan en espera por indicación del usuario. No se ejecutó ninguna actualización de Git ni se reemplazaron fuentes locales por archivos de GitHub.
