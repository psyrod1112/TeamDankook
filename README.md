# 팀단국 (Team Dankook)

<img src="docs/logo.svg" width="72" align="right">

팀플의 노력이 공정하게 기록되는 곳. 대학 팀 프로젝트 기여도 검증 앱의 **Flutter 껍데기(MVP 셸)** 예요.
모든 화면과 이동은 동작하고, 아직 만들지 않은 기능 자리에는 "개발 순서 N단계"가 붙어 있어요.

## 실행하기

```bash
cd team_dankook
flutter create . --platforms=web,android --project-name team_dankook   # web/, android/ 폴더 생성 (lib/는 덮어쓰지 않아요)
flutter pub get
flutter run -d chrome        # 웹으로 실행
# flutter run                # 안드로이드 기기/에뮬레이터
flutter test                 # mock 데이터 테스트
```

## 테스트해 볼 흐름

| 순서 | 할 것 | 확인할 것 |
| --- | --- | --- |
| 1 | 학생 탭, 아무 학번/비밀번호 입력 → 로그인 | 동의 화면이 나와요 |
| 2 | 체크하고 "동의하고 시작하기" | 과목 5개 중 2개만 활성화 |
| 3 | 소프트웨어공학 클릭 | 팀 스페이스, 아래 탭 5개 |
| 4 | 탭을 하나씩 눌러 보기 | 채팅 미리보기, 진행도 주차 목록, 잠긴 팀 평가 |
| 5 | 뒤로 → 로그아웃 → 교수 탭으로 로그인 | 동의 없이 담당 과목 2개, 누르면 팀 목록 |

## 폴더 구조

```
lib/
├── main.dart              # 앱 시작 (ProviderScope)
├── app.dart               # 테마 + AuthGate(로그인/동의/홈 분기)
├── theme/app_theme.dart   # 단국 블루 색, 입력칸·버튼 공통 모양
├── models/models.dart     # Role, AppUser, Course, Team
├── data/mock_data.dart    # 포털 대신 쓰는 가짜 데이터 (나중에 API로 교체)
├── providers/providers.dart  # Riverpod: 로그인, 동의, 과목 목록
├── screens/               # 로그인, 동의, 홈, 팀 스페이스, 교수 과목
└── widgets/               # 로고, 공통 조각, 팀 스페이스 탭 5개
```

## 개발 순서

1. 뼈대: Docker Compose로 FastAPI + PostgreSQL, Alembic
2. 첫 관통: mock 로그인 → 과목 → 팀 스페이스 (서버 연결)
3. 실시간 채팅 (WebSocket)
4. 주차 진행도 + R2 업로드
5. 교수 비공개 메시지, 팀 간 평가 열기/닫기
6. GitHub App + 웹훅
7. 기여도 리포트 (동의 → 하루 1번 분석 → 교수 승인)
8. Cloudflare Tunnel 배포

> 색과 로고는 단국대 홈페이지 분위기를 참고한 근사치이며, 공식 UI가 아니에요. 실제 포털과 연결되지 않은 학습용 데모입니다.
