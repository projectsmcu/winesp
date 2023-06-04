import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wine_esp/EditBottlePage.dart';
import 'package:wine_esp/Sockets.dart';
import 'CaveObject.dart';

class BottlePage extends StatefulWidget {
  const BottlePage(
      {Key? key,
      required this.socket,
      required this.wine,
      required this.caveId,
      required this.onBottlePage})
      : super(key: key);

  final Sockets socket;
  final Wine wine;
  final String caveId;
  final Function() onBottlePage;

  @override
  State<BottlePage> createState() => _BottlePageState();
}

class _BottlePageState extends State<BottlePage> {
  late Wine winevalue;

  @override
  void initState() {
    super.initState();
    winevalue = widget.wine;
  }

  void _handleEditBottleRoute(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBottlePage(
          socket: widget.socket,
          wine: winevalue,
          caveId: widget.caveId,
          onBottleAdded: () {
            widget.socket.sendCavePage(widget.caveId);
            widget.socket.receiveCavePage((data) {
              setState(() {
                winevalue = convertPage(data)
                    .wines
                    .firstWhere((element) => element.id == id);
              });
            });
          },
        ),
      ),
    ).then((value) => widget.onBottlePage());
  }

  void _handleDeleteBottle(int id) {
    widget.socket.sendDeleteBottle(id.toString());
    widget.socket.receiveDeleteBottle(() {
      widget.onBottlePage();
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            style: const TextStyle(color: Color(0xff222222)),
            "Bottle: ${winevalue.name}"),
        backgroundColor: const Color(0xfffaeab1),
        iconTheme: const IconThemeData(color: Color(0xff222222)),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'edit') {
                _handleEditBottleRoute(winevalue.id);
              } else if (value == 'delete') {
                _handleDeleteBottle(winevalue.id);
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // build a card with the wine information the card takes the whole screen but with a padding of 16
            Expanded(
              child: Card(
                color: const Color(0xffB8CE9E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: const EdgeInsets.all(16.0),
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        // the wine name
                        winevalue.image != 'no-image'
                            ? Image(
                                image: Image.memory(
                                  base64Decode(winevalue.image),
                                ).image,
                                width: 200,
                                height: 300,
                                fit: BoxFit.contain,
                              )
                            : Image(
                                image: AssetImage(
                                    'assets/images/${winevalue.color}-bottle.png'),
                                width: 200,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                        Text(
                          winevalue.name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(
                          height: 20,
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${winevalue.color} - ${winevalue.year}',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        // then make two columns one with the region and the country and the other with the price and the quantity
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  winevalue.country,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  winevalue.region,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  winevalue.grapes,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const VerticalDivider(
                              width: 20,
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: <Widget>[
                                Text(
                                  '${cutText(winevalue.price.toString())}€',
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  '${winevalue.quantity} bottles',
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  '${cutText(winevalue.rating.toString())}/5',
                                  style: TextStyle(
                                    // make the color of the rating depend on the value of the rating
                                    color: winevalue.rating >= 2
                                        ? winevalue.rating >= 3.5
                                            ? Colors.green
                                            : Colors.orange
                                        : Colors.red,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          height: 20,
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                        ),
                        Text(
                          winevalue.description,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String cutText(String text) {
    // keep 2 digits after the comma
    return text.substring(0, min(text.indexOf('.') + 3, text.length));
  }
}
