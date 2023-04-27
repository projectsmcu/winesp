import 'package:flutter/material.dart';

class CaveManagementPage extends StatefulWidget {
  const CaveManagementPage({Key? key}) : super(key: key);

  final String title = 'WinEsp';
  static String caveRouteName = '/cave';

  @override
  State<CaveManagementPage> createState() => _CaveManagementPageState();
}

class _CaveManagementPageState extends State<CaveManagementPage> {
  ScrollController _caveController = ScrollController();

  // contains a list of caves
  List<String> _caves = <String>[];

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
  void initState() {
    super.initState();
    _caveController = ScrollController();
    _caves = <String>['Cave Name 1', 'Cave Name 2', 'Cave Name 3'];
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
              child: _buildCaveList(),
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
        backgroundColor:const Color(0xff980201),
        child: const Icon(Icons.add, color: Color(0xffffffff)),
      ),
    );
  }
}

class CaveArguments {
  final String name;
  final int number;

  CaveArguments(this.name, this.number);
}
