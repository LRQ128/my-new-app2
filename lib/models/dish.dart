import 'dart:convert';

class Ingredient {
  final String name;
  final String amount;
  final bool isMain;

  Ingredient({
    required this.name,
    required this.amount,
    this.isMain = true,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'amount': amount,
        'isMain': isMain ? 1 : 0,
      };

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
        name: map['name'] ?? '',
        amount: map['amount'] ?? '',
        isMain: (map['isMain'] ?? 0) == 1,
      );
}

class Recipe {
  final int? id;
  final int dishId;
  final String dishName;
  final List<Ingredient> ingredients;
  final List<String> steps;

  Recipe({
    this.id,
    required this.dishId,
    required this.dishName,
    required this.ingredients,
    this.steps = const [],
  });

  String get shoppingList {
    final mains = ingredients.where((i) => i.isMain).map((i) => '${i.name}: ${i.amount}');
    final seasonings = ingredients.where((i) => !i.isMain).map((i) => '${i.name}: ${i.amount}');
    return '【主料】\n${mains.join('\n')}\n\n【配料/调料】\n${seasonings.join('\n')}';
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'dishId': dishId,
        'dishName': dishName,
        'ingredients': jsonEncode(ingredients.map((i) => i.toMap()).toList()),
        'steps': jsonEncode(steps),
      };

  factory Recipe.fromMap(Map<String, dynamic> map) => Recipe(
        id: map['id'],
        dishId: map['dishId'] ?? 0,
        dishName: map['dishName'] ?? '',
        ingredients: (jsonDecode(map['ingredients'] ?? '[]') as List)
            .map((e) => Ingredient.fromMap(e))
            .toList(),
        steps: (jsonDecode(map['steps'] ?? '[]') as List).cast<String>(),
      );
}

class Dish {
  final int? id;
  final String name;
  final String category;
  final double estimatedPrice;
  final Recipe? recipe;
  final String imageUrl;
  final double rating; // 评分 1-5
  final int salesCount; // 销量
  final int popularity; // 人气值 (🍃图标)
  final String description; // 简短描述
  final DateTime createdAt;

  Dish({
    this.id,
    required this.name,
    this.category = '肉类',
    this.estimatedPrice = 0,
    this.recipe,
    this.imageUrl = '',
    this.rating = 5.0,
    this.salesCount = 0,
    this.popularity = 0,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'category': category,
        'estimatedPrice': estimatedPrice,
        'imageUrl': imageUrl,
        'rating': rating,
        'salesCount': salesCount,
        'popularity': popularity,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Dish.fromMap(Map<String, dynamic> map) => Dish(
        id: map['id'],
        name: map['name'] ?? '',
        category: map['category'] ?? '肉类',
        estimatedPrice: (map['estimatedPrice'] ?? 0).toDouble(),
        imageUrl: map['imageUrl'] ?? '',
        rating: (map['rating'] ?? 5.0).toDouble(),
        salesCount: map['salesCount'] ?? 0,
        popularity: map['popularity'] ?? 0,
        description: map['description'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );
}

// 订单状态
enum OrderStatus { ordered, bought, cooked }

class OrderItem {
  final int? id;
  final Dish dish;
  final int orderBy; // 0=点菜人, 1=买菜人
  final OrderStatus status;
  final double actualCost;
  final DateTime orderDate;
  final String notes;
  final String orderCode; // 取餐码
  final String userId;

  OrderItem({
    this.id,
    required this.dish,
    this.orderBy = 0,
    this.status = OrderStatus.ordered,
    this.actualCost = 0,
    DateTime? orderDate,
    this.notes = '',
    this.orderCode = '',
    this.userId = '',
  }) : orderDate = orderDate ?? DateTime.now();

  String get statusText {
    switch (status) {
      case OrderStatus.ordered:
        return '未完成';
      case OrderStatus.bought:
        return '已买';
      case OrderStatus.cooked:
        return '已完成';
    }
  }

  bool get isComplete => status == OrderStatus.cooked;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'dishId': dish.id,
        'dishName': dish.name,
        'dishCategory': dish.category,
        'orderBy': orderBy,
        'status': status.index,
        'actualCost': actualCost,
        'orderDate': orderDate.toIso8601String(),
        'notes': notes,
        'orderCode': orderCode,
        'userId': userId,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map, {Dish? dish}) => OrderItem(
        id: map['id'],
        dish: dish ??
            Dish(
              name: map['dishName'] ?? '',
              category: map['dishCategory'] ?? '肉类',
            ),
        orderBy: map['orderBy'] ?? 0,
        status: OrderStatus.values[map['status'] ?? 0],
        actualCost: (map['actualCost'] ?? 0).toDouble(),
        orderDate: DateTime.tryParse(map['orderDate'] ?? '') ?? DateTime.now(),
        notes: map['notes'] ?? '',
        orderCode: map['orderCode'] ?? '',
        userId: map['userId'] ?? '',
      );
}
