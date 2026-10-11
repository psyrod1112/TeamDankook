import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/logo.dart';

/// 학생이 처음 들어올 때 보는 동의 화면.
/// "AI가 활동을 분석한다"는 사실을 숨기지 않고 먼저 알려요.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(alignment: Alignment.centerLeft, child: DkLogoMark(size: 48)),
                  const SizedBox(height: 24),
                  const Text(
                    '시작하기 전에\n꼭 알려드릴게요',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: DkColors.ink, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  const Text('팀단국은 숨기는 것 없이 운영돼요.', style: TextStyle(fontSize: 15, color: DkColors.muted)),
                  const SizedBox(height: 28),
                  const _Point(
                    icon: Icons.insights_outlined,
                    title: '활동이 기여도에 반영돼요',
                    body: '채팅, 주차 진행도, 커밋 활동을 AI가 하루 1번 모아서 분석해요.',
                  ),
                  const _Point(
                    icon: Icons.visibility_off_outlined,
                    title: '대화 원문은 교수님도 못 봐요',
                    body: "리포트에는 '일정 조율', '자료 공유' 같은 역할 카테고리만 담겨요.",
                  ),
                  const _Point(
                    icon: Icons.fact_check_outlined,
                    title: '내 점수의 근거를 볼 수 있어요',
                    body: '교수님이 승인한 리포트와 그 근거는 언제든 확인할 수 있어요.',
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: DkColors.primary,
                    title: const Text(
                      '위 내용을 이해했고 동의합니다',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: DkColors.ink),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: dkPrimaryButton(),
                    onPressed: _agreed ? () => ref.read(consentProvider.notifier).agree() : null,
                    child: const Text('동의하고 시작하기'),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    child: const Text('다음에 할게요', style: TextStyle(color: DkColors.muted)),
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

class _Point extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Point({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DkColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DkColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: DkColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DkColors.ink)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13.5, color: DkColors.muted, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
