import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peminjaman Alat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Connected')),
      body: Center(
        child:
            user == null
                ? const Text('Belum Login', style: TextStyle(fontSize: 18))
                : Text(
                  'Login sebagai: ${user.email}',
                  style: const TextStyle(fontSize: 18),
                ),
      ),
    );
  }
}
