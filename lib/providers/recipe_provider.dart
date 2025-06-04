import 'package:flutter/material.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreRecipes = true;
  String _searchQuery = '';

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get hasMoreRecipes => _hasMoreRecipes;
  String get searchQuery => _searchQuery;

  Future<void> fetchRecipes({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreRecipes = true;
    }

    if (!_hasMoreRecipes && !refresh) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final newRecipes = await _recipeService.getRecipes(_currentPage);
      
      if (refresh) {
        _recipes = newRecipes;
      } else {
        _recipes = [..._recipes, ...newRecipes];
      }
      
      _currentPage++;
      _hasMoreRecipes = newRecipes.isNotEmpty;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load recipes. Please try again later.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Recipe?> fetchRecipeById(String id) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final recipe = await _recipeService.getRecipeById(id);
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

  List<Recipe> get filteredRecipes {
    if (_searchQuery.isEmpty) {
      return _recipes;
    }
    
    return _recipes.where((recipe) => 
      recipe.title.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
}