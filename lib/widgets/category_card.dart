import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category.dart';
import '../utils/theme.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Category Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: category.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: category.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.backgroundColor,
                          child: Icon(
                            _getCategoryIcon(category.name),
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.backgroundColor,
                          child: Icon(
                            _getCategoryIcon(category.name),
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.backgroundColor,
                        child: Icon(
                          _getCategoryIcon(category.name),
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category Name
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'men':
        return Icons.man;
      case 'women':
        return Icons.woman;
      case 'kids':
        return Icons.child_friendly;
      case 'accessories':
        return Icons.watch;
      case 'shoes':
        return Icons.sports_handball; // Closest to shoe icon
      case 'bags':
        return Icons.shopping_bag;
      case 'jewelry':
        return Icons.diamond;
      case 'watches':
        return Icons.watch;
      case 'sunglasses':
        return Icons.visibility;
      default:
        return Icons.category;
    }
  }
}
