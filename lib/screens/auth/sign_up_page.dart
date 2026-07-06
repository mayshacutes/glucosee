import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/widgets/common_widgets.dart';
import 'package:glucosee/models/user_model.dart';
import 'package:glucosee/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noStrController = TextEditingController();

  UserRole _selectedRole = UserRole.patient;
  String _selectedProfession = 'Dokter';
  bool _agreePolicy = false;

bool _loading = false;

  Future<void> _register() async {
    if (!_agreePolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap setujui Privacy Policy')),
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama!')),
      );
      return;
    }
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua field!')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await AuthService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        profession: _selectedRole == UserRole.medic ? _selectedProfession : null,
        noStr: _selectedRole == UserRole.medic ? _noStrController.text.trim() : null,
      );

      if (!mounted) return;

      if (user == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi gagal, coba lagi.'), backgroundColor: Colors.red),
        );
        return;
      }

      String message = _selectedRole == UserRole.medic
          ? 'Registrasi berhasil! Menunggu verifikasi admin.'
          : 'Registrasi berhasil! Silakan login.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 220),
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(120),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.cardGrey,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Role selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<UserRole>(
                          isExpanded: true,
                          value: _selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: UserRole.patient,
                              child: Text('Pasien'),
                            ),
                            DropdownMenuItem(
                              value: UserRole.medic,
                              child: Text('Tenaga Medis'),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedRole = val!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    CustomTextField(
                      label: "Full Name",
                      hint: "Enter your full name",
                      controller: _nameController,
                    ),
                    CustomTextField(
                      label: "Email",
                      hint: "Enter your email",
                      controller: _emailController,
                    ),
                    CustomTextField(
                      label: "Phone",
                      hint: "Enter your phone number",
                      controller: _phoneController,
                    ),
                    CustomTextField(
                      label: "Password",
                      hint: "Enter your password",
                      controller: _passwordController,
                      obscure: true,
                    ),
                    CustomTextField(
                      label: "Confirm Password",
                      hint: "Repeat your password",
                      controller: _confirmController,
                      obscure: true,
                    ),

                    // Medical staff specific fields
                    if (_selectedRole == UserRole.medic) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedProfession,
                            items: const [
                              DropdownMenuItem(value: 'Dokter', child: Text('Dokter')),
                              DropdownMenuItem(value: 'Perawat', child: Text('Perawat')),
                              DropdownMenuItem(value: 'Ahli Gizi', child: Text('Ahli Gizi')),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedProfession = val!);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: "Nomor STR",
                        hint: "Masukkan Nomor STR",
                        controller: _noStrController,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Akun tenaga medis akan melalui proses verifikasi oleh admin sebelum dapat digunakan.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],

                    Row(
                      children: [
                        Checkbox(
                          value: _agreePolicy,
                          onChanged: (val) {
                            setState(() => _agreePolicy = val!);
                          },
                          activeColor: AppColors.primaryBlue,
                        ),
                        const Expanded(
                          child: Text(
                            "I have read and agree to the Privacy Policy",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _loading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: CircularProgressIndicator(color: AppColors.primaryBlue),
                          )
                        : GradientButton(
                            text: "Sign Up",
                            onPressed: _register,
                          ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Sign In.",
                        style: TextStyle(fontSize: 12, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Positioned(
            bottom: 20,
            left: 30,
            child: Row(
              children: const [
                Icon(Icons.language, size: 18),
                SizedBox(width: 5),
                Text("English"),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: 36, height: 36),
                const SizedBox(height: 2),
                const Text("Glucosee"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
