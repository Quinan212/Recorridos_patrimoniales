import 'package:flutter_test/flutter_test.dart';
import 'package:recorridos_patrimoniales/compartido/busqueda_inteligente.dart';

void main() {
  test('normaliza tildes y separadores del texto buscado', () {
    expect(
      normalizarTextoBusqueda('Casa Pendóla Díaz / 1929'),
      'casa pendola diaz 1929',
    );
  });

  test('tolera un error de escritura y prioriza todos los tokens', () {
    expect(
      puntuarTextoBusqueda('racionlista', 'obra racionalista'),
      greaterThanOrEqualTo(22),
    );
    expect(
      puntuarTextoBusqueda(
        'casa pendola',
        'Casa del Dr. Pendola Diaz, vivienda racionalista',
      ),
      greaterThan(100),
    );
  });
}
