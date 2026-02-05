import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pevbxlldrzhelxrcdnar.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBldmJ4bGxkcnpoZWx4cmNkbmFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NzY4MzksImV4cCI6MjA4NDE1MjgzOX0.X9uzpmDGv8rVjzmn8X6wZAz7Lhlb3gwR5ZzcsPVO0_0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(), // ✅ SESUAI DENGAN splash.dart
    );
  }
}
