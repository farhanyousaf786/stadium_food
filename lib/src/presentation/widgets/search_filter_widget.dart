import 'package:flutter/material.dart';
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
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search dishes',
                  hintStyle: CustomTextStyle.size14Weight400Text(Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onFilterTap,
              icon: Icon(Icons.tune, color: Colors.grey[800], size: 22),
              tooltip: 'Filter',
            ),
          ),
        ],
      ),
    );
  }
}
