class PatrimonioPoint {
  final String id;
  final String name;
  final String address;
  final String description;
  final List<String> imageUrls;
  final String? audioUrl;
  final double lat;
  final double lng;

  const PatrimonioPoint({
    required this.id,
    required this.name,
    this.address = "",
    this.description = "",
    this.imageUrls = const [],
    this.audioUrl,
    required this.lat,
    required this.lng,
  });
}

// ======== RUTA 1: ALEJO MARTÍNEZ (22 Puntos del KML) ========
const List<PatrimonioPoint> ruta1AlejoMartinez = [
  PatrimonioPoint(
    id: "r1-casa-de-bernardino-horne",
    name: "Casa de Bernardino Horne",
    address: "Pellegrini y 3 de Febrero",
    imageUrls: [
      "https://i.postimg.cc/MGbqqVCn/horne-2.jpg",
      "https://i.postimg.cc/qR1rC0M0/horne.jpg",
      "https://i.postimg.cc/vBYMBDy3/horne-3.jpg",
    ],
    lat: -31.391451,
    lng: -58.015167,
  ),
  PatrimonioPoint(
    id: "r1-casa-juan-antonio-castro",
    name: "Casa Juan Antonio Castro",
    address: "Pellegrini y 3 de Febrero",
    imageUrls: ["https://i.postimg.cc/nLtpy0P8/castro.jpg"],
    lat: -31.391711,
    lng: -58.015413,
  ),
  PatrimonioPoint(
    id: "r1-casa-del-dr-pendola-diaz",
    name: "Casa del Dr. Péndola Diaz",
    address: "Güemes entre San Luis y Entre Ríos",
    description: "Considerada la primera obra moderna de Argentina (1925).",
    imageUrls: [
      "https://i.postimg.cc/4NmfVK90/Casa-del-Dr-P-ndola-D-az-3.jpg",
      "https://i.postimg.cc/66H68VyR/Casa-del-Dr-P-ndola-D-az-2.jpg",
      "https://i.postimg.cc/jdmsXs6S/Casa-del-Dr-P-ndola-D-az.jpg",
    ],
    lat: -31.393054,
    lng: -58.018508,
  ),
  PatrimonioPoint(
    id: "r1-casa-dr-orlando-marcone",
    name: "Casa Dr. Orlando Marcone",
    address: "V. Sarsfield y San Luis",
    imageUrls: ["https://i.postimg.cc/J0gWPqk2/Marcone.jpg"],
    lat: -31.393915,
    lng: -58.019084,
  ),
  PatrimonioPoint(
    id: "r1-casa-alberto-crossa",
    name: "Casa Alberto Crossa",
    address: "San Luis y Entre Ríos",
    lat: -31.39553,
    lng: -58.018322,
  ),
  PatrimonioPoint(
    id: "r1-casa-arcioni",
    name: "Casa Arcioni",
    address: "Urquiza y San Luis",
    imageUrls: ["https://i.postimg.cc/bJpYt3x0/Arcioni.jpg"],
    lat: -31.396703,
    lng: -58.018683,
  ),
  PatrimonioPoint(
    id: "r1-banco-popular-de-concordia",
    name: "Banco Popular de Concordia",
    address: "Urquiza y Mitre",
    description: "Sede del antiguo Banco Popular.",
    lat: -31.396869,
    lng: -58.01767,
  ),
  PatrimonioPoint(
    id: "r1-casa-dr-camano",
    name: "Casa Dr. Camaño",
    address: "La Rioja y Mitre",
    imageUrls: [
      "https://i.postimg.cc/0QnkdDnT/Casa-Dr-Cama-o.jpg",
      "https://i.postimg.cc/x8d0s8Fc/cama-o.jpg",
    ],
    lat: -31.397376,
    lng: -58.014552,
  ),
  PatrimonioPoint(
    id: "r1-casa-suburo",
    name: "Casa Suburo",
    address: "Mitre 237",
    imageUrls: ["https://i.postimg.cc/Xvw7qTC7/Suburo.jpg"],
    lat: -31.397619,
    lng: -58.013872,
  ),
  PatrimonioPoint(
    id: "r1-casa-juana-c-de-salduna",
    name: "Casa Juana C. de Salduna",
    address: "Urquiza 862",
    lat: -31.393168,
    lng: -58.01734,
  ),
  PatrimonioPoint(
    id: "r1-casa-sarli",
    name: "Casa Sarli",
    address: "La Rioja y Carriego",
    lat: -31.394913,
    lng: -58.018331,
  ),
  PatrimonioPoint(
    id: "r1-casa-bardengo",
    name: "Casa Bardengo",
    address: "Hipólito Yrigoyen y Bernardo de Irigoyen",
    lat: -31.394078,
    lng: -58.018077,
  ),
  PatrimonioPoint(
    id: "r1-casa-cobelli",
    name: "Casa Cobelli",
    address: "Entre Ríos 800",
    imageUrls: ["https://i.postimg.cc/vZnG2pXL/Cobelli.jpg"],
    lat: -31.394185,
    lng: -58.018136,
  ),
  PatrimonioPoint(
    id: "r1-casa-minones",
    name: "Casa Miñones",
    address: "Urquiza 685",
    lat: -31.39626,
    lng: -58.017478,
  ),
  PatrimonioPoint(
    id: "r1-casa-artaghnan",
    name: "Casa Artaghnan",
    address: "Entre Ríos y Avellaneda",
    lat: -31.389694,
    lng: -58.01715,
  ),
  PatrimonioPoint(
    id: "r1-casa-hourcades",
    name: "Casa Hourcades",
    address: "Entre Ríos 700",
    lat: -31.398652,
    lng: -58.020334,
  ),
  PatrimonioPoint(
    id: "r1-casa-benatena",
    name: "Casa Beñatena",
    address: "Pellegrini 650",
    lat: -31.398804,
    lng: -58.015049,
  ),
  PatrimonioPoint(
    id: "r1-liga-argentina-prestamos-mutuos",
    name: "Liga Argentina de Préstamos Mutuos",
    address: "Buenos Aires 100",
    lat: -31.399698,
    lng: -58.019328,
  ),
  PatrimonioPoint(
    id: "r1-casa-fernandez",
    name: "Casa Manuel Fernández",
    address: "Urquiza y Pellegrini",
    lat: -31.399097,
    lng: -58.020703,
  ),
  PatrimonioPoint(
    id: "r1-casa-caprio",
    name: "Casa Caprio",
    address: "Pellegrini y Entre Ríos",
    lat: -31.397248,
    lng: -58.020636,
  ),
  PatrimonioPoint(
    id: "r1-casilla-juez-de-raya",
    name: "Casilla del Juez de Raya",
    address: "Hipódromo de Concordia",
    lat: -31.361992,
    lng: -58.06508,
  ),
];

// Alias para compatibilidad
const List<PatrimonioPoint> alejoPoints = [...ruta1AlejoMartinez];
