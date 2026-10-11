import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'common.dart';

// 아직 기능이 없는 탭은 "뼈대(skeleton)"로 그려 둬요.
// 회색 막대 = 나중에 실제 데이터가 들어갈 자리.
// 개발하면서 고려할 점은 `// TODO(N단계):` 주석과 docs/NOTES.md에 모아 뒀어요.

/// 미리보기임을 알려주는 띠
class PreviewBanner extends StatelessWidget {
  final String text;
  const PreviewBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DkColors.gold.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF8A6200)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B4C00)))),
        ],
      ),
    );
  }
}

/// 흰 카드 공통 모양
class DkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  const DkCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? DkColors.line),
      ),
      child: child,
    );
  }
}

/// 카드 안의 소제목
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DkColors.ink)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 아래쪽 입력창 (비활성)
class DisabledComposer extends StatelessWidget {
  final String hint;
  const DisabledComposer({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: DkColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                filled: true,
                fillColor: DkColors.bg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: null, icon: const Icon(Icons.send_rounded)),
        ],
      ),
    );
  }
}

// ─── 1. 채팅 ─────────────────────────────────────────────

class ChatTab extends StatelessWidget {
  final Team team;
  const ChatTab({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final m = team.members;
    // TODO(3단계): WebSocket 연결, 재연결, 이전 메시지 페이지네이션
    // TODO(3단계): '읽음 1' 표시를 넣을지 결정 (카톡 1 스트레스를 없애는 게 컨셉)
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const PreviewBanner(text: '실시간 채팅은 개발 순서 3단계에서 열려요. 지금은 미리보기예요.'),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: DkColors.line, borderRadius: BorderRadius.circular(99)),
                  child: Text('${team.name} 팀 스페이스가 열렸어요', style: const TextStyle(fontSize: 12, color: DkColors.muted)),
                ),
              ),
              const SizedBox(height: 16),
              ChatBubble(name: m[1], index: 1, text: '안녕하세요! 이번 주 회의 언제 할까요?'),
              const ChatBubble(name: '', index: 0, text: '수요일 수업 끝나고 어때요?', mine: true),
              if (m.length > 2) ChatBubble(name: m[2], index: 2, text: '좋아요, 저는 API 명세 정리해 올게요'),
            ],
          ),
        ),
        const DisabledComposer(hint: '3단계에서 메시지를 보낼 수 있어요'),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String name;
  final int index;
  final String? text; // null이면 회색 뼈대 말풍선
  final bool mine;
  const ChatBubble({super.key, required this.name, required this.index, this.text, this.mine = false});

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? DkColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(mine ? 18 : 4),
          bottomRight: Radius.circular(mine ? 4 : 18),
        ),
        border: mine ? null : Border.all(color: DkColors.line),
      ),
      child: text != null
          ? Text(text!, style: TextStyle(fontSize: 14, color: mine ? Colors.white : DkColors.ink, height: 1.4))
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 180),
                SizedBox(height: 6),
                SkeletonBox(width: 120),
              ],
            ),
    );

    if (mine) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(alignment: Alignment.centerRight, child: bubble),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MemberAvatar(name: name, index: index, radius: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 12, color: DkColors.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              bubble,
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 2. 주차 진행도 ───────────────────────────────────────

class ProgressTab extends StatelessWidget {
  final Team team;
  const ProgressTab({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final pastWeeks = [for (var w = team.currentWeek - 1; w >= 1; w--) w];
    // TODO(4단계): 파일 크기·확장자 제한, 마감 후 수정 정책, 늦은 제출 표시
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PreviewBanner(text: '진행도 올리기와 파일 업로드(R2)는 개발 순서 4단계에서 열려요.'),
        const SizedBox(height: 16),

        // GitHub 연결 (6단계)
        DkCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: DkColors.ink, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.code_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GitHub 저장소 연결', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: DkColors.ink)),
                    SizedBox(height: 2),
                    Text('커밋이 진행도에 자동으로 반영돼요 · 6단계', style: TextStyle(fontSize: 12.5, color: DkColors.muted)),
                  ],
                ),
              ),
              const OutlinedButton(onPressed: null, child: Text('연결')),
            ],
          ),
        ),

        // 이번 주: 팀원별 제출 현황
        DkCard(
          borderColor: DkColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                '${team.currentWeek}주차 · 이번 주',
                trailing: const StatusChip(label: '마감 D-3', color: DkColors.primary),
              ),
              for (var i = 0; i < team.members.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      MemberAvatar(name: team.members[i], index: i, radius: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i == 0 ? '${team.members[i]} (나)' : team.members[i],
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: DkColors.ink),
                            ),
                            const SizedBox(height: 6),
                            const SkeletonBox(width: 160), // 한 일 요약
                          ],
                        ),
                      ),
                      const StatusChip(label: '미제출', color: DkColors.muted, dot: false),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              FilledButton.icon(
                style: dkPrimaryButton(),
                onPressed: null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('내 진행도 올리기 (글 · 링크 · 파일)'),
              ),
            ],
          ),
        ),

        // 지난 주차
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 10),
          child: Text('지난 주차', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DkColors.muted)),
        ),
        for (final w in pastWeeks)
          DkCard(
            child: Row(
              children: [
                Text('$w주차', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DkColors.ink)),
                const SizedBox(width: 10),
                const StatusChip(label: '마감', color: DkColors.muted, dot: false),
                const Spacer(),
                Text('제출 0/${team.members.length}', style: const TextStyle(fontSize: 13, color: DkColors.muted)),
                const Icon(Icons.chevron_right_rounded, color: DkColors.muted),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── 3. 교수님께 비공개 메시지 ─────────────────────────────

class ProfessorMessageTab extends StatelessWidget {
  final Course course;
  const ProfessorMessageTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // TODO(5단계): 새 답장 표시는 푸시 대신 앱 안의 뱃지로 (푸시는 범위 밖)
    // TODO(5단계): 이 대화가 팀원에게 절대 노출되지 않도록 서버에서 권한 확인
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const PreviewBanner(text: '교수님 1:1 메시지는 개발 순서 5단계에서 열려요.'),
              const SizedBox(height: 12),
              DkCard(
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 18, color: DkColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${course.professor}님과의 비공개 대화 · 팀원은 볼 수 없어요',
                        style: const TextStyle(fontSize: 13, color: DkColors.ink, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const ChatBubble(name: '', index: 0, text: '팀 일정 관련해서 상담드리고 싶은 게 있습니다.', mine: true),
              ChatBubble(name: course.professor, index: 3), // 교수님 답장 자리 (뼈대)
            ],
          ),
        ),
        const DisabledComposer(hint: '5단계에서 교수님께 보낼 수 있어요'),
      ],
    );
  }
}

// ─── 4. 다른 팀 평가 ──────────────────────────────────────

class PeerReviewTab extends StatelessWidget {
  final Team team;
  const PeerReviewTab({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    // TODO(5단계): 우리 팀은 목록에서 제외, 평가자 익명 여부, 점수 척도(5점?), 마감 후 수정 불가
    final others = ['1조', '2조', '4조', '5조'].where((t) => t != team.name).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DkCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DkColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_clock_outlined, color: DkColors.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('아직 평가 기간이 아니에요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DkColors.ink)),
                    SizedBox(height: 2),
                    Text('교수님이 열면 아래 목록이 활성화돼요', style: TextStyle(fontSize: 12.5, color: DkColors.muted)),
                  ],
                ),
              ),
              const StepChip(step: '5단계'),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 10),
          child: Text('열리면 이렇게 보여요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DkColors.muted)),
        ),
        for (final t in others)
          Opacity(
            opacity: 0.6,
            child: DkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(t, trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: DkColors.muted)),
                  const SkeletonBox(width: double.infinity), // 결과물 설명
                  const SizedBox(height: 6),
                  const SkeletonBox(width: 200),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (var i = 0; i < 5; i++)
                        const Icon(Icons.star_outline_rounded, color: DkColors.muted, size: 26),
                      const Spacer(),
                      const OutlinedButton(onPressed: null, child: Text('평가하기')),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── 5. 기여도 리포트 ─────────────────────────────────────

class ContributionTab extends StatelessWidget {
  final Team team;
  const ContributionTab({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    const categories = ['일정 조율', '자료 공유', '구현 주도', '문서화', '리뷰'];
    // TODO(7단계): 동의 철회 시 처리, 이의 신청 경로, 프롬프트 인젝션 대비 (docs/NOTES.md)
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PreviewBanner(text: '기여도 리포트는 개발 순서 7단계에서 열려요. AI 초안 → 교수님 승인 → 공개 순서예요.'),
        const SizedBox(height: 16),

        // 이번 주 점수
        DkCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: DkColors.line, width: 8),
                ),
                child: const Text('--', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: DkColors.muted)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${team.currentWeek}주차 내 기여도', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: DkColors.ink)),
                    const SizedBox(height: 6),
                    const StatusChip(label: '교수님 승인 대기', color: Color(0xFFB7791F)),
                    const SizedBox(height: 10),
                    const Text('승인되면 점수와 근거가 공개돼요', style: TextStyle(fontSize: 12.5, color: DkColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 근거 카테고리
        DkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('근거 카테고리'),
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 72, child: Text(c, style: const TextStyle(fontSize: 13, color: DkColors.ink))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: const LinearProgressIndicator(
                            value: 0,
                            minHeight: 8,
                            backgroundColor: DkColors.line,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('--', style: TextStyle(fontSize: 13, color: DkColors.muted)),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: DkColors.success),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('대화 원문은 리포트에 들어가지 않아요', style: TextStyle(fontSize: 12.5, color: DkColors.muted)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // AI 요약 문장 자리
        const DkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('이번 주 요약'),
              SkeletonBox(width: double.infinity),
              SizedBox(height: 8),
              SkeletonBox(width: double.infinity),
              SizedBox(height: 8),
              SkeletonBox(width: 180),
            ],
          ),
        ),

        // 지난 리포트
        DkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('지난 리포트'),
              for (var w = team.currentWeek - 1; w >= team.currentWeek - 3 && w >= 1; w--)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text('$w주차', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: DkColors.ink)),
                      const SizedBox(width: 12),
                      const Expanded(child: SkeletonBox(width: double.infinity)),
                      const SizedBox(width: 12),
                      const Text('--', style: TextStyle(fontSize: 13, color: DkColors.muted)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Center(
          child: TextButton(onPressed: null, child: Text('리포트에 이의 신청하기')),
        ),
      ],
    );
  }
}
