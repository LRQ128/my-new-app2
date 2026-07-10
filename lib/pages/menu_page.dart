import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dish.dart';
import '../providers/order_provider.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final dishes = provider.dishes;
        final categories = dishes.map((d) => d.category).toSet().toList();

        if (dishes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('暂无菜品，请联系管理员添加', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // 当前角色提示
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      '当前角色：${provider.currentPersonName}',
                      style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 按分类展示
            ...categories.map((category) => _buildCategorySection(context, category, dishes, provider)),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection(BuildContext context, String category, List<Dish> dishes, OrderProvider provider) {
    final categoryDishes = dishes.where((d) => d.category == category).toList();
    final icons = {
      '荤菜': Icons.restaurant,
      '素菜': Icons.eco,
      '汤': Icons.soup_kitchen,
      '主食': Icons.rice_bowl,
      '凉菜': Icons.kitchen,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Icon(icons[category] ?? Icons.restaurant_menu, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('${categoryDishes.length}道', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        ),
        ...categoryDishes.map((dish) => _buildDishCard(context, dish, provider)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDishCard(BuildContext context, Dish dish, OrderProvider provider) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDishDetail(context, dish, provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 菜品图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  dish.category == '荤菜' ? Icons.restaurant :
                  dish.category == '素菜' ? Icons.eco :
                  dish.category == '汤' ? Icons.soup_kitchen : Icons.rice_bowl,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // 菜品信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dish.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(dish.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '约¥${dish.estimatedPrice.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    if (dish.recipe != null && dish.recipe!.ingredients.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '食材: ${dish.recipe!.ingredients.take(3).map((i) => i.name).join('、')}${dish.recipe!.ingredients.length > 3 ? '...' : ''}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              // 操作按钮
              ElevatedButton.icon(
                onPressed: () => _showOrderDialog(context, dish, provider),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('点菜'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDishDetail(BuildContext context, Dish dish, OrderProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(dish.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(dish.category, style: TextStyle(color: Colors.orange[700])),
                      ),
                      const SizedBox(width: 8),
                      Text('约¥${dish.estimatedPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, color: Colors.orange)),
                    ],
                  ),
                  if (dish.recipe != null) ...[
                    const SizedBox(height: 20),
                    const Text('📋 智能菜谱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('需要购买的食材：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ...dish.recipe!.ingredients.map((ing) => ListTile(
                      dense: true,
                      leading: Icon(
                        ing.isMain ? Icons.star : Icons.circle,
                        size: 16,
                        color: ing.isMain ? Colors.orange : Colors.grey,
                      ),
                      title: Text('${ing.name}: ${ing.amount}'),
                      subtitle: Text(ing.isMain ? '主料' : '配料/调料'),
                    )),
                    const SizedBox(height: 12),
                    const Text('烹饪步骤：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ...dish.recipe!.steps.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(entry.value, style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderDialog(BuildContext context, Dish dish, OrderProvider provider) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('点菜：${dish.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('由 ${provider.currentPersonName} 下单'),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: '口味备注（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              provider.addOrder(dish, notes: notesController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已点：${dish.name}'), backgroundColor: Colors.orange),
              );
            },
            child: const Text('确认点菜'),
          ),
        ],
      ),
    );
  }
}
