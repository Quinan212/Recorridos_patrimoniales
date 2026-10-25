class FuentePatrimonial {
  final String titulo;
  final String url;
  final String referencia;

  const FuentePatrimonial({
    required this.titulo,
    required this.url,
    required this.referencia,
  });
}

const tituloCatalogoAlejo =
    'Movimiento moderno en Concordia. Catálogo de obras de Alejo Martínez '
    '— M. A. Bruno, E. H. Cáseres y J. D. Sota (UTN, edUTecNe)';
const urlCatalogoAlejo =
    'https://ria.utn.edu.ar/bitstreams/7b43486f-e3df-4349-aa45-98380479ab0e/download';

class PuntoPatrimonial {
  final String id;
  final String nombre;
  final String direccion;
  final String descripcion;
  final List<String> urlsImagenes;
  final String? urlAudio;
  final double lat;
  final double lng;
  final List<FuentePatrimonial> fuentes;
  final String? procedenciaImagenes;

  /// Fecha y alcance de la revisión; no implica validación histórica completa.
  final String? revisionEditorial;

  const PuntoPatrimonial({
    required this.id,
    required this.nombre,
    this.direccion = "",
    this.descripcion = "",
    this.urlsImagenes = const [],
    this.urlAudio,
    required this.lat,
    required this.lng,
    this.fuentes = const [],
    this.procedenciaImagenes,
    this.revisionEditorial,
  });

  factory PuntoPatrimonial.desdeJson(
    Map<String, dynamic> json, {
    List<String> urlsImagenes = const [],
  }) {
    return PuntoPatrimonial(
      id: json['id'] as String,
      nombre: (json['name'] as String?) ?? '',
      direccion: (json['address'] as String?) ?? '',
      descripcion: (json['description'] as String?) ?? '',
      urlsImagenes: urlsImagenes,
      urlAudio: json['audio_url'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

// ======== RUTA 1: ALEJO MARTÍNEZ (catálogo local) ========
const List<PuntoPatrimonial> recorridoInnovacionAlejoMartinez = [
  PuntoPatrimonial(
    id: "r1-casa-de-bernardino-horne",
    nombre: "Casa de Bernardino Horne",
    direccion: "Pellegrini y 3 de Febrero",
    descripcion:
        "Es una vivienda de estilo moderno, entre medianeras, con un planteo similar a la Casa Péndola Díaz. La fachada es recta y está totalmente despojada de ornamentación, presentando un juego de llenos y vacíos y un balcón que aparece como una perforación. El programa incluye dos espacios para atención al público con acceso independiente, además de la vivienda. Cuenta con terrazas accesibles que posibilitan la expansión de las habitaciones. Antecedentes: Construida en 1930, es una obra de corte racionalista perteneciente al primer período de Alejo Martínez en Concordia. Declaratorias: Declarada Propiedad de Interés Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-de-bernardino-horne/1.jpg",
      "assets/imagenes/puntos/casa-de-bernardino-horne/2.jpg",
      "assets/imagenes/puntos/casa-de-bernardino-horne/3.jpg",
      "assets/imagenes/puntos/casa-de-bernardino-horne/4.jpg",
      "assets/imagenes/puntos/casa-de-bernardino-horne/5.jpg",
      "assets/imagenes/puntos/casa-de-bernardino-horne/6.jpg",
    ],
    lat: -31.391451,
    lng: -58.015167,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=22',
        referencia: 'Ficha de la obra, páginas 22–23 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-juan-antonio-castro",
    nombre: "Casa Juan Antonio Castro",
    direccion: "Pellegrini y 3 de Febrero",
    descripcion:
        "Vivienda de estilo moderno en esquina, desarrollada originalmente en dos plantas. La fachada original presentaba planos simples sin ornamentación. La vivienda diferenciaba claramente las áreas de servicio, privada y de recepción. En 2007, se le añadieron dos niveles superiores totalmente vidriados, alterando su aspecto original. Antecedentes: Construida en 1929, pertenece a la obra racionalista de Alejo Martínez. Declaratorias: Propiedad de Interés Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-juan-antonio-castro/Screenshot_1776823823.jpg",
      "assets/imagenes/puntos/casa-juan-antonio-castro/Screenshot_1776823825.jpg",
      "assets/imagenes/puntos/casa-juan-antonio-castro/Screenshot_1776823827.jpg",
    ],
    lat: -31.391711,
    lng: -58.015413,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=36',
        referencia: 'Ficha de la obra, páginas 36–37 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-del-dr-pendola-diaz",
    nombre: "Casa del Dr. Péndola Díaz",
    direccion: "Güemes 27–35, entre San Luis y Entre Ríos",
    descripcion:
        "Vivienda con consultorios, proyectada por Alejo Martínez en 1925. Bruno, Cáseres y Sota la consideran la primera construcción moderna del país en la presentación de su catálogo (página 11 del PDF). Esta valoración se refiere a su lenguaje arquitectónico y organización funcional.",
    urlAudio:
        "https://drive.usercontent.google.com/uc?id=1YOZNGs9p7ejUS6WAgPcsnG_bNpUs83Wx&export=download",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-del-dr-péndola-diaz/Screenshot_1776823630.jpg",
      "assets/imagenes/puntos/casa-del-dr-péndola-diaz/Screenshot_1776823632.jpg",
      "assets/imagenes/puntos/casa-del-dr-péndola-diaz/Screenshot_1776823633.jpg",
      "assets/imagenes/puntos/casa-del-dr-péndola-diaz/Screenshot_1776823635.jpg",
      "assets/imagenes/puntos/casa-del-dr-péndola-diaz/Screenshot_1776823637.jpg",
      "assets/imagenes/puntos/casa-del-dr-péndola-diaz/Screenshot_1776823641.jpg",
    ],
    lat: -31.393054,
    lng: -58.018508,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=20',
        referencia: 'Presentación: página 11; ficha: páginas 20–21 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión editorial: 29/09/2026. Fecha, dirección e interpretación histórica cotejadas con la UTN.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-dr-orlando-marcone",
    nombre: "Casa Dr. Orlando Marcone",
    direccion: "V. Sarsfield y San Luis",
    descripcion:
        "Vivienda moderna en esquina, dos plantas con consultorio. Volúmenes salientes en ambas fachadas con influencias vanguardistas; muros exteriores con terminación escalonada; aleros triangulares; influencias Art-Deco. Distribución funcional: sociales/consultorio en planta baja y dormitorios arriba. Antecedentes: 1928, primer período de Martínez. Declaratorias: Propiedad de Interés Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-dr-orlando-marcone/Screenshot_1776823716.jpg",
      "assets/imagenes/puntos/casa-dr-orlando-marcone/Screenshot_1776823717.jpg",
      "assets/imagenes/puntos/casa-dr-orlando-marcone/Screenshot_1776823719.jpg",
      "assets/imagenes/puntos/casa-dr-orlando-marcone/Screenshot_1776823723.jpg",
    ],
    lat: -31.393915,
    lng: -58.019084,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=32',
        referencia: 'Ficha de la obra, páginas 32–33 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-alberto-crossa",
    nombre: "Casa Alberto Crossa",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-alberto-crossa/Screenshot_1776823452.jpg",
      "assets/imagenes/puntos/casa-alberto-crossa/Screenshot_1776823453.jpg",
      "assets/imagenes/puntos/casa-alberto-crossa/Screenshot_1776823455.jpg",
    ],
    direccion: "San Luis y Entre Ríos",
    descripcion:
        "Edificio moderno con tipología viviendas arriba y locales abajo, sobre la peatonal. Fachada con dos balcones en los extremos y ventanas al centro; planta baja hoy muy intervenida. Antecedentes: Viviendas colectivas con locales de fines de los '20 poblaron el centro. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.39553,
    lng: -58.018322,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=46',
        referencia: 'Ficha de la obra, páginas 46–47 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-alberto-crossa-2",
    nombre: "Casa Alberto Crossa II",
    direccion: "San Luis y Entre Ríos",
    descripcion:
        "Segunda vivienda del conjunto Crossa, ubicada muy cerca de la Casa Alberto Crossa. Pertenece al conjunto de obras del primer período de Alejo Martínez en Concordia.",
    lat: -31.39561,
    lng: -58.01912,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=54',
        referencia: 'Ficha de la obra, páginas 54–55 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-arcioni",
    nombre: "Casa Arcioni",
    direccion: "Urquiza y San Luis",
    descripcion:
        "Es un amplio local comercial de estilo moderno, ubicado en esquina y desarrollado en dos plantas. La fachada se caracteriza por planos simples y predominio de líneas. Fue la sede de la tradicional tienda Hidalgo Solo. Antecedentes: Pertenece al primer período de Alejo Martínez en Concordia (1924-1931). Declaratorias: Declarada Propiedad de Interés Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823475.jpg",
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823476.jpg",
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823478.jpg",
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823480.jpg",
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823482.jpg",
    ],
    lat: -31.396703,
    lng: -58.018683,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=64',
        referencia: 'Ficha de la obra, páginas 64–65 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-banco-popular-de-concordia",
    nombre: "Banco Popular de Concordia",
    urlsImagenes: [
      "assets/imagenes/puntos/banco-popular-de-concordia/Screenshot_1776823374.jpg",
      "assets/imagenes/puntos/banco-popular-de-concordia/Screenshot_1776823376.jpg",
      "assets/imagenes/puntos/banco-popular-de-concordia/Screenshot_1776823378.jpg",
      "assets/imagenes/puntos/banco-popular-de-concordia/Screenshot_1776823371.jpg",
    ],
    direccion: "Urquiza y Mitre",
    descripcion:
        "Edificio de estilo moderno en esquina, de dos plantas. La fachada presenta líneas rectas y muy poca ornamentación, excepto en jambas y acceso; cornisa lineal. Actualmente se encuentra muy intervenido por la subdivisión en locales. Antecedentes: El banco se fundó en 1917; la remodelacion de Martínez es de 1930. Tras la fusión/cierre, se subdividió en locales comerciales. Declaratorias: Declarada Propiedad de Interés Municipal.",
    lat: -31.396869,
    lng: -58.01767,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=50',
        referencia: 'Ficha de la obra, páginas 50–51 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-dr-camano",
    nombre: "Casa Dr. Camaño",
    direccion: "La Rioja y Mitre",
    descripcion:
        "Vivienda de estilo moderno en esquina, desarrollada en dos plantas; fachada recta con planos simples, sin molduras. Zonificación funcional: recepción y servicios en planta baja; área privada en planta alta. Un porche en doble altura enmarca el acceso y protege la terraza-balcón. Antecedentes: 1930-1931; primer período de Martínez. Declaratorias: Declarada Propiedad de Interés Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-dr-camaño/Screenshot_1776823660.jpg",
      "assets/imagenes/puntos/casa-dr-camaño/Screenshot_1776823662.jpg",
      "assets/imagenes/puntos/casa-dr-camaño/Screenshot_1776823664.jpg",
      "assets/imagenes/puntos/casa-dr-camaño/Screenshot_1776823666.jpg",
      "assets/imagenes/puntos/casa-dr-camaño/Screenshot_1776823671.jpg",
      "assets/imagenes/puntos/casa-dr-camaño/Screenshot_1776823673.jpg",
      "assets/imagenes/puntos/casa-dr-camaño/Screenshot_1776823674.jpg",
    ],
    lat: -31.397376,
    lng: -58.014552,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=24',
        referencia: 'Ficha de la obra, páginas 24–25 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-suburo",
    nombre: "Casa Suburo",
    direccion: "Mitre 237",
    descripcion:
        "Conjunto Suburo, Masvernat y Woolmer - Casa Suburo (Mitre 237, 1929), Casa Masvernat (Mitre 259, 1931) y Casa Woolmer (Mitre 271, 1930). Permiten observar la evolución estilística y funcional de Alejo Martínez en una misma calle.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-suburo/Screenshot_1776825146.jpg",
      "assets/imagenes/puntos/casa-suburo/Screenshot_1776825148.jpg",
    ],
    lat: -31.397619,
    lng: -58.013872,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=38',
        referencia: 'Ficha de la obra, páginas 38–39 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión editorial: 29/09/2026. Identificación de las fotografías cotejada con la ficha de la UTN.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-juana-c-de-salduna",
    nombre: "Casa Juana C. de Salduna",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-juana-c-de-salduna/Screenshot_1776823767.jpg",
      "assets/imagenes/puntos/casa-juana-c-de-salduna/Screenshot_1776823768.jpg",
      "assets/imagenes/puntos/casa-juana-c-de-salduna/Screenshot_1776823770.jpg",
    ],
    direccion: "Urquiza 862",
    descripcion:
        "Vivienda de estilo eclectico, entre medianeras, organizada en dos plantas. Fachada plana con molduras, almohadillados, balcón con mensulas y balaustradas en el remate. Planta funcional y racional con acceso para cochera/consultorios y otro para la vivienda. Antecedentes: Aunque es de 1930 (primer período de Martínez), se aparta de la modernidad en la fachada con recursos eclecticos pero mantiene organización funcional. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.393168,
    lng: -58.01734,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=28',
        referencia: 'Ficha de la obra, páginas 28–29 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-sarli",
    nombre: "Casa Sarli",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-sarli/Screenshot_1776823868.jpg",
      "assets/imagenes/puntos/casa-sarli/Screenshot_1776823871.jpg",
      "assets/imagenes/puntos/casa-sarli/Screenshot_1776823872.jpg",
    ],
    direccion: "La Rioja y Carriego",
    descripcion:
        "Edificio moderno: viviendas en planta superior y locales comerciales en planta baja; ubicado sobre la peatonal. Antecedentes: Conjunto de viviendas colectivas con locales de fines de los anos '20 que acompanaron el desarrollo del centro. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.394913,
    lng: -58.018331,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=58',
        referencia: 'Ficha de la obra, páginas 58–59 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-bardengo",
    nombre: "Casa Bardengo",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-bardengo/Screenshot_1776823505.jpg",
      "assets/imagenes/puntos/casa-bardengo/Screenshot_1776823508.jpg",
      "assets/imagenes/puntos/casa-bardengo/Screenshot_1776823509.jpg",
    ],
    direccion: "Hipólito Yrigoyen y Bernardo de Irigoyen",
    descripcion:
        "Edificio moderno en esquina, con viviendas en planta superior y locales en planta baja. Fachada con elementos Art-Deco, recta y con balcones salientes con reja metálica. Forma conjunto urbano con la Casa Cobelli (enfrente). Antecedentes: Construida en 1926; conjunto importante con Cobelli en esquina céntrica. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.394078,
    lng: -58.018077,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=30',
        referencia: 'Ficha de la obra, páginas 30–31 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-cobelli",
    nombre: "Casa Cobelli",
    direccion: "Entre Ríos 800",
    descripcion:
        "Edificio moderno de tipología viviendas (planta alta) + locales (planta baja). Enfrentada a las viviendas Bardengo, generando un espacio urbano interesante. Antecedentes: Construida en 1926; conjunto urbano con la Casa Bardengo; la planta posibilita nuevas formas de vida y relación social (sistematización de espacios). Declaratorias: Propiedad de Interés Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-cobelli/Screenshot_1776823612.jpg",
      "assets/imagenes/puntos/casa-cobelli/Screenshot_1776823614.jpg",
      "assets/imagenes/puntos/casa-cobelli/Screenshot_1776823615.jpg",
    ],
    lat: -31.394185,
    lng: -58.018136,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=52',
        referencia: 'Ficha de la obra, páginas 52–53 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-minones",
    nombre: "Casa Miñones",
    urlsImagenes: ["assets/imagenes/puntos/casa-miñones/casa_minones_main.jpg"],
    direccion: "Urquiza 685",
    descripcion:
        "Vivienda moderna perteneciente al primer período de Alejo Martínez. Presenta características del racionalismo con plantas funcionales y organización racional de los espacios. Construida por Alejandro Pipolo. Antecedentes: Propietarios originales María Estela Otano e Isaías Miñones. Forma parte del conjunto de obras que introdujeron las ideas vanguardistas en Concordia. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.39626,
    lng: -58.017478,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=34',
        referencia: 'Ficha de la obra, páginas 34–35 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-artaghnan",
    nombre: "Casa Artaghnan",
    direccion: "Entre Ríos y Avellaneda",
    descripcion:
        "Vivienda de corte racionalista construida en 1930, despojada de toda ornamentación. Los esquemas de viviendas son compactos, con existencia de planta alta, aparecen terrazas, las plantas son funcionales y en muchos casos incluyen espacios para actividad profesional. Pertenece al primer período de Alejo Martínez en Concordia. Antecedentes: Construida para Juan Artaghnan. Actualmente modificada por intervención realizada en año 2000. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.389694,
    lng: -58.01715,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=26',
        referencia: 'Ficha de la obra, páginas 26–27 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-hourcades",
    nombre: "Casa Hourcades",
    direccion: "Entre Ríos 700",
    descripcion:
        "Vivienda entre medianeras, donde tiene un acceso único, vehicular y peatonal, hacia un hall que distribuye al estar de planta baja, y a la escalera central. En planta alta se localizan dormitorios y baño. La vivienda se desarrolla entre medianeras en lote de 11 m. Posee balcones salientes, con una escasa ornamentación, con barandas metálicas. Antecedentes: Construida para Oscar Hourcades, pertenece al primer período de Alejo Martínez. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.398652,
    lng: -58.020334,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=48',
        referencia: 'Ficha de la obra, páginas 48–49 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-benatena",
    nombre: "Casa Beñatena",
    direccion: "Pellegrini 650",
    descripcion:
        "Vivienda que reitera la tipología de casa y consultorio. Posee un acceso vehicular y a la vivienda por el mismo lugar, y un acceso a la espera del consultorio. La escalera y área de circulación se ubica en el centro. En planta baja, además de consultorios, posee la actividad social, y en planta alta, dormitorios, baño y un estar íntimo. Repite la pérgola, característica de sus obras. La vivienda se desarrolla entre medianeras en lote de 10 m. Posee 2 balcones salientes con una escasa ornamentación. Antecedentes: Construida para Nicolás Beñatena por Castiglione y Casarino Constructores. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.398804,
    lng: -58.015049,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=44',
        referencia: 'Ficha de la obra, páginas 44–45 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
  ),
  PuntoPatrimonial(
    id: "r1-liga-argentina-prestamos-mutuos",
    nombre: "Liga Argentina de Préstamos Mutuos",
    direccion: "Entre Ríos 487, entre Roque Sáenz Peña y Carriego",
    descripcion:
        "Edificio entre medianeras, originalmente fue sede de la Liga Argentina de Préstamos Mutuos. La fachada es simple, sin ornamentación. La planta de este edificio refleja el desarrollo de las nuevas transformaciones en la forma de vida y la relación social. Estos cambios se manifiestan en la sistematización y modulación de los espacios y las fachadas, y el ordenamiento de las funciones bien definidas. Uso original: viviendas y locales comerciales, según la ficha del catálogo de la UTN.",
    lat: -31.399698,
    lng: -58.019328,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=56',
        referencia: 'Ficha de la obra, páginas 56–57 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión editorial: 29/09/2026. Dirección y uso original cotejados con la UTN.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-fernandez",
    nombre: "Casa Manuel Fernández",
    direccion: "Urquiza y Pellegrini",
    descripcion:
        "Vivienda construida en 1931. Si bien pertenece al 1er período de Alejo Martínez, en está propiedad se aleja de los planteos de los postulados de la modernidad, incorporando en la fachada elementos decorativos del eclecticismo, aunque no así en planta, ya que la misma se organiza de manera funcional y racional. Antecedentes: Construida para Manuel M. Fernández por el constructor Hugo Belli. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.399097,
    lng: -58.020703,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=60',
        referencia: 'Ficha de la obra, páginas 60–61 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-caprio",
    nombre: "Casa Caprio",
    direccion: "Bernardo de Irigoyen 83, entre Sarmiento y San Luis",
    descripcion:
        "Vivienda moderna entre medianeras proyectada por Alejo Martínez (h) para la Familia Caprio. Se desarrolla en dos plantas sobre un lote de 11,62 m de frente, con ingreso peatonal y vehicular mediante un receso de fachada que genera un hall semicubierto. Presenta fachada recta de textura lisa, planos simples y ausencia de ornamentación; el único elemento saliente es un balcón. Uso original y actual: vivienda.",
    lat: -31.397248,
    lng: -58.020636,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=66',
        referencia: 'Ficha de la obra, páginas 66–67 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
  ),
  PuntoPatrimonial(
    id: "r1-casilla-juez-de-raya",
    nombre: "Casilla del Juez de Raya",
    direccion: "Hipódromo de Concordia",
    descripcion:
        "Construcción de doble planta en el hipódromo, con una planta oval que rememora el trazado del hipódromo. Posee una escalera caracol en uno de sus extremos. De corte racionalista, despojada de toda ornamentación, se observa con la misma implantación y en intactas condiciones en su conjunto. Planos simples en fachadas, sin ornamentación. Antecedentes: Construida en 1931, pertenece al primer período de Alejo Martínez. Se encuentra en el Hipódromo de Concordia, Barrio Cambá Paso. Declaratorias: Propiedad de Interés Municipal.",
    lat: -31.361992,
    lng: -58.06508,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=68',
        referencia: 'Ficha de la obra, páginas 68–69 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-masvernat",
    nombre: "Casa Masvernat",
    direccion: "Mitre 259",
    descripcion:
        "Conjunto Suburo, Masvernat y Woolmer - Casa Suburo (Mitre 237, 1929), Casa Masvernat (Mitre 259, 1931) y Casa Woolmer (Mitre 271, 1930). Permiten observar la evolución estilística y funcional de Alejo Martínez en una misma calle.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-masvernat/Screenshot_1776823895.jpg",
      "assets/imagenes/puntos/casa-masvernat/Screenshot_1776823897.jpg",
      "assets/imagenes/puntos/casa-masvernat/Screenshot_1776825150.jpg",
    ],
    lat: -31.3977437,
    lng: -58.012836,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=40',
        referencia: 'Ficha de la obra, páginas 40–41 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión editorial: 29/09/2026. Identificación de las fotografías cotejada con la ficha de la UTN.',
    procedenciaImagenes:
        'Fotografías del catálogo local: autoría y fecha de las capturas no documentadas. Plano de ubicación: catálogo de la UTN, página 41 del PDF.',
  ),
  PuntoPatrimonial(
    id: "r1-casa-woolmer",
    nombre: "Casa Woolmer",
    direccion: "Mitre 271",
    descripcion:
        "Conjunto Suburo, Masvernat y Woolmer - Casa Suburo (Mitre 237, 1929), Casa Masvernat (Mitre 259, 1931) y Casa Woolmer (Mitre 271, 1930). Permiten observar la evolución estilística y funcional de Alejo Martínez en una misma calle.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-woolmer/Screenshot_1776825171.jpg",
      "assets/imagenes/puntos/casa-woolmer/Screenshot_1776825173.jpg",
      "assets/imagenes/puntos/casa-woolmer/Screenshot_1776825176.jpg",
    ],
    lat: -31.3979589,
    lng: -58.0115003,
    fuentes: [
      FuentePatrimonial(
        titulo: tituloCatalogoAlejo,
        url: '$urlCatalogoAlejo#page=42',
        referencia: 'Ficha de la obra, páginas 42–43 del PDF.',
      ),
    ],
    revisionEditorial:
        'Revisión ortográfica: 29/09/2026. Datos históricos pendientes de cotejo.',
    procedenciaImagenes:
        'Fotografías del catálogo local. Autoría y fecha de las capturas no documentadas.',
  ),
];

// Alias para compatibilidad
const List<PuntoPatrimonial> puntosAlejo = [
  ...recorridoInnovacionAlejoMartinez,
];
