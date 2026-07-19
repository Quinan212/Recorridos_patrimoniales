import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PantallaInfoAlejo extends StatelessWidget {
  const PantallaInfoAlejo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F3),
      child: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informacion extra',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contexto, fuentes y creditos del proyecto.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // BIOGRAFIA
            _armarTarjeta(
              titulo: 'Arquitecto Alejo Martinez',
              contenido: [
                'Alejo Martinez (hijo) fue un arquitecto uruguayo asociado al primer modernismo rioplatense. Formado en el ambiente academico de Buenos Aires y atento a las vanguardias europeas, traslado esas ideas a la escala domestica con una mirada pragmatica: claridad de planta, economia de recursos y luz natural como criterio rector.',
                'Su etapa decisiva transcurrio en el litoral argentino, especialmente en Concordia, donde proyecto y construyo un conjunto notable de viviendas. Alli ensayo soluciones que reemplazaron la "casa chorizo" por tipologias compactas, con circulaciones mas eficientes y un uso activo de la azotea y la terraza.',
                'El lenguaje arquitectonico de Martinez se reconoce por volumenes puros, desfasajes sobrios, esquinas que se vuelven protagonistas y fachadas sin ornamentos superfluos. No es un formalismo vacio: cada decision responde a clima, asoleamiento, ventilacion y modos de habitar locales.',
                'Su legado es doble: por un lado, introdujo con coherencia el racionalismo a escala barrial; por otro, dejo un mapa tangible de modernidad cotidiana que todavia estructura paisajes urbanos del litoral. Las casas ya no son solo objetos aislados, sino piezas que ordenan esquinas, veredas y recorridos.',
              ],
              contenidoExtra: Column(
                children: [
                  const SizedBox(height: 20),
                  _armarFotoHistorica(
                    'assets/imagenes/arquitecto/alejo_martinez.jpg',
                    'Retrato de Alejo Martinez (h).',
                    esRecurso: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SOBRE EL PROYECTO
            _armarTarjeta(
              titulo: 'Sobre este proyecto',
              contenido: [
                'Este proyecto se realiza con fines educativos y de divulgacion del patrimonio arquitectonico local. Busca visibilizar obras y procesos poco conocidos, de gran valor para la memoria urbana y la cultura, acercando informacion clara y accesible para que mas personas puedan conocer, valorar y preservar estos bienes.',
                'Esta aplicacion interactiva te propone explorar esa obra en contexto. Vas a encontrar cada vivienda geolocalizada, con fotos comparativas, fichas tecnicas, planos esquematicos y claves de lectura para entender que hace "moderna" a cada solucion.',
                'Podes armar tus propios recorridos, filtrar por rasgos (esquinas, terrazas, relieves) y comparar obras para ver como la idea se adapta a cada sitio.',
              ],
            ),

            const SizedBox(height: 24),

            // BIBLIOGRAFIA (Expansion Tile)
            _armarBibliografia(),

            const SizedBox(height: 24),

            // AUTORIA Y CREDITOS
            _armarSeccionCreditos(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _armarTarjeta({
    required String titulo,
    required List<String> contenido,
    Widget? contenidoExtra,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ...contenido.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.6,
                  color: const Color(0xFF4A4A4A),
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          ...switch (contenidoExtra) {
            null => const <Widget>[],
            final child => <Widget>[child],
          },
        ],
      ),
    );
  }

  Widget _armarFotoHistorica(
    String ruta,
    String leyenda, {
    bool esRecurso = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: esRecurso
                ? Image.asset(
                    ruta,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    cacheWidth: 700,
                  )
                : Image.network(
                    ruta,
                    filterQuality: FilterQuality.low,
                    cacheWidth: 700,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Text(
            leyenda,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _armarBibliografia() {
    final List<String> fuentes = [
      '"Arquitectura en Concordia". Revista Nuestra Arquitectura. Ano 3. Nro. 35. Junio, 1932, Buenos Aires.',
      'Ahora Entre Rios. (15 de agosto de 2025). Concordia fue designada como la "Ciudad Art Nouveau 2025 de America". Ahora Entre Rios.',
      'Bertoncello, R.; Castro, H. y Zuman, P. (2003). Turismo y patrimonio: una relacion puesta en cuestion. En: Bertoncello, R. y Carlos, A. F. (Eds.). Procesos Territoriales en Argentina y Brasil. Buenos Aires, Ed. Instituto de Geografia.',
      'Bruno, Maria Alejandra; Caseres, Exequiel y otros. (2019). Arquitectura de Concordia: catalogo de obras patrimoniales. edUTecN',
      'Cammarata, E. B. (2006). El turismo como practica social y su papel en la apropiacion y consolidacion del territorio. En Geraiges de Lemos A. I.; Arroyo, M.; Silveira, M. L. (Eds.) America Latina: cidade, campo e turismo. CLACSO, Sao Paulo.',
      'Carrion, F (2001). Las nuevas tendencias de la urbanizacion en America Latina. En: Carrion, F. (Ed.). La ciudad construida. Urbanismo en America Latina: 7-24. Ecuador, FLACSO.',
      'DailyWeb. (3 de mayo de 2025). El Art Nouveau en Concordia es un testimonio del esplendor urbano de la epoca y de la influencia europea. DailyWeb.',
      'Durham, E. (1998). Cultura, patrimonio y preservacion. Alteridades 8 (16), 131-136.',
      'El legado del arquitecto Alejo Martinez en Concordia, la Capital de la Modernidad, disponible en: https://youtu.be/GKZpXMERMok',
      'Garcia Canclini, N. (1999). Los usos sociales del patrimonio. En: Aguilar Criado, E. (Ed.). Patrimonio etnologico. Nuevas perspectivas de estudio. Andalucia, Consejeria de Cultura de Andalucia.',
      'Gimenez, C. y Navarro, A. (2006). La experiencia moderna en la Argentina, la obra de Alejo Martinez (h). Summa nro. 13, Buenos Aires.',
      'Pipolo, J. A. (2013). Concordia. La ciudad y su arquitectura. 1831-1970. Duograf.',
      'Prats, LL. (2004). Antropologia y patrimonio. Ariel.',
      'Rotman, M. (2015). Procesos patrimoniales: redefiniciones, dinamica y tensiones. Quehaceres 2: 11-26.',
      'Vazquez, M. (2012). El arquitecto Alejo Martinez (hijo). Concordia.',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.menu_book, color: Color(0xFF1A1A1A)),
          title: Text(
            'Bibliografia',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: fuentes
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '-- ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(
                                s,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF4A4A4A),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _armarSeccionCreditos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Autoria y Creditos',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '(c) 2025 Flavia Marisol Frigo & Alan Gabriel Maillet - Autores originales. Todos los derechos reservados.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Este material tiene fines educativos y culturales. Para uso, reproduccion o consultas, comunicate con los autores.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

}
