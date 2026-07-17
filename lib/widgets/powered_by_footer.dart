import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class PoweredByFooter extends StatelessWidget {
  const PoweredByFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
            children: [
              TextSpan(text: 'Powered by '),
              TextSpan(
                text: 'Siyayya.com',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
