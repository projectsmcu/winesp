import 'package:flutter/material.dart';
import 'package:wine_esp/CavePage.dart';
import 'package:wine_esp/Sockets.dart';

import 'AddCavePage.dart';
import 'CaveObject.dart';

class CaveManagementPage extends StatefulWidget {
  const CaveManagementPage(
      {Key? key, required this.socket, required this.userId})
      : super(key: key);

  final Sockets socket;
  final String userId;
  final String title = 'WinEsp';
  static String caveRouteName = '/cave';
  static String addCaveRouteName = '/addCave';

  @override
  State<CaveManagementPage> createState() => _CaveManagementPageState();
}

class _CaveManagementPageState extends State<CaveManagementPage> {
  ScrollController _caveController = ScrollController();

  // contains a list of caves
  List<CaveObjectManagement> _caves = <CaveObjectManagement>[];
  //center text telling it's loading
  Widget _caveList = const Center(
      child: Text(
    'Loading...',
    style: TextStyle(fontSize: 24),
  ));

  void _handleCaveRoute(caveID) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CavePage(
            caveId: caveID,
            key: const Key('CavePage'),
            socket: widget.socket,
            onDeleted: () {
              widget.socket.sendCavesManagementPage(widget.userId);
              widget.socket.receiveCavesManagementPage((data) {
                setState(() {
                  _caves = convertCavesManagement(data);
                  _caves.isEmpty
                      ? _caveList = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Text(
                                  "No caves yet",
                                  style: TextStyle(
                                    color: Color(0xff222222),
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : _caveList = _buildCaveList();
                });
              });
              Navigator.of(context).pop();
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
    _caveController = ScrollController();
    widget.socket.sendCavesManagementPage(widget.userId);
    widget.socket.receiveCavesManagementPage((data) {
      if (data.isEmpty) {
        setState(() {
          _caveList = const Text('No caves found');
        });
        return;
      }
      setState(() {
        _caves = convertCavesManagement(data);
        _caves.isEmpty
            ? _caveList = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "No caves yet",
                        style: TextStyle(
                          color: Color(0xff222222),
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : _caveList = _buildCaveList();
      });
    });
  }

  @override
  void dispose() {
    _caveController.dispose();
    super.dispose();
  }

  Widget _buildCaveList() {
    return ListView.builder(
        controller: _caveController,
        itemCount: _caves.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildCaveCardItem(index);
        });
  }

  Widget _buildCaveCardItem(int index) {
    // The cave contains the name of the cave and the number of bottles with a icon in the top left corner
    // in the top rigt corner the data of the last update
    // in the bottom a horizontal scrollable list of bottles
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 3),
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
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    _caves[index].name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Last update: ${_caves[index].lastUpdate}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/bottle.png',
                                  color: const Color(0xff722F37),
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                    width:
                                        5), // Add spacing between image and text
                                Expanded(
                                  child: Text(
                                    "${_caves[index].numberWines.red}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/bottle.png',
                                  color: const Color(0xfff9e8c0),
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                    width:
                                        5), // Add spacing between image and text
                                Expanded(
                                  child: Text(
                                    "${_caves[index].numberWines.white}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/bottle.png',
                                  color: const Color(0xffe6b2b8),
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                    width:
                                        5), // Add spacing between image and text
                                Expanded(
                                  child: Text(
                                    "${_caves[index].numberWines.rose}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Add spacing between text and total
                  Text(
                    "Total: ${_caves[index].numberWines.red + _caves[index].numberWines.white + _caves[index].numberWines.rose}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  Image.asset(
                    'assets/images/bottle.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
        onTap: () {
          _handleCaveRoute(_caves[index].id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _caveList,
            ),
          ],
        ),
      ),
      //add a cave button
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(
          side: BorderSide(
            color: Color(0xff222222),
            width: 2.0,
          ),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCavePage(
                  key: const Key('addCavePage'),
                  socket: widget.socket,
                  userId: widget.userId,
                  onCaveAdded: () {
                    widget.socket.sendCavesManagementPage(widget.userId);
                    widget.socket.receiveCavesManagementPage((data) {
                      setState(() {
                        _caves = convertCavesManagement(data);
                        _caves.isEmpty
                            ? _caveList = Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const <Widget>[
                                      Text(
                                        "No caves yet",
                                        style: TextStyle(
                                          color: Color(0xff222222),
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : _caveList = _buildCaveList();
                      });
                    });
                  }),
            ),
          );
        },
        tooltip: 'Add Cave',
        backgroundColor: const Color(0xffB8CE9E),
        child: const Icon(Icons.add, color: Color(0xff2F4858)),
      ),
    );
  }
}
