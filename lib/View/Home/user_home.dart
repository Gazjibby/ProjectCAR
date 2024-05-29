import 'package:flutter/material.dart';
import 'package:projectcar/Providers/top_nav_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/View/User/book_ride.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Providers/bottom_nav_provider.dart';
import 'package:projectcar/View/User/logout.dart';
import 'package:projectcar/View/User/user_acc.dart';
import 'package:provider/provider.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key, required UserModel user});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<BottomNavProvider, TopNavProvider>(
        builder: (context, bottomNav, topNav, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PREBET UTM'),
          backgroundColor: AppColors.uniMaroon,
          foregroundColor: AppColors.uniGold,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserAcc()),
                );
              },
            ),
          ],
        ),
        body: _pages[bottomNav.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: _items,
          currentIndex: bottomNav.currentIndex,
          onTap: (value) {
            bottomNav.changeIndex = value;
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
