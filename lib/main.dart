import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projectcar/View/login_view.dart';
import 'package:provider/provider.dart';
import 'package:projectcar/firebase_options.dart';
import 'package:projectcar/Providers/active_ride_provider.dart';
import 'package:projectcar/Providers/ride_template_provider.dart';
import 'package:projectcar/Providers/top_nav_provider.dart';
import 'package:projectcar/Providers/poll_db_provider.dart';
import 'package:projectcar/Providers/get_poll_db_provider.dart';
import 'package:projectcar/Providers/bottom_nav_provider.dart';
import 'package:projectcar/Providers/get_ride_provider.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectcar/Model/admin.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActiveRideProvider()),
        ChangeNotifierProvider(create: (_) => RideTemplateProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => PollDbProvider()),
        ChangeNotifierProvider(create: (_) => FetchPollsProvider()),
        ChangeNotifierProvider(create: (context) => TopNavProvider()),
        ChangeNotifierProvider(create: (context) => BottomNavProvider()),
      ],
      child: MaterialApp(
        title: "Prebet UTM",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.uniPeach,
          ),
          textTheme: TextTheme(
            displayLarge: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: GoogleFonts.oswald(
              fontSize: 30,
              fontStyle: FontStyle.italic,
            ),
            bodyMedium: GoogleFonts.oswald(),
            displaySmall: GoogleFonts.oswald(),
          ),
        ),
        home: LoginView(),
      ),
    );
  }
}
