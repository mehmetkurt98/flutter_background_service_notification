import 'package:flutter/material.dart';
import 'package:flutter_notification/plate_page.dart';

import 'car_request.dart';
import 'late_car_request.dart';


class CustomStatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FrappeDataList(),
    );
  }
}

class CustomAmperePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: LateRezervationPage(),
    );
  }
}
class CustomPlatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: PlatePageView(),
    );
  }
}

class MyTabs extends StatefulWidget {
  @override
  _MyTabsState createState() => _MyTabsState();
}

class _MyTabsState extends State<MyTabs> {
  int _currentIndex = 0;
  final List<Widget> _pages = [CustomStatusPage(), CustomAmperePage(),PlatePageView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            activeIcon: Icon(Icons.home, color: Colors.blue), // Seçildiğinde rengi mavi

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
            activeIcon: Icon(Icons.history, color: Colors.blue), // Seçildiğinde rengi mavi

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash_outlined),
            label: "Assets",
            activeIcon: Icon(Icons.car_crash_outlined, color: Colors.blue), // Seçildiğinde rengi mavi

          ),
        ],
        selectedItemColor: Colors.blue,
        selectedFontSize: 15,
      ),
    );
  }
}
