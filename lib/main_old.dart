import 'package:flutter/material.dart';
import 'views/music_editor_screen.dart';

void main() {
  runApp(const AuraDawApp());
}

class AuraDawApp extends StatelessWidget {
  const AuraDawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Studio DAW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF12131C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA855F7),
          secondary: Color(0xFFEC4899),
          surface: Color(0xFF181926),
        ),
      ),
      home: const MusicEditorScreen(),
    );
  }
}
