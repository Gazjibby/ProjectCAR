import 'package:flutter/material.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/View/User/book_ride.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Providers/bottom_nav_provider.dart';
import 'package:projectcar/View/User/logout.dart';
import 'package:provider/provider.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key, required UserModel user});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavProvider>(builder: (context, nav, child) {
      return Scaffold(
        body: _pages[nav.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: _items,
          currentIndex: nav.currentIndex,
          onTap: (value) {
            nav.changeIndex = value;
          },
          backgroundColor: AppColors.uniMaroon,
          fixedColor: AppColors.uniPeach,
          unselectedItemColor: Colors.white,
        ),
      );
    });
  }

  final List<Widget> _pages = [
    const BookRide(),
    const UserLogout(),
  ];

  final List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(
        icon: Icon(Icons.bookmark_add_outlined), label: "Book Ride"),
    BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Log Out"),
  ];
}
