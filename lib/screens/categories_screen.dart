import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/category.dart';
import '../utils/theme.dart';
import '../widgets/product_card.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> 
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTabController();
    });

    // Load more products when scrolling to bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 
          _scrollController.position.maxScrollExtent) {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        productProvider.loadProducts(loadMore: true);
      }
    });
  }

  void _initializeTabController() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final mainCategoriesCount = productProvider.categories.where((c) => c.isMainCategory).length;
    
    if (mainCategoriesCount > 0 && !_isInitialized && mounted) {
      _tabController = TabController(
        length: mainCategoriesCount,
        vsync: this,
      );
      _isInitialized = true;
      setState(() {}); // Trigger rebuild
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final mainCategories = productProvider.categories
            .where((category) => category.isMainCategory)
            .cast<Category>()
            .toList();

        if (mainCategories.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Categories'),
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Categories'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(context, productProvider),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: mainCategories.map<Tab>((category) {
                return Tab(
                  text: category.name,
                );
              }).toList(),
              onTap: (index) {
                final selectedCategory = mainCategories[index];
                productProvider.setCategory(selectedCategory.id);
              },
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: mainCategories.map<Widget>((category) {
              return _buildCategoryView(context, productProvider, category);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryView(
    BuildContext context,
    ProductProvider productProvider,
    Category category,
  ) {
    // Get subcategories for this main category
    final subCategories = productProvider.categories
        .where((c) => c.parentId == category.id)
        .toList();

    return Column(
      children: [
        // Subcategories horizontal list
        if (subCategories.isNotEmpty) ...[
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subCategories.length + 1, // +1 for "All" chip
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "All" chip
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: productProvider.selectedSubCategory.isEmpty,
                      onSelected: (selected) {
                        productProvider.setCategory(category.id, subCategory: '');
                      },
                    ),
                  );
                }

                final subCategory = subCategories[index - 1];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(subCategory.name),
                    selected: productProvider.selectedSubCategory == subCategory.id,
                    onSelected: (selected) {
                      productProvider.setCategory(
                        category.id,
                        subCategory: selected ? subCategory.id : '',
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
        ],

        // Products grid
        Expanded(
          child: _buildProductsGrid(productProvider),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(ProductProvider productProvider) {
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => productProvider.loadProducts(),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: productProvider.products.length + 
            (productProvider.isLoadingMore ? 2 : 0), // +2 for loading indicators
        itemBuilder: (context, index) {
          if (index >= productProvider.products.length) {
            // Loading indicator
            return const Center(child: CircularProgressIndicator());
          }

          final product = productProvider.products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, ProductProvider productProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterBottomSheet(productProvider: productProvider),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final ProductProvider productProvider;

  const FilterBottomSheet({
    Key? key,
    required this.productProvider,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late List<String> _selectedSizes;
  late List<String> _selectedColors;
  late List<String> _selectedBrands;
  late String _selectedSort;

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _availableColors = [
    'Black', 'White', 'Red', 'Blue', 'Green', 'Yellow', 'Pink', 'Purple'
  ];
  final List<String> _availableBrands = [
    'Nike', 'Adidas', 'Zara', 'H&M', 'Uniqlo', 'Forever 21'
  ];
  final Map<String, String> _sortOptions = {
    'name': 'Name A-Z',
    'price_low': 'Price: Low to High',
    'price_high': 'Price: High to Low',
    'rating': 'Highest Rated',
    'newest': 'Newest First',
  };

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.productProvider.minPrice,
      widget.productProvider.maxPrice,
    );
    _selectedSizes = List.from(widget.productProvider.selectedSizes);
    _selectedColors = List.from(widget.productProvider.selectedColors);
    _selectedBrands = List.from(widget.productProvider.selectedBrands);
    _selectedSort = widget.productProvider.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  _buildSortSection(),
                  const SizedBox(height: 24),

                  // Price Range
                  _buildPriceRangeSection(),
                  const SizedBox(height: 24),

                  // Sizes
                  _buildSizeSection(),
                  const SizedBox(height: 24),

                  // Colors
                  _buildColorSection(),
                  const SizedBox(height: 24),

                  // Brands
                  _buildBrandSection(),
                ],
              ),
            ),
          ),

          // Apply Button
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...(_sortOptions.entries.map((entry) {
          return RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: _selectedSort,
            onChanged: (value) {
              setState(() {
                _selectedSort = value!;
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        })),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 1000,
          divisions: 20,
          labels: RangeLabels(
            '\$${_priceRange.start.round()}',
            '\$${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${_priceRange.start.round()}'),
            Text('\$${_priceRange.end.round()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sizes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSizes.map((size) {
            final isSelected = _selectedSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSizes.add(size);
                  } else {
                    _selectedSizes.remove(size);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colors',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            final isSelected = _selectedColors.contains(color);
            return FilterChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedColors.add(color);
                  } else {
                    _selectedColors.remove(color);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brands',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableBrands.map((brand) {
            final isSelected = _selectedBrands.contains(brand);
            return FilterChip(
              label: Text(brand),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedBrands.add(brand);
                  } else {
                    _selectedBrands.remove(brand);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _selectedSizes.clear();
      _selectedColors.clear();
      _selectedBrands.clear();
      _selectedSort = 'name';
    });
  }

  void _applyFilters() {
    widget.productProvider.setPriceRange(_priceRange.start, _priceRange.end);
    widget.productProvider.setSizeFilter(_selectedSizes);
    widget.productProvider.setColorFilter(_selectedColors);
    widget.productProvider.setBrandFilter(_selectedBrands);
    widget.productProvider.setSortBy(_selectedSort);
    
    Navigator.pop(context);
  }
}
