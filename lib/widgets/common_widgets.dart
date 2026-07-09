import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glucosee/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool showToggle;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.prefixIcon,
    this.showToggle = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: widget.controller,
          obscureText: _obscured,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.showToggle
                ? IconButton(
                    icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class HeaderCurve extends StatelessWidget {
  final double height;
  final Widget? child;

  const HeaderCurve({super.key, this.height = 280, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
        ),
        Positioned(
          top: height - 60,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.bgGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(120),
                topRight: Radius.circular(120),
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
