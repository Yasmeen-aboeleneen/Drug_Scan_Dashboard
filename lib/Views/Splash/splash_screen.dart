import 'package:dashboard_drug_scan/Core/colors.dart';
import 'package:dashboard_drug_scan/Views/Dashboard/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kPrimary,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          child: Text(
            'Welcome To Drug Scan \n Admin Dashboard',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: kveryWhite,
              fontSize: w * .08,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
