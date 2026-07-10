import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dish.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'order_cook.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 菜品库
        await db.execute('''
          CREATE TABLE dishes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT DEFAULT '荤菜',
            estimatedPrice REAL DEFAULT 0,
            imageUrl TEXT DEFAULT '',
            createdAt TEXT NOT NULL
          )
        ''');

        // 菜谱（智能菜谱）
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dishId INTEGER NOT NULL,
            dishName TEXT NOT NULL,
            ingredients TEXT,
            steps TEXT,
            FOREIGN KEY (dishId) REFERENCES dishes(id) ON DELETE CASCADE
          )
        ''');

        // 订单记录
        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dishId INTEGER NOT NULL,
            dishName TEXT NOT NULL,
            dishCategory TEXT DEFAULT '荤菜',
            orderBy INTEGER DEFAULT 0,
            status INTEGER DEFAULT 0,
            actualCost REAL DEFAULT 0,
            orderDate TEXT NOT NULL,
            notes TEXT DEFAULT '',
            FOREIGN KEY (dishId) REFERENCES dishes(id)
          )
        ''');

        // 做菜记账
        await db.execute('''
          CREATE TABLE cooking_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            totalCost REAL DEFAULT 0,
            orderIds TEXT,
            paidBy INTEGER DEFAULT 0,
            notes TEXT DEFAULT ''
          )
        ''');

        // 插入默认菜谱
        await _insertDefaultDishes(db);
      },
    );
  }

  static Future<void> _insertDefaultDishes(Database db) async {
    final defaultDishes = [
      {
        'name': '番茄炒蛋',
        'category': '素菜',
        'estimatedPrice': 15.0,
        'ingredients': [
          {'name': '西红柿', 'amount': '2个', 'isMain': 1},
          {'name': '鸡蛋', 'amount': '3个', 'isMain': 1},
          {'name': '葱花', 'amount': '适量', 'isMain': 0},
          {'name': '盐', 'amount': '适量', 'isMain': 0},
          {'name': '糖', 'amount': '1小勺', 'isMain': 0},
          {'name': '食用油', 'amount': '适量', 'isMain': 0},
        ],
        'steps': [
          '西红柿切块，鸡蛋打散',
          '热锅凉油，先炒鸡蛋至凝固盛出',
          '再炒西红柿至出汁',
          '倒入炒好的鸡蛋翻炒均匀',
          '加盐和糖调味，撒葱花出锅',
        ],
      },
      {
        'name': '红烧肉',
        'category': '荤菜',
        'estimatedPrice': 35.0,
        'ingredients': [
          {'name': '五花肉', 'amount': '500g', 'isMain': 1},
          {'name': '姜', 'amount': '3片', 'isMain': 0},
          {'name': '葱', 'amount': '2根', 'isMain': 0},
          {'name': '八角', 'amount': '2个', 'isMain': 0},
          {'name': '生抽', 'amount': '2勺', 'isMain': 0},
          {'name': '老抽', 'amount': '1勺', 'isMain': 0},
          {'name': '冰糖', 'amount': '20g', 'isMain': 0},
          {'name': '料酒', 'amount': '1勺', 'isMain': 0},
        ],
        'steps': [
          '五花肉切块，冷水下锅焯水去血沫',
          '热锅少油，放入冰糖炒出糖色',
          '下五花肉翻炒上色',
          '加入姜、葱、八角、料酒、生抽、老抽',
          '加入没过肉的热水，大火烧开转小火炖40分钟',
          '大火收汁即可',
        ],
      },
      {
        'name': '清炒时蔬',
        'category': '素菜',
        'estimatedPrice': 12.0,
        'ingredients': [
          {'name': '青菜', 'amount': '300g', 'isMain': 1},
          {'name': '蒜', 'amount': '3瓣', 'isMain': 0},
          {'name': '盐', 'amount': '适量', 'isMain': 0},
          {'name': '食用油', 'amount': '适量', 'isMain': 0},
        ],
        'steps': [
          '青菜洗净沥干，蒜切片',
          '热锅凉油爆香蒜片',
          '下青菜大火快炒',
          '加盐调味，炒至断生即可出锅',
        ],
      },
    ];

    for (final dish in defaultDishes) {
      final ingredients = dish['ingredients'] as List;
      final steps = dish['steps'] as List;

      final dishId = await db.insert('dishes', {
        'name': dish['name'],
        'category': dish['category'],
        'estimatedPrice': dish['estimatedPrice'],
        'createdAt': DateTime.now().toIso8601String(),
      });

      await db.insert('recipes', {
        'dishId': dishId,
        'dishName': dish['name'],
        'ingredients': ingredients.map((i) => {
          'name': i['name'],
          'amount': i['amount'],
          'isMain': i['isMain'],
        }).toList().toString(),
        'steps': steps.map((s) => s.toString()).toList().toString(),
      });
    }
  }

  // ====== 菜品库 ======
  static Future<List<Dish>> getAllDishes() async {
    final db = await database;
    final maps = await db.query('dishes', orderBy: 'id DESC');
    final dishes = <Dish>[];
    for (final map in maps) {
      final dish = Dish.fromMap(map);
      final recipe = await getRecipeByDishId(dish.id!);
      dishes.add(Dish(
        id: dish.id,
        name: dish.name,
        category: dish.category,
        estimatedPrice: dish.estimatedPrice,
        recipe: recipe,
      ));
    }
    return dishes;
  }

  static Future<void> addDish(Dish dish) async {
    final db = await database;
    await db.insert('dishes', dish.toMap());
  }

  // ====== 菜谱 ======
  static Future<Recipe?> getRecipeByDishId(int dishId) async {
    final db = await database;
    final maps = await db.query('recipes', where: 'dishId = ?', whereArgs: [dishId]);
    if (maps.isEmpty) return null;
    return Recipe.fromMap(maps.first);
  }

  static Future<void> saveRecipe(Recipe recipe) async {
    final db = await database;
    await db.insert('recipes', recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final maps = await db.query('recipes', orderBy: 'id DESC');
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  // ====== 订单 ======
  static Future<void> addOrder(OrderItem order) async {
    final db = await database;
    await db.insert('order_items', order.toMap());
  }

  static Future<List<OrderItem>> getOrdersByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final maps = await db.query(
      'order_items',
      where: 'orderDate >= ? AND orderDate < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'id DESC',
    );
    return maps.map((m) => OrderItem.fromMap(m)).toList();
  }

  static Future<List<OrderItem>> getAllOrders() async {
    final db = await database;
    final maps = await db.query('order_items', orderBy: 'orderDate DESC');
    return maps.map((m) => OrderItem.fromMap(m)).toList();
  }

  static Future<void> updateOrderStatus(int orderId, OrderStatus status) async {
    final db = await database;
    await db.update(
      'order_items',
      {'status': status.index},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  static Future<void> updateOrderCost(int orderId, double cost) async {
    final db = await database;
    await db.update(
      'order_items',
      {'actualCost': cost},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  static Future<Map<String, double>> getMonthlyStats(int year, int month) async {
    final db = await database;
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    final maps = await db.query(
      'order_items',
      where: 'orderDate >= ? AND orderDate < ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );

    double totalCost = 0;
    int ordererCost = 0;
    int buyerCost = 0;

    for (final m in maps) {
      final cost = (m['actualCost'] ?? 0).toDouble();
      totalCost += cost;
      if ((m['paidBy'] ?? 0) == 0) {
        ordererCost += cost as int;
      } else {
        buyerCost += cost;
      }
    }

    return {
      'totalCost': totalCost,
      'ordererCost': ordererCost.toDouble(),
      'buyerCost': buyerCost.toDouble(),
    };
  }
}
