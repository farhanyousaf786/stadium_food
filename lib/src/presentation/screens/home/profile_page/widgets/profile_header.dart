import 'package:flutter/material.dart';
import '../../../../../data/models/user.dart';
import '../../../../widgets/image_placeholder.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return FlexibleSpaceBar(
      expandedTitleScale: 1.5,
      background: Stack(
        fit: StackFit.expand,
        children: [
          // Profile Image with Hero Animation
          user.image != null
              ? Hero(
                  tag: 'profile_image',
                  child: Image.network(
                    user.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        ImagePlaceholder(
                      iconData: Icons.person,
                      iconSize: 100,
                    ),
                  ),
                )
              : ImagePlaceholder(
                  iconData: Icons.person,
                  iconSize: 100,
                ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  theme.colorScheme.surface.withOpacity(isDarkMode ? 0.9 : 0.7),
                ],
              ),
            ),
          ),

          // User Info
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Member Badge


                // User Name
                Text(
                  user.fullName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}