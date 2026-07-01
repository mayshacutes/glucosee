import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
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

  final List<Widget> _pages = [
    const PatientHomePage(),
    const AppointmentPatientPage(),
    const AiGloPage(),
    const ChatPatientPage(),
    const PatientProfilePage(),
  ];

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