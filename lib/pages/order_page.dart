import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dish.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // 日期和状态选择
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('选择状态', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.grey, size: 18),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
            // Tab 栏
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryGreen,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: const [
                  Tab(text: '厨房订单'),
                  Tab(text: '我下单的'),
                ],
              ),
            ),
            // 订单列表
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(context, provider, provider.kitchenOrders, isKitchen: true),
                  _buildOrderList(context, provider, provider.myOrders, isKitchen: false),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderList(BuildContext context, OrderProvider provider, List<OrderItem> orders, {required bool isKitchen}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isKitchen ? Icons.kitchen : Icons.receipt_long, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              isKitchen ? '暂无厨房订单' : '暂无你下的单',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(context, orders[index], provider, isKitchen);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderItem order, OrderProvider provider, bool isKitchen) {
    // 按菜品ID合并相同菜品
    final orderCounts = <int, int>{};
    orderCounts[order.dish.id ?? 0] = 1;

    // 为了显示更丰富，计算一下总价（实际项目应按数据库汇总）
    final amount = order.dish.estimatedPrice;
    final totalPrice = amount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：用户ID + 菜品数量 + 总价
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('👤', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '用户 ${order.userId.isNotEmpty ? order.userId : '4DR5Q'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${1}个菜',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // 总价
                Row(
                  children: [
                    const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      '${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 菜品行
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        order.dish.name[0],
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(order.dish.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                            const Spacer(),
                            if (order.dish.estimatedPrice > 0)
                              Text(
                                '¥${order.dish.estimatedPrice.toStringAsFixed(2)}',
                                style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'X1',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 时间 + 状态 + 取餐码
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')}:${order.orderDate.second.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const Spacer(),
                // 取餐码
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Text(
                    '取餐码 ${order.orderCode.isNotEmpty ? order.orderCode : '1001'}',
                    style: TextStyle(color: Colors.orange[700], fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                // 状态
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(color: Colors.red[600], fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            // 备注
            if (order.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.notes, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('备注: ${order.notes}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isKitchen) ...[
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('取消订单', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => provider.deleteOrder(order.id!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red[200]!),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('删除订单', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => provider.completeOrder(order.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('完成订单', style: TextStyle(fontSize: 12)),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () => provider.cancelOrder(order.id!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('取消', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => provider.deleteOrder(order.id!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red[200]!),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('删除', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
