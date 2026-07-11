import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showLifeShare = false;

  final List<Map<String, String>> _discoverDishes = [
    {'name': '芝士多肉葡萄', 'author': '赣饭啦', 'emoji': '🍇'},
    {'name': '蒜香黄油虾', 'author': '用户DC1Vo的厨房', 'emoji': '🦐'},
    {'name': '甜甜西瓜', 'author': '福瑞明堂', 'emoji': '🍉'},
    {'name': '烤五花肉片', 'author': '杨宇杰私家小厨', 'emoji': '🥩'},
    {'name': '蜂蜜柠檬茶', 'author': '茶茶子', 'emoji': '🍋'},
    {'name': '麻辣香锅', 'author': '辣辣厨房', 'emoji': '🌶️'},
    {'name': '抹茶蛋糕', 'author': '甜点师小李', 'emoji': '🍵'},
    {'name': '红烧牛肉面', 'author': '面面俱到', 'emoji': '🍜'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索栏
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '输入菜谱名称可搜索',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        // Tab 栏
        Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showLifeShare = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _showLifeShare ? Colors.black87 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      '生活分享',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _showLifeShare ? Colors.black87 : Colors.grey,
                        fontWeight: _showLifeShare ? FontWeight.w500 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showLifeShare = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: !_showLifeShare ? Colors.black87 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      '发现菜谱',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_showLifeShare ? Colors.black87 : Colors.grey,
                        fontWeight: !_showLifeShare ? FontWeight.w500 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 内容区域
        Expanded(
          child: _showLifeShare ? _buildLifeShare() : _buildDiscoverGrid(),
        ),
      ],
    );
  }

  Widget _buildLifeShare() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('生活分享功能开发中...', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDiscoverGrid() {
    return RefreshIndicator(
      onRefresh: () async {},
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _discoverDishes.length,
        itemBuilder: (context, index) {
          final dish = _discoverDishes[index];
          return _buildDiscoverCard(dish['name']!, dish['author']!, dish['emoji']!);
        },
      ),
    );
  }

  Widget _buildDiscoverCard(String name, String author, String emoji) {
    final colors = [
      AppTheme.lightGreen,
      Colors.orange[50]!,
      Colors.blue[50]!,
      Colors.pink[50]!,
      Colors.purple[50]!,
      Colors.amber[50]!,
      Colors.teal[50]!,
      Colors.indigo[50]!,
    ];
    final colorIndex = name.length % colors.length;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 菜品图片
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors[colorIndex],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 48)),
              ),
            ),
          ),
          // 菜品信息
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: colors[(colorIndex + 3) % colors.length],
                      child: Text(
                        author[0],
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        author,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
