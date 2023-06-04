class CaveNumberWines {
  int red;
  int white;
  int rose;

  CaveNumberWines()
      : red = 0,
        white = 0,
        rose = 0;
}

class CaveObject {
  final String name;
  final int id;
  final String location;
  final List<Wine> wines;
  final Data data;

  CaveObject(this.name, this.id, this.wines, this.data, this.location);
  //empty constructor
  CaveObject.empty()
      : name = '',
        id = 0,
        wines = [],
        data = Data(0, 0, 0, ''),
        location = '';
}

class CaveObjectManagement {
  final String name;
  final int id;
  final String lastUpdate;
  final CaveNumberWines numberWines;

  CaveObjectManagement(this.name, this.id, this.lastUpdate, this.numberWines);
}

class CaveObjectStats {
  final String name;
  final int id;
  final List<Data> data;
  final double temperatureWarning;
  final double humidityWarning;
  final double lightWarning;
  final double temperatureCritical;
  final double humidityCritical;
  final double lightCritical;

  CaveObjectStats(
      this.name,
      this.id,
      this.data,
      this.temperatureWarning,
      this.temperatureCritical,
      this.humidityWarning,
      this.humidityCritical,
      this.lightWarning,
      this.lightCritical);
}

class Wine {
  final String name;
  final int id;
  final String color;
  final String region;
  final String country;
  final int year;
  final double rating;
  final double price;
  final String grapes;
  final int quantity;
  final String description;
  final String image;

  Wine(
    this.name,
    this.id,
    this.color,
    this.region,
    this.country,
    this.year,
    this.rating,
    this.price,
    this.grapes,
    this.quantity,
    this.description,
    this.image,
  );
}

class Data {
  final double temperature;
  final double humidity;
  final double light;
  final String date;

  Data(this.temperature, this.humidity, this.light, this.date);
}

List<CaveObject> convertHome(List<dynamic> data) {
  List<String> caveNames = [];
  List<CaveObject> caveObjects = [];
  List<Data> caveData = [];
  List<List<Wine>> caveWines = [];
  caveWines.add([]);
  for (var i = 0; i < data[0].length; i++) {
    caveNames.add(data[0][i][1]);
    print(data[2][i]);

    caveData
        .add(Data(data[1][i][1], data[1][i][2], data[1][i][3], data[1][i][4]));
    for (var j = 0; j < data[2][i].length; j++) {
      caveWines[i].add(Wine(
          data[2][i][j][0],
          data[2][i][j][1],
          data[2][i][j][2],
          data[2][i][j][3],
          data[2][i][j][4],
          data[2][i][j][5],
          data[2][i][j][6],
          data[2][i][j][7],
          data[2][i][j][8],
          data[2][i][j][9].round(),
          data[2][i][j][10],
          data[3][i][j] ?? 'no-image'));
      //initializing the list of wines
      caveWines.add([]);
    }
    caveObjects.add(CaveObject(
        caveNames[i], data[0][i][0], caveWines[i], caveData[i], data[0][i][2]));
  }

  return caveObjects;
}

List<CaveObjectManagement> convertCavesManagement(List<dynamic> data) {
  List<String> caveNames = [];
  List<CaveObjectManagement> caveObjects = [];
  List<CaveNumberWines> caveNumberWines = [];
  for (var i = 0; i < data[0].length; i++) {
    caveNames.add(data[0][i][1]);
    caveNumberWines.add(CaveNumberWines());
    for (var j = 0; j < data[2][i].length; j++) {
      if (data[2][i][j][0] == 'red') {
        caveNumberWines[i].red = data[2][i][j][1];
      } else if (data[2][i][j][0] == 'white') {
        caveNumberWines[i].white = data[2][i][j][1];
      } else if (data[2][i][j][0] == 'rose') {
        caveNumberWines[i].rose = data[2][i][j][1];
      }
    }
    caveObjects.add(CaveObjectManagement(
        caveNames[i], data[0][i][0], data[1][i][0], caveNumberWines[i]));
  }

  return caveObjects;
}

CaveObject convertPage(List<dynamic> data) {
  String caveNames;
  Data caveData;
  List<Wine> caveWines = [];

  caveNames = data[0][0];
  caveData = Data(data[1][1], data[1][2], data[1][3], data[1][4]);
  for (var j = 0; j < data[2].length; j++) {
    if (data[4][j] == null) {
      print(data[4][j]);
    }
    caveWines.add(Wine(
        data[2][j][0],
        data[2][j][1],
        data[2][j][2],
        data[2][j][3],
        data[2][j][4],
        data[2][j][5],
        data[2][j][6],
        data[2][j][7],
        data[2][j][8],
        data[2][j][9].round(),
        data[2][j][10],
        data[4][j] ?? 'no-image'));
  }

  return CaveObject(
      caveNames, int.parse(data[3]), caveWines, caveData, data[0][1]);
}

List<Data> convertData(List<dynamic> data) {
  List<Data> caveData = [];
  caveData.add(Data(12.0, 12.0, 12.0, '12:12:12'));
  return caveData;
}

List<CaveObjectStats> convertPageData(List<dynamic> data) {
  List<String> caveNames = [];
  List<CaveObjectStats> caveObjects = [];
  List<List<Data>> caveData = [];
  print(data[0][3]);
  for (var i = 0; i < data.length; i++) {
    caveData.add([]);
    for (var j = 0; j < data[i][2].length; j++) {
      caveData[i].add(Data(data[i][2][j][0], data[i][2][j][1], data[i][2][j][2],
          data[i][2][j][3]));
    }
    caveObjects.add(CaveObjectStats(
        data[i][1],
        data[i][0],
        caveData[i],
        data[i][3][0],
        data[i][3][1],
        data[i][3][2],
        data[i][3][3],
        data[i][3][4],
        data[i][3][5]));
  }

  return caveObjects;
}
