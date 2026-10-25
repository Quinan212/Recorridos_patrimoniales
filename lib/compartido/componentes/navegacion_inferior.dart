import 'package:flutter/material.dart';

class NavegacionInferiorApp extends StatelessWidget {
  final int current;
  final VoidCallback onTapInicio, onTapDescubrir, onTapMapa, onTapInfo;

  const NavegacionInferiorApp({
    super.key,
    required this.current,
    required this.onTapInicio,
    required this.onTapDescubrir,
    required this.onTapMapa,
    required this.onTapInfo,
  });

  static const _accent = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black.withValues(alpha: .10),
              width: .5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth / 4;
                return Stack(
                  children: [
                    Row(
                      children: [
                        _item(
                          0,
                          Icons.home_outlined,
                          Icons.home_rounded,
                          'Inicio',
                          onTapInicio,
                        ),
                        _item(
                          1,
                          Icons.explore_outlined,
                          Icons.explore_rounded,
                          'Descubrir',
                          onTapDescubrir,
                        ),
                        _item(
                          2,
                          Icons.map_outlined,
                          Icons.map_rounded,
                          'Mapa',
                          onTapMapa,
                        ),
                        _item(
                          3,
                          Icons.info_outline,
                          Icons.info_rounded,
                          'Info',
                          onTapInfo,
                        ),
                      ],
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      top: 0,
                      left: width * current + (width - 32) / 2,
                      child: Container(
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
    VoidCallback onTap,
  ) {
    final selected = current == index;
    final color = selected ? _accent : const Color(0xFF565956);
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          key: ValueKey('navegacion-$index'),
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? selectedIcon : icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: color,
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
