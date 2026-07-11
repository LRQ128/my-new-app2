import 'package:flutter/foundation.dart';
import '../models/dish.dart';
import '../services/database_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Dish> _dishes = [];
  List<OrderItem> _orders = [];
  bool _isLoading = false;
  int _currentPerson = 0; // 0=点菜人, 1=买菜人
  int _selectedCategoryIndex = 0;

  List<Dish> get dishes => _dishes;
  List<OrderItem> get orders => _orders;
  bool get isLoading => _isLoading;
  int get currentPerson => _currentPerson;
  String get currentPersonName => _currentPerson == 0 ? '点菜人' : '买菜人';
  int get selectedCategoryIndex => _selectedCategoryIndex;

  set selectedCategoryIndex(int val) {
    _selectedCategoryIndex = val;
    notifyListeners();
  }

  List<String> get categories => ['全部', '肉类🍖', '炒菜🥘', '主食🍚', '海鲜🦞', '凉菜🥗', '砂锅系列🍲', '臭臭💩(但爱吃)'];

  List<Dish> get filteredDishes {
    if (_selectedCategoryIndex == 0) return _dishes;
    final cat = categories[_selectedCategoryIndex].replaceAll(RegExp(r'[🍖🥘🍚🦞🥗🍲💩]'), '').trim();
    return _dishes.where((d) => d.category.contains(cat)).toList();
  }

  List<OrderItem> get kitchenOrders => _orders.where((o) => o.status == OrderStatus.ordered).toList();
  List<OrderItem> get myOrders => _orders.where((o) => o.orderBy == _currentPerson).toList();
  int get orderCounter => _orders.length + 1; // 用于取餐码

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dishes = await DatabaseService.getAllDishes();
      _orders = await DatabaseService.getAllOrders();
    } catch (e) {
      debugPrint('loadData error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void switchPerson() {
    _currentPerson = 1 - _currentPerson;
    notifyListeners();
  }

  Future<void> addOrder(Dish dish, {String notes = ''}) async {
    final code = (1000 + _orders.length + 1).toString();
    final order = OrderItem(
      dish: dish,
      orderBy: _currentPerson,
      notes: notes,
      orderCode: code,
      userId: '4DR5Q', // 固定用户
    );

    await DatabaseService.addOrder(order);
    await loadData();
  }

  Future<void> completeOrder(int orderId) async {
    await DatabaseService.updateOrderStatus(orderId, OrderStatus.cooked);
    await loadData();
  }

  Future<void> cancelOrder(int orderId) async {
    await DatabaseService.updateOrderStatus(orderId, OrderStatus.cooked); // 标记完成（取消等同于完成）
    await loadData();
  }

  Future<void> deleteOrder(int orderId) async {
    await DatabaseService.deleteOrder(orderId);
    await loadData();
  }
}
