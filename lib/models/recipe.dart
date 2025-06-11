// lib/models/recipe.dart
class Recipe {
  final String id;
  final String title;
  final String image;
  // cookingTime ve difficulty kaldırıldı
  final String? category; // Yeni eklendi
  final String? area; // Yeni eklendi
  final String? youtubeLink; // Yeni eklendi
  final List<Ingredient> ingredients;
  final String? instructions; // List<String> yerine String? olarak değiştirildi

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    // this.cookingTime, // Kaldırıldı
    // this.difficulty, // Kaldırıldı
    this.category, // Opsiyonel yapıldı
    this.area, // Opsiyonel yapıldı
    this.youtubeLink, // Opsiyonel yapıldı
    required this.ingredients,
    this.instructions, // Opsiyonel yapıldı
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // TheMealDB API'sından gelen malzemeler strIngredient1-20 ve strMeasure1-20 olarak gelir.
    List<Ingredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredientName = json['strIngredient$i'];
      final ingredientMeasure = json['strMeasure$i'];

      if (ingredientName != null && ingredientName.isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredientName,
          quantity: ingredientMeasure ?? '', // Miktar artık string
          unit: '', // TheMealDB'de ayrı bir 'unit' alanı yok, measure ile birleşiyor
        ));
      }
    }

    return Recipe(
      id: json['idMeal'], // TheMealDB'den idMeal olarak geliyor
      title: json['strMeal'], // TheMealDB'den strMeal olarak geliyor
      image: json['strMealThumb'], // TheMealDB'den strMealThumb olarak geliyor
      category: json['strCategory'], // TheMealDB'den strCategory
      area: json['strArea'], // TheMealDB'den strArea
      youtubeLink: json['strYoutube'], // TheMealDB'den strYoutube
      ingredients: ingredients,
      instructions: json['strInstructions'], // String? olarak alınıyor
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      // 'cookingTime': cookingTime, // Kaldırıldı
      // 'difficulty': difficulty, // Kaldırıldı
      'category': category,
      'area': area,
      'youtubeLink': youtubeLink,
      'ingredients': ingredients.map((x) => x.toJson()).toList(),
      'instructions': instructions,
    };
  }
}

class Ingredient {
  final String name;
  final String quantity; // double yerine String olarak değiştirildi
  final String unit; // Kullanım dışı bırakılabilir veya TheMealDB'ye göre ayarlanabilir

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit, // Hala tutulabilir, ancak TheMealDB'de genelde measure içinde birleşiyor
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    // Bu metod TheMealDB'ye uyumlu hale getirilmeli.
    // TheMealDB'de Ingredient tek bir JSON objesi olarak değil,
    // 'strIngredientX' ve 'strMeasureX' olarak gelir.
    // Bu metod, Recipe.fromJson içindeki manuel parse ile geçersiz kılındı.
    // Ancak yine de bir yerden çağrılıyorsa düzeltilmeli.
    // Şimdilik varsayımsal olarak bırakıyorum ama dikkat edin.
    return Ingredient(
      name: json['name'] ?? '',
      quantity: json['quantity']?.toString() ?? '', // String'e çevriliyor
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}