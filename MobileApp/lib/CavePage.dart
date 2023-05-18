import 'package:flutter/material.dart';

import 'Arguments.dart';
import 'CaveObject.dart';

class CavePage extends StatefulWidget {
  const CavePage({Key? key}) : super(key: key);

  static String bottleRouteName = '/bottle';
  static String addBottleRouteName = '/addBottle';

  @override
  State<CavePage> createState() => _CavePageState();
}

class _CavePageState extends State<CavePage> {
  void _handleBottleRoute(bottleNumber, caveName) {
    Navigator.pushNamed(
      context,
      CavePage.bottleRouteName,
      arguments: BottleArguments(
        caveName,
        bottleNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as CaveObject;
    // The page consists of 2 parts:
    // - a list of bottles as a horizontal scrollable list of cards
    // - a list of statistics as a vertical scrollable list of cards
    return Scaffold(
      appBar: AppBar(
        title: Text(args.name),
      ),
      body: Center(
        // divide the screen in 2 parts
        child: Column(
          children: <Widget>[
            // display the list of bottles
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: 160.0,
                    color: const Color(0xff980201),
                    child: GestureDetector(
                      child: Card(
                        child: Text('Bottle $index'),
                      ),
                      onTap: () {
                        _handleBottleRoute(index, args.name);
                      },
                    ),
                  );
                },
              ),
            ),
            // display the list of statistics
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: 160.0,
                    color: const Color(0xffE0D1A3),
                    child: Card(
                      child: Text('Stat $index'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            CavePage.addBottleRouteName,
            arguments: CaveArguments(
              args.name,
              args.id,
            ),
          );
        },
        backgroundColor: const Color(0xff980201),
        child: const Icon(Icons.add, color: Color(0xffffffff)),
      ),
    );
  }
}




