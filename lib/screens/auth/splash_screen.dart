import 'package:flutter/material.dart';
import 'package:glucosee/screens/auth/sign_in_page.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/models/user_model.dart';
import 'package:glucosee/screens/patient/patient_main.dart';
import 'package:glucosee/screens/medic/medic_main.dart';
import 'package:glucosee/screens/admin/admin_main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      final user = await AuthService.restoreSession();
      if (!mounted) return;

      if (user == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInPage()));
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/logo.png',
            width: 280,
            height: 280,
          ),
        ),
      ),
    );
  }
}
