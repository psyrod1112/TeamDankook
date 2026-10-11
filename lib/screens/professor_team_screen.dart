import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/team_tabs.dart';

/// 교수가 팀 하나를 눌렀을 때: AI 리포트 초안 검토·승인, 제출 현황, 비공개 메시지
/// 교수에게도 채팅 원문은 보이지 않아요. 지표와 카테고리만.
class ProfessorTeamScreen extends StatelessWidget {
  final Course course;
  final int teamNo;
  const ProfessorTeamScreen({super.key, required this.course, required this.teamNo});

  static const _members = ['김민준', '이서연', '박지호', '최하은']; // mock

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DkColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$teamNo조', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(course.title, style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
        actions: const [MemberStack(members: _members), SizedBox(width: 16)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const PreviewBanner(text: '리포트 승인은 7단계, 메시지는 5단계에서 열려요.'),
              const SizedBox(height: 16),

              // 1) AI 리포트 초안 검토 (7단계)
              // TODO(7단계): 수정 요청 시 사유 입력, 승인 이력 기록, 승인 전에는 학생에게 비공개
              DkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionTitle(
                      '6주차 기여도 리포트 · AI 초안',
                      trailing: StatusChip(label: '검토 필요', color: Color(0xFFB7791F)),
                    ),
                    for (var i = 0; i < _members.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            MemberAvatar(name: _members[i], index: i, radius: 16),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 56,
                              child: Text(_members[i], style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: DkColors.ink)),
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonBox(width: double.infinity, height: 8), // 점수 막대
                                  SizedBox(height: 6),
                                  SkeletonBox(width: 110, height: 8), // 역할 카테고리
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('--', style: TextStyle(fontWeight: FontWeight.w800, color: DkColors.muted)),
                          ],
                        ),
                      ),
                    const Row(
                      children: [
                        Icon(Icons.visibility_off_outlined, size: 16, color: DkColors.success),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text('채팅 원문은 교수님께도 보이지 않아요. 지표와 역할 카테고리만 표시돼요.',
                              style: TextStyle(fontSize: 12.5, color: DkColors.muted)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: null, child: Text('수정 요청'))),
                        SizedBox(width: 10),
                        Expanded(child: FilledButton(onPressed: null, child: Text('승인하고 공개'))),
                      ],
                    ),
                  ],
                ),
              ),

              // 2) 주차별 제출 현황
              DkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('주차별 제출 현황'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var w = 1; w <= 6; w++)
                          Container(
                            width: 64,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: DkColors.bg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text('$w주', style: const TextStyle(fontSize: 12, color: DkColors.muted)),
                                const SizedBox(height: 4),
                                const Text('-/4', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DkColors.ink)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3) 이 팀 학생들의 비공개 메시지 (5단계)
              DkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('학생 비공개 메시지', trailing: StepChip(step: '5단계')),
                    for (var i = 0; i < 2; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            MemberAvatar(name: _members[i], index: i, radius: 16),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonBox(width: 90),
                                  SizedBox(height: 6),
                                  SkeletonBox(width: double.infinity),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
