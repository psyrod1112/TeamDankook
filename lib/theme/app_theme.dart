import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 단국대 홈페이지의 남색(단국 블루) 계열을 참고한 색 (공식 값이 아닌 근사치)
class DkColors {
  static const primary = Color(0xFF0B3D91); // 단국 블루
  static const primaryDeep = Color(0xFF062A66); // 진한 남색
  static const sky = Color(0xFF3D8BFD); // 포인트 하늘색
  static const gold = Color(0xFFFFD86B); // 로고 궤도의 빛
  static const bg = Color(0xFFF4F6FB);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const line = Color(0xFFE5E9F2);
  static const success = Color(0xFF16A34A);

  static const avatar = [
    Color(0xFF0B3D91),
    Color(0xFF3D8BFD),
    Color(0xFF0E9F8E),
    Color(0xFFE07A2E),
  ];
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: DkColors.primary,
      primary: DkColors.primary,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: DkColors.bg,
  );
  return base.copyWith(textTheme: GoogleFonts.notoSansKrTextTheme(base.textTheme));
}

/// 입력칸 공통 모양
InputDecoration dkInput(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: DkColors.muted),
    filled: true,
    fillColor: DkColors.bg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: DkColors.primary, width: 1.5),
    ),
  );
}

/// 큰 주 버튼 공통 모양
ButtonStyle dkPrimaryButton() {
  return FilledButton.styleFrom(
    backgroundColor: DkColors.primary,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
}
