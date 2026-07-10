import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dish.dart';
import '../providers/order_provider.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = provider.allOrders;
        final totalOrders = orders.length;
        final totalCost = orders.fold<double>(0, (sum, o) => sum + o.actualCost);
        final ordererOrders = orders.where((o) => o.orderBy == 0).length;
        final buyerOrders = orders.where((o) => o.orderBy == 1).length;
        final cookedCount = orders.where((o) => o.status == OrderStatus.cooked).length;

        // 按类别统计
        final categoryMap = <String, int>{};
        for (final order in orders) {
          categoryMap[order.dish.category] = (categoryMap[order.dish.category] ?? 0) + 1;
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 概况卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(Icons.list_alt, '总订单', '$totalOrders', Colors.blue),
                            _buildStatCard(Icons.check_circle, '已完成', '$cookedCount', Colors.green),
                            _buildStatCard(Icons.attach_money, '总花费', '¥${totalCost.toStringAsFixed(0)}', Colors.orange),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('$ordererOrders', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                                const Text('点菜人', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('$buyerOrders', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                const Text('买菜人', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 分类统计
                const Text('📊 分类统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(categoryMap),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 最近订单
                const Text('📝 最近订单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (orders.isEmpty)
                  Card(child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(child: Text('暂无订单记录', style: TextStyle(color: Colors.grey[500]))),
                  ))
                else
                  ...orders.take(10).map((order) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                            child: Icon(
                              order.status == OrderStatus.cooked ? Icons.check_circle : Icons.schedule,
                              color: _getStatusColor(order.status),
                              size: 20,
                            ),
                          ),
                          title: Text(order.dish.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('${order.orderDate.toString().substring(0, 10)} · ${order.orderBy == 0 ? "点菜人" : "买菜人"} | ¥${order.actualCost.toStringAsFixed(0)}'),
                          trailing: Text(order.statusText, style: TextStyle(color: _getStatusColor(order.status))),
                        ),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered: return Colors.orange;
      case OrderStatus.bought: return Colors.blue;
      case OrderStatus.cooked: return Colors.green;
    }
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> categoryMap) {
    final colors = [Colors.orange, Colors.green, Colors.blue, Colors.purple, Colors.teal];
    final total = categoryMap.values.fold(0, (sum, v) => sum + v);
    int i = 0;
    return categoryMap.entries.map((entry) {
      final pct = (entry.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: colors[i++ % colors.length],
        title: '${entry.key}\n$pct%',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        radius: 60,
      );
    }).toList();
  }
}
