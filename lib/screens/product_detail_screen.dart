import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../models/product_review.dart';
import '../utils/theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late TabController _tabController;
  int _currentImageIndex = 0;
  String _selectedSize = '';
  String _selectedColor = '';
  int _quantity = 1;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load product details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.getProduct(widget.productId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          // Find product from the provider's products list or featured products
          Product? product;
          
          // Try to find in regular products first
          try {
            product = productProvider.products
                .firstWhere((p) => p.id == widget.productId);
          } catch (e) {
            // If not found in products, try featured products
            try {
              product = productProvider.featuredProducts
                  .firstWhere((p) => p.id == widget.productId);
            } catch (e) {
              // If still not found, show loading or error
              product = null;
            }
          }

          if (product == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Set default selections if not set
          if (_selectedSize.isEmpty && product.sizes.isNotEmpty) {
            _selectedSize = product.sizes.first;
          }
          if (_selectedColor.isEmpty && product.colors.isNotEmpty) {
            _selectedColor = product.colors.first;
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(product),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImages(product),
                    _buildProductInfo(product),
                    _buildSizeColorSelection(product),
                    _buildQuantitySelector(),
                    _buildActionButtons(product),
                    _buildProductDetails(product),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildSliverAppBar(Product product) {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.surfaceColor,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      actions: [
        Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            return IconButton(
              icon: Icon(
                productProvider.isInWishlist(product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: productProvider.isInWishlist(product.id)
                    ? FashionColors.sale
                    : AppTheme.textSecondary,
              ),
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                if (auth.user != null) {
                  await productProvider.toggleWishlist(auth.user!.id, product.id);
                } else {
                  // Show login dialog
                  _showLoginDialog();
                }
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Implement share functionality
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(product.images.first),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {},
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImages(Product product) {
    if (product.images.length <= 1) return const SizedBox();

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(product.images[index]),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSmoothIndicator(
            activeIndex: _currentImageIndex,
            count: product.images.length,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: AppTheme.primaryColor,
              dotColor: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand and Name
          Text(
            product.brand.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Rating and Reviews
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < product.rating.floor()
                        ? Icons.star
                        : index < product.rating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: FashionColors.ratingStar,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${product.rating} (${product.reviews.length} reviews)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Price
          Row(
            children: [
              if (product.hasDiscount) ...[
                Text(
                  '\$${product.originalPrice.toStringAsFixed(2)}',
                  style: FashionTextStyles.originalPrice,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FashionColors.sale,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${product.discountPercentage.round()}% OFF',
                    style: FashionTextStyles.badge,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '\$${product.finalPrice.toStringAsFixed(2)}',
                style: FashionTextStyles.price.copyWith(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: _isExpanded ? null : 3,
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
          ),
          if (product.description.length > 150)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'Read Less' : 'Read More'),
            ),
        ],
      ),
    );
  }

  Widget _buildSizeColorSelection(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size Selection
          if (product.sizes.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Size',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    _showSizeGuide();
                  },
                  child: const Text('Size Guide'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.sizes.map((size) {
                final isSelected = _selectedSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = size;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.textLight,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected 
                          ? AppTheme.primaryColor.withOpacity(0.1) 
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        size,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? AppTheme.primaryColor 
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Color Selection
          if (product.colors.isNotEmpty) ...[
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.textLight,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected 
                          ? AppTheme.primaryColor.withOpacity(0.1) 
                          : null,
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Quantity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.textLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1 
                      ? () {
                          setState(() {
                            _quantity--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _quantity.toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _addToCart(product, isWishlist: true);
              },
              icon: const Icon(Icons.favorite_border),
              label: const Text('Wishlist'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                _addToCart(product);
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
              Tab(text: 'Shipping'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(product),
                _buildReviewsTab(product),
                _buildShippingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Brand', product.brand),
          _buildDetailRow('Material', 'Cotton Blend'),
          _buildDetailRow('Care Instructions', 'Machine wash cold, tumble dry low'),
          _buildDetailRow('Country of Origin', 'Made in USA'),
          _buildDetailRow('SKU', product.id),
          if (product.sizes.isNotEmpty)
            _buildDetailRow('Available Sizes', product.sizes.join(', ')),
          if (product.colors.isNotEmpty)
            _buildDetailRow('Available Colors', product.colors.join(', ')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary
          Row(
            children: [
              Text(
                product.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < product.rating.floor()
                            ? Icons.star
                            : index < product.rating
                                ? Icons.star_half
                                : Icons.star_border,
                        color: FashionColors.ratingStar,
                        size: 20,
                      );
                    }),
                  ),
                  Text(
                    '${product.reviews.length} reviews',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Reviews List
          if (product.reviews.isNotEmpty) ...[
            ...product.reviews.take(3).map((review) => _buildReviewItem(review)),
            if (product.reviews.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to all reviews
                },
                child: Text('See all ${product.reviews.length} reviews'),
              ),
          ] else ...[
            const Center(
              child: Text('No reviews yet. Be the first to review!'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(ProductReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  review.userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: FashionColors.ratingStar,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShippingOption(
            'Standard Delivery',
            '5-7 business days',
            'Free',
            Icons.local_shipping,
          ),
          _buildShippingOption(
            'Express Delivery',
            '2-3 business days',
            '\$9.99',
            Icons.flash_on,
          ),
          _buildShippingOption(
            'Next Day Delivery',
            '1 business day',
            '\$19.99',
            Icons.rocket_launch,
          ),
          const SizedBox(height: 24),
          const Text(
            'Return Policy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Free returns within 30 days\n'
            '• Items must be in original condition\n'
            '• Return shipping is free for defective items\n'
            '• Refund processed within 5-10 business days',
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption(String title, String duration, String price, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  duration,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        Product? product;
        
        try {
          product = productProvider.products
              .firstWhere((p) => p.id == widget.productId);
        } catch (e) {
          try {
            product = productProvider.featuredProducts
                .firstWhere((p) => p.id == widget.productId);
          } catch (e) {
            return const SizedBox();
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '\$${(product.finalPrice * _quantity).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _buyNow(product!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToCart(Product product, {bool isWishlist = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    if (auth.user == null) {
      _showLoginDialog();
      return;
    }

    if (isWishlist) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.toggleWishlist(auth.user!.id, product.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            productProvider.isInWishlist(product.id)
                ? 'Added to wishlist!'
                : 'Removed from wishlist!',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      if (_selectedSize.isEmpty && product.sizes.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a size'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      if (_selectedColor.isEmpty && product.colors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a color'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.addToCart(
        product,
        userId: auth.user!.id,
        quantity: _quantity,
        selectedSize: _selectedSize,
        selectedColor: _selectedColor,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _buyNow(Product product) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    if (auth.user == null) {
      _showLoginDialog();
      return;
    }

    if (_selectedSize.isEmpty && product.sizes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedColor.isEmpty && product.colors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a color'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Add to cart first
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.addToCart(
      product,
      userId: auth.user!.id,
      quantity: _quantity,
      selectedSize: _selectedSize,
      selectedColor: _selectedColor,
    );

    // Navigate to checkout
    Navigator.pushNamed(context, '/checkout');
  }

  void _showSizeGuide() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Size Guide',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Size measurements (inches):'),
            const SizedBox(height: 8),
            const Text('XS: Chest 32-34, Waist 26-28'),
            const Text('S: Chest 34-36, Waist 28-30'),
            const Text('M: Chest 36-38, Waist 30-32'),
            const Text('L: Chest 38-40, Waist 32-34'),
            const Text('XL: Chest 40-42, Waist 34-36'),
            const Text('XXL: Chest 42-44, Waist 36-38'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to continue shopping.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
