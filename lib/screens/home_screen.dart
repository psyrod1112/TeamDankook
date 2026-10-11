import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/logo.dart';
import 'professor_course_screen.dart';
import 'team_space_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider)!;
    final courses = ref.watch(coursesProvider);
    final isStudent = user.role == Role.student;
    final activeCount = courses.where((c) => c.hasTeamProject).length;
    final teamTotal = courses.fold<int>(0, (sum, c) => sum + c.teamCount);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(
              user: user,
              stats: isStudent
                  ? [('수강 과목', '${courses.length}'), ('진행 중인 팀플', '$activeCount')]
                  : [('담당 과목', '${courses.length}'), ('관리 중인 팀', '$teamTotal')],
              onLogout: () => ref.read(authProvider.notifier).logout(),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isStudent ? '내 수강 과목' : '담당 과목',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DkColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isStudent ? '팀플이 있는 과목만 팀 스페이스에 들어갈 수 있어요' : '과목을 눌러 팀 현황을 확인하세요',
                        style: const TextStyle(fontSize: 13, color: DkColors.muted),
                      ),
                      const SizedBox(height: 16),
                      for (final course in courses)
                        _CourseCard(
                          course: course,
                          isStudent: isStudent,
                          onTap: () => _openCourse(context, course, isStudent),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCourse(BuildContext context, Course course, bool isStudent) {
    final Widget page;
    if (isStudent) {
      page = TeamSpaceScreen(course: course, team: mockTeams[course.teamId]!);
    } else {
      page = ProfessorCourseScreen(course: course);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _Header extends StatelessWidget {
  final AppUser user;
  final List<(String, String)> stats;
  final VoidCallback onLogout;
  const _Header({required this.user, required this.stats, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final roleLabel = user.role == Role.student ? '학생' : '교수';
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DkColors.primaryDeep, DkColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const DkLogoMark(size: 40),
                      const SizedBox(width: 10),
                      const DkWordmark(onDark: true),
                      const Spacer(),
                      IconButton(
                        tooltip: '로그아웃',
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '안녕하세요, ${user.name}님',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$roleLabel · ${user.department} · 2026-2학기',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      for (final (label, value) in stats) ...[
                        _StatPill(label: label, value: value),
                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: DkColors.gold, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final bool isStudent;
  final VoidCallback onTap;
  const _CourseCard({required this.course, required this.isStudent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = course.hasTeamProject;
    final teamName = mockTeams[course.teamId]?.name;

    final Widget chip;
    if (!isStudent) {
      chip = StatusChip(label: '팀 ${course.teamCount}개', color: DkColors.primary);
    } else if (enabled) {
      chip = StatusChip(label: '팀플 진행 중 · $teamName', color: DkColors.success);
    } else {
      chip = const StatusChip(label: '팀플 없음', color: DkColors.muted, dot: false);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: DkColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: enabled ? DkColors.primary.withValues(alpha: 0.08) : DkColors.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      course.code,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: enabled ? DkColors.primary : DkColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DkColors.ink)),
                        const SizedBox(height: 3),
                        Text('${course.professor} · ${course.schedule}', style: const TextStyle(fontSize: 13, color: DkColors.muted)),
                        const SizedBox(height: 10),
                        chip,
                      ],
                    ),
                  ),
                  Icon(enabled ? Icons.chevron_right_rounded : Icons.lock_outline_rounded, color: DkColors.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
