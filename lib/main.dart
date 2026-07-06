import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_inicio_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/configuracion_supabase.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componente_reproductor_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_info_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_mapa_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_notificaciones.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final ValueNotifier<int> notificadorIndiceNavegacion = ValueNotifier<int>(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (ConfiguracionSupabase.estaConfigurado) {
    await Supabase.initialize(
      url: ConfiguracionSupabase.url,
      anonKey: ConfiguracionSupabase.anonKey,
    );
  }
  await ServicioAudio().inicializar();
  ServicioNotificaciones().inicializar();
  await initializeDateFormatting('es');
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const AplicacionAlejo());
}

class AplicacionAlejo extends StatelessWidget {
  const AplicacionAlejo({super.key});

  @override
  Widget build(BuildContext context) {
    const fondoAplicacion = Color(0xFFF5F5F3);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ControladorAudio()),
        ChangeNotifierProvider(
          create: (_) => RepositorioPatrimonio()..cargar(),
        ),
        ChangeNotifierProvider(
          create: (_) => RepositorioPublicaciones()..cargar(),
        ),
      ],
      child: MaterialApp(
        title: 'Recorridos Patrimoniales',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF1A1A1A),
          scaffoldBackgroundColor: fondoAplicacion,
          canvasColor: fondoAplicacion,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD32F2F),
            brightness: Brightness.light,
            surface: fondoAplicacion,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: fondoAplicacion,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: fondoAplicacion,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        builder: (context, hija) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Color(0xFFF5F5F3),
              systemNavigationBarIconBrightness: Brightness.dark,
              systemStatusBarContrastEnforced: false,
              systemNavigationBarContrastEnforced: false,
            ),
            child: CapaAudioGlobal(contenido: hija ?? const SizedBox()),
          );
        },
        home: const NavegacionPrincipal(),
      ),
    );
  }
}

class CapaAudioGlobal extends StatelessWidget {
  final Widget contenido;

  const CapaAudioGlobal({super.key, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notificadorIndiceNavegacion,
      builder: (context, indiceSeleccionado, _) {
        final desplazamientoInferior = indiceSeleccionado == 1 ? 95.0 : 60.0;
        return Selector<ControladorAudio, bool>(
          selector: (_, audio) => audio.tieneAudio,
          builder: (context, tieneAudio, _) {
            return Stack(
              children: [
                contenido,
                if (tieneAudio)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: desplazamientoInferior,
                    child: _ComponenteReproductorFlotanteGlobal(),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ComponenteReproductorFlotanteGlobal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = context.watch<ControladorAudio>();
    final double progress = audio.duracion.inMilliseconds > 0
        ? (audio.posicion.inMilliseconds / audio.duracion.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    // DefaultTextStyle nuclear: corta CUALQUIER decoracion heredada del arbol
    // padre (el MaterialApp.builder esta fuera del contexto Material normal,
    // por eso el Text heredaba el underline amarillo del DefaultTextStyle raiz).
    // Material(transparency) reinicia el contexto sin agregar fondo de color.
    return DefaultTextStyle(
      style: const TextStyle(
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
        decorationThickness: 0,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.headphones,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                // Titulo + barra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // -- Titulo sin ningun subrayado --
                      Text(
                        audio.tituloActual ?? 'Audio',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                          decorationColor: Colors.transparent,
                          decorationThickness: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      // -- Barra de progreso: solo Containers, cero tema --
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            height: 3,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD32F2F),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Play / Pause
                GestureDetector(
                  onTap: audio.alternarReproduccionPausa,
                  child: Icon(
                    audio.estaReproduciendo
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 6),
                // Cerrar
                GestureDetector(
                  onTap: audio.detener,
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavegacionPrincipal extends StatefulWidget {
  const NavegacionPrincipal({super.key});

  @override
  State<NavegacionPrincipal> createState() => _NavegacionPrincipalState();
}

class _NavegacionPrincipalState extends State<NavegacionPrincipal> {
  int _indiceSeleccionado = 0;

  @override
  void initState() {
    super.initState();
    notificadorIndiceNavegacion.value = _indiceSeleccionado;
  }

  List<Widget> get _pantallas => [
    const PantallaInicioAlejo(),
    PantallaMapaAlejo(
      onBack: () {
        setState(() {
          _indiceSeleccionado = 0;
        });
        notificadorIndiceNavegacion.value = 0;
      },
    ),
    const PantallaPublicaciones(),
    const PantallaInfoAlejo(),
  ];
  void _alTocarElemento(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
    notificadorIndiceNavegacion.value = indice;
  }

  @override
  Widget build(BuildContext context) {
    const fondoAplicacion = Color(0xFFF5F5F3);

    return Scaffold(
      backgroundColor: fondoAplicacion,
      body: IndexedStack(index: _indiceSeleccionado, children: _pantallas),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: fondoAplicacion,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _indiceSeleccionado,
            onTap: _alTocarElemento,
            backgroundColor: fondoAplicacion,
            elevation: 0,
            selectedItemColor: const Color(0xFF1A1A1A),
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
            ),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: _MarcaAlejoNavegacion(color: Color(0xFFBDBDBD)),
                activeIcon: _MarcaAlejoNavegacion(color: Color(0xFF1A1A1A)),
                label: 'Descubrir',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Mapa',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article),
                label: 'Pub.',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                activeIcon: Icon(Icons.info),
                label: 'Info',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarcaAlejoNavegacion extends StatelessWidget {
  const _MarcaAlejoNavegacion({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'A',
      style: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: color,
        fontStyle: FontStyle.italic,
        height: 1,
      ),
    );
  }
}
