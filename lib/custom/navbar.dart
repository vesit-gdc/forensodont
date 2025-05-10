import 'package:flutter/material.dart';
import 'package:forensodont/pages/about.dart';
import 'package:forensodont/pages/home.dart';
import 'package:forensodont/pages/profile.dart';

class Navbar extends StatefulWidget {
  final int initialIndex;

  const Navbar({
    super.key,
    required this.initialIndex
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, About.id);
    } else if (index == 1) {
      Navigator.pushNamed(context, HomePage.id);
    } else if (index == 2) {
      Navigator.pushNamed(context, ProfilePage.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(37.5),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.purple.shade900,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'About',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.house),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}