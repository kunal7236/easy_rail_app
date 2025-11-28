import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import 'providers/pnr_provider.dart';
import 'providers/train_search_provider.dart';
import 'providers/live_status_provider.dart';
import 'providers/availability_provider.dart';
import 'providers/home_provider.dart';
import 'providers/at_station_provider.dart';

import 'screens/home_screen.dart';
import 'screens/availability_screen.dart';
import 'screens/train_search_screen.dart';
import 'screens/pnr_status_screen.dart';
import 'screens/live_status_screen.dart';
import 'screens/at_station_screen.dart';

import 'utils/app_theme.dart';
import 'widgets/app_header.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PnrProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TrainSearchProvider()),
        ChangeNotifierProvider(create: (_) => LiveStatusProvider()),
        ChangeNotifierProvider(create: (_) => AvailabilityProvider()),
        ChangeNotifierProvider(create: (_) => AtStationProvider()),
      ],
      child: const EasyRailApp(),
    ),
  );
}

class EasyRailApp extends StatelessWidget {
  const EasyRailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Rail',
      theme: AppTheme.theme, //  custom theme
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // Default to Home

  final List<Widget> _screens = [
    const HomeScreen(),
    const AvailabilityScreen(),
    const TrainSearchScreen(),
    const PnrStatusScreen(),
    const LiveStatusScreen(),
    const AtStationScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),

      // The main content area
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.accentDark,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_seat),
            label: 'Availability',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Train Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'PNR Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.train),
            label: 'Live Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.departure_board),
            label: 'At Station',
          ),
        ],
      ),
    );
  }
}
