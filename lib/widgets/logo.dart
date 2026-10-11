import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 팀단국 로고 마크: 남색 타일 위에 TD 이니셜과 그 둘레를 도는 빛의 궤도
class DkLogoMark extends StatelessWidget {
  final double size;
  const DkLogoMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DkColors.sky, DkColors.primary, DkColors.primaryDeep],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: size * 0.02),
        boxShadow: [
          BoxShadow(
            color: DkColors.primaryDeep.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _OrbitPainter(),
        child: Center(
          child: Text(
            'TD',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.42);

    final orbit = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.82,
      height: size.height * 0.4,
    );

    // 희미한 궤도
    canvas.drawOval(
      orbit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.025
        ..color = Colors.white.withValues(alpha: 0.35),
    );

    // 궤도를 따라 도는 빛
    canvas.drawArc(
      orbit,
      -math.pi * 0.95,
      math.pi * 0.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..strokeCap = StrokeCap.round
        ..color = DkColors.gold,
    );

    // 빛의 끝에 있는 별
    const angle = -math.pi * 0.45;
    final star = Offset(
      orbit.width / 2 * math.cos(angle),
      orbit.height / 2 * math.sin(angle),
    );
    canvas.drawCircle(star, size.width * 0.045, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 로고 옆에 붙는 글자 로고
class DkWordmark extends StatelessWidget {
  final bool onDark;
  const DkWordmark({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final main = onDark ? Colors.white : DkColors.ink;
    final sub = onDark ? Colors.white.withValues(alpha: 0.65) : DkColors.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('팀단국', style: TextStyle(color: main, fontSize: 18, fontWeight: FontWeight.w800, height: 1.1)),
        Text('TEAM DANKOOK', style: TextStyle(color: sub, fontSize: 9.5, letterSpacing: 2.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
