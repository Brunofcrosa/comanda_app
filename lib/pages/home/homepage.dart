import 'package:flutter/material.dart';
import 'package:flutter_comandas_app/pages/comanda/comanda.dart';
import 'package:flutter_comandas_app/comandas/comprovantes.dart';
import 'package:flutter_comandas_app/main.dart';

class MainAppNavigator extends StatefulWidget {
  const MainAppNavigator({super.key});

  @override
  State<MainAppNavigator> createState() => _MainAppNavigatorState();
}

class _MainAppNavigatorState extends State<MainAppNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const ComandaListPage(),
    const ComprovantesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Comandas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Comprovantes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
