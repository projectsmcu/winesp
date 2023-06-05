import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wine_esp/AddBottlePage.dart';
import 'package:wine_esp/BottlePage.dart';
import 'package:wine_esp/CaveEditingPage.dart';
import 'package:wine_esp/Sockets.dart';

import 'CaveObject.dart';

class CavePage extends StatefulWidget {
  const CavePage(
      {Key? key,
      required this.socket,
      required this.onDeleted,
      required this.caveId})
      : super(key: key);

  final Sockets socket;
  final int caveId;

  static String bottleRouteName = '/bottle';
  static String addBottleRouteName = '/addBottle';
  final Function() onDeleted;

  @override
  State<CavePage> createState() => _CavePageState();
}

class _CavePageState extends State<CavePage> {
  void _handleAddBottle() async {
    //open a caveEditingPage
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBottlePage(
            key: const Key('addBottlePage'),
            socket: widget.socket,
            caveId: widget.caveId.toString(),
            cavename: _cave.name,
            onBottleAdded: () {
              widget.socket.sendCavePage(widget.caveId.toString());
              widget.socket.receiveCavePage((data) {
                if (data.isEmpty) {
                  return;
                }
                setState(() {
                  _cave = convertPage(data);
                });
              });
              super.didChangeDependencies();
            }),
      ),
    );
  }

  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  String _colorFilter = 'All';

  // contains a list of caves
  CaveObject _cave = CaveObject.empty();
  //center text telling it's loading

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    widget.socket.sendCavePage(widget.caveId.toString());
    widget.socket.receiveCavePage((data) {
      if (data.isEmpty) {
        return;
      }
      setState(() {
        _cave = convertPage(data);
      });
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // implement _handleEditCaveRoute
  void _handleEditCaveRoute(int caveId) async {
    //open a caveEditingPage
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaveEditingPage(
            key: const Key('addCavePage'),
            socket: widget.socket,
            cavename: _cave.name,
            cavelocation: _cave.location,
            caveid: caveId.toString(),
            onCaveEdited: () {
              widget.socket.sendCavePage(caveId.toString());
              widget.socket.receiveCavePage((data) {
                if (data.isEmpty) {
                  return;
                }
                setState(() {
                  _cave = convertPage(data);
                });
              });
              super.didChangeDependencies();
            }),
      ),
    );
  }

  void _handleBottle(wine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BottlePage(
            key: const Key('addCavePage'),
            socket: widget.socket,
            wine: wine,
            caveId: _cave.id.toString(),
            onBottlePage: () {
              widget.socket.sendCavePage(widget.caveId.toString());
              widget.socket.receiveCavePage((data) {
                if (data.isEmpty) {
                  return;
                }
                setState(() {
                  _cave = convertPage(data);
                });
              });
              super.didChangeDependencies();
            }),
      ),
    );
  }

  void _handleDeleteCave(int caveId) async {
    //open a dialog to confirm the deletion
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Cave'),
          content: const Text('Are you sure you want to delete this cave?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.socket.sendDeleteCave(caveId.toString());
                widget.socket.receiveDeleteCave(() {
                  widget.onDeleted();
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _handleConnectCave() async {
    //open a dialog to explain how to connect
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connect to Cave'),
          content: const Text(
              'To connect to this cave, please press the button on the cave\'s esp32 board for 5 seconds.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Wine> wines = _cave.wines.where((Wine wine) {
      final bool nameMatches =
          wine.name.toLowerCase().contains(_filter.toLowerCase()) ||
              wine.region.toLowerCase().contains(_filter.toLowerCase()) ||
              wine.grapes.toLowerCase().contains(_filter.toLowerCase()) ||
              wine.country.toLowerCase().contains(_filter.toLowerCase()) ||
              wine.year.toString().contains(_filter.toLowerCase());
      final bool colorMatches = _colorFilter == 'All' ||
          wine.color.toLowerCase() == _colorFilter.toLowerCase();
      return nameMatches && colorMatches;
    }).toList();
    //get the id from the context
    // The page consists of 2 parts:
    // - a card with the information about the cave displayed at the top of the screen
    // - a list of statistics as a horizontal scrollable list of cards
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
            style: const TextStyle(color: Color(0xff222222)),
            "Cave : ${_cave.name}"),
        backgroundColor: const Color(0xfffaeab1),
        iconTheme: const IconThemeData(color: Color(0xff222222)),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'edit') {
                _handleEditCaveRoute(_cave.id);
              } else if (value == 'delete') {
                _handleDeleteCave(_cave.id);
              } else if (value == 'connect') {
                widget.socket.connectCave(_cave.id.toString());
                widget.socket.receiveConnectCave((data) {
                  _handleConnectCave();
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'connect',
                  child: ListTile(
                    leading: Icon(Icons.sensors),
                    title: Text(
                      'Connect',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text(
                      'Edit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text(
                      'Delete',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        // divide the screen in 2 parts
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(5),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                color: const Color(0xffB8CE9E),
                child: Column(
                  children: <Widget>[
                    // display the name of the cave with a icon but centered
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.shelves),
                        Text(
                          _cave.name,
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    // display the id of the cave but in a smaller font
                    Text(
                      '#${_cave.id}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    // make two columns of text one with the location, number of bottles and total price
                    // and the other with the stats
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 5, 5, 5),
                      child: Row(
                        children: <Widget>[
                          // make a column with the location, number of bottles and total price
                          SizedBox(
                            width: 150,
                            child: Column(
                              children: <Widget>[
                                // display the location of the cave with pin location icon
                                Row(
                                  children: <Widget>[
                                    const Icon(Icons.location_pin),
                                    Text(
                                      _cave.location,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(padding: EdgeInsets.only(top: 8)),
                                // display the number of bottles in the cave aligned to the left
                                Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/images/bottle.png',
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.contain,
                                      color: const Color(0xff222222),
                                    ),
                                    Text(
                                      '${wines.length} bottles',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                // display the total price of the cave aligned to the left
                                const Padding(padding: EdgeInsets.only(top: 8)),
                                Row(
                                  children: <Widget>[
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(11, 0, 0, 0),
                                    ),
                                    Text(
                                      // sum the price of all the wines in the cave
                                      'Total: ${cutText(wines.fold<double>(0, (double previousValue, Wine wine) => previousValue + wine.price * wine.quantity).toString(), wines.fold<double>(0, (double previousValue, Wine wine) => previousValue + wine.price).toString().indexOf(".") + 3)}€',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            child: Column(
                              // align the text to the right
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                // display the temperature of the cave aligned to the right
                                Transform.translate(
                                  offset: const Offset(8, -5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '${cutText(_cave.data.temperature.toString(), 4)}°C',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Icon(Icons.thermostat_outlined),
                                    ],
                                  ),
                                ),
                                // display the humidity of the cave aligned to the right
                                Transform.translate(
                                  offset: const Offset(8, 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '${cutText(_cave.data.humidity.toString(), 4)}%',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Icon(Icons.water_damage_outlined),
                                    ],
                                  ),
                                ),
                                // display the light level of the cave aligned to the right
                                Transform.translate(
                                  offset: const Offset(8, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '${cutText(_cave.data.light.toString(), 4)}%',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Icon(Icons.lightbulb_outline),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _filter = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _colorFilter,
                    items: <String>['All', 'red', 'white', 'rose']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value
                              .replaceAll("red", "Red")
                              .replaceAll("white", "White")
                              .replaceAll("rose", "Rosé")));
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _colorFilter = value ?? 'All';
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // The bottom is a Horizontal scroll list of all the bottles in the cave that you can scroll and take all the space left
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: wines.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _handleBottle(wines[index]);
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.all(5),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        color: const Color(0xffB8CE9E),
                        child: Column(
                          // make a big column with the image of the bottle in the top center and the name of the wine in the bottom center
                          mainAxisAlignment: MainAxisAlignment.start,

                          children: <Widget>[
                            // display the image of the bottle
                            wines[index].image != 'no-image'
                                ? Image(
                                    image: Image.memory(
                                      base64Decode(wines[index].image),
                                    ).image,
                                    width: 150,
                                    height: 240,
                                    fit: BoxFit.contain,
                                  )
                                : Image(
                                    image: AssetImage(
                                        'assets/images/${wines[index].color}-bottle.png'),
                                    width: 150,
                                    height: 240,
                                    fit: BoxFit.contain,
                                  ),
                            // display the name of the wine
                            Text(
                              wines[index].name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${wines[index].country} - ${wines[index].region}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${wines[index].year} - ${wines[index].color.replaceAll("red", "Red").replaceAll("white", "White").replaceAll("rose", "Rosé")}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${cutText(wines[index].price.toString(), wines[index].price.toString().indexOf(".") + 3)}€ - ${wines[index].quantity} bottles',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            // display the country and the region of the wine
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(
          side: BorderSide(
            color: Color(0xff222222),
            width: 2.0,
          ),
        ),
        onPressed: () {
          _handleAddBottle();
        },
        tooltip: 'Add Bottle',
        backgroundColor: const Color(0xffB8CE9E),
        child: const Icon(Icons.add, color: Color(0xff2F4858)),
      ),
    );
  }

  // function to cut the text if it's too long
  String cutText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength);
    }
    return text;
  }
}
