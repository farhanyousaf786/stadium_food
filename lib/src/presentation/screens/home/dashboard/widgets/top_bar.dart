import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stadium_food/src/data/models/user.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String? _selectedStadiumName;
  String _greeting = '';
  late User _user;

  @override
  void initState() {
    super.initState();
    _loadUserAndStadium();
    _updateGreeting();
  }

  Future<void> _loadUserAndStadium() async {
    _user = User.fromHive();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedStadiumName = prefs.getString('selected_stadium_name') ?? 'Select Stadium';
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        _greeting = 'Good Morning';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon';
      } else {
        _greeting = 'Good Evening';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stadium Selection Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Stadium',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grayColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _selectedStadiumName ?? 'Select Stadium',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
                    ],
                  ),
                ],
              ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Greeting Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey ${_user.firstName},',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _greeting,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
