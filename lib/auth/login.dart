import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// IMPORT HALAMAN SESUAI ROLE
import '../pages/admin/homeADMIN.dart';
import '../pages/peminjam/homePEMINJAM.dart';
// ignore: unused_import
import '../pages/petugas/homePETUGAS.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  // 🔴 LOGIN EMAIL/PASSWORD
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // VALIDASI INPUT
    if (email.isEmpty && password.isEmpty) {
      setState(() {
        errorMessage = 'Email dan password wajib diisi';
      });
      return;
    }
    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Email wajib diisi';
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        errorMessage = 'Password wajib diisi';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // LOGIN SUPABASE
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Login gagal';
        });
        return;
      }

      // AMBIL ROLE
      final data =
          await Supabase.instance.client
              .from('users')
              .select('role')
              .eq('id', user.id)
              .single();

      final role = data['role'];

      if (!mounted) return;

      // REDIRECT SESUAI ROLE
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeADMIN()),
        );
      } else if (role == 'peminjam') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePEMINJAM()),
        );
      } else if (role == 'petugas') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePetugasPage()),
        );
      } else {
        setState(() {
          errorMessage = 'Role tidak dikenali';
        });
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid')) {
        final res =
            await Supabase.instance.client
                .from('users')
                .select('email')
                .eq('email', email)
                .maybeSingle();

        setState(() {
          if (res == null) {
            errorMessage = 'Email tidak terdaftar';
          } else {
            errorMessage = 'Kata sandi salah';
          }
        });
      } else {
        setState(() {
          errorMessage = e.message;
        });
      }
    } catch (_) {
      setState(() {
        errorMessage = 'Terjadi kesalahan, coba lagi';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

 Future<void> loginWithGoogle() async {
  try {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb
    ? 'https://pevbxlldrzhelxrcdnar.supabase.co/auth/v1/callback'  // web
    : 'io.supabase.sipas://login-callback/'                        // mobile

    );
  } catch (e) {
    setState(() {
      errorMessage = 'Login Google gagal';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1445),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.build, size: 70, color: Colors.white),
              const SizedBox(height: 10),
              const Text(
                'SIPAS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Sistem Peminjaman Alat Sekolah',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan Email',
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Masukkan Password',
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1445),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('LOGIN'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD LOGIN GOOGLE
                    InkWell(
                      onTap: () async {
                        await loginWithGoogle();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.login, color: Colors.red),
                            SizedBox(width: 10),
                            Text(
                              "Masuk dengan Google",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePETUGAS {
  const HomePETUGAS();
}
