

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
  final List<Wine> wines;
  final Data data;

  CaveObject(this.name, this.id, this.wines, this.data);
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
  final List<String> grapes;

  Wine(this.name, this.id, this.color, this.region, this.country, this.year,
      this.rating, this.price, this.grapes);
}

class Data {
  final double temperature;
  final double humidity;
  final double light;
  final String date;

  Data(this.temperature, this.humidity, this.light, this.date);
}
