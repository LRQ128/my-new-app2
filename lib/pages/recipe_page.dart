import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dish.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final ScrollController _dishScrollController = ScrollController();

  @override
  void dispose() {
    _dishScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = provider.categories;
        final filteredDishes = provider.filteredDishes;

        return Column(
          children: [
            // 顶部标题栏
            _buildHeader(context, provider),
            // 主体内容：左侧分类 + 右侧菜品
            Expanded(
              child: Row(
                children: [
                  // 左侧分类导航
                  _buildCategoryNav(context, provider, categories),
                  // 右侧菜品列表
                  Expanded(
                    child: _buildDishList(context, provider, filteredDishes),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, OrderProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 12),
      child: Column(
        children: [
          Row(
            children: [
              // 标题+副标题
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '好大一颗菜',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '今日: ${DateTime.now().month}/${DateTime.now().day}',
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          '申大厨的爱心厨房',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '共${provider.dishes.length}个菜谱',
                            style: const TextStyle(color: Colors.black87, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 搜索按钮
              _buildIconButton(Icons.search, () {}),
              const SizedBox(width: 4),
              // 消息按钮
              _buildIconButton(Icons.message_outlined, () {}),
              const SizedBox(width: 4),
              // 菜谱管理按钮
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note, color: Colors.white, size: 16),
                    SizedBox(width: 2),
                    Text('菜谱管理', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 角色切换
          Row(
            children: [
              GestureDetector(
                onTap: () => provider.switchPerson(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.currentPerson == 0 ? Icons.person : Icons.shopping_cart,
                        color: Colors.white, size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '当前: ${provider.currentPersonName}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      const Icon(Icons.swap_horiz, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCategoryNav(BuildContext context, OrderProvider provider, List<String> categories) {
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = provider.selectedCategoryIndex == index;
          final cat = categories[index].replaceAll(RegExp(r'[🍖🥘🍚🦞🥗🍲💩\(\)]'), '').trim();

          return GestureDetector(
            onTap: () => provider.selectedCategoryIndex = index,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                    width: 3,
                  ),
                ),
                color: isSelected ? AppTheme.lightGreen : null,
              ),
              child: Column(
                children: [
                  Text(
                    categories[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryGreen : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDishList(BuildContext context, OrderProvider provider, List<Dish> dishes) {
    if (dishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('暂无菜品', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: ListView.builder(
        controller: _dishScrollController,
        padding: const EdgeInsets.all(12),
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          return _buildDishCard(context, dishes[index], provider);
        },
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, Dish dish, OrderProvider provider) {
    final categoryEmoji = {
      '肉类': '🍖', '炒菜': '🥘', '主食': '🍚', '海鲜': '🦞',
      '凉菜': '🥗', '砂锅系列': '🍲', '臭臭💩(但爱吃)': '💩',
    };
    final emoji = categoryEmoji.entries
        .firstWhere((e) => dish.category.contains(e.key.replaceAll(RegExp(r'[🍖🥘🍚🦞🥗🍲💩\(\)]'), '').trim()),
            orElse: () => MapEntry('', '🍽️'))
        .value;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDishDetail(context, dish, provider),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 菜品图片占位
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 12),
              // 菜品信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // 评分星星
                        ...List.generate(5, (i) => Icon(
                          i < dish.rating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 人气值
                        if (dish.popularity > 0) ...[
                          const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            '${dish.popularity}',
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // 销量
                        Icon(Icons.trending_up, color: Colors.grey[400], size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '销量 ${dish.salesCount}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        if (dish.description.isNotEmpty) ...[
                          const Spacer(),
                          Icon(Icons.info_outline, color: Colors.grey[400], size: 14),
                          const SizedBox(width: 2),
                          Text(
                            dish.description.length > 10
                                ? '${dish.description.substring(0, 10)}...'
                                : dish.description,
                            style: TextStyle(color: Colors.grey[400], fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                    if (dish.estimatedPrice > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '¥${dish.estimatedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '约 ${dish.estimatedPrice.toStringAsFixed(0)}元',
                              style: TextStyle(color: Colors.red[300], fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 点菜按钮
              GestureDetector(
                onTap: () => _showOrderDialog(context, dish, provider),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
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
          initialChildSize: 0.65,
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
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(dish.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      ...List.generate(5, (i) => Icon(
                        i < dish.rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 20,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(dish.category, style: const TextStyle(color: AppTheme.darkGreen)),
                      ),
                      const SizedBox(width: 8),
                      if (dish.popularity > 0) ...[
                        const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 18),
                        const SizedBox(width: 2),
                        Text('${dish.popularity}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                      ],
                      Text('销量 ${dish.salesCount}', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥${dish.estimatedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (dish.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(dish.description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                  if (dish.recipe != null) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('📋 菜谱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('食材清单：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ...dish.recipe!.ingredients.map((ing) => ListTile(
                      dense: true,
                      leading: Icon(
                        ing.isMain ? Icons.star : Icons.circle,
                        size: 16,
                        color: ing.isMain ? AppTheme.primaryGreen : Colors.grey,
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
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showOrderDialog(context, dish, provider);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('点菜'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
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
    final priceController = TextEditingController(text: dish.estimatedPrice.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_shopping_cart, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Expanded(child: Text('点菜：${dish.name}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('由 '),
                Text(provider.currentPersonName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                const Text(' 下单'),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                hintText: '不放辣、少油...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note, size: 20),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.addOrder(dish, notes: notesController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('已点：${dish.name}'),
                    ],
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认点菜'),
          ),
        ],
      ),
    );
  }
}
