import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/widgets/common_widgets.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/models/user_model.dart';
import 'package:glucosee/screens/auth/sign_up_page.dart';
import 'package:glucosee/screens/patient/patient_main.dart';
import 'package:glucosee/screens/medic/medic_main.dart';
import 'package:glucosee/screens/admin/admin_main.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);
    UserModel? user;
    try {
      user = await AuthService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau password salah!'), backgroundColor: Colors.red),
      );
      return;
    }

    if (user.role == UserRole.medic && user.medicStatus != MedicStatus.verified) {
      await AuthService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun tenaga medis belum diverifikasi oleh admin.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Widget destination;
    switch (user.role) {
      case UserRole.medic:
        destination = const MedicMain();
        break;
      case UserRole.admin:
        destination = const AdminMain();
        break;
      case UserRole.patient:
      case UserRole.family:
        destination = const PatientMain();
        break;
    }

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 220),
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.only(topRight: Radius.circular(120)),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.cardGrey,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Smart Monitoring\nfor Better Living",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      label: "Email",
                      hint: "Your Email",
                      controller: _emailController,
                      prefixIcon: Icons.email,
                    ),
                    CustomTextField(
                      label: "Password",
                      hint: "Your Password",
                      controller: _passwordController,
                      obscure: true,
                      prefixIcon: Icons.lock,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () {}, child: const Text("Forgot password?")),
                    ),
                    _loading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: CircularProgressIndicator(color: AppColors.primaryBlue),
                          )
                        : GradientButton(text: "Sign In", onPressed: _login),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text("Don't have an account yet?"),
                    const SizedBox(height: 10),
                    GradientButton(
                      text: "Sign Up",
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: Column(
              children: const [
                Icon(Icons.bloodtype, color: AppColors.accentRed, size: 30),
                Text("Glucosee", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}