import 'package:flutter/material.dart';
import 'package:projeto/models/product.dart';
import 'package:projeto/pages/order_history.dart';
import 'package:projeto/pages/product_list.dart';
import 'package:projeto/pages/profile_page.dart';

class MainScreen extends StatefulWidget {
  final String email;
  final Map<Product, int> selectedProducts;

  MainScreen({required this.email, required this.selectedProducts});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions() { 
    return <Widget>[
      ProductListPage(email: widget.email),
      OrderHistoryPage(email: widget.email,),
      ProfilePage(email: widget.email),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snacks', 
        style: TextStyle(
            color: Colors.white, // Altere a cor para a desejada
            fontSize: 20, // Tamanho da fonte (opcional)
            fontWeight: FontWeight.bold, // Estilo da fonte (opcional)
          ),
          ),
        centerTitle: true,
        backgroundColor: Color(0xFFBF0603),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _widgetOptions().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Cardápio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFBF0603),
        unselectedItemColor: const Color.fromARGB(255, 73, 73, 73),
        onTap: _onItemTapped,
      ),
    );
  }
}