class Recipe {
  final String id;
  final String title;
  final String image;
  final int cookingTime;
  final String difficulty;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.cookingTime,
    required this.difficulty,
    required this.servings,
    required this.ingredients,
    required this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      cookingTime: json['cookingTime'],
      difficulty: json['difficulty'],
      servings: json['servings'],
      ingredients: List<Ingredient>.from(
          json['ingredients'].map((x) => Ingredient.fromJson(x))),
      instructions: List<String>.from(json['instructions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'servings': servings,
      'ingredients': ingredients.map((x) => x.toJson()).toList(),
      'instructions': instructions,
    };
  }
}

class Ingredient {
  final String name;
  final double quantity;
  final String unit;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      quantity: json['quantity'] is int 
          ? (json['quantity'] as int).toDouble() 
          : json['quantity'],
      unit: json['unit'],
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