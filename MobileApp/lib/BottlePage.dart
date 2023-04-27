import 'package:flutter/material.dart';

import 'CavePage.dart';

class BottlePage extends StatefulWidget {
  const BottlePage({Key? key}) : super(key: key);

  @override
  State<BottlePage> createState() => _BottlePageState();
}

class _BottlePageState extends State<BottlePage> {
  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as BottleArguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.caveName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bottle n°${args.bottleNumber+1}',
            ),
            Text(
              args.caveName,
            ),
          ],
        ),
      ),
    );
  }
}