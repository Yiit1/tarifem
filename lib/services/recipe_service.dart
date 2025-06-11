// lib/services/recipe_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_app/models/recipe.dart';

class RecipeService {
  // TheMealDB API base URL
  final String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // ID'ye göre tek bir tarif getir
  Future<Recipe?> fetchRecipeById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          // Recipe.fromJsonTheMealDB yerine Recipe.fromJson kullanıldı
          return Recipe.fromJson(data['meals'][0]);
        } else {
          return null; // Tarif bulunamadı
        }
      } else {
        throw Exception('Failed to load recipe: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipe by ID: $e');
      throw Exception('Failed to load recipe. Please check your network connection.');
    }
  }

  // Kategoriye göre tarifleri getir (TheMealDB'de doğrudan sayfalama yok, bu yüzden kategori bazlı çekiyoruz)
  // Veya tüm tarifleri getirmek için random kullanabiliriz, ama bu örnekte kategori bazlı filtreleme yapalım
  Future<List<Recipe>> fetchRecipesByCategory(String categoryName) async {
    List<Recipe> recipes = [];
    try {
      final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=$categoryName'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          for (var mealJson in data['meals']) {
            // Sadece liste için basit Recipe objesi oluşturuyoruz (detayları değil)
            // Detayları RecipeDetailScreen'de çekeceğiz
            recipes.add(Recipe(
              id: mealJson['idMeal'],
              title: mealJson['strMeal'],
              image: mealJson['strMealThumb'],
              // Diğer alanlar burada dolu değil, detay ekranında çekilecek
              ingredients: [],
              instructions: null,
            ));
          }
        }
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes by category: $e');
      throw Exception('Failed to load recipes. Please check your network connection.');
    }
    return recipes;
  }

  // Arama sorgusuna göre tarifleri getir
  Future<List<Recipe>> searchRecipes(String query) async {
    List<Recipe> recipes = [];
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$query'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          // Buradaki her bir meal için tam detayları çekmek yerine,
          // sadece id, title, image alanlarını içeren basit bir Recipe objesi oluşturuyoruz.
          // Çünkü arama sonuç listesi için tam detaylar gereksizdir.
          // Detaylar yine RecipeDetailScreen'de çekilecek.
          recipes = List<Recipe>.from(data['meals'].map((json) => Recipe(
            id: json['idMeal'],
            title: json['strMeal'],
            image: json['strMealThumb'],
            ingredients: [],
            instructions: null,
          )));
        }
      } else {
        throw Exception('Failed to search recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching recipes: $e');
      throw Exception('Failed to search recipes. Please check your network connection.');
    }
    return recipes;
  }

  // Favori ID'lerine göre tarifleri getir (bu metot muhtemelen FavoritesProvider tarafından kullanılır)
  Future<List<Recipe>> getFavoriteRecipes(List<String> ids) async {
    List<Recipe> favoriteRecipes = [];
    for (String id in ids) {
      try {
        final recipe = await fetchRecipeById(id);
        if (recipe != null) {
          favoriteRecipes.add(recipe);
        }
      } catch (e) {
        print('Error fetching favorite recipe with ID $id: $e');
      }
    }
    return favoriteRecipes;
  }

// TheMealDB API'sında doğrudan rastgele tarif listesi veya tüm tarifler için bir endpoint yok.
// Bu yüzden 'getRecipes' metodunu, TheMealDB'nin kategorilerine göre tarifleri getirecek şekilde değiştirdim.
// Veya bu listelemeyi "Random Meals" gibi düşünebiliriz.
// Şimdilik categoryName'e göre çalışan fetchRecipesByCategory'ı doğrudan kullanalım
// ya da basitçe rastgele 10 tarif çekmek için yeni bir metot ekleyelim.
// Mevcut yapıda "pagination" desteklemediğimiz için, Home Screen'de
// belirli bir kategoriye ait tarifleri listeleme veya rastgele tarifleri getirme yoluna gidebiliriz.
// Basitlik adına, Home Screen'de "Chicken" gibi varsayılan bir kategori belirleyebiliriz.
// getRecipes yerine fetchRecipesByCategory kullanacağız.
}