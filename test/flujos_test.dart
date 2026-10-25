import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio/just_audio.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/main.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componentes/distancia_punto.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componentes/fuentes_punto.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componente_reproductor_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_punto_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_inicio_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_mapa_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/servicio_dispositivo_admin.dart';

class _ReproductorDePrueba extends Fake implements AudioPlayer {
  bool fallar = true;
  int intentos = 0;
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<Duration?> get durationStream => const Stream.empty();
  @override
  Stream<PlayerState> get playerStateStream => const Stream.empty();
  @override
  Future<Duration?> setUrl(
    String url, {
    Map<String, String>? headers,
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async {
    intentos++;
    if (fallar) throw StateError('Audio inaccesible');
    return const Duration(seconds: 10);
  }

  @override
  Future<void> play() async {}
}

class _CatalogoAlternativo extends RepositorioPatrimonio {
  @override
  List<PuntoPatrimonial> get puntos => [puntosAlejo.first];
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late _ReproductorDePrueba reproductor;
  late ControladorAudio audio;
  var servicioUbicacion = false;
  var permiso = 0;
  var consultasPosicion = 0;
  var posicionFalla = false;

  setUpAll(() async {
    await initializeDateFormatting('es');
    GoogleFonts.config.allowRuntimeFetching = false;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => Directory('test/fixtures/fonts').absolute.path,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator'),
      (call) async {
        switch (call.method) {
          case 'isLocationServiceEnabled':
            return servicioUbicacion;
          case 'checkPermission':
          case 'requestPermission':
            return permiso;
          case 'getCurrentPosition':
            consultasPosicion++;
            if (posicionFalla) {
              throw PlatformException(code: 'LOCATION_SERVICES_DISABLED');
            }
            return {
              'latitude': -31.393054,
              'longitude': -58.018508,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'accuracy': 5.0,
              'altitude': 0.0,
              'heading': 0.0,
              'speed': 0.0,
              'speed_accuracy': 0.0,
              'is_mocked': true,
            };
          default:
            return null;
        }
      },
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    reproductor = _ReproductorDePrueba();
    audio = ControladorAudio(reproductor: reproductor);
    servicioUbicacion = false;
    permiso = 0;
    consultasPosicion = 0;
    posicionFalla = false;
  });
  tearDown(() => audio.dispose());

  Future<void> montar(
    WidgetTester tester,
    Widget pantalla, {
    RepositorioPatrimonio? catalogo,
    double escala = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(411, 891);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RepositorioPatrimonio>(
              create: (_) => catalogo ?? RepositorioPatrimonio(),
            ),
            ChangeNotifierProvider<ControladorAudio>.value(value: audio),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(escala)),
              child: child!,
            ),
            home: pantalla,
          ),
        ),
      );
      await GoogleFonts.pendingFonts();
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets(
    'Descubrir no inventa distancias ni atribuye primacía a otra obra',
    (tester) async {
      await montar(
        tester,
        PantallaInicioAlejo(),
        catalogo: _CatalogoAlternativo(),
      );
      await tester.scrollUntilVisible(
        find.text('Obra destacada'),
        300,
        scrollable: find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(find.text('211 m'), findsNothing);
      expect(find.text('610 m'), findsNothing);
      expect(find.text('Primera obra moderna de Argentina'), findsNothing);
      expect(find.text('Obra destacada'), findsOneWidget);
    },
  );

  testWidgets('navegación real y buscador abren una ficha sin fotografía', (
    tester,
  ) async {
    await montar(tester, const NavegacionPrincipal());
    expect(find.text('Pub.'), findsNothing);
    await tester.tap(find.text('Info').last);
    await tester.pumpAndSettle();
    expect(find.text('Información extra'), findsOneWidget);
    await tester.tap(find.text('Inicio').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Publicaciones y eventos'), findsNothing);
    await tester.tap(find.text('Información y fuentes').first);
    await tester.pumpAndSettle();
    expect(find.text('Información extra'), findsOneWidget);
    expect(notificadorIndiceNavegacion.value, 3);
    await tester.tap(find.text('Inicio').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search_rounded).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'liga prestamos');
    await tester.pumpAndSettle();
    expect(find.text('Liga Argentina de Préstamos Mutuos'), findsOneWidget);
    await tester.tap(find.text('Ver ficha').first);
    await tester.runAsync(() async {
      await GoogleFonts.pendingFonts();
    });
    await tester.pumpAndSettle();
    expect(find.byType(PantallaDetallePuntoAlejo), findsOneWidget);
    expect(
      find.text('Entre Ríos 487, entre Roque Sáenz Peña y Carriego'),
      findsOneWidget,
    );
    await tester.tap(find.text('REPRODUCIR AUDIO'));
    await tester.pump();
    expect(find.text('Audio no disponible para este punto'), findsOneWidget);
    expect(reproductor.intentos, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final estado in [
    'GPS apagado',
    'permiso denegado',
    'permiso denegado permanentemente',
  ]) {
    testWidgets('mapa utilizable con $estado, sin distancias falsas', (
      tester,
    ) async {
      servicioUbicacion = estado != 'GPS apagado';
      permiso = estado.endsWith('permanentemente') ? 1 : 0;
      await montar(
        tester,
        const PantallaMapaAlejo(idPuntoInicial: 'r1-casa-suburo'),
      );
      expect(find.text('Ubicación no disponible'), findsOneWidget);
      expect(consultasPosicion, 0);
      expect(find.text('Casa Suburo'), findsWidgets);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'el mapa actualiza el origen real y retira distancias al perder ubicación',
    (tester) async {
      servicioUbicacion = true;
      permiso = 2;
      await montar(
        tester,
        const PantallaMapaAlejo(idPuntoInicial: 'r1-casa-del-dr-pendola-diaz'),
      );
      expect(find.text('≈ 0 m en línea recta'), findsOneWidget);
      expect(consultasPosicion, 1);
      posicionFalla = true;
      // El montaje con fuentes usa runAsync; su temporizador corre en el reloj real.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 3200)),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Ubicación no disponible'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'la distancia y los créditos se adaptan a una columna estrecha y letra grande',
    (tester) async {
      await montar(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 180,
              child: Column(
                children: [
                  const DistanciaPunto(origen: null, destino: LatLng(0, 0)),
                  const DistanciaPunto(
                    origen: LatLng(0, 0),
                    destino: LatLng(0, 0.01),
                  ),
                  FuentesPunto(punto: puntosAlejo[2]),
                ],
              ),
            ),
          ),
        ),
        escala: 2,
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('fallo de audio: avisa, limpia el estado y permite reintentar', (
    tester,
  ) async {
    final casa = puntosAlejo.singleWhere((p) => p.urlAudio != null);
    await montar(tester, PantallaDetallePuntoAlejo(punto: casa));
    await tester.tap(find.text('REPRODUCIR AUDIO'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo reproducir el audio. Intentá nuevamente.'),
      findsOneWidget,
    );
    expect(audio.tieneAudio, isFalse);
    expect(audio.estaReproduciendo, isFalse);
    reproductor.fallar = false;
    await tester.tap(find.text('REPRODUCIR AUDIO'));
    await tester.pump();
    expect(reproductor.intentos, 2);
    expect(audio.urlActual, casa.urlAudio);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
    'sin configuración de servidor el dispositivo no recibe permiso editorial',
    () async {
      final estado = await const ServicioDispositivoAdmin()
          .verificarDispositivoActual();
      expect(estado.esAdmin, isFalse);
    },
  );
}
