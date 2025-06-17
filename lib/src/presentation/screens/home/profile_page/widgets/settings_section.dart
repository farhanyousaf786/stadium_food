import 'package:flutter/material.dart';
import 'package:stadium_food/src/bloc/settings/settings_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart' as themeBloc;
import '../../../../../data/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsSection extends StatelessWidget {
  final User user;
  final SettingsBloc settingsBloc;
  final bool isDarkMode;
  final VoidCallback onLogout;

  const SettingsSection({
    Key? key,
    required this.user,
    required this.settingsBloc,
    required this.isDarkMode,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.dark_mode,
              color: theme.iconTheme.color,
            ),
            title: Text(
              'Dark Mode',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                context.read<themeBloc.ThemeBloc>().add(themeBloc.ToggleTheme());
              },
              activeColor: theme.primaryColor,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.logout,
              color: theme.iconTheme.color,
            ),
            title: Text(
              'Logout',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}