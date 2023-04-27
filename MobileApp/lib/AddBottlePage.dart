//a form to add a bottle
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CaveManagementPage.dart';

class AddBottlePage extends StatefulWidget {
  const AddBottlePage({Key? key}) : super(key: key);
  static const String routeName = '/addBottle';
  
  @override
  _AddBottlePageState createState() => _AddBottlePageState();
}

class _AddBottlePageState extends State<AddBottlePage> {
  final _formKey = GlobalKey<FormState>();
  final _bottleNumberController = TextEditingController();
  final _bottleNameController = TextEditingController();
  final _bottleTypeController = TextEditingController();
  final _bottleYearController = TextEditingController();
  final _bottlePriceController = TextEditingController();
  final _bottleQuantityController = TextEditingController();
  final _bottleCommentController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _bottleNumberController.dispose();
    _bottleNameController.dispose();
    _bottleTypeController.dispose();
    _bottleYearController.dispose();
    _bottlePriceController.dispose();
    _bottleQuantityController.dispose();
    _bottleCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as CaveArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.name),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // display the list of statistics
            Expanded(
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _bottleNumberController,
                    decoration: const InputDecoration(
                      hintText: 'Bottle number',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a bottle number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bottleNameController,
                    decoration: const InputDecoration(
                      hintText: 'Bottle name',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a bottle name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bottleTypeController,
                    decoration: const InputDecoration(
                      hintText: 'Bottle type',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a bottle type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bottleYearController,
                    decoration: const InputDecoration(
                      hintText: 'Bottle year',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a bottle year';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bottlePriceController,
                    decoration: const InputDecoration(
                      hintText: 'Bottle price',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a bottle price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bottleQuantityController,
                    decoration: const InputDecoration(
                      hintText: 'Bottle quantity',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a bottle quantity';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bottleCommentController,
                    decoration: const InputDecoration(
                      hintText: 'Bottle comment',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a bottle comment';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}