import 'package:flutter/material.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/View/Driver/active_ride.dart';
import 'package:projectcar/View/Driver/cast_vote.dart';
import 'package:projectcar/View/Driver/driver_acc.dart';
import 'package:projectcar/View/Driver/get_ride.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Providers/bottom_nav_provider.dart';
import 'package:projectcar/Providers/top_nav_provider.dart';
import 'package:provider/provider.dart';

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
    Provider.of<TopNavProvider>(context, listen: false)
        .initTabController(this, _topTabs.length);
  }

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
                    MaterialPageRoute(builder: (context) => const DriverAcc()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {},
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

  final List<Tab> _topTabs = const [
    Tab(icon: Icon(Icons.account_circle), text: "Account"),
    Tab(icon: Icon(Icons.logout), text: "Logout"),
  ];
}
