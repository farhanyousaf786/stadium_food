import 'package:flutter/material.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

/// Matches web `AuthRequiredModal`: Sign in, Not now, Continue as guest.
class AuthRequiredDialog extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onContinueAsGuest;
  final VoidCallback? onRegister;
  final VoidCallback onCancel;

  const AuthRequiredDialog({
    super.key,
    required this.onSignIn,
    required this.onContinueAsGuest,
    required this.onCancel,
    this.onRegister,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSignIn,
    required VoidCallback onContinueAsGuest,
    VoidCallback? onRegister,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (dialogContext) {
        return AuthRequiredDialog(
          onCancel: () => Navigator.pop(dialogContext),
          onSignIn: () {
            Navigator.pop(dialogContext);
            onSignIn();
          },
          onContinueAsGuest: () {
            Navigator.pop(dialogContext);
            onContinueAsGuest();
          },
          onRegister: onRegister == null
              ? null
              : () {
                  Navigator.pop(dialogContext);
                  onRegister();
                },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Translate.get('accountRequired'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Translate.get('loginOrRegister'),
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111827),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      backgroundColor: const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      Translate.get('cancel'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      Translate.get('login'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              Translate.get('orContinueAsGuest'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onContinueAsGuest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111827),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  backgroundColor: const Color(0xFFF3F4F6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  Translate.get('loginAsGuest'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (onRegister != null) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: onRegister,
                child: Text(
                  Translate.get('createAccount'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
