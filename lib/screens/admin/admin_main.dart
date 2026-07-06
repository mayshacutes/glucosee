import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/screens/admin/home_admin_page.dart';
import 'package:glucosee/screens/admin/account_user_management_page.dart';
import 'package:glucosee/screens/admin/article_page.dart';
import 'package:glucosee/screens/admin/verification_page.dart';
import 'package:glucosee/screens/admin/payment_verification_page.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/screens/auth/sign_in_page.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
  const HomeAdminPage(),
  const AccountUserManagementPage(),
  const ArticlePage(),
  const PaymentVerificationPage(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Glucosee"),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VerificationPage()),
              );
            },
            tooltip: "Verifikasi Tenaga Medis",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.currentUser = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: "Article"),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Pembayaran"),
],
      ),
    );
  }
}