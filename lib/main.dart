import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_inicio_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/configuracion_supabase.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componente_reproductor_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_info_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/pantalla_mapa_3d.dart';
import 'package:recorridos_patrimoniales/modulos/pantalla_inicio.dart';
import 'package:recorridos_patrimoniales/compartido/componentes/navegacion_inferior.dart';
import 'package:recorridos_patrimoniales/compartido/componentes/barra_busqueda_morphing.dart';
import 'package:recorridos_patrimoniales/compartido/busqueda_inteligente.dart';
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
          appBarTheme: const AppBarTheme(
            backgroundColor: fondoAplicacion,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        builder: (context, hija) {
          return MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.95,
            maxScaleFactor: 1.10,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
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
            ),
          );
        },
        home: const NavegacionPrincipal(),
        onGenerateRoute: (settings) {
          final uri = Uri.tryParse(settings.name ?? '');
          if (uri?.path != '/mapa') return null;
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) =>
                PantallaMapa3D(idPuntoInicial: uri!.queryParameters['casa']),
          );
        },
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
        final desplazamientoInferior =
            64.0 + MediaQuery.paddingOf(context).bottom;
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
                    child: MediaQuery.withNoTextScaling(
                      child: _ComponenteReproductorFlotanteGlobal(),
                    ),
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
  double _progressBusqueda = 0.0;
  bool _mapaVisitado = false;

  @override
  void initState() {
    super.initState();
    notificadorIndiceNavegacion.value = _indiceSeleccionado;
  }

  List<Widget> get _pantallas => [
    const PantallaInicio(),
    PantallaInicioAlejo(),
    // El visor nativo se crea al entrar a Mapa y conserva la cámara entre pestañas.
    if (_mapaVisitado)
      PantallaMapa3D(onBack: () => _irA(0), activo: _indiceSeleccionado == 2)
    else
      const SizedBox.shrink(),
    const PantallaInfoAlejo(),
  ];

  void _irA(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
      if (indice == 2) _mapaVisitado = true;
      _progressBusqueda = 0.0;
    });
    notificadorIndiceNavegacion.value = indice;
  }

  bool _manejarScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final progress = (notification.metrics.pixels / 60).clamp(0.0, 1.0);
    if ((progress - _progressBusqueda).abs() < 0.01) return false;
    setState(() => _progressBusqueda = progress);
    return false;
  }

  void _abrirBusqueda() {
    showSearch(
      context: context,
      delegate: BusquedaInteligenteDelegate(onOpenSection: _irA),
    );
  }

  @override
  Widget build(BuildContext context) {
    const fondoAplicacion = Color(0xFFF5F5F3);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: fondoAplicacion,
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _manejarScroll,
              child: IndexedStack(
                index: _indiceSeleccionado,
                children: _pantallas,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: MediaQuery.of(context).padding.top,
                color: const Color(0xFFD32F2F),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: _progressBusqueda.clamp(0.0, 1.0),
                  child: Container(
                    height: MediaQuery.of(context).padding.top + 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_indiceSeleccionado != 2)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: BarraBusquedaMorphing(
                  progress: _progressBusqueda,
                  onOpen: _abrirBusqueda,
                ),
              ),
          ],
        ),
        bottomNavigationBar: MediaQuery.withNoTextScaling(
          child: NavegacionInferiorApp(
            current: _indiceSeleccionado,
            onTapInicio: () => _irA(0),
            onTapDescubrir: () => _irA(1),
            onTapMapa: () => _irA(2),
            onTapInfo: () => _irA(3),
          ),
        ),
      ),
    );
  }
}
