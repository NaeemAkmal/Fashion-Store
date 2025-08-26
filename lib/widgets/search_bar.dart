import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final String hintText;

  const CustomSearchBar({
    super.key,
    this.onTap,
    this.onChanged,
    this.hintText = 'Search for fashion items...',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppTheme.textLight.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: onTap != null
                  ? Text(
                      hintText,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    )
                  : TextField(
                      onChanged: onChanged,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
            ),
            const Icon(
              Icons.tune,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
