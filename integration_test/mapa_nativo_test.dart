import 'dart:math';
import 'dart:convert';
import 'package:recorridos_patrimoniales/main.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componente_reproductor_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/pantalla_mapa_3d.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_punto_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  for (final name in [
    'flutter.baseflow.com/geolocator',
    'flutter.baseflow.com/geolocator_android',
  ]) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel(name),
      (call) async => call.method == 'isLocationServiceEnabled' ? false : null,
    );
  }
  testWidgets('Motor nativo offline: edificios reales, tarjetas, ficha, Casilla y 2D', (
    tester,
  ) async {
    await tester.runAsync(() => initializeDateFormatting('es'));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RepositorioPatrimonio()),
          ChangeNotifierProvider(create: (_) => ControladorAudio()),
        ],
        child: MaterialApp(
          theme: ThemeData(colorSchemeSeed: const Color(0xffd32f2f)),
          home: const NavegacionPrincipal(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('navegacion-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('navegacion-3')), findsOneWidget);
    expect(find.text('Pub.'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('navegacion-3')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Información extra'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('navegacion-2')));
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if ((tester.state(find.byType(PantallaMapa3D)) as dynamic)
              .mapaListoParaPruebas ==
          true) {
        break;
      }
    }
    final dynamic state = tester.state(find.byType(PantallaMapa3D));
    expect(state.mapaListoParaPruebas, true);
    final map = state.controladorParaPruebas as MapLibreMapController;
    await tester.runAsync(
      () =>
          map.waitUntilMapTilesAreLoaded().timeout(const Duration(seconds: 25)),
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.byTooltip('Buscar una casa'), findsOneWidget);
    expect(find.byTooltip('Ver mapa en 2D'), findsOneWidget);
    debugPrint('QA_CAPTURA_CENTRO');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    Future<void> buscar(String query, String title) async {
      await tester.tap(find.byTooltip('Buscar una casa'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byType(TextField), query);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.widgetWithText(ListTile, title));
      for (var i = 0; i < 40; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 100));
        if (find
            .byKey(const ValueKey('tarjeta-patrimonial'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
      }
      await tester.runAsync(
        () => map.waitUntilMapTilesAreLoaded().timeout(
          const Duration(seconds: 25),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(title), findsOneWidget);
      expect(find.text('Ver ficha completa'), findsOneWidget);
    }

    await buscar('Cobelli', 'Casa Cobelli');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    debugPrint(
      'QA_SOURCE: ${await tester.runAsync(() => map.querySourceFeatures('city', 'building', null).then((features) => features.length))}',
    );
    debugPrint(
      'QA_HERITAGE: ${await tester.runAsync(() => map.querySourceFeatures('heritage', null, null).then((features) => features.length))}',
    );
    debugPrint('QA_CAMERA: ${map.cameraPosition}');
    debugPrint('QA_DIAGNOSTICO_COBELLI');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    final camera = map.cameraPosition!;
    expect(camera.target.latitude, closeTo(-31.394185, .000001));
    expect(camera.target.longitude, closeTo(-58.018136, .000001));
    final size = tester.getSize(find.byType(MapLibreMap));
    final buildings = await tester.runAsync(
      () => map.queryRenderedFeaturesInRect(
        Rect.fromLTWH(
          0,
          0,
          size.width * tester.view.devicePixelRatio,
          size.height * tester.view.devicePixelRatio,
        ),
        ['edificios-3d'],
        null,
      ),
    );
    expect(
      buildings,
      isNotEmpty,
      reason: 'Deben dibujarse edificios 3D reales en la vista Android',
    );
    debugPrint('QA_EDIFICIOS_VISIBLES: ${buildings!.length}');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('tarjeta-patrimonial')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    debugPrint('QA_POPUP_COBELLI');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    final cardFinder = find.byKey(const ValueKey('tarjeta-patrimonial'));
    final largeCard = tester.getSize(cardFinder);
    final selectedCamera = map.cameraPosition!;
    for (final zoom in [17.1, 15.8]) {
      await tester.runAsync(
        () => map.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedCamera.target,
              zoom: zoom,
              tilt: selectedCamera.tilt,
              bearing: selectedCamera.bearing,
            ),
          ),
          duration: const Duration(milliseconds: 450),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      final card = tester.getSize(cardFinder);
      expect(card.width, lessThan(largeCard.width));
      expect(card.height, lessThan(largeCard.height));
    }
    final compactCard = tester.getSize(cardFinder);
    expect(compactCard.height, lessThan(largeCard.height * .65));
    expect(
      tester.getSize(find.byTooltip('Cerrar ventana')).height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester
          .getSize(find.widgetWithText(FilledButton, 'Ver ficha completa'))
          .height,
      greaterThanOrEqualTo(44),
    );
    debugPrint(
      'QA_POPUP_COMPACTO: ${largeCard.width}x${largeCard.height} → ${compactCard.width}x${compactCard.height}',
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await tester.tap(find.text('Ver ficha completa'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PantallaDetallePuntoAlejo), findsOneWidget);
    await tester.ensureVisible(find.text('Ver en mapa'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.ensureVisible(find.text('Ver en mapa'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Ver en mapa'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PantallaDetallePuntoAlejo), findsNothing);
    await tester.runAsync(
      () => map.animateCamera(
        CameraUpdate.newCameraPosition(selectedCamera),
        duration: const Duration(milliseconds: 450),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getSize(cardFinder).width, closeTo(largeCard.width, 1));
    expect(tester.getSize(cardFinder).height, closeTo(largeCard.height, 1));
    debugPrint('QA_POPUP_RESTAURADO');
    await tester.tap(find.byTooltip('Cerrar ventana'));
    await tester.pump(const Duration(milliseconds: 300));
    await buscar('Casilla', 'Casilla del Juez de Raya');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(map.cameraPosition!.target.latitude, closeTo(-31.361992, .000001));
    expect(map.cameraPosition!.target.longitude, closeTo(-58.06508, .000001));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    final casillaScreen = await tester.runAsync(
      () => map.toScreenLocation(const LatLng(-31.361992, -58.06508)),
    );
    final casillaFeatures = await tester.runAsync(
      () => map.queryRenderedFeatures(
        Point<double>(casillaScreen!.x.toDouble(), casillaScreen.y.toDouble()),
        ['puntos-circulos'],
        null,
      ),
    );
    expect(casillaFeatures!.any((f) => f['properties']['number'] == 21), true);
    debugPrint('QA_CAPTURA_CASILLA');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 4)),
    );
    await tester.tap(find.byTooltip('Cerrar ventana'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('2D'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('3D'), findsOneWidget);
    await tester.tap(find.text('3D'));
    await tester.pump(const Duration(seconds: 1));
    // Tres paneos a zoom 18/pitch45, iguales al escenario del WebView.
    await tester.runAsync(() async {
      await map.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(-31.394185, -58.018136),
            zoom: 18,
            tilt: 45,
            bearing: -10,
          ),
        ),
      );
      await map.waitUntilMapTilesAreLoaded().timeout(
        const Duration(seconds: 20),
      );
      debugPrint('QA_MOVIMIENTO_INICIO');
      for (final longitude in [-58.0175, -58.0185, -58.018136]) {
        await map.animateCamera(
          CameraUpdate.newLatLng(LatLng(-31.394185, longitude)),
          duration: const Duration(milliseconds: 900),
        );
        await Future<void>.delayed(const Duration(milliseconds: 1000));
      }
      debugPrint('QA_MOVIMIENTO_FIN');
    });
    await tester.pump(const Duration(milliseconds: 200));
    // Fuera de la antigua elipse, dentro del área incluida: no debe volver atrás.
    await tester.runAsync(
      () => map.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(-31.407, -58.012),
            zoom: 18,
            tilt: 45,
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(map.cameraPosition!.target.latitude, closeTo(-31.407, .000001));
    final outside = await tester.runAsync(
      () => map.querySourceFeatures('city', 'building', null),
    );
    expect(outside, isNotEmpty);
    debugPrint('QA_SIN_RECORTE_LOCAL: ${outside!.length}');
    // Sector que no está empaquetado: verificar carga real del proveedor desde Android.
    await tester.runAsync(
      () => map.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(-31.41233684, -58.02993536),
            zoom: 17.5,
            tilt: 40,
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 12)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(map.cameraPosition!.target.latitude, closeTo(-31.41233684, .000001));
    final online = await tester.runAsync(
      () => map.querySourceFeatures('city', 'building', null),
    );
    expect(
      online,
      isNotEmpty,
      reason: 'Sector fuera del paquete local debe cargar por Internet',
    );
    final visibleOnline = await tester.runAsync(
      () => map.queryRenderedFeaturesInRect(
        Rect.fromLTWH(
          0,
          0,
          size.width * tester.view.devicePixelRatio,
          size.height * tester.view.devicePixelRatio,
        ),
        ['edificios-3d'],
        null,
      ),
    );
    expect(
      visibleOnline,
      isNotEmpty,
      reason: 'Los edificios descargados deben verse en pantalla',
    );
    debugPrint('QA_MAPA_CONTINUO_ONLINE: ${online!.length}');
    await tester.tap(find.byKey(const ValueKey('navegacion-3')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Información extra'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('navegacion-2')));
    await tester.pump(const Duration(seconds: 1));
    expect(map.cameraPosition!.target.latitude, closeTo(-31.41233684, .000001));
    debugPrint('QA_CUATRO_PESTANAS_VALIDADAS');
    debugPrint(
      'QA_NATIVO_VALIDADO: ${jsonEncode({'points': 24, 'buildings': buildings.length})}',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
