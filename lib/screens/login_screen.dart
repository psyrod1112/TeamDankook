import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  Role _role = Role.student;
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_role == Role.student ? '학번을 입력해 주세요' : '교번을 입력해 주세요')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // 서버 응답을 기다리는 척
    if (!mounted) return;
    ref.read(authProvider.notifier).login(id, _role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [DkColors.primaryDeep, DkColors.primary, Color(0xFF1C5BC7)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: DkLogoMark(size: 80)),
                    const SizedBox(height: 20),
                    const Text(
                      '팀단국',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'TEAM DANKOOK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '팀플의 노력이 공정하게 기록되는 곳',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    _buildCard(),
                    const SizedBox(height: 20),
                    Text(
                      '실제 단국대학교 포털과 연결되지 않은 데모 앱이에요',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final isStudent = _role == Role.student;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 30, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('단국 포털 로그인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DkColors.ink)),
          const SizedBox(height: 4),
          const Text('모의 로그인이에요. 아무 값이나 입력하세요.', style: TextStyle(fontSize: 12.5, color: DkColors.muted)),
          const SizedBox(height: 20),
          SegmentedButton<Role>(
            segments: const [
              ButtonSegment(value: Role.student, label: Text('학생'), icon: Icon(Icons.school_outlined)),
              ButtonSegment(value: Role.professor, label: Text('교수'), icon: Icon(Icons.badge_outlined)),
            ],
            selected: {_role},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _role = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _idController,
            decoration: dkInput(isStudent ? '학번' : '교번', Icons.person_outline),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pwController,
            obscureText: true,
            decoration: dkInput('비밀번호', Icons.lock_outline),
            onSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: dkPrimaryButton(),
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                  )
                : const Text('로그인'),
          ),
        ],
      ),
    );
  }
}
