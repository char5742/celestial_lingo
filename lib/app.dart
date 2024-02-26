import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router.dart';

class App extends HookConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF27F7C5),
        fontFamily: GoogleFonts.yomogi().fontFamily,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: GoogleFonts.yomogi().fontFamily,
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: const Color(0xFF27F7C5),
              secondary: const Color(0xFF27F7C5),
            ),
      ),
    );
  }
}
