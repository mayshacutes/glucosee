import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/screens/auth/splash_screen.dart';
import 'package:glucosee/services/supabase_config.dart';
import 'package:glucosee/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.init();
  await NotificationService.init();
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