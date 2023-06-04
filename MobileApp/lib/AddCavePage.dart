import 'package:wine_esp/Sockets.dart';

import 'package:flutter/material.dart';

class AddCavePage extends StatefulWidget {
  final Sockets socket;
  final Function() onCaveAdded;
  final String userId;

  const AddCavePage({
    required Key key,
    required this.socket,
    required this.onCaveAdded,
    required this.userId,
  }) : super(key: key);

  @override
  _AddCavePageState createState() => _AddCavePageState();
}

class _AddCavePageState extends State<AddCavePage> {
  final TextEditingController _caveNameController = TextEditingController();
  final TextEditingController _caveLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(style: TextStyle(color: Color(0xff222222)), 'Add Cave'),
        backgroundColor: const Color(0xfffaeab1),
        iconTheme: const IconThemeData(color: Color(0xff222222)),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Cave Name',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _caveNameController,
              decoration: const InputDecoration(
                hintText: 'Enter cave name',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Cave Location',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _caveLocationController,
              decoration: const InputDecoration(
                hintText: 'Enter cave location',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Collect data and send to server
                final String caveName = _caveNameController.text;
                final String caveLocation = _caveLocationController.text;
                widget.socket.addCave(widget.userId, caveName, caveLocation);
                widget.socket.receiveAddCave(() => widget.onCaveAdded());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xffffffff),
                backgroundColor: const Color(0xff108963),
              ),
              child: const Text('Add Cave'),
            ),
          ],
        ),
      ),
    );
  }
}
