//The home page

import 'package:flutter/material.dart';
import 'ExpandableFAB.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  final String title = 'WinEsp';
  static String statsRouteName = '/stats';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _homeController = ScrollController();

  // contains a list of caves
  List<String> _caves = <String>[];

  

  // handle the /stats route
  void _handleStatsRoute(caveNumber) {
    Navigator.pushNamed(
      context,
      HomePage.statsRouteName,
      arguments: CaveArguments(
        _caves[caveNumber],
        caveNumber,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _homeController = ScrollController();
    _caves = <String>['Cave Name 1', 'Cave Name 2', 'Cave Name 3'];
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  Widget _buildCaveList() {
    return Center(
      child: ListView.builder(
        controller: _homeController,
        itemCount: _caves.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(_caves[index]),
              onTap: () {
                _handleStatsRoute(index);
              },
            ),
          );
        }
      ),
    );
  }

  void _showAction(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You selected: $index'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCaveList(),
        floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _showAction(context, 0),
            icon: const Icon(Icons.format_size),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 1),
            icon: const Icon(Icons.insert_photo),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 2),
            icon: const Icon(Icons.videocam),
          ),
        ],
      ),
        
    ); 
  }
}

//the MaterialApp widget with the routes
class CaveArguments {
  final String name;
  final int number;

  CaveArguments(this.name, this.number);
}
