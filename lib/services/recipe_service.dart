import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_app/models/recipe.dart';

class RecipeService {
  // This is a mock service. In a real app, you would use an actual API endpoint.
  final String _baseUrl = 'https://mockapi.example.com/api';
  
  // Mock data to simulate API responses
  final List<Map<String, dynamic>> _mockRecipes = [
    {
      'id': '1',
      'title': 'Spaghetti Carbonara',
      'image': 'https://images.pexels.com/photos/1527603/pexels-photo-1527603.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'cookingTime': 25,
      'difficulty': 'Medium',
      'servings': 4,
      'ingredients': [
        {'name': 'spaghetti', 'quantity': 400, 'unit': 'g'},
        {'name': 'pancetta or guanciale', 'quantity': 150, 'unit': 'g'},
        {'name': 'eggs', 'quantity': 4, 'unit': ''},
        {'name': 'Pecorino Romano cheese', 'quantity': 50, 'unit': 'g'},
        {'name': 'Parmesan cheese', 'quantity': 50, 'unit': 'g'},
        {'name': 'black pepper', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'salt', 'quantity': 1, 'unit': 'tsp'}
      ],
      'instructions': [
        'Bring a large pot of salted water to boil and cook the spaghetti according to package instructions until al dente.',
        'While the pasta is cooking, heat a large skillet over medium heat. Add the pancetta or guanciale and cook until crispy, about 5-7 minutes.',
        'In a bowl, whisk together the eggs, grated Pecorino, and Parmesan. Season with plenty of freshly ground black pepper.',
        'When the pasta is done, reserve 1/2 cup of pasta water, then drain the pasta.',
        'Working quickly, add the hot pasta to the skillet with the pancetta. Toss to combine.',
        'Remove the skillet from the heat and pour in the egg and cheese mixture, stirring constantly to create a creamy sauce. If needed, add a splash of the reserved pasta water to loosen the sauce.',
        'Serve immediately with extra grated cheese and black pepper on top.'
      ]
    },
    {
      'id': '2',
      'title': 'Chicken Tikka Masala',
      'image': 'https://images.pexels.com/photos/2474661/pexels-photo-2474661.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'cookingTime': 40,
      'difficulty': 'Medium',
      'servings': 4,
      'ingredients': [
        {'name': 'boneless chicken breasts', 'quantity': 800, 'unit': 'g'},
        {'name': 'yogurt', 'quantity': 150, 'unit': 'g'},
        {'name': 'lemon juice', 'quantity': 2, 'unit': 'tbsp'},
        {'name': 'garam masala', 'quantity': 2, 'unit': 'tsp'},
        {'name': 'cumin', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'coriander', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'turmeric', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'onion', 'quantity': 1, 'unit': 'large'},
        {'name': 'garlic cloves', 'quantity': 4, 'unit': ''},
        {'name': 'ginger', 'quantity': 1, 'unit': 'inch'},
        {'name': 'tomatoes', 'quantity': 400, 'unit': 'g'},
        {'name': 'heavy cream', 'quantity': 200, 'unit': 'ml'}
      ],
      'instructions': [
        'In a bowl, mix together the yogurt, lemon juice, 1 tsp garam masala, cumin, coriander, and turmeric.',
        'Cut the chicken into bite-sized pieces and add to the marinade. Mix well to coat and refrigerate for at least 1 hour, or overnight.',
        'Preheat oven to 400°F (200°C). Thread the chicken onto skewers and place on a baking sheet. Bake for 15 minutes until slightly charred.',
        'Meanwhile, heat oil in a large pan. Add chopped onions and cook until soft and translucent.',
        'Add minced garlic and ginger, cook for another minute until fragrant.',
        'Add crushed tomatoes, remaining garam masala, and salt. Simmer for 10-15 minutes until the sauce thickens.',
        'Stir in the cream and add the cooked chicken. Simmer for another 5 minutes.',
        'Garnish with fresh cilantro and serve with rice or naan bread.'
      ]
    },
    {
      'id': '3',
      'title': 'Vegetable Stir Fry',
      'image': 'https://images.pexels.com/photos/2347311/pexels-photo-2347311.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'cookingTime': 20,
      'difficulty': 'Easy',
      'servings': 4,
      'ingredients': [
        {'name': 'broccoli florets', 'quantity': 200, 'unit': 'g'},
        {'name': 'bell peppers', 'quantity': 2, 'unit': ''},
        {'name': 'carrots', 'quantity': 2, 'unit': ''},
        {'name': 'snow peas', 'quantity': 100, 'unit': 'g'},
        {'name': 'garlic cloves', 'quantity': 3, 'unit': ''},
        {'name': 'ginger', 'quantity': 1, 'unit': 'inch'},
        {'name': 'soy sauce', 'quantity': 3, 'unit': 'tbsp'},
        {'name': 'sesame oil', 'quantity': 1, 'unit': 'tbsp'},
        {'name': 'rice vinegar', 'quantity': 1, 'unit': 'tbsp'},
        {'name': 'honey', 'quantity': 1, 'unit': 'tbsp'},
        {'name': 'vegetable oil', 'quantity': 2, 'unit': 'tbsp'},
        {'name': 'sesame seeds', 'quantity': 1, 'unit': 'tbsp'}
      ],
      'instructions': [
        'Cut all vegetables into similar-sized pieces for even cooking.',
        'In a small bowl, mix together soy sauce, sesame oil, rice vinegar, and honey to make the sauce.',
        'Heat vegetable oil in a large wok or pan over high heat.',
        'Add minced garlic and ginger, stir for about 30 seconds until fragrant.',
        'Add harder vegetables first (carrots and broccoli), stir-fry for 2-3 minutes.',
        'Add bell peppers and snow peas, continue to stir-fry for another 2-3 minutes until vegetables are crisp-tender.',
        'Pour the sauce over the vegetables and toss to coat evenly. Cook for another minute.',
        'Sprinkle with sesame seeds and serve immediately over rice or noodles.'
      ]
    },
    {
      'id': '4',
      'title': 'Classic Beef Burger',
      'image': 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'cookingTime': 30,
      'difficulty': 'Easy',
      'servings': 4,
      'ingredients': [
        {'name': 'ground beef (80/20)', 'quantity': 800, 'unit': 'g'},
        {'name': 'salt', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'black pepper', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'garlic powder', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'onion powder', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'Worcestershire sauce', 'quantity': 1, 'unit': 'tbsp'},
        {'name': 'burger buns', 'quantity': 4, 'unit': ''},
        {'name': 'cheese slices', 'quantity': 4, 'unit': ''},
        {'name': 'lettuce leaves', 'quantity': 4, 'unit': ''},
        {'name': 'tomato slices', 'quantity': 8, 'unit': ''},
        {'name': 'onion slices', 'quantity': 4, 'unit': ''},
        {'name': 'pickles', 'quantity': 8, 'unit': 'slices'}
      ],
      'instructions': [
        'In a large bowl, combine ground beef, salt, pepper, garlic powder, onion powder, and Worcestershire sauce.',
        'Gently mix with your hands, being careful not to overwork the meat.',
        'Divide the mixture into 4 equal portions and form into patties slightly larger than your buns, as they will shrink when cooking.',
        'Make a slight depression in the center of each patty with your thumb to prevent it from puffing up during cooking.',
        'Preheat grill or skillet to medium-high heat. Cook patties for about 4-5 minutes per side for medium doneness.',
        'During the last minute of cooking, add cheese slices on top of the patties and cover to melt.',
        'Lightly toast the burger buns on the grill or in a toaster.',
        'Assemble burgers with lettuce, tomato, onion, pickles, and your favorite condiments.'
      ]
    },
    {
      'id': '5',
      'title': 'Chocolate Lava Cake',
      'image': 'https://images.pexels.com/photos/3992132/pexels-photo-3992132.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'cookingTime': 25,
      'difficulty': 'Medium',
      'servings': 4,
      'ingredients': [
        {'name': 'dark chocolate', 'quantity': 100, 'unit': 'g'},
        {'name': 'unsalted butter', 'quantity': 100, 'unit': 'g'},
        {'name': 'eggs', 'quantity': 2, 'unit': ''},
        {'name': 'egg yolks', 'quantity': 2, 'unit': ''},
        {'name': 'granulated sugar', 'quantity': 50, 'unit': 'g'},
        {'name': 'vanilla extract', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'all-purpose flour', 'quantity': 30, 'unit': 'g'},
        {'name': 'salt', 'quantity': 0.25, 'unit': 'tsp'},
        {'name': 'cocoa powder', 'quantity': 1, 'unit': 'tbsp'}
      ],
      'instructions': [
        'Preheat oven to 425°F (220°C). Butter and lightly flour four 6-ounce ramekins.',
        'In a heatproof bowl, combine chocolate and butter. Microwave in 30-second intervals, stirring between each, until melted and smooth.',
        'In another bowl, whisk together eggs, egg yolks, sugar, and vanilla until light and foamy.',
        'Gradually fold the chocolate mixture into the egg mixture until combined.',
        'Gently fold in the flour and salt until just mixed.',
        'Divide the batter evenly among the prepared ramekins.',
        'Place ramekins on a baking sheet and bake for 12-14 minutes until the edges are firm but the center is still soft.',
        'Let cool for 1 minute, then run a knife around the edges and invert onto serving plates. Dust with cocoa powder and serve immediately.'
      ]
    },
    {
      'id': '6',
      'title': 'Greek Salad',
      'image': 'https://images.pexels.com/photos/1211887/pexels-photo-1211887.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'cookingTime': 15,
      'difficulty': 'Easy',
      'servings': 4,
      'ingredients': [
        {'name': 'cucumber', 'quantity': 1, 'unit': 'large'},
        {'name': 'red onion', 'quantity': 1, 'unit': 'small'},
        {'name': 'tomatoes', 'quantity': 4, 'unit': 'medium'},
        {'name': 'green bell pepper', 'quantity': 1, 'unit': ''},
        {'name': 'kalamata olives', 'quantity': 100, 'unit': 'g'},
        {'name': 'feta cheese', 'quantity': 200, 'unit': 'g'},
        {'name': 'extra virgin olive oil', 'quantity': 4, 'unit': 'tbsp'},
        {'name': 'red wine vinegar', 'quantity': 2, 'unit': 'tbsp'},
        {'name': 'dried oregano', 'quantity': 1, 'unit': 'tsp'},
        {'name': 'salt', 'quantity': 0.5, 'unit': 'tsp'},
        {'name': 'black pepper', 'quantity': 0.25, 'unit': 'tsp'}
      ],
      'instructions': [
        'Cut cucumber into thick half-moons, quarter the tomatoes, thinly slice the red onion, and dice the bell pepper.',
        'In a large bowl, combine all the vegetables.',
        'Add the olives and cubed or crumbled feta cheese on top.',
        'In a small bowl, whisk together olive oil, red wine vinegar, oregano, salt, and pepper.',
        'Pour the dressing over the salad right before serving.',
        'Gently toss to combine all ingredients.',
        'Serve immediately for the freshest taste and texture.'
      ]
    }
  ];

  // Simulate API delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Get all recipes with pagination
  Future<List<Recipe>> getRecipes(int page, {int limit = 6}) async {
    await _delay();
    
    final start = (page - 1) * limit;
    final end = start + limit;
    
    final recipes = _mockRecipes
        .skip(start)
        .take(limit)
        .map((json) => Recipe.fromJson(json))
        .toList();
    
    return recipes;
  }

  // Get a specific recipe by ID
  Future<Recipe> getRecipeById(String id) async {
    await _delay();
    
    final recipeJson = _mockRecipes.firstWhere(
      (recipe) => recipe['id'] == id,
      orElse: () => throw Exception('Recipe not found'),
    );
    
    return Recipe.fromJson(recipeJson);
  }

  // Get multiple recipes by IDs (for favorites)
  Future<List<Recipe>> getFavoriteRecipes(List<String> ids) async {
    await _delay();
    
    final recipes = _mockRecipes
        .where((recipe) => ids.contains(recipe['id']))
        .map((json) => Recipe.fromJson(json))
        .toList();
    
    return recipes;
  }
}