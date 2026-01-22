import 'package:flutter/material.dart';
import 'screen/dashboard_screen.dart';
import 'screen/assets_screen.dart';
import 'screen/monitoring_screen.dart';
import 'screen/alerts_screen.dart';
import 'screen/Setting_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BaSyx Mobile',
       theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1565C0), // xanh công nghiệp
  ),
  scaffoldBackgroundColor: const Color(0xFFF4F6F8),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1565C0),
    foregroundColor: Colors.white,
  ),
),

      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
   final screens = [
  DashboardScreen(onTabChange: (i) {
    setState(() => _index = i);
  }),
  const AssetsScreen(),
  const MonitoringScreen(), // thay cho Center
 const AlertsScreen(),
  const SettingsScreen() ,
];

    return Scaffold(
      appBar: AppBar(title: const Text("BaSyx Mobile")),
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // thêm dòng này
        currentIndex: _index,
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: "Assets"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Monitor"),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Alerts"),
         BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
