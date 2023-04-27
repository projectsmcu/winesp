import 'package:flutter/material.dart';
import 'package:wine_esp/HomePage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'AddBottlePage.dart';
import 'BottlePage.dart';
import 'CaveManagementPage.dart';
import 'StatsPage.dart';
import 'CaveStatsPage.dart';
import 'CavePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void connect() async {
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:5000'),
    );
    channel.stream.listen(
      (data) {
        print(data);
      },
      onError: (error) => print(error),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xffE0D1A3),
            secondary: Color(0xff980201),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xffE0D1A3),
            selectedItemColor: Colors.black,
            unselectedItemColor: Color(0xff980201),
          )),
      home: const MainPage(title: 'WinEsp'),
      routes: {
        HomePage.statsRouteName: (context) => const CaveStatsPage(),
        CaveManagementPage.caveRouteName: (context) => const CavePage(),
        CavePage.bottleRouteName: (context) => const BottlePage(),
        CavePage.addBottleRouteName: (context) => const AddBottlePage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required title});

  final String title = 'WinEsp';

  @override
  State<MainPage> createState() => _MainState();
}

class _MainState extends State<MainPage> {
  int _selectedIndex = 1;
  ScrollController _homeController = ScrollController();

  @override
  void initState() {
    super.initState();
    _homeController = ScrollController();
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  final List<Widget> _widgetMenu = <Widget>[
    const StatsPage(),
    const HomePage(),
    const CaveManagementPage(),
  ];

  final List<String> _TitleMenu = <String>[
    'Stats',
    'Home',
    'Caves',
  ];

  void _handleBottomNavigationBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WinEsp ${_TitleMenu.elementAt(_selectedIndex)}'),
      ),
      body: _widgetMenu.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.query_stats), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shelves),
            label: 'Caves',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        onTap: (int index) {
          _handleBottomNavigationBarTap(index);
        },
      ),
    );
  }

  void showCaveList(BuildContext context) {}
}
