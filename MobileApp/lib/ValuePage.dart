import 'package:wine_esp/CaveObject.dart';
import 'package:wine_esp/Sockets.dart';

import 'package:flutter/material.dart';

class ValuePage extends StatefulWidget {
  final Sockets socket;
  final Function() onValueChanged;
  final CaveObjectStats cave;
  final String type;

  const ValuePage({
    required this.socket,
    required this.onValueChanged,
    required this.cave,
    required this.type,
  });

  @override
  _ValuePageState createState() => _ValuePageState();
}

class _ValuePageState extends State<ValuePage> {
  late TextEditingController _warningController;
  late TextEditingController _criticalController;

  double _warningValue = 0;
  double _criticalValue = 0;

  @override
  void initState() {
    super.initState();
    if (widget.type == "temperature") {
      _warningValue = widget.cave.temperatureWarning;
      _criticalValue = widget.cave.temperatureCritical;
    } else if (widget.type == "humidity") {
      _warningValue = widget.cave.humidityWarning;
      _criticalValue = widget.cave.humidityCritical;
    } else if (widget.type == "luminosity") {
      _warningValue = widget.cave.lightWarning;
      _criticalValue = widget.cave.lightCritical;
    }
    _warningController =
        TextEditingController(text: _warningValue.round().toString());
    _criticalController =
        TextEditingController(text: _criticalValue.round().toString());
  }

  @override
  void dispose() {
    _warningController.dispose();
    _criticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Modify value", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xfffaeab1),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color(0xfffaeab1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.cave.name,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff222222)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Set Warning/Critical Values',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xff222222)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Expanded(
                      child: Text(
                        'Warning',
                        style:
                            TextStyle(fontSize: 24, color: Colors.orangeAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        thumbColor: const Color(0xff108963),
                        activeColor: const Color(0xffB8CE9E),
                        value: _warningValue,
                        min: 0,
                        max: widget.type == "temperature" ? 32 : 100,
                        divisions: 100,
                        label: _warningValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _warningValue = value;
                            _warningController.text = value.round().toString();
                            if (value > _criticalValue) {
                              _criticalValue = _warningValue;
                              _criticalController.text =
                                  _warningValue.round().toString();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _warningController.text,
                        style: const TextStyle(
                            fontSize: 24, color: Color(0xff222222)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Critical',
                        style: TextStyle(fontSize: 24, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _criticalValue,
                        thumbColor: const Color(0xff108963),
                        activeColor: const Color(0xffB8CE9E),
                        min: 0,
                        max: widget.type == "temperature" ? 32 : 100,
                        divisions: 100,
                        label: _criticalValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _criticalValue = value;
                            _criticalController.text = value.round().toString();
                            if (value < _warningValue) {
                              _warningValue = value;
                              _warningController.text =
                                  value.round().toString();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _criticalController.text,
                        style: const TextStyle(
                            fontSize: 24, color: Color(0xff222222)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          double warningValue =
                              double.tryParse(_warningController.text) ?? 0.0;
                          double criticalValue =
                              double.tryParse(_criticalController.text) ?? 0.0;
                          widget.socket.updateCaveValue(
                              widget.cave.id.toString(),
                              warningValue,
                              criticalValue,
                              widget.type);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save',
                          style:
                              TextStyle(fontSize: 24, color: Color(0xff222222)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style:
                              TextStyle(fontSize: 24, color: Color(0xff222222)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
