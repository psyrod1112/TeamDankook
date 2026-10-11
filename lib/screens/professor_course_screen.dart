import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/team_tabs.dart';
import 'professor_team_screen.dart';

/// 교수가 과목을 눌렀을 때 보는 화면: 평가 기간 스위치 + 팀 목록
class ProfessorCourseScreen extends StatelessWidget {
  final Course course;
  const ProfessorCourseScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DkColors.primary,
        foregroundColor: Colors.white,
        title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const PreviewBanner(text: '교수 기능은 개발 순서 5·7단계에서 열려요. 지금은 뼈대예요.'),
              const SizedBox(height: 16),

              // 팀 간 평가 기간 (5단계)
              // TODO(5단계): 열고 닫은 시각을 기록하고, 닫히면 학생 평가는 수정 불가
              DkCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwitchListTile(
                  value: false,
                  onChanged: null,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('팀 간 평가 기간 열기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DkColors.ink)),
                  subtitle: const Text('켜면 학생들이 다른 팀을 평가할 수 있어요 · 5단계', style: TextStyle(fontSize: 12.5)),
                ),
              ),

              // 이번 주 요약
              const DkCard(
                child: Row(
                  children: [
                    _Summary(label: '승인 대기 리포트', value: '--'),
                    _Summary(label: '이번 주 제출률', value: '--'),
                    _Summary(label: '새 메시지', value: '--'),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 10),
                child: Text('팀 목록', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DkColors.muted)),
              ),
              for (var i = 0; i < course.teamCount; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProfessorTeamScreen(course: course, teamNo: i + 1)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: DkColors.line),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: DkColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, color: DkColors.primary)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text('${i + 1}조', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DkColors.ink)),
                            ),
                            const StatusChip(label: '리포트 대기', color: DkColors.muted, dot: false),
                            const Icon(Icons.chevron_right_rounded, color: DkColors.muted),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String label;
  final String value;
  const _Summary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: DkColors.primary)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: DkColors.muted)),
        ],
      ),
    );
  }
}
