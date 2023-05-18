//The home page

import 'package:flutter/material.dart';
import 'ExpandableFAB.dart';
import 'Sockets.dart';
import 'CaveObject.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.socket}) : super(key: key);

  final Sockets socket;
  final String title = 'WinEsp';
  static String caveRouteName = '/cavemanagement';

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
  void _handleCaveRoute(caveNumber) {
    Navigator.pushNamed(
      context,
      HomePage.caveRouteName,
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
      child: GestureDetector(
        child: Card(
          // make the top corners rounded
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  const SizedBox(width: 10),
                  _buildCaveName(index),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                decoration: const BoxDecoration(
                  color: Color(0x45FFA194),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                ),
                child: _buildWineList(index),
              ),
            ],
          ),
        ),
        onTap: () {
          _handleCaveRoute(index);
        },
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
                _buildCaveStats(index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildWineNumber(int index, String color) {
  //   String num = '';
  //   if (color == 'red') num = _caves[index].numberWines.red.toString();
  //   if (color == 'white') num = _caves[index].numberWines.white.toString();
  //   if (color == 'rose') num = _caves[index].numberWines.rose.toString();
  //   return Expanded(
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Image(
  //             image: AssetImage('assets/images/$color-bottle.png'),
  //             width: 32,
  //             height: 32,
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(
  //             num,
  //             style: const TextStyle(fontSize: 18),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCaveStats(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _caves[index]
                            .data
                            .temperature
                            .toString()
                            .substring(0, 4),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(
                        Icons.thermostat,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _caves[index].data.humidity.toString().substring(0, 4),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(
                        Icons.water_drop,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _caves[index].data.light.toString().substring(0, 4),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(
                        Icons.lightbulb,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _caves[index].data.date.toString().split(' ')[1],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(
                        Icons.timer,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWineList(int index) {
    return SizedBox(
      height: 250.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (BuildContext context, int index2) {
          return _buildWineCardItem(index2, index);
        },
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
                      image: AssetImage(
                          'assets/images/${_caves[cave_index].wines[index].color}-bottle.png'),
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
                                    _caves[cave_index]
                                        .wines[index]
                                        .year
                                        .toString(),
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
    List<List<Wine>> caveWines = [];
    for (var i = 0; i < data[0].length; i++) {
      caveNames.add(data[0][i][1]);
      caveData.add(
          Data(data[1][i][1], data[1][i][2], data[1][i][3], data[1][i][4]));
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
