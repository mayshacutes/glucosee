import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.bloodtype,
                        size: 60,
                        color: AppColors.accentRed,
                      ),
                      Positioned(
                        bottom: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pan_tool, size: 20, color: AppColors.primaryBlue),
                            SizedBox(width: 4),
                            Icon(Icons.pan_tool, size: 20, color: AppColors.primaryBlue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Glucosee',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Smart Monitoring for Better Living',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
