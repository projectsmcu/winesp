import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:wine_esp/CaveObject.dart';
import 'package:wine_esp/ValuePage.dart';

import 'Sockets.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key, required this.socket, required this.userId})
      : super(key: key);

  final Sockets socket;
  final String userId;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Color> gradientColors = const [Colors.lightGreen, Color(0xff108963)];

  List<CaveObjectStats> _stats = [];
  double warningTemp = 0.0;
  double criticalTemp = 0.0;
  String valueFilter = "";

  ScrollController _homeController = ScrollController();

  Widget _dataLightList = const Center(
      child: Text(
    'Loading...',
    style: TextStyle(fontSize: 24),
  ));
  Widget _dataTempList = const Center(
      child: Text(
    'Loading...',
    style: TextStyle(fontSize: 24),
  ));
  Widget _dataHumiList = const Center(
      child: Text(
    'Loading...',
    style: TextStyle(fontSize: 24),
  ));

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _handleCaveRoute(cave, type) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ValuePage(
                socket: widget.socket,
                cave: cave,
                type: type,
                onValueChanged: () {
                  widget.socket.sendDataStats(widget.userId);
                  widget.socket.receiveDataStats((data) {
                    _stats = convertPageData(data);
                    if (data.isEmpty) {
                      setState(() {
                        _dataLightList = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'No data found using light',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ],
                        );
                        _dataTempList = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'No data found with temperature',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ],
                        );
                        _dataHumiList = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'No data found with humidity',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ],
                        );
                      });
                      return;
                    }
                    setState(() {
                      var filteredCaves = _stats
                          .where((cave) => cave.name
                              .toLowerCase()
                              .contains(valueFilter.toLowerCase()))
                          .toList();

                      _dataLightList = _buildLight(filteredCaves);
                      _dataTempList = _buildTemp(filteredCaves);
                      _dataHumiList = _buildHumi(filteredCaves);
                    });
                  });
                })));
  }

  @override
  void initState() {
    super.initState();
    _homeController = ScrollController();
    widget.socket.sendDataStats(widget.userId);
    widget.socket.receiveDataStats((data) {
      _stats = convertPageData(data);
      if (data.isEmpty) {
        setState(() {
          _dataLightList = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'No data found using light',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ],
          );
          _dataTempList = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'No data found with temperature',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ],
          );
          _dataHumiList = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'No data found with humidity',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ],
          );
        });
        return;
      }
      setState(() {
        _dataLightList = _buildLight(_stats);
        _dataTempList = _buildTemp(_stats);
        _dataHumiList = _buildHumi(_stats);
      });
    });
  }

  Widget _buildLight(List<CaveObjectStats> stats) {
    // build a vertical list of cards that display the light data for each cave
    return ListView.builder(
      controller: _homeController,
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return buildLightItem(context, index, stats);
      },
    );
  }

  Widget buildLightItem(context, index, stats) {
    List<double> light = [];
    List<String> time = [];

    if (stats[index].data.isEmpty) {
      return Card(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No data found in cave ${stats[index].name}',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ));
    }

    for (var i = 0; i < stats[index].data.length; i++) {
      light.add(stats[index].data[i].light);
      // time format is yyyy-mm-dd hh:mm:ss
      // first convert it to seconds since epoch
      time.add(stats[index].data[stats[index].data.length - i - 1].date);
    }
    // build a card that displays the light data for a single cave
    return GestureDetector(
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stats[index].name,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.70,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18,
                      left: 12,
                      top: 10,
                      bottom: 8,
                    ),
                    child: LineChart(
                      // pass in the data for the line chart only light data contains in stats[index].data[].light
                      mainData(
                        index,
                        light,
                        time,
                        stats[index].lightWarning,
                        stats[index].lightCritical,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
      onTap: () {
        _handleCaveRoute(stats[index], "luminosity");
      },
    );
  }

  Widget _buildTemp(List<CaveObjectStats> stats) {
    // build a vertical list of cards that display the light data for each cave
    return ListView.builder(
      controller: _homeController,
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return _buildTempItem(context, index, stats);
      },
    );
  }

  Widget _buildTempItem(context, index, stats) {
    List<double> temp = [];
    List<String> time = [];

    if (stats[index].data.isEmpty) {
      return Card(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No data found in cave ${stats[index].name}',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ));
    }

    for (var i = 0; i < stats[index].data.length; i++) {
      temp.add(stats[index].data[i].temperature);
      // time format is yyyy-mm-dd hh:mm:ss
      // first convert it to seconds since epoch
      time.add(stats[index].data[stats[index].data.length - i - 1].date);
    }
    // build a card that displays the light data for a single cave
    return GestureDetector(
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stats[index].name,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.70,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18,
                      left: 12,
                      top: 24,
                      bottom: 12,
                    ),
                    child: LineChart(
                      // pass in the data for the line chart only light data contains in stats[index].data[].light
                      mainData(
                        index,
                        temp,
                        time,
                        stats[index].temperatureWarning,
                        stats[index].temperatureCritical,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        _handleCaveRoute(stats[index], 'temperature');
      },
    );
  }

  Widget _buildHumi(List<CaveObjectStats> stats) {
    // build a vertical list of cards that display the light data for each cave
    return ListView.builder(
      controller: _homeController,
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return _buildHumiItem(context, index, stats);
      },
    );
  }

  Widget _buildHumiItem(context, index, stats) {
    List<double> humi = [];
    List<String> time = [];

    if (stats[index].data.isEmpty) {
      return Card(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No data found in cave ${stats[index].name}',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ));
    }

    for (var i = 0; i < stats[index].data.length; i++) {
      humi.add(stats[index].data[i].humidity);
      // time format is yyyy-mm-dd hh:mm:ss
      // first convert it to seconds since epoch
      time.add(stats[index].data[stats[index].data.length - i - 1].date);
    }
    // build a card that displays the light data for a single cave
    return GestureDetector(
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stats[index].name,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.70,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18,
                      left: 12,
                      top: 24,
                      bottom: 12,
                    ),
                    child: LineChart(
                      // pass in the data for the line chart only light data contains in stats[index].data[].light
                      mainData(
                        index,
                        humi,
                        time,
                        stats[index].humidityWarning,
                        stats[index].humidityCritical,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        _handleCaveRoute(stats[index], "humidity");
      },
    );
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // the stats page has a tab bar at the top, with 3 tabs
    // temperature, humidity, and light above the tab is a text field that filters the list of caves
    return DefaultTabController(
      length: 3, // number of tabs
      child: Column(
        children: [
          Container(
            color: const Color(0xffB8CE9E),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter a filter term',
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => _filterCaves(value),
            ),
          ),
          Container(
            color: const Color(0xFF60A26D),
            child: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicatorColor: Colors.orangeAccent,
              tabs: [
                Tab(icon: Icon(Icons.thermostat), text: 'Temperature'),
                Tab(icon: Icon(Icons.water), text: 'Humidity'),
                Tab(icon: Icon(Icons.lightbulb), text: 'Light'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _dataTempList,
                _dataHumiList,
                _dataLightList,
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData mainData(index, data, time, warningValue, criticalValue) {
    List<FlSpot> spots = [];
    double minData = min(data) < warningValue ? min(data) : warningValue;
    double maxData = max(data) > criticalValue ? max(data) : criticalValue;
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(double.parse(i.toString()),
          ((data[i] - minData) * 10 / (maxData - minData)) + 1));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.5),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.5),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              // add to the meta data the min and max of the data
              reservedSize: 25,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                );
                Widget text;
                switch (value.toInt()) {
                  case 1:
                    text = Text(time[1], style: style);
                    break;
                  case 7:
                    text = Text(time[7], style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: text,
                );
              }),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                );
                String text;
                switch (value.toInt()) {
                  case 1:
                    text = cutText(minData.toString(), 4);
                    break;
                  case 5:
                    text = cutText(
                        ((4 / 10 * (maxData - minData)) + minData).toString(),
                        4);
                    break;
                  case 9:
                    text = cutText(
                        ((8 / 10 * (maxData - minData)) + minData).toString(),
                        4);
                    break;
                  default:
                    return Container();
                }

                return Text(text, style: style, textAlign: TextAlign.left);
              },
              reservedSize: 40),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 9,
      minY: 0,
      maxY: 12,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 0.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
        LineChartBarData(
          spots: [
            FlSpot(
                0, ((warningValue - minData) * 10 / (maxData - minData)) + 1),
            FlSpot(9, ((warningValue - minData) * 10 / (maxData - minData)) + 1)
          ],
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Colors.orangeAccent, Colors.orangeAccent],
          ),
          barWidth: 1,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
        LineChartBarData(
          spots: [
            FlSpot(
                0, ((criticalValue - minData) * 10 / (maxData - minData)) + 1),
            FlSpot(
                9, ((criticalValue - minData) * 10 / (maxData - minData)) + 1)
          ],
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.redAccent],
          ),
          barWidth: 1,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (value) {
            return value
                .map((e) => LineTooltipItem(
                    cutText(
                        (((e.y.toDouble() - 1) / 10 * (maxData - minData)) +
                                minData)
                            .toString(),
                        4),
                    const TextStyle(
                        color: Color(0xff222222),
                        fontSize: 14,
                        fontWeight: FontWeight.bold)))
                .toList();
          },
          tooltipBgColor: Colors.lightGreen,
        ),
      ),
    );
  }

  double min(List<double> data) {
    double min = data[0];
    for (int i = 1; i < data.length; i++) {
      if (data[i] < min) {
        min = data[i];
      }
    }
    return min;
  }

  double max(List<double> data) {
    double max = data[0];
    for (int i = 1; i < data.length; i++) {
      if (data[i] > max) {
        max = data[i];
      }
    }
    return max;
  }

  String cutText(String text, int length) {
    if (text.length > length) {
      return text.substring(0, length);
    } else {
      return text;
    }
  }

  _filterCaves(String value) {
    setState(() {
      valueFilter = value;
      var filteredCaves = _stats
          .where(
              (cave) => cave.name.toLowerCase().contains(value.toLowerCase()))
          .toList();

      _dataLightList = _buildLight(filteredCaves);
      _dataTempList = _buildTemp(filteredCaves);
      _dataHumiList = _buildHumi(filteredCaves);
    });
  }
}
