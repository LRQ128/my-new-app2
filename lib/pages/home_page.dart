import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/dish.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final todayOrders = provider.todayOrders;
        final pendingCount = todayOrders
            .where((o) => o.status != OrderStatus.cooked)
            .length;
        final cookedCount = todayOrders
            .where((o) => o.status == OrderStatus.cooked)
            .length;

        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 今日概览卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              Icons.restaurant_menu,
                              '已点',
                              '${todayOrders.length}',
                              Colors.blue,
                            ),
                            _buildStatItem(
                              Icons.shopping_cart,
                              '待处理',
                              '$pendingCount',
                              Colors.orange,
                            ),
                            _buildStatItem(
                              Icons.check_circle,
                              '已完成',
                              '$cookedCount',
                              Colors.green,
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        Text(
                          '当前角色：${provider.currentPersonName}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.currentPerson == 0 ? '今天想吃什么呢？来点点菜吧！' : '看看需要买什么菜~',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 今日菜品列表
                const Text('今日已点', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (todayOrders.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.restaurant, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text('今天还没点菜呢', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...todayOrders.map((order) => _buildOrderCard(context, order, provider)),

                const SizedBox(height: 20),

                // 快捷入口
                const Text('快捷操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        Icons.restaurant_menu,
                        '点菜',
                        Colors.orange,
                        () => _switchTab(context, 1),
                      ),
                    ),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        Icons.shopping_cart,
                        '买菜清单',
                        Colors.green,
                        () => _switchTab(context, 2),
                      ),
                    ),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        Icons.kitchen,
                        '做菜指南',
                        Colors.blue,
                        () => _switchTab(context, 3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderItem order, OrderProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
          child: Icon(_getStatusIcon(order.status), color: _getStatusColor(order.status)),
        ),
        title: Text(order.dish.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${order.orderBy == 0 ? "点菜人" : "买菜人"} · ${order.statusText}'),
        trailing: PopupMenuButton<OrderStatus>(
          onSelected: (status) => provider.updateStatus(order.id!, status),
          itemBuilder: (context) => [
            const PopupMenuItem(value: OrderStatus.ordered, child: Text('已点')),
            const PopupMenuItem(value: OrderStatus.bought, child: Text('已买')),
            const PopupMenuItem(value: OrderStatus.cooked, child: Text('已做')),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered: return Colors.orange;
      case OrderStatus.bought: return Colors.blue;
      case OrderStatus.cooked: return Colors.green;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered: return Icons.schedule;
      case OrderStatus.bought: return Icons.shopping_cart;
      case OrderStatus.cooked: return Icons.check_circle;
    }
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  void _switchTab(BuildContext context, int index) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.bottomNavigationBar is BottomNavigationBar) {
      // DefaultTabController approach won't work easily, so navigate via back
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SizedBox()),
      );
    }
  }
}
