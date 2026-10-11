import '../models/models.dart';

/// 진짜 포털 대신 쓰는 mock 데이터. 나중에 서버 API 응답으로 바뀔 자리예요.

const mockStudentCourses = <Course>[
  Course(
    id: 'c1',
    code: 'SWE',
    title: '소프트웨어공학',
    professor: '김교수',
    schedule: '월 3-4교시',
    hasTeamProject: true,
    teamId: 't1',
  ),
  Course(
    id: 'c2',
    code: 'CAP',
    title: '캡스톤디자인',
    professor: '이교수',
    schedule: '수 5-7교시',
    hasTeamProject: true,
    teamId: 't2',
  ),
  Course(
    id: 'c3',
    code: 'DB',
    title: '데이터베이스',
    professor: '박교수',
    schedule: '화 1-2교시',
    hasTeamProject: false,
  ),
  Course(
    id: 'c4',
    code: 'OS',
    title: '운영체제',
    professor: '최교수',
    schedule: '목 3-4교시',
    hasTeamProject: false,
  ),
  Course(
    id: 'c5',
    code: 'LNX',
    title: '리눅스시스템',
    professor: '정교수',
    schedule: '금 2-3교시',
    hasTeamProject: false,
  ),
];

const mockProfessorCourses = <Course>[
  Course(
    id: 'c1',
    code: 'SWE',
    title: '소프트웨어공학',
    professor: '김교수',
    schedule: '월 3-4교시',
    hasTeamProject: true,
    teamCount: 8,
  ),
  Course(
    id: 'c6',
    code: 'AI',
    title: '인공지능개론',
    professor: '김교수',
    schedule: '목 5-6교시',
    hasTeamProject: true,
    teamCount: 5,
  ),
];

const mockTeams = <String, Team>{
  't1': Team(
    id: 't1',
    name: '3조',
    members: ['김단국', '이하늘', '박서준', '최유나'],
    currentWeek: 6,
  ),
  't2': Team(
    id: 't2',
    name: '1조',
    members: ['김단국', '정민호', '한지우'],
    currentWeek: 6,
  ),
};
