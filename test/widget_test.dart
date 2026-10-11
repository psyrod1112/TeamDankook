import 'package:flutter_test/flutter_test.dart';
import 'package:team_dankook/data/mock_data.dart';

void main() {
  test('학생 mock 과목 중 팀플이 있는 건 2개', () {
    final active = mockStudentCourses.where((c) => c.hasTeamProject);
    expect(active.length, 2);
  });

  test('팀플 과목은 모두 팀 데이터가 있다', () {
    for (final c in mockStudentCourses.where((c) => c.hasTeamProject)) {
      expect(mockTeams[c.teamId], isNotNull);
    }
  });
}
