import 'package:wine_esp/Sockets.dart';

import 'package:flutter/material.dart';

class CaveEditingPage extends StatefulWidget {
  final Sockets socket;
  final Function() onCaveEdited;
  final String cavename;
  final String cavelocation;
  final String caveid;
  final String caveEditing = "/caveEditing";

  const CaveEditingPage({
    required Key key,
    required this.socket,
    required this.onCaveEdited,
    required this.cavename,
    required this.caveid,
    required this.cavelocation,
  }) : super(key: key);

  @override
  _CaveEditingPageState createState() => _CaveEditingPageState();
}

class _CaveEditingPageState extends State<CaveEditingPage> {
  final TextEditingController _caveNameController = TextEditingController();
  final TextEditingController _caveLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _caveNameController.text = widget.cavename;
    _caveLocationController.text = widget.cavelocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(style: const TextStyle(color: Color(0xff222222)), 'Edit Cave: ${widget.cavename}'),
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
            // pre fill the textfield with the cavename
            TextField(
              controller: _caveNameController,
              decoration: const InputDecoration(
                hintText: "Enter cave name",
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
                widget.socket.modifyCave(widget.caveid, caveName, caveLocation);
                widget.socket.receiveModifyCave(() => widget.onCaveEdited());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xffffffff),
                backgroundColor: const Color(0xff108963),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
