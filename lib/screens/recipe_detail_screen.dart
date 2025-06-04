import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/providers/favorites_provider.dart';
import 'package:recipe_app/providers/recipe_provider.dart';
import 'package:recipe_app/providers/shopping_list_provider.dart';
import 'package:share_plus/share_plus.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String id;

  const RecipeDetailScreen({
    super.key,
    required this.id,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isFavorite = false;
  int _servings = 4;
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _loadRecipe();
    _checkFavoriteStatus();
    _scrollController.addListener(_updateScrollOffset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollOffset);
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  void _updateScrollOffset() {
    _scrollOffset.value = _scrollController.offset;
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _loading = true;
    });

    final recipe = await context.read<RecipeProvider>().fetchRecipeById(widget.id);
    
    if (mounted) {
      setState(() {
        _recipe = recipe;
        _servings = recipe?.servings ?? 4;
        _loading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await context.read<FavoritesProvider>().isFavorite(widget.id);
    
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  void _adjustServings(int change) {
    final newServings = _servings + change;
    if (newServings >= 1 && newServings <= 12) {
      setState(() {
        _servings = newServings;
      });
    }
  }

  double _calculateAdjustedQuantity(double quantity) {
    if (_recipe == null) return quantity;
    return quantity / _recipe!.servings * _servings;
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(1);
  }

  void _toggleFavorite() {
    if (_recipe != null) {
      context.read<FavoritesProvider>().toggleFavorite(_recipe!);
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  void _shareRecipe() {
    if (_recipe != null) {
      Share.share(
        'Check out this recipe for ${_recipe!.title}! It takes ${_recipe!.cookingTime} minutes to prepare.',
        subject: _recipe!.title,
      );
    }
  }

  void _addIngredientsToShoppingList() {
    if (_recipe == null) return;
    
    final shoppingListProvider = context.read<ShoppingListProvider>();
    
    for (var ingredient in _recipe!.ingredients) {
      final adjustedQuantity = _calculateAdjustedQuantity(ingredient.quantity);
      final formattedQuantity = _formatQuantity(adjustedQuantity);
      final unit = ingredient.unit.isNotEmpty ? ingredient.unit : '';
      final quantityText = '$formattedQuantity $unit'.trim();
      
      shoppingListProvider.addItem(ingredient.name, quantityText);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ingredients added to shopping list'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Recipe not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The recipe you\'re looking for doesn\'t exist.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Recipe image with parallax effect
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: _recipe!.image,
                    fit: BoxFit.cover,
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      onPressed: _shareRecipe,
                    ),
                  ),
                ],
              ),
              
              // Recipe content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and metadata
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _recipe!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_recipe!.cookingTime} mins',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _recipe!.difficulty,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: _recipe!.difficulty == 'Easy'
                                      ? Colors.green
                                      : _recipe!.difficulty == 'Medium'
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Servings adjuster
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Row(
                        children: [
                          const Text(
                            'Servings:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _servings > 1
                                ? () => _adjustServings(-1)
                                : null,
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_servings',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _servings < 12
                                ? () => _adjustServings(1)
                                : null,
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Ingredients
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Add All'),
                                onPressed: _addIngredientsToShoppingList,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            _recipe!.ingredients.length,
                            (index) {
                              final ingredient = _recipe!.ingredients[index];
                              final adjustedQuantity = _calculateAdjustedQuantity(ingredient.quantity);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _formatQuantity(adjustedQuantity),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (ingredient.unit.isNotEmpty)
                                      Text(
                                        ingredient.unit,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(ingredient.name),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Instructions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Instructions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            _recipe!.instructions.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _recipe!.instructions[index],
                                      style: const TextStyle(
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Add bottom padding
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}