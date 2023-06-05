//The home page
import 'dart:convert';
import "dart:io";

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:wine_esp/AddBottlePage.dart';
import 'package:wine_esp/AddCavePage.dart';
import 'package:wine_esp/BottlePage.dart';
import 'package:wine_esp/CavePage.dart';
import 'package:wine_esp/ValuePage.dart';
import 'ExpandableFAB.dart';
import 'Sockets.dart';
import 'CaveObject.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.socket, required this.userId})
      : super(key: key);

  final Sockets socket;
  final String userId;
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

  @override
  void didChangeDependencies() {
    widget.socket.sendlistCavesHome(widget.userId);
    widget.socket.receiveCaveListHome((data) {
      if (data[0].length == 0) {
        setState(() {
          // make a widget that says no caves found in the middle of the screen
          _caveCardList = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'No caves found',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ]);
        });
      } else {
        setState(() {
          _caves = convertHome(data);
          _caveCardList = _buildCaveCardList();
        });
      }
    });
    super.didChangeDependencies();
  }

  // handle the /stats route
  void _handleCaveRoute(caveID) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CavePage(
            caveId: caveID,
            key: const Key('CavePage'),
            socket: widget.socket,
            onDeleted: () {
              widget.socket.sendlistCavesHome(widget.userId);
              widget.socket.receiveCaveListHome((data) {
                if (data[0].length == 0) {
                  setState(() {
                    // make a widget that says no caves found in the middle of the screen
                    _caveCardList = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'No caves found',
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ]);
                  });
                } else {
                  setState(() {
                    _caves = convertHome(data);
                    _caveCardList = _buildCaveCardList();
                  });
                }
              });
              didChangeDependencies();
            }),
      ),
    );
  }

  void _handleBottleRoute(wine, caveID) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BottlePage(
            key: const Key('CavePage'),
            socket: widget.socket,
            wine: wine,
            caveId: caveID.toString(),
            onBottlePage: () {
              widget.socket.sendlistCavesHome(widget.userId);
              widget.socket.receiveCaveListHome((data) {
                if (data[0].length == 0) {
                  setState(() {
                    // make a widget that says no caves found in the middle of the screen
                    _caveCardList = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'No caves found',
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ]);
                  });
                } else {
                  setState(() {
                    _caves = convertHome(data);
                    _caveCardList = _buildCaveCardList();
                  });
                }
              });
            }),
      ),
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
    widget.socket.sendlistCavesHome(widget.userId);
    widget.socket.receiveCaveListHome((data) {
      if (data[0].length == 0) {
        setState(() {
          // make a widget that says no caves found in the middle of the screen
          _caveCardList = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'No caves found',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ]);
        });
      } else {
        setState(() {
          _caves = convertHome(data);
          _caveCardList = _buildCaveCardList();
        });
      }
    });
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  Widget _buildCaveCardList() {
    return Container(
      color: const Color(0x80F6F6F6),
      child: ListView.builder(
        controller: _homeController,
        itemCount: _caves.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildCaveCardItem(index);
        },
      ),
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
          color: const Color(0xFF60A26D),
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
                  _buildCaveName(index),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
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
          _handleCaveRoute(_caves[index].id);
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
                        getSmallText(_caves[index].data.temperature),
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
                        getSmallText(_caves[index].data.humidity),
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
                        getSmallText(_caves[index].data.light),
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
        itemCount: _caves[index].wines.length,
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
          child: GestureDetector(
            child: Card(
              color: const Color(0xffCAD293),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: _caves[cave_index].wines[index].image != 'no-image'
                          ? Image(
                              image: Image.memory(
                                base64Decode(
                                    _caves[cave_index].wines[index].image),
                              ).image,
                              width: 150,
                              height: 240,
                              fit: BoxFit.contain,
                            )
                          : Image(
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
            onTap: () {
              _handleBottleRoute(
                  _caves[cave_index].wines[index], _caves[index].id);
            },
          ),
        ));
  }

  void _showAction(int index) {
    switch (index) {
      case 0:
        if (_caves.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No caves found'),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddBottlePage(
              socket: widget.socket,
              caveId: _caves[0].id.toString(),
              cavename: _caves[0].name,
              onBottleAdded: () {
                widget.socket.sendlistCavesHome(widget.userId);
                widget.socket.receiveCaveListHome((data) {
                  if (data[0].length == 0) {
                    setState(() {
                      // make a widget that says no caves found in the middle of the screen
                      _caveCardList = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'No caves found',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ]);
                    });
                  } else {
                    setState(() {
                      _caves = convertHome(data);
                      _caveCardList = _buildCaveCardList();
                    });
                  }
                });
              },
            ),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCavePage(
              key: const Key('add_cave_page'),
              socket: widget.socket,
              userId: widget.userId,
              onCaveAdded: () {
                widget.socket.sendlistCavesHome(widget.userId);
                widget.socket.receiveCaveListHome((data) {
                  if (data[0].length == 0) {
                    setState(() {
                      // make a widget that says no caves found in the middle of the screen
                      _caveCardList = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'No caves found',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ]);
                    });
                  } else {
                    setState(() {
                      _caves = convertHome(data);
                      _caveCardList = _buildCaveCardList();
                    });
                  }
                });
                didChangeDependencies();
              },
            ),
          ),
        );
        break;
      case 2:
        if (_caves.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No caves found'),
            ),
          );
          return;
        }
        widget.socket.sendDataStats(widget.userId);
        List<CaveObjectStats> stats;
        widget.socket.receiveDataStats((data) {
          stats = convertPageData(data);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ValuePage(
                      socket: widget.socket,
                      cave: stats[0],
                      type: 'temperature',
                      onValueChanged: () {})));
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _caveCardList,
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _showAction(0),
            icon: Image.asset(
              'assets/images/bottle.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              color: const Color(0xff222222),
            ),
          ),
          ActionButton(
            onPressed: () => _showAction(1),
            icon: const Icon(Icons.shelves),
          ),
          ActionButton(
            onPressed: () => _showAction(2),
            icon: const Icon(Icons.warning),
          ),
        ],
      ),
    );
  }

  String getSmallText(double value) {
    // if the temperature is more than 4 digits long cut it down to 4 digits
    if (value.toString().length > 4) {
      value = double.parse(value.toString().substring(0, 4));
    }
    String temp = value.toString();
    return temp;
  }
}
