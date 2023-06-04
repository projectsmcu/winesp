import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wine_esp/CaveObject.dart';

import 'Sockets.dart';

class EditBottlePage extends StatefulWidget {
  const EditBottlePage(
      {Key? key,
      required this.socket,
      required this.wine,
      required this.caveId,
      required this.onBottleAdded})
      : super(key: key);

  final Wine wine;
  final String caveId;
  final Function() onBottleAdded;

  static const String routeName = '/EditBottle';

  final Sockets socket;

  @override
  _EditBottlePageState createState() => _EditBottlePageState();
}

class _EditBottlePageState extends State<EditBottlePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bottleNameController;
  late TextEditingController _bottleTypeController;
  late TextEditingController _bottleCountryController;
  late TextEditingController _bottleRegionController;
  late TextEditingController _bottleGrapeController;
  late TextEditingController _bottleYearController;
  late TextEditingController _bottlePriceController;
  late TextEditingController _bottleQuantityController;
  late TextEditingController _bottleCommentController;
  late TextEditingController _bottleRatingController;
  String base64image = '';
  String _imageName = 'No picture selected';

  @override
  void initState() {
    super.initState();
    _bottleNameController = TextEditingController(text: widget.wine.name);
    _bottleTypeController = TextEditingController(text: widget.wine.color);
    _bottleCountryController = TextEditingController(text: widget.wine.country);
    _bottleRegionController = TextEditingController(text: widget.wine.region);
    _bottleGrapeController = TextEditingController(text: widget.wine.grapes);
    _bottleYearController =
        TextEditingController(text: widget.wine.year.toString());
    _bottlePriceController =
        TextEditingController(text: widget.wine.price.toString());
    _bottleQuantityController =
        TextEditingController(text: widget.wine.quantity.toString());
    _bottleCommentController =
        TextEditingController(text: widget.wine.description);
    _bottleRatingController =
        TextEditingController(text: widget.wine.rating.toString());
    if (widget.wine.image != 'no-image') {
      base64image = widget.wine.image;
      _imageName = "${widget.wine.name}.jpg";
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _bottleNameController.dispose();
    _bottleTypeController.dispose();
    _bottleYearController.dispose();
    _bottleCountryController.dispose();
    _bottleRegionController.dispose();
    _bottleGrapeController.dispose();
    _bottlePriceController.dispose();
    _bottleQuantityController.dispose();
    _bottleCommentController.dispose();
    _bottleRatingController.dispose();
    super.dispose();
  }

  void _saveBottle() {
    //get all the values from the form
    final String bottleName = _bottleNameController.text;
    final String bottleColor = _bottleTypeController.text;
    final String bottleCountry = _bottleCountryController.text;
    final String bottleRegion = _bottleRegionController.text;
    final String bottleGrape = _bottleGrapeController.text;
    final String bottleYear = _bottleYearController.text;
    final String bottlePrice = _bottlePriceController.text;
    final String bottleQuantity = _bottleQuantityController.text;
    final String bottleComment = _bottleCommentController.text;
    final String bottleRating = _bottleRatingController.text;

    // check if the image is null if not convert it to base64
    if (base64image == '') {
      base64image = 'no-image';
    }
    widget.socket.modifyBottle(
        widget.wine.id.toString(),
        widget.caveId,
        bottleName,
        bottleColor,
        bottleCountry,
        bottleRegion,
        bottleGrape,
        bottleYear,
        bottlePrice,
        bottleQuantity,
        bottleComment,
        bottleRating,
        base64image);
  }

  Future<void> _pickImage() async {
    // pick an image from the gallery with a size limit of 1MB
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 1024);
    if (pickedFile != null) {
      setState(() {
        // convert the image to base64
        base64image = base64Encode(File(pickedFile.path).readAsBytesSync());
        _imageName = pickedFile.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            style: const TextStyle(color: Color(0xff222222)),
            "Modify bottle ${widget.wine.name}"),
        backgroundColor: const Color(0xfffaeab1),
        iconTheme: const IconThemeData(color: Color(0xff222222)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  // make a button to add a picture aligned to the right with a padding of 5px
                  // on the left of it display the file name of the picture
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        const SizedBox(
                          width: 10,
                        ),
                        Text(_imageName),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            _pickImage();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xffB8CE9E),
                          ),
                          child: const Text('Add picture'),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: _bottleNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter the name of the bottle',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _bottleTypeController.text = 'red';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _bottleTypeController.text == 'red'
                                ? const Color(0xff722F37)
                                : Colors.grey,
                          ),
                          child: const Text('Red'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _bottleTypeController.text = 'white';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _bottleTypeController.text == 'white'
                                    ? const Color(0xfff9e8c0)
                                    : Colors.grey,
                          ),
                          child: Text(
                            'White',
                            // #222222 color when clicked white else
                            style: _bottleTypeController.text == 'white'
                                ? const TextStyle(color: Color(0xff222222))
                                : const TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _bottleTypeController.text = 'rose';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _bottleTypeController.text == 'rose'
                                    ? const Color(0xffF4C4BB)
                                    : Colors.grey,
                          ),
                          child: const Text('Rose'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: _bottleCountryController,
                      decoration: const InputDecoration(
                        hintText: 'Enter the country of the bottle',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: _bottleRegionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter the region of the bottle',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: _bottleGrapeController,
                      decoration: const InputDecoration(
                        hintText: 'Enter the grape of the bottle',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        const Text('Year: '),
                        Expanded(
                          child: Slider(
                            thumbColor: const Color(0xFF60A26D),
                            activeColor: const Color(0xffB8CE9E),
                            value: double.parse(_bottleYearController.text),
                            min: 1850,
                            max: 2023,
                            divisions: 173,
                            label: _bottleYearController.text,
                            onChanged: (double value) {
                              setState(() {
                                _bottleYearController.text =
                                    value.round().toString();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: _bottleYearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Year',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a year';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        const Text('Price: '),
                        Expanded(
                          child: Slider(
                            thumbColor: const Color(0xFF60A26D),
                            activeColor: const Color(0xffB8CE9E),
                            value: double.parse(_bottlePriceController.text),
                            min: 0,
                            max: 100,
                            divisions: 200,
                            label: _bottlePriceController.text,
                            onChanged: (double value) {
                              setState(() {
                                _bottlePriceController.text =
                                    value.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: _bottlePriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Price',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        const Text('Quantity: '),
                        Expanded(
                          child: Slider(
                            thumbColor: const Color(0xFF60A26D),
                            activeColor: const Color(0xffB8CE9E),
                            value: double.parse(_bottleQuantityController.text),
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: _bottleQuantityController.text,
                            onChanged: (double value) {
                              setState(() {
                                _bottleQuantityController.text =
                                    value.round().toString();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: _bottleQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Quantity',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[
                        const Text('Rating: '),
                        Expanded(
                          child: Slider(
                            thumbColor: const Color(0xFF60A26D),
                            activeColor: const Color(0xffB8CE9E),
                            value: double.parse(_bottleRatingController.text),
                            min: 0,
                            max: 5,
                            divisions: 50,
                            label: _bottleRatingController.text,
                            onChanged: (double value) {
                              setState(() {
                                _bottleRatingController.text =
                                    value.toStringAsFixed(1);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: _bottleRatingController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Rating',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a rating';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: _bottleCommentController,
                      decoration: const InputDecoration(
                        hintText: 'Enter a comment',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Expanded(
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveBottle();
                      widget.socket
                          .receiveModifyBottle(() => widget.onBottleAdded());
                      Navigator.pop(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff60A26D),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
