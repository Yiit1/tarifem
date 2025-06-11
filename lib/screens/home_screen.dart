// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/providers/recipe_provider.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_app/models/recipe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  // final ScrollController _scrollController = ScrollController(); // Infinite scroll kaldırıldığı için kaldırıldı

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll); // Infinite scroll kaldırıldığı için kaldırıldı

    // ilk tarifleri fetchleme (Refresh ile ilk yüklemede veya yenilemede tüm listeyi getirir)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeProvider = context.read<RecipeProvider>();
      _searchController.text = recipeProvider.searchQuery; // currentSearchQuery yerine searchQuery
      recipeProvider.fetchRecipes(refresh: true); // İlk yüklemede ve yenilemede fetchRecipes'i çağır
    });
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll); // Infinite scroll kaldırıldığı için kaldırıldı
    // _scrollController.dispose(); // Infinite scroll kaldırıldığı için kaldırıldı
    _searchController.dispose();
    super.dispose();
  }

  // Infinite scroll mantığı artık kullanılmadığı için _onScroll metodu kaldırıldı.
  // void _onScroll() {
  //   if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
  //     final recipeProvider = context.read<RecipeProvider>();
  //     if (!recipeProvider.isLoading && recipeProvider.hasMoreRecipes) {
  //       recipeProvider.fetchRecipes();
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/shopping-list'),
          ),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          final filteredRecipes = recipeProvider.filteredRecipes;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    suffixIcon: recipeProvider.searchQuery.isNotEmpty // currentSearchQuery yerine searchQuery
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        recipeProvider.setSearchQuery('');
                        recipeProvider.fetchRecipes(refresh: true); // Yeniden tüm tarifleri çek (varsayılan kategori)
                      },
                    )
                        : null,
                  ),
                  onChanged: (value) {
                    recipeProvider.setSearchQuery(value);
                  },
                  onSubmitted: (value) {
                    // Arama yapıldığında, provider'ın kendi filtreleme mantığı çalışacak.
                    // API'den yeniden arama yapmak isterseniz, burada farklı bir metod çağırabilirsiniz.
                    // Şimdilik sadece mevcut listede filtreleme yapıyoruz.
                  },
                ),
              ),
              Expanded(
                child: _buildRecipeList(recipeProvider, filteredRecipes),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipeList(RecipeProvider recipeProvider, List<Recipe> filteredRecipes) {
    if (recipeProvider.isLoading && filteredRecipes.isEmpty) {
      // Yükleniyor ve henüz hiç tarif yoksa
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
                recipeProvider.fetchRecipes(refresh: true); // Tekrar Dene butonunda fetchRecipes'i çağır
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (filteredRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No recipes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipeProvider.searchQuery.isNotEmpty // currentSearchQuery yerine searchQuery
                  ? 'Try different search terms'
                  : 'Check your internet connection or try again later.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            if (recipeProvider.searchQuery.isNotEmpty) // currentSearchQuery yerine searchQuery
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  recipeProvider.setSearchQuery('');
                  recipeProvider.fetchRecipes(refresh: true); // Rastgele tarifleri tekrar çek
                },
                child: const Text('Tüm Tarifleri Göster'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => recipeProvider.fetchRecipes(refresh: true), // Refresh yapıldığında fetchRecipes'i çağır
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          // scrollController kaldırıldı
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: filteredRecipes.length, // Yükleniyor göstergesi kaldırıldığı için düzeltildi
          itemBuilder: (context, index) {
            // Infinite scroll kaldırıldığı için loading indicator kontrolü kaldırıldı
            // if (index >= filteredRecipes.length) {
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
            // }

            final recipe = filteredRecipes[index];
            return RecipeCard(
              recipe: recipe,
              onTap: () => context.push('/recipe/${recipe.id}'),
            );
          },
        ),
      ),
    );
  }
}