class PuntoPatrimonial {
  final String id;
  final String nombre;
  final String direccion;
  final String descripcion;
  final List<String> urlsImagenes;
  final String? urlAudio;
  final double lat;
  final double lng;

  const PuntoPatrimonial({
    required this.id,
    required this.nombre,
    this.direccion = "",
    this.descripcion = "",
    this.urlsImagenes = const [],
    this.urlAudio,
    required this.lat,
    required this.lng,
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

// ======== RUTA 1: ALEJO MARTINEZ (23 Puntos del KML) ========
const List<PuntoPatrimonial> recorridoInnovacionAlejoMartinez = [
  PuntoPatrimonial(
    id: "r1-casa-de-bernardino-horne",
    nombre: "Casa de Bernardino Horne",
    direccion: "Pellegrini y 3 de Febrero",
    descripcion:
        "Es una vivienda de estilo moderno, entre medianeras, con un planteo similar a la Casa Pendola Diaz. La fachada es recta y esta totalmente despojada de ornamentacion, presentando un juego de llenos y vacios y un balcon que aparece como una perforacion. El programa incluye dos espacios para atencion al publico con acceso independiente, ademas de la vivienda. Cuenta con terrazas accesibles que posibilitan la expansion de las habitaciones. Antecedentes: Construida en 1930, es una obra de corte racionalista perteneciente al primer periodo de Alejo Martinez en Concordia. Declaratorias: Declarada Propiedad de Interes Municipal.",
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
  ),
  PuntoPatrimonial(
    id: "r1-casa-juan-antonio-castro",
    nombre: "Casa Juan Antonio Castro",
    direccion: "Pellegrini y 3 de Febrero",
    descripcion:
        "Vivienda de estilo moderno en esquina, desarrollada originalmente en dos plantas. La fachada original presentaba planos simples sin ornamentacion. La vivienda diferenciaba claramente las areas de servicio, privada y de recepcion. En 2007, se le anadieron dos niveles superiores totalmente vidriados, alterando su aspecto original. Antecedentes: Construida en 1929, pertenece a la obra racionalista de Alejo Martinez. Declaratorias: Propiedad de Interes Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-juan-antonio-castro/Screenshot_1776823823.jpg",
      "assets/imagenes/puntos/casa-juan-antonio-castro/Screenshot_1776823825.jpg",
      "assets/imagenes/puntos/casa-juan-antonio-castro/Screenshot_1776823827.jpg",
    ],
    lat: -31.391711,
    lng: -58.015413,
  ),
  PuntoPatrimonial(
    id: "r1-casa-del-dr-pendola-diaz",
    nombre: "Casa del Dr. Pendola Diaz",
    direccion: "Guemes entre San Luis y Entre Rios",
    descripcion: "Considerada la primera obra moderna de Argentina (1925).",
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
  ),
  PuntoPatrimonial(
    id: "r1-casa-dr-orlando-marcone",
    nombre: "Casa Dr. Orlando Marcone",
    direccion: "V. Sarsfield y San Luis",
    descripcion:
        "Vivienda moderna en esquina, dos plantas con consultorio. Volumenes salientes en ambas fachadas con influencias vanguardistas; muros exteriores con terminacion escalonada; aleros triangulares; influencias Art-Deco. Distribucion funcional: sociales/consultorio en planta baja y dormitorios arriba. Antecedentes: 1928, primer periodo de Martinez. Declaratorias: Propiedad de Interes Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-dr-orlando-marcone/Screenshot_1776823716.jpg",
      "assets/imagenes/puntos/casa-dr-orlando-marcone/Screenshot_1776823717.jpg",
      "assets/imagenes/puntos/casa-dr-orlando-marcone/Screenshot_1776823719.jpg",
      "assets/imagenes/puntos/casa-dr-orlando-marcone/Screenshot_1776823723.jpg",
    ],
    lat: -31.393915,
    lng: -58.019084,
  ),
  PuntoPatrimonial(
    id: "r1-casa-alberto-crossa",
    nombre: "Casa Alberto Crossa",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-alberto-crossa/Screenshot_1776823452.jpg",
      "assets/imagenes/puntos/casa-alberto-crossa/Screenshot_1776823453.jpg",
      "assets/imagenes/puntos/casa-alberto-crossa/Screenshot_1776823455.jpg",
    ],
    direccion: "San Luis y Entre Rios",
    descripcion:
        "Edificio moderno con tipologia viviendas arriba y locales abajo, sobre la peatonal. Fachada con dos balcones en los extremos y ventanas al centro; planta baja hoy muy intervenida. Antecedentes: Viviendas colectivas con locales de fines de los '20 poblaron el centro. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.39553,
    lng: -58.018322,
  ),
  PuntoPatrimonial(
    id: "r1-casa-alberto-crossa-2",
    nombre: "Casa Alberto Crossa II",
    direccion: "San Luis y Entre Rios",
    descripcion:
        "Segunda vivienda del conjunto Crossa, ubicada muy cerca de la Casa Alberto Crossa. Pertenece al conjunto de obras del primer periodo de Alejo Martinez en Concordia.",
    lat: -31.39561,
    lng: -58.01912,
  ),
  PuntoPatrimonial(
    id: "r1-casa-arcioni",
    nombre: "Casa Arcioni",
    direccion: "Urquiza y San Luis",
    descripcion:
        "Es un amplio local comercial de estilo moderno, ubicado en esquina y desarrollado en dos plantas. La fachada se caracteriza por planos simples y predominio de lineas. Fue la sede de la tradicional tienda Hidalgo Solo. Antecedentes: Pertenece al primer periodo de Alejo Martinez en Concordia (1924-1931). Declaratorias: Declarada Propiedad de Interes Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823475.jpg",
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823476.jpg",
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823478.jpg",
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823480.jpg",
      "assets/imagenes/puntos/casa-arcioni/Screenshot_1776823482.jpg",
    ],
    lat: -31.396703,
    lng: -58.018683,
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
        "Edificio de estilo moderno en esquina, de dos plantas. La fachada presenta lineas rectas y muy poca ornamentacion, excepto en jambas y acceso; cornisa lineal. Actualmente se encuentra muy intervenido por la subdivision en locales. Antecedentes: El banco se fundo en 1917; la remodelacion de Martinez es de 1930. Tras la fusion/cierre, se subdividio en locales comerciales. Declaratorias: Declarada Propiedad de Interes Municipal.",
    lat: -31.396869,
    lng: -58.01767,
  ),
  PuntoPatrimonial(
    id: "r1-casa-dr-camano",
    nombre: "Casa Dr. Camano",
    direccion: "La Rioja y Mitre",
    descripcion:
        "Vivienda de estilo moderno en esquina, desarrollada en dos plantas; fachada recta con planos simples, sin molduras. Zonificacion funcional: recepcion y servicios en planta baja; area privada en planta alta. Un porche en doble altura enmarca el acceso y protege la terraza-balcon. Antecedentes: 1930-1931; primer periodo de Martinez. Declaratorias: Declarada Propiedad de Interes Municipal.",
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
  ),
  PuntoPatrimonial(
    id: "r1-casa-suburo",
    nombre: "Casa Suburo",
    direccion: "Mitre 237",
    descripcion:
        "Conjunto Suburo, Masvernat y Woolmer - Casa Suburo (Mitre 237, 1929), Casa Masvernat (Mitre 259, 1931) y Casa Woolmer (Mitre 271, 1930). Permiten observar la evolucion estilistica y funcional de Alejo Martinez en una misma calle.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-masvernat/Screenshot_1776825146.jpg",
      "assets/imagenes/puntos/casa-masvernat/Screenshot_1776825148.jpg",
      "assets/imagenes/puntos/casa-masvernat/Screenshot_1776825150.jpg",
    ],
    lat: -31.397619,
    lng: -58.013872,
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
        "Vivienda de estilo eclectico, entre medianeras, organizada en dos plantas. Fachada plana con molduras, almohadillados, balcon con mensulas y balaustradas en el remate. Planta funcional y racional con acceso para cochera/consultorios y otro para la vivienda. Antecedentes: Aunque es de 1930 (primer periodo de Martinez), se aparta de la modernidad en la fachada con recursos eclecticos pero mantiene organizacion funcional. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.393168,
    lng: -58.01734,
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
        "Edificio moderno: viviendas en planta superior y locales comerciales en planta baja; ubicado sobre la peatonal. Antecedentes: Conjunto de viviendas colectivas con locales de fines de los anos '20 que acompanaron el desarrollo del centro. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.394913,
    lng: -58.018331,
  ),
  PuntoPatrimonial(
    id: "r1-casa-bardengo",
    nombre: "Casa Bardengo",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-bardengo/Screenshot_1776823505.jpg",
      "assets/imagenes/puntos/casa-bardengo/Screenshot_1776823508.jpg",
      "assets/imagenes/puntos/casa-bardengo/Screenshot_1776823509.jpg",
    ],
    direccion: "Hipolito Yrigoyen y Bernardo de Irigoyen",
    descripcion:
        "Edificio moderno en esquina, con viviendas en planta superior y locales en planta baja. Fachada con elementos Art-Deco, recta y con balcones salientes con reja metalica. Forma conjunto urbano con la Casa Cobelli (enfrente). Antecedentes: Construida en 1926; conjunto importante con Cobelli en esquina centrica. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.394078,
    lng: -58.018077,
  ),
  PuntoPatrimonial(
    id: "r1-casa-cobelli",
    nombre: "Casa Cobelli",
    direccion: "Entre Rios 800",
    descripcion:
        "Edificio moderno de tipologia viviendas (planta alta) + locales (planta baja). Enfrentada a las viviendas Bardengo, generando un espacio urbano interesante. Antecedentes: Construida en 1926; conjunto urbano con la Casa Bardengo; la planta posibilita nuevas formas de vida y relacion social (sistematizacion de espacios). Declaratorias: Propiedad de Interes Municipal.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-cobelli/Screenshot_1776823612.jpg",
      "assets/imagenes/puntos/casa-cobelli/Screenshot_1776823614.jpg",
      "assets/imagenes/puntos/casa-cobelli/Screenshot_1776823615.jpg",
    ],
    lat: -31.394185,
    lng: -58.018136,
  ),
  PuntoPatrimonial(
    id: "r1-casa-minones",
    nombre: "Casa Minones",
    urlsImagenes: ["assets/imagenes/puntos/casa-miñones/casa_minones_main.jpg"],
    direccion: "Urquiza 685",
    descripcion:
        "Vivienda moderna perteneciente al primer periodo de Alejo Martinez. Presenta caracteristicas del racionalismo con plantas funcionales y organizacion racional de los espacios. Construida por Alejandro Pipolo. Antecedentes: Propietarios originales Maria Estela Otano e Isaias Minones. Forma parte del conjunto de obras que introdujeron las ideas vanguardistas en Concordia. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.39626,
    lng: -58.017478,
  ),
  PuntoPatrimonial(
    id: "r1-casa-artaghnan",
    nombre: "Casa Artaghnan",
    direccion: "Entre Rios y Avellaneda",
    descripcion:
        "Vivienda de corte racionalista construida en 1930, despojada de toda ornamentacion. Los esquemas de viviendas son compactos, con existencia de planta alta, aparecen terrazas, las plantas son funcionales y en muchos casos incluyen espacios para actividad profesional. Pertenece al primer periodo de Alejo Martinez en Concordia. Antecedentes: Construida para Juan Artaghnan. Actualmente modificada por intervencion realizada en ano 2000. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.389694,
    lng: -58.01715,
  ),
  PuntoPatrimonial(
    id: "r1-casa-hourcades",
    nombre: "Casa Hourcades",
    direccion: "Entre Rios 700",
    descripcion:
        "Vivienda entre medianeras, donde tiene un acceso unico, vehicular y peatonal, hacia un hall que distribuye al estar de planta baja, y a la escalera central. En planta alta se localizan dormitorios y bano. La vivienda se desarrolla entre medianeras en lote de 11 m. Posee balcones salientes, con una escasa ornamentacion, con barandas metalicas. Antecedentes: Construida para Oscar Hourcades, pertenece al primer periodo de Alejo Martinez. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.398652,
    lng: -58.020334,
  ),
  PuntoPatrimonial(
    id: "r1-casa-benatena",
    nombre: "Casa Benatena",
    direccion: "Pellegrini 650",
    descripcion:
        "Vivienda que reitera la tipologia de casa y consultorio. Posee un acceso vehicular y a la vivienda por el mismo lugar, y un acceso a la espera del consultorio. La escalera y area de circulacion se ubica en el centro. En planta baja, ademas de consultorios, posee la actividad social, y en planta alta, dormitorios, bano y un estar intimo. Repite la pergola, caracteristica de sus obras. La vivienda se desarrolla entre medianeras en lote de 10 m. Posee 2 balcones salientes con una escasa ornamentacion. Antecedentes: Construida para Nicolas Benatena por Castiglione y Casarino Constructores. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.398804,
    lng: -58.015049,
  ),
  PuntoPatrimonial(
    id: "r1-liga-argentina-prestamos-mutuos",
    nombre: "Liga Argentina de Prestamos Mutuos",
    direccion: "Buenos Aires 100",
    descripcion:
        "Edificio entre medianeras, originalmente fue sede de la Liga Argentina de Prestamos Mutuos. La fachada es simple, sin ornamentacion. La planta de este edificio refleja el desarrollo de las nuevas transformaciones en la forma de vida y la relacion social. Estos cambios se manifiestan en la sistematizacion y modulacion de los espacios y las fachadas, y el ordenamiento de las funciones bien definidas. Antecedentes: Uso original vivienda y",
    lat: -31.399698,
    lng: -58.019328,
  ),
  PuntoPatrimonial(
    id: "r1-casa-fernandez",
    nombre: "Casa Manuel Fernandez",
    direccion: "Urquiza y Pellegrini",
    descripcion:
        "Vivienda construida en 1931. Si bien pertenece al 1er periodo de Alejo Martinez, en esta propiedad se aleja de los planteos de los postulados de la modernidad, incorporando en la fachada elementos decorativos del eclecticismo, aunque no asi en planta, ya que la misma se organiza de manera funcional y racional. Antecedentes: Construida para Manuel M. Fernandez por el constructor Hugo Belli. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.399097,
    lng: -58.020703,
  ),
  PuntoPatrimonial(
    id: "r1-casa-caprio",
    nombre: "Casa Caprio",
    direccion: "Bernardo de Irigoyen 83, entre Sarmiento y San Luis",
    descripcion:
        "Vivienda moderna entre medianeras proyectada por Alejo Martinez (h) para la Familia Caprio. Se desarrolla en dos plantas sobre un lote de 11,62 m de frente, con ingreso peatonal y vehicular mediante un receso de fachada que genera un hall semicubierto. Presenta fachada recta de textura lisa, planos simples y ausencia de ornamentacion; el unico elemento saliente es un balcon. Uso original y actual: vivienda.",
    lat: -31.397248,
    lng: -58.020636,
  ),
  PuntoPatrimonial(
    id: "r1-casilla-juez-de-raya",
    nombre: "Casilla del Juez de Raya",
    direccion: "Hipodromo de Concordia",
    descripcion:
        "Construccion de doble planta en el hipodromo, con una planta oval que rememora el trazado del hipodromo. Posee una escalera caracol en uno de sus extremos. De corte racionalista, despojada de toda ornamentacion, se observa con la misma implantacion y en intactas condiciones en su conjunto. Planos simples en fachadas, sin ornamentacion. Antecedentes: Construida en 1931, pertenece al primer periodo de Alejo Martinez. Se encuentra en el Hipodromo de Concordia, Barrio Camba Paso. Declaratorias: Propiedad de Interes Municipal.",
    lat: -31.361992,
    lng: -58.06508,
  ),
  PuntoPatrimonial(
    id: "r1-casa-masvernat",
    nombre: "Casa Masvernat",
    direccion: "Mitre 259",
    descripcion:
        "Conjunto Suburo, Masvernat y Woolmer - Casa Suburo (Mitre 237, 1929), Casa Masvernat (Mitre 259, 1931) y Casa Woolmer (Mitre 271, 1930). Permiten observar la evolucion estilistica y funcional de Alejo Martinez en una misma calle.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-suburo/Screenshot_1776823895.jpg",
      "assets/imagenes/puntos/casa-suburo/Screenshot_1776823897.jpg",
      "assets/imagenes/puntos/casa-suburo/Screenshot_1776823898.jpg",
    ],
    lat: -31.3977437,
    lng: -58.012836,
  ),
  PuntoPatrimonial(
    id: "r1-casa-woolmer",
    nombre: "Casa Woolmer",
    direccion: "Mitre 271",
    descripcion:
        "Conjunto Suburo, Masvernat y Woolmer - Casa Suburo (Mitre 237, 1929), Casa Masvernat (Mitre 259, 1931) y Casa Woolmer (Mitre 271, 1930). Permiten observar la evolucion estilistica y funcional de Alejo Martinez en una misma calle.",
    urlsImagenes: [
      "assets/imagenes/puntos/casa-woolmer/Screenshot_1776825171.jpg",
      "assets/imagenes/puntos/casa-woolmer/Screenshot_1776825173.jpg",
      "assets/imagenes/puntos/casa-woolmer/Screenshot_1776825176.jpg",
    ],
    lat: -31.3979589,
    lng: -58.0115003,
  ),
];

// Alias para compatibilidad
const List<PuntoPatrimonial> puntosAlejo = [
  ...recorridoInnovacionAlejoMartinez,
];
