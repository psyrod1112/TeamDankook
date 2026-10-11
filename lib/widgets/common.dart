import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 아직 만들지 않은 기능 자리. 개발 순서 몇 단계에서 열리는지 알려줘요.
class ComingSoonPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String step;
  final Widget? child;

  const ComingSoonPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.step,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: DkColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: DkColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: DkColors.ink),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: DkColors.muted, height: 1.55),
            ),
            const SizedBox(height: 16),
            StepChip(step: step),
            if (child != null) ...[const SizedBox(height: 24), child!],
          ],
        ),
      ),
    );
  }
}

/// 나중에 실제 데이터가 들어갈 회색 막대 (뼈대)
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const SkeletonBox({super.key, required this.width, this.height = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DkColors.line,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

/// "개발 순서 N단계" 꼬리표
class StepChip extends StatelessWidget {
  final String step;
  const StepChip({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DkColors.sky.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.construction_rounded, size: 14, color: DkColors.primary),
          const SizedBox(width: 6),
          Text('개발 순서 $step', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DkColors.primary)),
        ],
      ),
    );
  }
}

/// 작은 상태 꼬리표 (팀플 진행 중, 팀플 없음 등)
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;
  const StatusChip({super.key, required this.label, required this.color, this.dot = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

/// 이름 두 글자로 만든 동그란 프로필
class MemberAvatar extends StatelessWidget {
  final String name;
  final int index;
  final double radius;
  const MemberAvatar({super.key, required this.name, required this.index, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    final short = name.length >= 2 ? name.substring(name.length - 2) : name;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: radius - 1.5,
        backgroundColor: DkColors.avatar[index % DkColors.avatar.length],
        child: Text(short, style: TextStyle(fontSize: radius * 0.68, color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// 겹쳐진 팀원 프로필 줄
class MemberStack extends StatelessWidget {
  final List<String> members;
  const MemberStack({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    const r = 14.0;
    const step = 18.0;
    return SizedBox(
      width: r * 2 + step * (members.length - 1),
      height: r * 2,
      child: Stack(
        children: [
          for (var i = 0; i < members.length; i++)
            Positioned(left: step * i, child: MemberAvatar(name: members[i], index: i, radius: r)),
        ],
      ),
    );
  }
}
