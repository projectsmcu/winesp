//The home page

import 'package:flutter/material.dart';
import 'ExpandableFAB.dart';
import 'Sockets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.socket}) : super(key: key);

  final Sockets socket;
  final String title = 'WinEsp';
  static String statsRouteName = '/stats';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _homeController = ScrollController();

  List<CaveObject> _caves = <CaveObject>[];
  Widget _caveCardList = const Center(
      child: Text(
    'Loading...',
    style: TextStyle(fontSize: 24),
  ));

  // handle the /stats route
  void _handleStatsRoute(caveNumber) {
    Navigator.pushNamed(
      context,
      HomePage.statsRouteName,
      arguments: _caves[caveNumber],
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _homeController = ScrollController();
    widget.socket.sendlistCaves('1');
    widget.socket.receiveCaveList((data) {
      if (data[0].length == 0) {
        setState(() {
          _caveCardList = const Text('No caves found');
        });
        return;
      }
      setState(() {
        _caves = convert(data);
        _caveCardList = _buildCaveCardList();
      });
    });
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  Widget _buildCaveCardList() {
    return ListView.builder(
      controller: _homeController,
      itemCount: _caves.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildCaveCardItem(index);
      },
    );
  }

  Widget _buildCaveCardItem(int index) {
    // The cave contains the name of the cave and the number of bottles with a icon in the top left corner
    // in the top rigt corner the data of the last update
    // in the bottom a horizontal scrollable list of bottles
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 13),
      child: Container(
        color: const Color(0xFFFFFFFF),
        child: GestureDetector(
          child: Card(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    _buildCaveName(index),
                    _buildCaveStats(index),
                  ],
                ),
                _buildWineList(index),
              ],
            ),
          ),
          onTap: () {
            _handleStatsRoute(index);
          },
        ),
      ),
    );
  }

  Widget _buildCaveName(int index) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  _caves[index].name,
                  style: const TextStyle(fontSize: 32),
                ),
                Row(
                  children: [
                    _buildWineNumber(index, 'red'),
                    _buildWineNumber(index, 'white'),
                    _buildWineNumber(index, 'rose'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWineNumber(int index, String color) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Image(
              image: AssetImage('assets/images/$color-bottle.png'),
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
          const Expanded(
            child: Text(
              '0',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaveStats(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    _caves[index].data.temperature.toString().substring(0, 4),
                    style: TextStyle(fontSize: 16),
                  ),
                  const Icon(
                    Icons.thermostat,
                    size: 20,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _caves[index].data.humidity.toString().substring(0, 4),
                    style: TextStyle(fontSize: 16),
                  ),
                  const Icon(
                    Icons.water_drop,
                    size: 20,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _caves[index].data.light.toString().substring(0, 4),
                    style: TextStyle(fontSize: 16),
                  ),
                  const Icon(
                    Icons.lightbulb,
                    size: 20,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _caves[index].data.date.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  const Icon(
                    Icons.timer,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWineList(int index) {
    return Container(
      color: const Color(0x45FFA194),
      child: SizedBox(
        height: 250.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (BuildContext context, int index2) {
            return _buildWineCardItem(index2, index);
          },
        ),
      ),
    );
  }

  Widget _buildWineCardItem(int index, int cave_index) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
        child: SizedBox(
          width: 150.0,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: Image(
                      image: AssetImage('assets/images/${_caves[cave_index].wines[index].color}-bottle.png'),
                      width: 150,
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          // The name of the wine center at the top the region on the left and the year on the right
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _caves[cave_index].wines[index].name,
                                      style: const TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _caves[cave_index].wines[index].region,
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _caves[cave_index].wines[index].year.toString(),
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
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
      body: _caveCardList,
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

  List<CaveObject> convert(List<dynamic> data) {
    List<String> caveNames = [];
    List<CaveObject> caveObjects = [];
    List<Data> caveData = [];
    List<int> caveWineIds = [];
    List<List<Wine>> caveWines = [];
    for (var i = 0; i < data[0].length; i++) {
      caveNames.add(data[0][i][1]);
      caveData.add(
          Data(data[1][i][1], data[1][i][2], data[1][i][3], data[1][i][4]));
      caveWineIds.add(data[2][i][1]);
      for (var j = 0; j < data[3][i].length; j++) {
        //initializing the list of wines
        caveWines.add([]);
        caveWines[i].add(Wine(
            data[3][i][j][1],
            data[3][i][j][0],
            data[3][i][j][3],
            data[3][i][j][5],
            data[3][i][j][4],
            data[3][i][j][6],
            data[3][i][j][8],
            data[3][i][j][9],
            [data[3][i][j][7]]));
      }
      caveObjects.add(CaveObject(caveNames[i], i, caveWines[i], caveData[i]));
    }

    return caveObjects;
  }
}

//the MaterialApp widget with the routes
class CaveArguments {
  final String name;
  final int number;

  CaveArguments(this.name, this.number);
}

class CaveObject {
  final String name;
  final int id;
  final List<Wine> wines;
  final Data data;

  CaveObject(this.name, this.id, this.wines, this.data);
}

class Wine {
  final String name;
  final int id;
  final String color;
  final String region;
  final String country;
  final int year;
  final double rating;
  final double price;
  final List<String> grapes;

  Wine(this.name, this.id, this.color, this.region, this.country, this.year,
      this.rating, this.price, this.grapes);
}

class Data {
  final double temperature;
  final double humidity;
  final double light;
  final String date;

  Data(this.temperature, this.humidity, this.light, this.date);
}
