import 'dart:convert';
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
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
        await _insertDefaultDishes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 升级到 v2：新增字段
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE dishes ADD COLUMN rating REAL DEFAULT 5.0');
          await db.execute('ALTER TABLE dishes ADD COLUMN salesCount INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE dishes ADD COLUMN popularity INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE dishes ADD COLUMN description TEXT DEFAULT ""');
          await db.execute('ALTER TABLE order_items ADD COLUMN orderCode TEXT DEFAULT ""');
          await db.execute('ALTER TABLE order_items ADD COLUMN userId TEXT DEFAULT ""');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE dishes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT DEFAULT '肉类',
        estimatedPrice REAL DEFAULT 0,
        imageUrl TEXT DEFAULT '',
        rating REAL DEFAULT 5.0,
        salesCount INTEGER DEFAULT 0,
        popularity INTEGER DEFAULT 0,
        description TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dishId INTEGER NOT NULL,
        dishName TEXT NOT NULL,
        dishCategory TEXT DEFAULT '肉类',
        orderBy INTEGER DEFAULT 0,
        status INTEGER DEFAULT 0,
        actualCost REAL DEFAULT 0,
        orderDate TEXT NOT NULL,
        notes TEXT DEFAULT '',
        orderCode TEXT DEFAULT '',
        userId TEXT DEFAULT '',
        FOREIGN KEY (dishId) REFERENCES dishes(id)
      )
    ''');

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
  }

  static Future<void> _insertDefaultDishes(Database db) async {
    final defaultDishes = [
      {
        'name': '糖醋排骨',
        'category': '肉类',
        'estimatedPrice': 38.0,
        'rating': 5.0,
        'salesCount': 1,
        'popularity': 88,
        'description': '酸甜可口，外酥里嫩',
        'ingredients': [
          {'name': '排骨', 'amount': '500g', 'isMain': 1},
          {'name': '料酒', 'amount': '1勺', 'isMain': 0},
          {'name': '生抽', 'amount': '2勺', 'isMain': 0},
          {'name': '醋', 'amount': '3勺', 'isMain': 0},
          {'name': '糖', 'amount': '3勺', 'isMain': 0},
          {'name': '姜', 'amount': '3片', 'isMain': 0},
          {'name': '食用油', 'amount': '适量', 'isMain': 0},
        ],
        'steps': [
          '排骨焯水去血沫',
          '调糖醋汁：1勺料酒+2勺生抽+3勺醋+3勺糖',
          '热油炒糖色，下排骨翻炒',
          '倒入糖醋汁，加姜片',
          '加水没过排骨，大火烧开转小火炖30分钟',
          '大火收汁，撒芝麻出锅',
        ],
      },
      {
        'name': '烤翅',
        'category': '肉类',
        'estimatedPrice': 25.0,
        'rating': 5.0,
        'salesCount': 1,
        'popularity': 45,
        'description': '香嫩多汁，回味无穷',
        'ingredients': [
          {'name': '鸡翅', 'amount': '10个', 'isMain': 1},
          {'name': '奥尔良腌料', 'amount': '30g', 'isMain': 0},
          {'name': '料酒', 'amount': '1勺', 'isMain': 0},
          {'name': '生抽', 'amount': '1勺', 'isMain': 0},
          {'name': '蜂蜜', 'amount': '适量', 'isMain': 0},
        ],
        'steps': [
          '鸡翅洗净，正反面各划两刀',
          '加入腌料、料酒、生抽抓匀',
          '腌制2小时以上（冷藏过夜更佳）',
          '烤箱预热200度，烤15分钟',
          '刷蜂蜜翻面，再烤10分钟即可',
        ],
      },
      {
        'name': '火鸡面',
        'category': '主食',
        'estimatedPrice': 10.0,
        'rating': 5.0,
        'salesCount': 0,
        'popularity': 0,
        'description': '辣到过瘾',
        'ingredients': [
          {'name': '火鸡面', 'amount': '1包', 'isMain': 1},
          {'name': '鸡蛋', 'amount': '1个', 'isMain': 0},
          {'name': '芝士片', 'amount': '1片', 'isMain': 0},
          {'name': '葱花', 'amount': '适量', 'isMain': 0},
        ],
        'steps': [
          '水开后下面饼煮至散开',
          '倒掉大部分水，留少许',
          '加入辣酱包拌匀',
          '打入鸡蛋，盖盖子焖至蛋白凝固',
          '放芝士片，撒葱花即可',
        ],
      },
      {
        'name': '快乐水鸡翅',
        'category': '肉类',
        'estimatedPrice': 28.0,
        'rating': 5.0,
        'salesCount': 0,
        'popularity': 520,
        'description': '香甜多汁 软烂脱骨！',
        'ingredients': [
          {'name': '鸡翅', 'amount': '10个', 'isMain': 1},
          {'name': '可乐', 'amount': '1罐', 'isMain': 0},
          {'name': '姜', 'amount': '3片', 'isMain': 0},
          {'name': '生抽', 'amount': '2勺', 'isMain': 0},
          {'name': '老抽', 'amount': '1勺', 'isMain': 0},
          {'name': '料酒', 'amount': '1勺', 'isMain': 0},
        ],
        'steps': [
          '鸡翅正反面各划两刀，冷水下锅焯水',
          '热锅少油，下姜片爆香',
          '放入鸡翅煎至两面金黄',
          '倒入可乐、生抽、老抽、料酒',
          '大火烧开转中小火炖15分钟',
          '大火收汁即可',
        ],
      },
      {
        'name': '酸辣土豆丝',
        'category': '炒菜',
        'estimatedPrice': 12.0,
        'rating': 5.0,
        'salesCount': 1,
        'popularity': 66,
        'description': '酸辣开胃，下饭神器',
        'ingredients': [
          {'name': '土豆', 'amount': '2个', 'isMain': 1},
          {'name': '干辣椒', 'amount': '3-4个', 'isMain': 0},
          {'name': '蒜', 'amount': '3瓣', 'isMain': 0},
          {'name': '醋', 'amount': '2勺', 'isMain': 0},
          {'name': '盐', 'amount': '适量', 'isMain': 0},
          {'name': '食用油', 'amount': '适量', 'isMain': 0},
        ],
        'steps': [
          '土豆切细丝，泡水去淀粉',
          '热锅凉油，下干辣椒和蒜片爆香',
          '下土豆丝大火快炒',
          '加醋和盐调味',
          '翻炒均匀即可出锅',
        ],
      },
      {
        'name': '蒜香黄油虾',
        'category': '海鲜',
        'estimatedPrice': 45.0,
        'rating': 5.0,
        'salesCount': 2,
        'popularity': 128,
        'description': '外酥里嫩，蒜香四溢',
        'ingredients': [
          {'name': '大虾', 'amount': '300g', 'isMain': 1},
          {'name': '黄油', 'amount': '20g', 'isMain': 0},
          {'name': '蒜', 'amount': '5瓣（切末）', 'isMain': 0},
          {'name': '盐', 'amount': '适量', 'isMain': 0},
          {'name': '黑胡椒', 'amount': '适量', 'isMain': 0},
        ],
        'steps': [
          '大虾去壳去虾线，洗净沥干',
          '平底锅融化黄油',
          '下蒜末爆香',
          '放入虾仁煎至两面金黄',
          '撒盐和黑胡椒调味即可',
        ],
      },
      {
        'name': '西红柿炒鸡蛋',
        'category': '炒菜',
        'estimatedPrice': 15.0,
        'rating': 5.0,
        'salesCount': 1,
        'popularity': 99,
        'description': '经典家常菜',
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
        'name': '水煮鱼',
        'category': '海鲜',
        'estimatedPrice': 55.0,
        'rating': 5.0,
        'salesCount': 0,
        'popularity': 200,
        'description': '麻辣鲜香，嫩滑入味',
        'ingredients': [
          {'name': '草鱼', 'amount': '1条（约1kg）', 'isMain': 1},
          {'name': '豆芽', 'amount': '200g', 'isMain': 0},
          {'name': '干辣椒', 'amount': '适量', 'isMain': 0},
          {'name': '花椒', 'amount': '适量', 'isMain': 0},
          {'name': '姜蒜', 'amount': '适量', 'isMain': 0},
          {'name': '豆瓣酱', 'amount': '1勺', 'isMain': 0},
        ],
        'steps': [
          '鱼片成薄片，用蛋清和淀粉腌制',
          '豆芽焯水铺碗底',
          '炒香豆瓣酱和姜蒜，加水烧开',
          '下鱼片煮至变白即可',
          '撒干辣椒和花椒，浇热油',
        ],
      },
    ];

    final categoryEmoji = {
      '肉类': '🍖',
      '炒菜': '🥘',
      '主食': '🍚',
      '海鲜': '🦞',
      '凉菜': '🥗',
      '砂锅系列': '🍲',
      '臭臭💩(但爱吃)': '💩',
    };

    for (final dish in defaultDishes) {
      await _insertSingleDish(db, dish);
    }

    // 额外添加含 emoji 的分类示范
    final extraDishes = [
      {
        'name': '小龙虾',
        'category': '海鲜',
        'estimatedPrice': 68.0,
        'rating': 5.0,
        'salesCount': 5,
        'popularity': 666,
        'description': '夏日必吃，麻辣鲜香',
        'ingredients': [
          {'name': '小龙虾', 'amount': '2斤', 'isMain': 1},
          {'name': '啤酒', 'amount': '1罐', 'isMain': 0},
          {'name': '干辣椒', 'amount': '适量', 'isMain': 0},
          {'name': '姜蒜', 'amount': '适量', 'isMain': 0},
          {'name': '郫县豆瓣酱', 'amount': '2勺', 'isMain': 0},
        ],
        'steps': ['小龙虾刷洗干净', '热油爆香姜蒜辣椒', '加豆瓣酱炒出红油', '下小龙虾翻炒', '倒入啤酒焖煮15分钟即可'],
      },
      {
        'name': '砂锅排骨',
        'category': '砂锅系列',
        'estimatedPrice': 42.0,
        'rating': 4.5,
        'salesCount': 3,
        'popularity': 156,
        'description': '慢炖入味，暖心暖胃',
        'ingredients': [
          {'name': '排骨', 'amount': '400g', 'isMain': 1},
          {'name': '土豆', 'amount': '1个', 'isMain': 0},
          {'name': '胡萝卜', 'amount': '1根', 'isMain': 0},
          {'name': '姜片', 'amount': '3片', 'isMain': 0},
          {'name': '盐', 'amount': '适量', 'isMain': 0},
        ],
        'steps': ['排骨焯水', '砂锅加底油炒香姜片', '下排骨翻炒', '加水没过食材', '大火烧开转小火炖40分钟，加土豆胡萝卜再炖15分钟'],
      },
      {
        'name': '皮蛋豆腐',
        'category': '凉菜',
        'estimatedPrice': 18.0,
        'rating': 4.0,
        'salesCount': 2,
        'popularity': 88,
        'description': '清爽开胃，简单快手',
        'ingredients': [
          {'name': '内酯豆腐', 'amount': '1盒', 'isMain': 1},
          {'name': '皮蛋', 'amount': '2个', 'isMain': 1},
          {'name': '葱花', 'amount': '适量', 'isMain': 0},
          {'name': '生抽', 'amount': '2勺', 'isMain': 0},
          {'name': '香油', 'amount': '1勺', 'isMain': 0},
        ],
        'steps': ['豆腐切块码盘', '皮蛋切碎放在豆腐上', '淋生抽和香油', '撒葱花即可'],
      },
    ];

    for (final dish in extraDishes) {
      await _insertSingleDish(db, dish);
    }
  }

  static Future<void> _insertSingleDish(Database db, Map<String, dynamic> dish) async {
    final ingredients = dish['ingredients'] as List;
    final steps = dish['steps'] as List;

    final dishId = await db.insert('dishes', {
      'name': dish['name'],
      'category': dish['category'],
      'estimatedPrice': dish['estimatedPrice'],
      'rating': dish['rating'] ?? 5.0,
      'salesCount': dish['salesCount'] ?? 0,
      'popularity': dish['popularity'] ?? 0,
      'description': dish['description'] ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    });

    final ingredientsJson = jsonEncode(ingredients);
    final stepsJson = jsonEncode(steps);

    await db.insert('recipes', {
      'dishId': dishId,
      'dishName': dish['name'],
      'ingredients': ingredientsJson,
      'steps': stepsJson,
    });
  }

  // ====== 菜品库 ======
  static Future<List<Dish>> getAllDishes() async {
    final db = await database;
    final maps = await db.query('dishes', orderBy: 'popularity DESC, id ASC');
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
        rating: dish.rating,
        salesCount: dish.salesCount,
        popularity: dish.popularity,
        description: dish.description,
      ));
    }
    return dishes;
  }

  static Future<Recipe?> getRecipeByDishId(int dishId) async {
    final db = await database;
    final maps = await db.query('recipes', where: 'dishId = ?', whereArgs: [dishId]);
    if (maps.isEmpty) return null;
    return Recipe.fromMap(maps.first);
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

  static Future<void> deleteOrder(int orderId) async {
    final db = await database;
    await db.delete('order_items', where: 'id = ?', whereArgs: [orderId]);
  }
}
