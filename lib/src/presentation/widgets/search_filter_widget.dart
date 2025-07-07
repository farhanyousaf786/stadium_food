import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../utils/custom_text_style.dart';

class SearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onChanged;
  final VoidCallback onFilterTap;

  const SearchFilterWidget({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search for food...',
          prefixIcon: const Icon(Icons.search,
              color: AppColors.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );


  }
}
