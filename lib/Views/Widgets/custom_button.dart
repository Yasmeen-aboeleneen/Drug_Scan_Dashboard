// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:dashboard_drug_scan/Core/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Container(
      height: h * .09,
      width: w * .45,
      decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.cairo(
              color: kveryWhite,
              fontSize: w * .05,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
