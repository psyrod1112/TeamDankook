import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/models.dart';
import 'providers/providers.dart';
import 'screens/consent_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

class TeamDankookApp extends StatelessWidget {
  const TeamDankookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '팀단국',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AuthGate(),
    );
  }
}

/// 로그인 상태에 따라 첫 화면을 고르는 문지기.
/// 로그인 전 → 로그인, 학생인데 동의 전 → 동의 화면, 그 외 → 홈
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const LoginScreen();

    final consented = ref.watch(consentProvider);
    if (user.role == Role.student && !consented) return const ConsentScreen();

    return const HomeScreen();
  }
}
