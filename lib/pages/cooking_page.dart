import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dish.dart';
import '../providers/order_provider.dart';

class CookingPage extends StatelessWidget {
  const CookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final cookingList = provider.getCookingList();

        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cookingList.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.kitchen, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text('暂无需要做的菜', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('先去点菜吧~', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...cookingList.asMap().entries.map((entry) => _buildRecipeCard(
                        context,
                        entry.value,
                        entry.key,
                        provider,
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeCard(BuildContext context, Map<String, String> recipe, int index, OrderProvider provider) {
    final steps = recipe['steps']!.split('\n');
    final dishName = recipe['dishName'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Text('${index + 1}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
        title: Text(dishName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${steps.length} 步', style: TextStyle(color: Colors.grey[500])),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                ...steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(entry.value, style: const TextStyle(fontSize: 15, height: 1.5)),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 标记为已完成
                      final orders = provider.allOrders.where(
                        (o) => o.dish.name == dishName && o.status != OrderStatus.cooked,
                      );
                      for (final order in orders) {
                        provider.updateStatus(order.id!, OrderStatus.cooked);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$dishName 已做好！'), backgroundColor: Colors.green),
                      );
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('标记为已完成'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
