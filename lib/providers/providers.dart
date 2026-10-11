import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

/// 로그인한 사용자 (null = 로그아웃 상태)
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  /// 지금은 mock 로그인. 나중에 서버에 요청하고 JWT를 받는 자리예요.
  void login(String id, Role role) {
    state = role == Role.student
        ? AppUser(id: id, name: '김단국', role: role, department: '컴퓨터공학과')
        : AppUser(id: id, name: '김교수', role: role, department: '컴퓨터공학과');
  }

  void logout() {
    state = null;
    ref.read(consentProvider.notifier).reset();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

/// 채팅·활동 분석에 대한 동의 여부
class ConsentNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void agree() => state = true;
  void reset() => state = false;
}

final consentProvider = NotifierProvider<ConsentNotifier, bool>(ConsentNotifier.new);

/// 로그인한 사람에 맞는 과목 목록
final coursesProvider = Provider<List<Course>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return const [];
  return user.role == Role.student ? mockStudentCourses : mockProfessorCourses;
});
