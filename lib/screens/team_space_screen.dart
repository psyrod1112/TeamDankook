import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/team_tabs.dart';

/// 팀 스페이스: 아래 탭 5개로 기능이 나뉘어요.
class TeamSpaceScreen extends StatefulWidget {
  final Course course;
  final Team team;
  const TeamSpaceScreen({super.key, required this.course, required this.team});

  @override
  State<TeamSpaceScreen> createState() => _TeamSpaceScreenState();
}

class _TeamSpaceScreenState extends State<TeamSpaceScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DkColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.course.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(
              '${team.name} · ${team.members.length}명 · ${team.currentWeek}주차',
              style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
        actions: [
          MemberStack(members: team.members),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: IndexedStack(
            index: _index,
            children: [
              ChatTab(team: team),
              ProgressTab(team: team),
              ProfessorMessageTab(course: widget.course),
              PeerReviewTab(team: team),
              ContributionTab(team: team),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: DkColors.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: '채팅'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: '진행도'),
          NavigationDestination(icon: Icon(Icons.mail_outline), selectedIcon: Icon(Icons.mail), label: '교수님'),
          NavigationDestination(icon: Icon(Icons.how_to_vote_outlined), selectedIcon: Icon(Icons.how_to_vote), label: '팀 평가'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: '기여도'),
        ],
      ),
    );
  }
}
