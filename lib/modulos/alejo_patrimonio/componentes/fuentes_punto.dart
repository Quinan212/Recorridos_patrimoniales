import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:url_launcher/url_launcher.dart';

class FuentesPunto extends StatelessWidget {
  const FuentesPunto({super.key, required this.punto});

  final PuntoPatrimonial punto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FUENTES Y CRÉDITOS',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 10),
        if (punto.fuentes.isEmpty)
          const Text('Fuente histórica no documentada para esta ficha.'),
        for (final fuente in punto.fuentes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fuente.titulo),
                const SizedBox(height: 4),
                Text(fuente.referencia),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () async {
                    final uri = Uri.tryParse(fuente.url);
                    if (uri == null ||
                        !['http', 'https'].contains(uri.scheme)) {
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      if (await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        return;
                      }
                    } catch (_) {
                      // Conserva la referencia legible aunque no haya navegador.
                    }
                    if (context.mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir la fuente.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Consultar fuente'),
                ),
              ],
            ),
          ),
        if (punto.urlsImagenes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            punto.procedenciaImagenes ??
                'Fotografías: autoría y fecha no documentadas.',
          ),
        ],
        if (punto.revisionEditorial != null) ...[
          const SizedBox(height: 8),
          Text(punto.revisionEditorial!),
        ],
      ],
    );
  }
}
