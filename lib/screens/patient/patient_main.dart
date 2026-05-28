import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/screens/patient/home_page.dart';
import 'package:glucosee/screens/patient/aiglo_page.dart';
import 'package:glucosee/screens/patient/gluconet_page.dart';
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
    const AiGloPage(),
    const GlucoNetPage(),
    const PatientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Glucourse", 0),
              _buildNavItem(Icons.chat_bubble, "Gluconet", 2),
              const SizedBox(width: 40), // space for FAB
              _buildNavItem(Icons.person, "Profil", 3),
              _buildNavItem(Icons.settings, "Settings", 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentRed,
        onPressed: () {
          setState(() => _currentIndex = 1);
        },
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primaryBlue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.primaryBlue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
