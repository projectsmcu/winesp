import 'package:flutter/material.dart';
import 'package:wine_esp/CaveManagementPage.dart';
import 'package:wine_esp/HomePage.dart';
import 'package:wine_esp/ProfilePage.dart';
import 'package:wine_esp/Sockets.dart';
import 'package:wine_esp/StatsPage.dart';
import 'package:wine_esp/main.dart';

class AfterLoginPage extends StatefulWidget {
  const AfterLoginPage({Key? key, required this.socket, required this.userId})
      : super(key: key);

  final Sockets socket;
  final String userId;

  @override
  State<AfterLoginPage> createState() => _AfterLoginPageState();
}

class _AfterLoginPageState extends State<AfterLoginPage> {
  int _selectedIndex = 1;
  ScrollController _homeController = ScrollController();
  List<Widget> _widgetMenu = <Widget>[];

  @override
  void initState() {
    super.initState();
    _homeController = ScrollController();
    _widgetMenu = [
      StatsPage(
        socket: widget.socket,
        userId: widget.userId,
      ),
      HomePage(
        socket: widget.socket,
        userId: widget.userId,
      ),
      CaveManagementPage(
        socket: widget.socket,
        userId: widget.userId,
      ),
    ];
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

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

  Widget buildMain() {
    return WillPopScope(
        onWillPop: () async {
          // Block going back to the login page
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
                //make the color of the title black
                style: const TextStyle(color: Color(0xff222222)),
                'WinEsp ${_TitleMenu.elementAt(_selectedIndex)}'),
            // a profile icon to access the profile page
            iconTheme: const IconThemeData(color: Color(0xff222222)),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        key: const Key('add_cave_page'),
                        socket: widget.socket,
                        userId: widget.userId,
                        quit: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainPage(
                                title: 'WinEsp',
                                socket: widget.socket,
                                quit: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            ],
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return buildMain();
  }
}
