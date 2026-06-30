import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/screens/auth/splash_screen.dart';
import 'package:glucosee/services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const GlucoseeApp());
}

class GlucoseeApp extends StatelessWidget {
  const GlucoseeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glucosee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}