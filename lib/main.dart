import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'pages/shopping_page.dart';
import 'pages/cooking_page.dart';
import 'pages/stats_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider()..loadData(),
      child: MaterialApp(
        title: '点菜做菜',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MenuPage(),
    ShoppingPage(),
    CookingPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getTitle()),
            actions: [
              // 角色切换按钮
              TextButton.icon(
                onPressed: () => provider.switchPerson(),
                icon: Icon(
                  provider.currentPerson == 0 ? Icons.person : Icons.person_outline,
                  color: Colors.white,
                ),
                label: Text(
                  provider.currentPersonName,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.orange,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: '点菜'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '买菜'),
              BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '做菜'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '统计'),
            ],
          ),
        );
      },
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return '首页';
      case 1: return '点菜';
      case 2: return '买菜清单';
      case 3: return '做菜指南';
      case 4: return '记账统计';
      default: return '点菜做菜';
    }
  }
}
