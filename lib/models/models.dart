enum Role { student, professor }

class AppUser {
  final String id; // 학번 또는 교번
  final String name;
  final Role role;
  final String department;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
  });
}

class Course {
  final String id;
  final String code;
  final String title;
  final String professor;
  final String schedule;
  final bool hasTeamProject; // 팀플 있는 과목만 입장 가능
  final String? teamId; // 학생: 내가 배정된 팀
  final int teamCount; // 교수: 이 과목의 팀 수

  const Course({
    required this.id,
    required this.code,
    required this.title,
    required this.professor,
    required this.schedule,
    required this.hasTeamProject,
    this.teamId,
    this.teamCount = 0,
  });
}

class Team {
  final String id;
  final String name;
  final List<String> members; // 첫 번째가 나
  final int currentWeek;
  final bool peerReviewOpen; // 교수가 평가 기간을 열었는지

  const Team({
    required this.id,
    required this.name,
    required this.members,
    required this.currentWeek,
    this.peerReviewOpen = false,
  });
}
