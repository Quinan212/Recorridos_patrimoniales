import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recorridos_patrimoniales/datos/datos_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/pantalla_inicio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_inicio_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_info_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_publicacion.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_publicaciones.dart';

class _PublicacionesDePrueba extends RepositorioPublicaciones {
  @override
  List<Publicacion> get publicaciones => [
    ...publicacionesAlejo,
    Publicacion(
      id: 'tarjeta-larga',
      titulo: 'Presentación con un título largo que necesita varias líneas',
      nombreEvento:
          'Actividad interinstitucional con un nombre de evento largo',
      descripcion:
          'Una descripción extensa para comprobar que el enlace y '
          'la cantidad de fotos siguen dentro de la tarjeta con letras grandes.',
      fechaEvento: DateTime(2026, 9),
      urlsImagenes: List.filled(
        20,
        publicacionesAlejo.first.urlsImagenes.first,
      ),
    ),
  ];
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
    GoogleFonts.config.allowRuntimeFetching = false;
    // Tipografías reales: evita depender de la red y conserva las medidas de texto.
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => Directory('test/fixtures/fonts').absolute.path,
    );
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final pantallas = <String, Widget Function()>{
    'Inicio': () => const PantallaInicio(),
    'Descubrir': () => PantallaInicioAlejo(),
    'Info': () => const PantallaInfoAlejo(),
    'Publicaciones': () => const PantallaPublicaciones(),
    'Detalle de publicación': () =>
        PantallaDetallePublicacion(publicacion: publicacionesAlejo[1]),
  };

  for (final size in [const Size(411, 891), const Size(320, 568)]) {
    for (final escala in [1.0, 2.0]) {
      for (final pantalla in pantallas.entries) {
        testWidgets('${pantalla.key}, $size, texto $escala', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.runAsync(() async {
            await tester.pumpWidget(
              MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => RepositorioPatrimonio(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) =>
                        _PublicacionesDePrueba() as RepositorioPublicaciones,
                  ),
                ],
                child: MaterialApp(
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(escala)),
                    child: child!,
                  ),
                  home: Scaffold(body: pantalla.value()),
                ),
              ),
            );
            await GoogleFonts.pendingFonts();
          });
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          if (pantalla.key == 'Info') {
            final bibliografia = find.byType(ExpansionTile);
            await tester.ensureVisible(bibliografia);
            await tester.pumpAndSettle();
            await tester.tap(bibliografia);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }

          final vertical = find.byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          );
          if (vertical.evaluate().isNotEmpty) {
            final scrollable = tester.state<ScrollableState>(vertical.first);
            // Revisa también contenido que la lista crea recién al desplazarse.
            for (var step = 0; step < 40; step++) {
              final position = scrollable.position;
              if (position.pixels >= position.maxScrollExtent) break;
              position.jumpTo(
                (position.pixels + size.height * 0.65).clamp(
                  0.0,
                  position.maxScrollExtent,
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
          }
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}
