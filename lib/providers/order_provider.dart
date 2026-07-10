import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../services/database_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Dish> _dishes = [];
  List<OrderItem> _todayOrders = [];
  List<OrderItem> _allOrders = [];
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  int _currentPerson = 0; // 0=点菜人, 1=买菜人

  List<Dish> get dishes => _dishes;
  List<OrderItem> get todayOrders => _todayOrders;
  List<OrderItem> get allOrders => _allOrders;
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  int get currentPerson => _currentPerson;

  String get currentPersonName => _currentPerson == 0 ? '点菜人' : '买菜人';

  void switchPerson() {
    _currentPerson = _currentPerson == 0 ? 1 : 0;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _dishes = await DatabaseService.getAllDishes();
    _allOrders = await DatabaseService.getAllOrders();
    _recipes = await DatabaseService.getAllRecipes();
    _todayOrders = await DatabaseService.getOrdersByDate(DateTime.now());

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrder(Dish dish, {String notes = ''}) async {
    final order = OrderItem(
      dish: dish,
      orderBy: _currentPerson,
      notes: notes,
    );
    await DatabaseService.addOrder(order);
    await loadData();
  }

  Future<void> updateStatus(int orderId, OrderStatus status) async {
    await DatabaseService.updateOrderStatus(orderId, status);
    await loadData();
  }

  Future<void> updateCost(int orderId, double cost) async {
    await DatabaseService.updateOrderCost(orderId, cost);
    await loadData();
  }

  // 获取购物清单（所有已点但还没买或没做的菜的材料）
  List<Map<String, String>> getShoppingList() {
    final shoppingMap = <String, Map<String, String>>{};

    for (final order in _allOrders) {
      if (order.status == OrderStatus.ordered || order.status == OrderStatus.bought) {
        final recipe = _recipes.where((r) => r.dishId == order.dish.id).firstOrNull;
        if (recipe != null) {
          for (final ing in recipe.ingredients) {
            if (shoppingMap.containsKey(ing.name)) {
              // 合并同类项，简单处理
            } else {
              shoppingMap[ing.name] = {'name': ing.name, 'amount': ing.amount, 'type': ing.isMain ? '主料' : '配料'};
            }
          }
        }
      }
    }

    return shoppingMap.values.toList()
      ..sort((a, b) => a['type']!.compareTo(b['type']!));
  }

  List<Map<String, String>> getCookingList() {
    final result = <Map<String, String>>[];
    for (final order in _allOrders) {
      if (order.status == OrderStatus.bought || order.status == OrderStatus.ordered) {
        final recipe = _recipes.where((r) => r.dishId == order.dish.id).firstOrNull;
        result.add({
          'dishName': order.dish.name,
          'steps': recipe?.steps.join('\n') ?? '暂无菜谱',
        });
      }
    }
    return result;
  }
}
