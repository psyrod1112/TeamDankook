# 팀단국 MVP 범위·기술 스택 확정본

Oct 11, 2026 · @ParkSangyoon

팀단국 MVP는 mock 로그인부터 실시간 채팅, 주차 진행도, AI 기여도 리포트까지 만들고, 아래 스택은 개발 중에 바꾸지 않는다.

## MVP에 넣는 기능

역할은 학생과 교수 둘이고, 같은 앱 안에서 화면만 달라진다.

| 기능 | 학생 | 교수 | 비고 |
| --- | --- | --- | --- |
| mock 로그인 | 학번 로그인, 수강 과목·팀 배정 수신 | 교번 로그인, 담당 과목 수신 | 진짜 포털 연동 없음 |
| 과목 목록 | 팀플 있는 과목만 활성화 | 담당 과목의 팀 목록 |  |
| 팀 스페이스 | 우리 팀원만 입장 | 담당 과목 팀 조회 | 남의 팀 접근 차단 |
| 실시간 채팅 | 팀원끼리 대화 | 볼 수 없음 | 원문은 교수에게도 비공개 |
| 주차 진행도 | 글, 링크, 파일(R2) 제출 | 조회 |  |
| GitHub 연동 | 팀 저장소 연결 | 커밋 지표 조회 | GitHub App + 웹훅 |
| 교수 비공개 메시지 | 교수에게 1:1 전송 | 수신·답장 | 팀원은 볼 수 없음 |
| 팀 간 평가 | 다른 팀 결과물 평가 | 평가 기간 열기/닫기 | 교수가 열 때만 활성 |
| 기여도 리포트 | 승인된 내 리포트와 근거 카테고리 조회 | AI 초안 검토·승인 | 승인 전 학생 비공개 |

## 이번에 안 만드는 것

| 제외 항목 | 이유 |
| --- | --- |
| 진짜 단국대 포털 연동 | 학생 비밀번호를 대신 다루면 보안·개인정보 문제, 학교 공식 허가 필요 |
| 메시지마다 실시간 AI 분석 | 비용 폭발. 하루 1번 모아서 분석 |
| 푸시 알림, 음성·영상 통화 | MVP 핵심이 아님 |
| 앱스토어 출시 | 웹과 안드로이드 실행까지만 |
| 다른 대학용 확장 | 단국대 한 곳에서 검증 먼저 |
| 서버 여러 대 운영 | 서버 1대 기준. 필요해지면 Redis로 확장 |

## 기여도와 채팅 개인정보 원칙

기여도는 AI 판단 비중을 크게 두되, 채팅을 AI가 분석한다는 사실은 숨기지 않고 원문은 누구에게도 내보내지 않는다. 숨기면 들키는 순간 "몰래 감시하는 앱"이 되고, 고지 없는 수집은 개인정보보호법에도 걸린다.

1. **가입 시 고지와 동의**: "채팅 활동과 협업 패턴이 기여도에 반영됩니다. 분석을 위해 대화 내용이 외부 AI 서비스(Anthropic Claude API)로 전송됩니다. 대화 원문은 교수도 볼 수 없습니다."
   - 원문이 교수에게는 안 보여도 외부 회사로는 넘어가므로, 이 사실까지 고지해야 "숨기지 않는다"는 원칙과 맞는다.
   - 처리위탁·국외 이전 고지가 법적으로 어디까지 필요한지는 7단계(기여도 리포트) 전에 확인한다.
2. **원문 비노출**: AI 출력은 역할 카테고리(일정 조율, 자료 공유, 구현 주도 등)와 수치만. 대화 인용은 출력 형식에서 막는다.
3. **근거 공개**: 학생은 자기 점수의 근거 카테고리를 볼 수 있다. "왜 내 점수가 이래요?"에 답할 수 있어야 한다.
4. **교수 승인 후 공개**: AI 초안은 교수가 검토·승인해야 학생에게 보인다.
5. **보상 중심**: 벌점이 아니라 기여한 학생에게 가점을 주는 구조로 표현한다.

## 기술 스택 확정표

개발 중에는 아래 선택을 바꾸지 않는다. 바꿔야 할 이유가 생기면 이 문서를 먼저 고친다.

| 영역 | 확정 | 이유 |
| --- | --- | --- |
| 앱 | Flutter (웹 + 안드로이드) | 코드 하나로 두 플랫폼 |
| 앱 상태 관리 | Riverpod | 업계 표준, 테스트하기 쉬움 |
| HTTP / 실시간 | `dio` / `web_socket_channel` |  |
| 서버 | FastAPI + JWT | portfolio 경험 재사용 |
| DB | PostgreSQL + SQLAlchemy 2.0 + Alembic | 핵심 스택, 마이그레이션 도구 학습 |
| 실시간 채팅 | FastAPI WebSocket, 메모리에서 연결 관리 | 서버 1대 MVP에 충분 |
| 파일 | Cloudflare R2, presigned URL로 앱이 직접 업로드 | 서버 부담 없음, 다운로드 비용 0 |
| GitHub | GitHub App + 웹훅 | 비공개 저장소 지원, 실시간 커밋 반영 |
| AI | Claude API 직접 호출 + JSON 출력 강제 | LangChain 없이 단순하게 |
| AI 분석 주기 | APScheduler로 하루 1번 | 비용 통제 |
| 배포 | Docker Compose + Cloudflare Tunnel | 지금 쓰는 방식 그대로 |

## 아키텍처

&#91;embedded content: 팀단국 아키텍처 · 서버 1대, 외부 서비스 3개\]

앱은 서버(REST, WebSocket)와 R2(파일 직접 업로드)만 만나고, Claude API는 서버의 하루 1번 분석 작업만 호출한다.

## 데이터 모델 초안

초안이라 컬럼은 개발하면서 Alembic 마이그레이션으로 다듬는다.

| 테이블 | 핵심 컬럼 | 메모 |
| --- | --- | --- |
| User | id, 학번/교번, name, role(student/professor), consent\_at | 동의 시각 기록 |
| Course | id, code, title, professor\_id, peer\_review\_open | 교수가 평가 기간을 연다 |
| Enrollment | user\_id, course\_id | 수강 관계 |
| Team | id, course\_id, name, github\_installation\_id | GitHub App 연결 정보 |
| TeamMember | team\_id, user\_id | 팀 배정 (mock 데이터로 채움) |
| Message | id, team\_id, sender\_id, content, created\_at | 원문은 팀원만 조회 |
| Milestone | id, team\_id, user\_id, week, body, links | 주차 진행도 |
| MilestoneFile | id, milestone\_id, r2\_key, filename | 파일은 R2, DB엔 키만 |
| CommitEvent | id, team\_id, author\_login, sha, committed\_at | 웹훅으로 적재 |
| ProfessorMessage | id, course\_id, student\_id, body, from\_professor | 1:1 비공개 |
| PeerReview | id, reviewer\_team\_id, target\_team\_id, score, comment | 평가 기간에만 작성 |
| ContributionReport | id, team\_id, user\_id, week, score, categories, status(draft/approved) | AI 초안 → 교수 승인 |

### 중복을 막는 DB 제약

중복은 코드의 `if`가 아니라 DB 제약으로 막는다. 동시에 요청이 두 번 와도 DB가 한 번만 받아준다.

| 테이블 | 제약 | 막는 상황 |
| --- | --- | --- |
| User | UNIQUE(학번/교번) | 같은 학번으로 계정이 두 개 생김 |
| Enrollment | UNIQUE(user\_id, course\_id) | 같은 과목 수강 기록이 두 번 들어감 |
| TeamMember | UNIQUE(team\_id, user\_id) | 같은 학생이 같은 팀에 두 번 배정됨 |
| CommitEvent | UNIQUE(team\_id, sha) | GitHub 웹훅 재전송으로 같은 커밋이 두 번 쌓임 |
| PeerReview | UNIQUE(reviewer\_team\_id, target\_team\_id), CHECK(reviewer\_team\_id ≠ target\_team\_id) | 같은 팀을 두 번 평가, 자기 팀 평가 |
| ContributionReport | UNIQUE(team\_id, user\_id, week) | 한 학생의 같은 주차 리포트가 두 개 생김 |

## 개발 순서

한 줄을 끝까지 관통시킨 뒤 기능을 하나씩 얹는다. 각 단계는 사전지식 + 과제 방식으로 진행한다.

1. **뼈대**: Docker Compose로 FastAPI + PostgreSQL 띄우기, Alembic 첫 마이그레이션
2. **첫 관통**: mock 로그인 → 과목 목록(팀플 있는 것만 활성) → 팀 스페이스 입장 (서버 + Flutter)
3. **실시간 채팅**: WebSocket, 팀원만 접속, 메시지 저장
4. **주차 진행도 + R2 업로드**
5. **교수 화면**: 비공개 메시지, 팀 간 평가 열기/닫기
6. **GitHub App + 웹훅**: 커밋 이벤트 적재
7. **기여도 리포트**: 동의 화면 → 하루 1번 분석 → 교수 승인 → 학생 조회
8. **배포**: Cloudflare Tunnel로 공개
