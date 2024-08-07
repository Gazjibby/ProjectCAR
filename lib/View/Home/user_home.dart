import 'package:flutter/material.dart';
import 'package:projectcar/Providers/logout_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/View/User/book_ride.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Providers/bottom_nav_provider.dart';
import 'package:projectcar/View/User/coming_soon.dart';
import 'package:projectcar/View/User/user_acc.dart';
import 'package:projectcar/View/User/user_ride_history.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key, required this.user});
  final UserModel user;
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<LogoutProvider>(context, listen: false)
                  .logout(context);
            },
          ),
        ],
      ),
      body: Consumer<BottomNavProvider>(
        builder: (context, bottomNav, child) {
          return _pages[bottomNav.currentIndex];
        },
      ),
      bottomNavigationBar: Consumer<BottomNavProvider>(
        builder: (context, bottomNav, child) {
          return BottomNavigationBar(
            items: _items,
            currentIndex: bottomNav.currentIndex,
            onTap: (value) {
              bottomNav.changeIndex = value;
            },
            backgroundColor: AppColors.uniMaroon,
            fixedColor: AppColors.uniPeach,
            unselectedItemColor: Colors.white,
          );
        },
      ),
    );
  }

  final List<Widget> _pages = [
    const BookRide(),
    const PersonalRideHistory(),
    const ComingSoon()
  ];

  final List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(
        icon: Icon(Icons.bookmark_add_outlined), label: "Book Ride"),
    BottomNavigationBarItem(
        icon: Icon(Icons.library_books), label: "Ride History"),
    BottomNavigationBarItem(
        icon: Icon(Icons.delivery_dining), label: "Coming Soon"),
  ];
}
