import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/datos/datos_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_publicaciones.dart';

void main() {
  test('carga puntos y avisa al entrar y salir del estado de carga', () async {
    final respuesta = Completer<List<Map<String, dynamic>>>();
    final repo = RepositorioPatrimonio(cargarFilas: () => respuesta.future);
    addTearDown(repo.dispose);
    final estados = <bool>[];
    repo.addListener(() => estados.add(repo.estaCargando));
    final carga = repo.cargar();
    expect(repo.estaCargando, isTrue);
    expect(repo.puntos, puntosAlejo);
    respuesta.complete([
      {
        'id': 'obra-remota',
        'name': 'Obra recibida',
        'address': 'Calle 123',
        'description': 'Descripción remota',
        'lat': -31.39,
        'lng': -58.01,
        'image_urls': <String>[],
      },
    ]);
    await carga;
    expect(repo.puntos.single.nombre, 'Obra recibida');
    expect(repo.puntos.single.urlsImagenes, isEmpty);
    expect(
      repo.puntos.single.fuentes,
      isEmpty,
    ); // No atribuir fuentes a un texto remoto.
    expect(estados, [true, false]);
  });

  test('puntos: una respuesta vacía conserva el catálogo local', () async {
    final repo = RepositorioPatrimonio(cargarFilas: () async => []);
    addTearDown(repo.dispose);
    await repo.cargar();
    expect(repo.puntos, puntosAlejo);
    expect(repo.estaCargando, isFalse);
  });

  test('puntos: fallo de conexión recupera el respaldo local', () async {
    final repo = RepositorioPatrimonio(
      cargarFilas: () async => throw StateError('Sin conexión'),
    );
    addTearDown(repo.dispose);
    await repo.cargar();
    expect(repo.puntos, puntosAlejo);
    expect(repo.estaCargando, isFalse);
  });

  test('puntos: una fila incompleta no deja la carga bloqueada', () async {
    final repo = RepositorioPatrimonio(
      cargarFilas: () async => [
        {'id': 'incompleto'},
      ],
    );
    addTearDown(repo.dispose);
    await repo.cargar();
    expect(repo.puntos, puntosAlejo);
    expect(repo.estaCargando, isFalse);
  });

  test('publicaciones: carga contenido válido sin fotografías', () async {
    final repo = RepositorioPublicaciones(
      cargarFilas: () async => [
        {
          'id': 'nueva',
          'title': 'Nueva publicación',
          'event_date': '2026-09-29',
        },
      ],
    );
    addTearDown(repo.dispose);
    await repo.cargar();
    expect(repo.publicaciones.single.titulo, 'Nueva publicación');
    expect(repo.publicaciones.single.urlsImagenes, isEmpty);
    expect(repo.estaCargando, isFalse);
  });

  for (final falla in [false, true]) {
    test(
      'publicaciones: respaldo ante ${falla ? 'error de conexión' : 'respuesta vacía'}',
      () async {
        final repo = RepositorioPublicaciones(
          cargarFilas: () async {
            if (falla) throw StateError('Sin conexión');
            return [];
          },
        );
        addTearDown(repo.dispose);
        await repo.cargar();
        expect(repo.publicaciones, publicacionesAlejo);
        expect(repo.estaCargando, isFalse);
      },
    );
  }
}
