// lib/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  // int _currentPage = 1; // Artık doğrudan pagination yapmadığımız için kaldırılabilir
  // bool _hasMoreRecipes = true; // Artık doğrudan pagination yapmadığımız için kaldırılabilir
  String _searchQuery = '';

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  // bool get hasMoreRecipes => _hasMoreRecipes; // Kaldırıldı
  String get searchQuery => _searchQuery;

  // fetchRecipes metodunu, varsayılan olarak bir kategoriye göre veya rastgele tarifler getirecek şekilde güncelledik.
  // TheMealDB'de doğrudan sayfalama (pagination) destekleyen bir 'tüm tarifleri getir' endpoint'i olmadığı için,
  // bu metodu belirli bir kategoriye göre tarifleri getirecek şekilde basitleştiriyoruz.
  // Örneğin, "Dessert" kategorisinden tarifleri getirelim.
  Future<void> fetchRecipes({bool refresh = false}) async {
    // if (refresh) { // Pagination olmadığı için refresh logic'i de basitleştirildi
    //   _currentPage = 1;
    //   _hasMoreRecipes = true;
    // }

    // if (!_hasMoreRecipes && !refresh) return; // Kaldırıldı

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // _recipeService.getRecipes(_currentPage) yerine fetchRecipesByCategory kullanıldı
      // Veya isterseniz RecipeService'e random tarif getiren bir metot ekleyebilirsiniz.
      // Şimdilik varsayılan olarak "Dessert" kategorisini getiriyoruz.
      final newRecipes = await _recipeService.fetchRecipesByCategory('Dessert');

      // refresh parametresi hala kullanılabilir, tüm listeyi yenilemek için
      if (refresh) {
        _recipes = newRecipes;
      } else {
        // Eğer yeni tarifler ekleniyorsa, tekrarları önlemek için dikkatli olunmalı
        // TheMealDB'de getByCategory zaten her seferinde aynı listeyi dönebilir
        // Bu örnekte basitçe ekleyelim veya sadece 'refresh' ile tam liste yenileyelim.
        // Şimdilik sadece refresh durumunda _recipes'i güncelleyelim.
        _recipes = newRecipes; // Sadece yenileme durumunda listeyi güncelleyelim.
      }

      // _currentPage++; // Kaldırıldı
      // _hasMoreRecipes = newRecipes.isNotEmpty; // Kaldırıldı (şimdilik)
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load recipes. Please try again later.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // getRecipeById metodu fetchRecipeById olarak güncellendi
  Future<Recipe?> fetchRecipeById(String id) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // _recipeService.getRecipeById(id) yerine fetchRecipeById kullanıldı
      final recipe = await _recipeService.fetchRecipeById(id);
      _isLoading = false;
      notifyListeners();
      return recipe;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load recipe. Please try again later.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Home Screen'de arama filtrelemesi için
  List<Recipe> get filteredRecipes {
    if (_searchQuery.isEmpty) {
      return _recipes;
    }
    return _recipes
        .where((recipe) =>
        recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
}