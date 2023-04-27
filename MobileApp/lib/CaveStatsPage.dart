import 'package:flutter/material.dart';

import 'HomePage.dart';

class CaveStatsPage extends StatefulWidget {

  const CaveStatsPage({Key? key}): super(key: key);

  
  @override
  State<CaveStatsPage> createState() => _CaveStatsPageState();
}

class _CaveStatsPageState extends State<CaveStatsPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as CaveArguments;

          // display the information for the cave
    return Scaffold(
      appBar: AppBar(
        title: Text(args.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Cave n°${args.number+1}',
            ),
            Text(
              args.name,
            ),
          ],
        ),
      ),
    );
  }
}


