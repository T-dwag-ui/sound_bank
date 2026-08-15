import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your EditorViewModel implementation
import 'view_models/editor_view_model.dart'; 
import 'new_song_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => EditorViewModel(),
      child: const AuraMusicApp(),
    ),
  );
}

class AuraMusicApp extends StatelessWidget {
  const AuraMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AURA',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF262626),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F4),
        fontFamily: 'Inter',
      ),
      home: const NewSongScreen(),
    );
  }
}