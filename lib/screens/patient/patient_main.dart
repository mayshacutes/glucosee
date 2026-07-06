import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/supabase_config.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/notification_service.dart';
import 'package:glucosee/screens/patient/home_page.dart';
import 'package:glucosee/screens/patient/aiglo_page.dart';
import 'package:glucosee/screens/patient/appointment_patient_page.dart';
import 'package:glucosee/screens/patient/chat_patient_page.dart';
import 'package:glucosee/screens/patient/profile_patient_page.dart';

class PatientMain extends StatefulWidget {
  const PatientMain({super.key});

  @override
  State<PatientMain> createState() => _PatientMainState();
}

class _PatientMainState extends State<PatientMain> {
  int _currentIndex = 0;
  Timer? _reminderTimer;

  final List<Widget> _pages = [
    const PatientHomePage(),
    const AppointmentPatientPage(),
    const AiGloPage(),
    const ChatPatientPage(),
    const PatientProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _startReminderCheck();
  }

  void _startReminderCheck() {
    _reminderTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkReminders());
  }

  Future<void> _checkReminders() async {
    if (AuthService.currentUser == null) return;
    final now = DateTime.now();
    final currentMinute = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final rows1 = await SupabaseConfig.client
        .from('medicine_reminders')
        .select('id, medicine_name, dose')
        .eq('user_id', AuthService.currentUser!.id)
        .eq('is_active', true)
        .eq('time', currentMinute) as List;

    for (final r in rows1) {
      final key = 'med1_${r['id']}_$currentMinute';
      if (_shownReminders.contains(key)) continue;
      _shownReminders.add(key);
      if (_shownReminders.length > 50) _shownReminders.removeRange(0, 25);

      await _triggerReminder(r['medicine_name'], r['dose'] ?? '-');
    }

    final rows2 = await SupabaseConfig.client
        .from('medication_reminders')
        .select('id, medication_name, dosage, times')
        .eq('patient_id', AuthService.currentUser!.id) as List;

    for (final r in rows2) {
      final times = (r['times'] as List?)?.cast<String>() ?? [];
      if (times.contains(currentMinute)) {
        final key = 'med2_${r['id']}_$currentMinute';
        if (_shownReminders.contains(key)) continue;
        _shownReminders.add(key);
        if (_shownReminders.length > 50) _shownReminders.removeRange(0, 25);

        await _triggerReminder(r['medication_name'], r['dosage'] ?? '-');
      }
    }
  }

  Future<void> _triggerReminder(String name, String dose) async {
    await SupabaseConfig.client.from('notifications').insert({
      'receiver_id': AuthService.currentUser!.id,
      'sender_id': AuthService.currentUser!.id,
      'title': 'Pengingat Minum Obat',
      'message': '$name ($dose) — saatnya minum obat!',
    });

    await NotificationService.showNotification(
      id: name.hashCode,
      title: 'Pengingat Minum Obat',
      body: '$name ($dose) — saatnya minum obat!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$name ($dose)'),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 5),
      ));
    }
  }

  final List<String> _shownReminders = [];

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Appointment"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "AiGlo"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
