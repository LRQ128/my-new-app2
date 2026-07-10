import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dish.dart';
import '../providers/order_provider.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final shoppingList = provider.getShoppingList();
        final pendingOrders = provider.allOrders
            .where((o) => o.status == OrderStatus.ordered || o.status == OrderStatus.bought)
            .toList();

        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 待买菜提示
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '需要买菜做菜',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green[800],
                                ),
                              ),
                              Text(
                                '共 ${pendingOrders.length} 道菜等待处理',
                                style: TextStyle(color: Colors.green[600]),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // 批量标记已买
                            for (final order in pendingOrders) {
                              if (order.status == OrderStatus.ordered) {
                                provider.updateStatus(order.id!, OrderStatus.bought);
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已标记为已买'), backgroundColor: Colors.green),
                            );
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('全部已买'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 购物清单
                const Text('🛒 购物清单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                if (shoppingList.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.check_circle, size: 60, color: Colors.green[200]),
                            const SizedBox(height: 10),
                            Text('没有待买的菜', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        // 主料
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('主料', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                        ...shoppingList
                            .where((item) => item['type'] == '主料')
                            .map((item) => ListTile(
                                  leading: const Icon(Icons.check_box_outline_blank, color: Colors.grey),
                                  title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  trailing: Text(item['amount'] ?? '', style: TextStyle(color: Colors.grey[600])),
                                )),
                        const Divider(),
                        // 配料
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: 14, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('配料/调料', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                        ...shoppingList
                            .where((item) => item['type'] == '配料')
                            .map((item) => ListTile(
                                  leading: const Icon(Icons.check_box_outline_blank, color: Colors.grey),
                                  title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  trailing: Text(item['amount'] ?? '', style: TextStyle(color: Colors.grey[600])),
                                )),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // 待处理的菜
                const Text('📋 待处理菜品', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (pendingOrders.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text('全部处理完毕！', style: TextStyle(color: Colors.grey[500]))),
                    ),
                  )
                else
                  ...pendingOrders.map((order) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[50],
                            child: Text(
                              order.dish.name.isNotEmpty ? order.dish.name[0] : '?',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                          title: Text(order.dish.name),
                          subtitle: Text('状态: ${order.statusText} · ${order.notes.isNotEmpty ? order.notes : "无备注"}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (order.status == OrderStatus.ordered)
                                TextButton(
                                  onPressed: () => provider.updateStatus(order.id!, OrderStatus.bought),
                                  child: const Text('已买', style: TextStyle(color: Colors.blue)),
                                ),
                              if (order.status == OrderStatus.bought)
                                TextButton(
                                  onPressed: () => provider.updateStatus(order.id!, OrderStatus.cooked),
                                  child: const Text('已做', style: TextStyle(color: Colors.green)),
                                ),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }
}
