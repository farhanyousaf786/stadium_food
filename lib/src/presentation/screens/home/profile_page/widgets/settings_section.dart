import 'package:flutter/material.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/services/language_service.dart';
import '../../../../../data/models/user.dart';

class SettingsSection extends StatefulWidget {
  final User user;
  final SettingsBloc settingsBloc;
  final bool isDarkMode;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const SettingsSection({
    Key? key,
    required this.user,
    required this.settingsBloc,
    required this.isDarkMode,
    required this.onLogout,
    required this.onDeleteAccount,
  }) : super(key: key);

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.iconTheme.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        String current = LanguageService.getCurrentLanguage();
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                Translate.get('language'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                value: 'en',
                groupValue: current,
                title: const Text('English'),
                onChanged: (val) {
                  Navigator.pop(context);
                  if (val != null) widget.settingsBloc.add(ChangeLanguage(val));
                },
              ),
              RadioListTile<String>(
                value: 'he',
                groupValue: current,
                title: const Text('Hebrew'),
                onChanged: (val) {
                  Navigator.pop(context);
                  if (val != null) widget.settingsBloc.add(ChangeLanguage(val));
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tile(
            icon: Icons.language,
            title: Translate.get('language'),
            onTap: _showLanguagePicker,
          ),
          const SizedBox(height: 12),
          _tile(
            icon: Icons.info_outline,
            title: 'About app',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('About app'),
                  content: const Text('Fan Munch - Stadium Food Delivery App'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(Translate.get('cancel')),
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _tile(
            icon: Icons.description_outlined,
            title: Translate.get('termsAndConditions'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Translate.get('comingSoon'))),
              );
            },
          ),
          const SizedBox(height: 12),
          _tile(
            icon: Icons.feedback_outlined,
            title: Translate.get('feedback'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Translate.get('comingSoon'))),
              );
            },
          ),
          const SizedBox(height: 12),
          _tile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Translate.get('comingSoon'))),
              );
            },
          ),
          const SizedBox(height: 12),
          _tile(
            icon: Icons.report_problem_outlined,
            title: Translate.get('reportProblem'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Translate.get('comingSoon'))),
              );
            },
          ),
        ],
      ),
    );
  }
}
