import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/providers/recipe_provider.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch initial recipes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().fetchRecipes();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final recipeProvider = context.read<RecipeProvider>();
      if (!recipeProvider.isLoading && recipeProvider.hasMoreRecipes) {
        recipeProvider.fetchRecipes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer<RecipeProvider>(
              builder: (context, recipeProvider, child) {
                return TextField(
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: recipeProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              recipeProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    recipeProvider.setSearchQuery(value);
                  },
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading && recipeProvider.recipes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (recipeProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    recipeProvider.errorMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      recipeProvider.fetchRecipes(refresh: true);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final filteredRecipes = recipeProvider.filteredRecipes;
          
          if (filteredRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No recipes found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (recipeProvider.searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Try different search terms',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => recipeProvider.fetchRecipes(refresh: true),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredRecipes.length + (recipeProvider.isLoading ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index >= filteredRecipes.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  final recipe = filteredRecipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    onTap: () => context.push('/recipe/${recipe.id}'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}