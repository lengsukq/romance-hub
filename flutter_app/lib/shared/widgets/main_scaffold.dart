import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 主框架 Scaffold
/// 包含底部导航栏和通用布局
class MainScaffold extends StatefulWidget {
  final Widget child;
  final int? initialIndex;

  const MainScaffold({
    super.key,
    required this.child,
    this.initialIndex,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/tasks');
        break;
      case 2:
        context.go('/gifts');
        break;
      case 3:
        context.go('/whispers?type=my');
        break;
      case 4:
        context.go('/user-info');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: '礼物',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '留言',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
