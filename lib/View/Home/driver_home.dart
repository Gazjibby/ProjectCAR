import 'package:flutter/material.dart';
import 'package:projectcar/Providers/logout_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/View/Driver/active_ride.dart';
import 'package:projectcar/View/Driver/cast_vote.dart';
import 'package:projectcar/View/Driver/driver_acc.dart';
import 'package:projectcar/View/Driver/get_ride.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Providers/bottom_nav_provider.dart';
import 'package:projectcar/Providers/top_nav_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DriverHome extends StatefulWidget {
  final DriverModel driver;
  const DriverHome({Key? key, required this.driver}) : super(key: key);

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Consumer3<BottomNavProvider, TopNavProvider, LogoutProvider>(
      builder: (context, bottomNav, topNav, logoutProvider, child) {
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
                    MaterialPageRoute(builder: (context) => const DriverAcc()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  logoutProvider.logout(context);
                },
              ),
            ],
          ),
          body: _topPages[bottomNav.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: _bottomItems,
            currentIndex: bottomNav.currentIndex,
            onTap: (value) {
              bottomNav.changeIndex = value;
            },
            backgroundColor: AppColors.uniMaroon,
            fixedColor: AppColors.uniPeach,
            unselectedItemColor: Colors.white,
          ),
        );
      },
    );
  }

  final List<Widget> _topPages = [
    const RideReq(),
    const ActiveRide(),
    const VotePage(),
  ];

  final List<BottomNavigationBarItem> _bottomItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: "Rides"),
    BottomNavigationBarItem(
        icon: Icon(Icons.emoji_transportation), label: "Active Ride"),
    BottomNavigationBarItem(icon: Icon(Icons.ballot), label: "Voting"),
  ];
}
