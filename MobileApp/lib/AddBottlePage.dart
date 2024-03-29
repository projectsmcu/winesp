import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Sockets.dart';

class AddBottlePage extends StatefulWidget {
  const AddBottlePage(
      {Key? key,
      required this.socket,
      required this.caveId,
      required this.cavename,
      required this.onBottleAdded})
      : super(key: key);

  final String caveId;
  final String cavename;
  final Function() onBottleAdded;

  static const String routeName = '/addBottle';

  final Sockets socket;

  @override
  _AddBottlePageState createState() => _AddBottlePageState();
}

class _AddBottlePageState extends State<AddBottlePage> {
  final _formKey = GlobalKey<FormState>();
  final _bottleNameController = TextEditingController();
  final _bottleTypeController = TextEditingController(text: 'red');
  final _bottleCountryController = TextEditingController();
  final _bottleRegionController = TextEditingController();
  final _bottleGrapeController = TextEditingController();
  final _bottleYearController = TextEditingController(text: '2020');
  final _bottlePriceController = TextEditingController(text: "15");
  final _bottleQuantityController = TextEditingController(text: '1');
  final _bottleCommentController = TextEditingController();
  final _bottleRatingController = TextEditingController(text: '3.0');

  File? _imageFile;
  String _imageName = 'No picture selected';

  @override
  void initState() {
    super.initState();
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

    String base64image;
    // check if the image is null if not convert it to base64
    if (_imageFile != null) {
      final bytes = _imageFile!.readAsBytesSync();
      base64image = base64Encode(bytes);
    } else {
      base64image = 'no-image';
    }
    // send the values to the server
    widget.socket.addBottle(
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
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 1024);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
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
            "Add bottle in ${widget.cavename}"),
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
                          .receiveAddBottle(() => widget.onBottleAdded());
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
