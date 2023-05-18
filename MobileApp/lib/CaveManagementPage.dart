import 'package:flutter/material.dart';
import 'package:wine_esp/Arguments.dart';
import 'package:wine_esp/Sockets.dart';

import 'Sockets.dart';

class CaveManagementPage extends StatefulWidget {
  const CaveManagementPage({Key? key, required this.socket}) : super(key: key);

  final Sockets socket;
  final String title = 'WinEsp';
  static String caveRouteName = '/cave';

  @override
  State<CaveManagementPage> createState() => _CaveManagementPageState();
}

class _CaveManagementPageState extends State<CaveManagementPage> {
  ScrollController _caveController = ScrollController();

  // contains a list of caves
  List<String> _caves = <String>[];
  //center text telling it's loading
  Widget _caveList = const Center(
      child: Text(
    'Loading...',
    style: TextStyle(fontSize: 24),
  ));

  // handle the /stats route
  void _handleCaveRoute(caveNumber) {
    Navigator.pushNamed(
      context,
      CaveManagementPage.caveRouteName,
      arguments: CaveArguments(
        _caves[caveNumber],
        caveNumber,
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
    widget.socket.sendlistCaves('2');
    widget.socket.receiveCaveList((data) {
      if (data.length == 0) {
        setState(() {
          _caves = <String>[];
          _caveList = const Text('No caves found');
        });
        return;
      }
      setState(() {
        _caves = data.cast<String>();
        _caveList = _buildCaveList();
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
          return Card(
            child: ListTile(
              title: Text(_caves[index]),
              onTap: () {
                _handleCaveRoute(index);
              },
            ),
          );
        });
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
        onPressed: () {
          setState(() {
            _caves.add('Cave Name ${_caves.length + 1}');
          });
        },
        tooltip: 'Add Cave',
        backgroundColor: const Color(0xff980201),
        child: const Icon(Icons.add, color: Color(0xffffffff)),
      ),
    );
  }
}
