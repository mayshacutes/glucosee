import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/screens/medic/home_nakes_page.dart';
import 'package:glucosee/screens/medic/chat_page.dart';
import 'package:glucosee/screens/medic/resep_page.dart';
import 'package:glucosee/screens/medic/appointment_page.dart';
import 'package:glucosee/screens/medic/profile_nakes_page.dart';

class MedicMain extends StatefulWidget {
  const MedicMain({super.key});

  @override
  State<MedicMain> createState() => _MedicMainState();
}

class _MedicMainState extends State<MedicMain> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeNakesPage(),
    const ChatPage(),
    const ResepPage(),
    const AppointmentPage(),
    const ProfileNakesPage(),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: "Resep"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Jadwal"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
