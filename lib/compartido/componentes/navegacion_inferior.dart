import 'package:flutter/material.dart';

class NavegacionInferiorApp extends StatelessWidget {
  final int current;
  final VoidCallback onTapInicio;
  final VoidCallback onTapDescubrir;
  final VoidCallback onTapMapa;
  final VoidCallback onTapPub;
  final VoidCallback onTapInfo;

  const NavegacionInferiorApp({
    super.key,
    required this.current,
    required this.onTapInicio,
    required this.onTapDescubrir,
    required this.onTapMapa,
    required this.onTapPub,
    required this.onTapInfo,
  });

  static const _fabDiameter = 54.0;
  static const _fabRadius = _fabDiameter / 2;
  static const _navBodyH = 60.0;
  static const _fabGap = _fabDiameter + 8.0;
  static const _indicatorH = 5.0;
  static const _indicatorW = 36.0;
  static const _accentColor = Color(0xFFD32F2F);
  static const _darkColor = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final bg = const Color(0xFFF5F5F3);
    final brd = Colors.grey.withValues(alpha: 0.2);
    final bodyH = _navBodyH + bottomPad;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: bodyH,
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalW = constraints.maxWidth;
                    final tabW = (totalW - _fabGap) / 4;
                    final left = _indicatorLeft(current, tabW);

                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: bg,
                            border: Border(top: BorderSide(color: brd, width: 0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _item(Icons.home_outlined, 'Inicio', onTapInicio)),
                              Expanded(child: _item(Icons.explore_outlined, 'Descubrir', onTapDescubrir)),
                              const SizedBox(width: _fabGap),
                              Expanded(child: _item(Icons.article_outlined, 'Pub.', onTapPub)),
                              Expanded(child: _item(Icons.info_outline, 'Info', onTapInfo)),
                            ],
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          top: 0,
                          left: left,
                          child: Container(
                            width: _indicatorW,
                            height: _indicatorH,
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: bottomPad),
            ],
          ),
        ),
        Positioned(
          top: -_fabRadius,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onTapMapa,
                  child: Container(
                    width: _fabDiameter,
                    height: _fabDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: bg, width: 3),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mapa',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _darkColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _indicatorLeft(int idx, double tabW) {
    final offset = (tabW - _indicatorW) / 2;
    switch (idx) {
      case 0: return offset;
      case 1: return tabW + offset;
      case 2: return tabW * 2 + _fabGap + offset;
      case 3: return tabW * 3 + _fabGap + offset;
      default: return 0;
    }
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: _navBodyH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: _darkColor),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _darkColor,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
