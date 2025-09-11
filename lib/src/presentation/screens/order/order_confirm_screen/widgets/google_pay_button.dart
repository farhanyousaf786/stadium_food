import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:stadium_food/src/core/translations/translate.dart';

class GooglePayButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const GooglePayButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.g_mobiledata_rounded, size: 22, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              Translate.get('payWithGooglePay'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
