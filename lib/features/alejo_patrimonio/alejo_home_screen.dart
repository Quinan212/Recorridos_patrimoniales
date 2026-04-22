import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/alejo_map_screen.dart';

class AlejoHomeScreen extends StatelessWidget {
  const AlejoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://i.postimg.cc/XJ658GS4/wqeqwe.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'ALEJO\nMARTÍNEZ',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
                  const SizedBox(height: 20),
                  Container(
                    height: 4,
                    width: 60,
                    color: const Color(0xFFD32F2F),
                  ).animate().scaleX(delay: 400.ms),
                  const SizedBox(height: 20),
                  Text(
                    'LA VANGUARDIA\nRACIONALISTA EN\nCONCORDIA',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  const Spacer(),
                  _buildRouteCard(
                    context,
                    title: 'RUTA DE LA INNOVACIÓN',
                    subtitle: 'Obras fundacionales (1925-1930)',
                    count: '24 Puntos Clave',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlejoMapScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EDICIÓN 2026',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Icon(
                        Icons.architecture,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ).animate().fadeIn(delay: const Duration(seconds: 1)).slideY(begin: 0.1),
    );
  }
}
