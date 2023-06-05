import 'dart:io';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_common/src/util/event_emitter.dart';

// A singleton socket instance

IO.Socket socket = IO.io('http://192.168.43.187:5021', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});

class Sockets {
  static final Sockets _sockets = Sockets._internal();

  factory Sockets() {
    return _sockets;
  }

  Sockets._internal();

  void connectSocket() {
    socket.connect();
  }

  void disconnectSocket() {
    socket.disconnect();
  }

  void sendlistCavesHome(String userId) {
    socket.emit('getCavesHome', userId);
  }

  //on receive list of caves from server side
  void receiveCaveListHome(Function(List<dynamic>) callback) {
    socket.on('caveHome', ((data) => {callback(data)}));
  }

  void sendCavesManagementPage(String userId) {
    socket.emit('getCavesManagementPage', userId);
  }

  //on receive list of caves with stats from server side
  void receiveCavesManagementPage(Function(List<dynamic>) callback) {
    socket.on('cavesManagementPage', ((data) => {callback(data)}));
  }

  void addCave(String userId, String caveName, String caveLocation) {
    //create a dictionary with the cave name and location
    var data = {
      'userID': userId,
      'caveName': caveName,
      'caveLocation': caveLocation
    };
    socket.emit('addCave', data);
  }

  // the output of addCave is either 'caveAdded' or 'caveAlreadyExists'
  void receiveAddCave(Function() callback) {
    socket.on("caveAdded", (data) {
      callback();
    });
  }

  void sendCavePage(String caveId) {
    socket.emit('getCavePage', {'caveID': caveId});
  }

  void receiveCavePage(Function(List<dynamic>) callback) {
    socket.on('cavePage', ((data) => {callback(data)}));
  }

  void modifyCave(String caveid, String caveName, String caveLocation) {
    var data = {
      'caveID': caveid,
      'caveName': caveName,
      'caveLocation': caveLocation
    };
    socket.emit('modifyCave', data);
  }

  void receiveModifyCave(Function() callback) {
    socket.on("caveModified", (data) {
      callback();
    });
  }

  void sendDeleteCave(String caveid) {
    var data = {'caveID': caveid};
    socket.emit('deleteCave', data);
  }

  void receiveDeleteCave(Function() callback) {
    socket.on("caveDeleted", (data) {
      callback();
    });
  }

  void addBottle(
      String caveid,
      String bottleName,
      String bottleColor,
      String bottleCountry,
      String bottleRegion,
      String bottleGrappes,
      String bottleYear,
      String bottlePrice,
      String bottleQuantity,
      String bottleComment,
      String bottleRating,
      String bottleImage) {
    var data = {
      'caveID': caveid,
      'bottleName': bottleName,
      'bottleColor': bottleColor,
      'bottleCountry': bottleCountry,
      'bottleRegion': bottleRegion,
      'bottleGrappes': bottleGrappes,
      'bottleYear': bottleYear,
      'bottleQuantity': bottleQuantity,
      'bottlePrice': bottlePrice,
      'bottleComment': bottleComment,
      'bottleRating': bottleRating,
      'bottleImage': bottleImage
    };
    socket.emit('addBottle', data);
  }

  void receiveAddBottle(Function() callback) {
    socket.on("bottleAdded", (data) {
      callback();
    });
  }

  void sendDeleteBottle(String bottleid) {
    var data = {'bottleID': bottleid};
    socket.emit('deleteBottle', data);
  }

  void receiveDeleteBottle(Function() callback) {
    socket.on("bottleDeleted", (data) {
      callback();
    });
  }

  void modifyBottle(
      String bottleid,
      String caveid,
      String bottleName,
      String bottleColor,
      String bottleCountry,
      String bottleRegion,
      String bottleGrappes,
      String bottleYear,
      String bottleQuantity,
      String bottlePrice,
      String bottleComment,
      String bottleRating,
      String bottleImage) {
    var data = {
      'bottleID': bottleid,
      'caveID': caveid,
      'bottleName': bottleName,
      'bottleColor': bottleColor,
      'bottleCountry': bottleCountry,
      'bottleRegion': bottleRegion,
      'bottleGrappes': bottleGrappes,
      'bottleYear': bottleYear,
      'bottleQuantity': bottleQuantity,
      'bottlePrice': bottlePrice,
      'bottleComment': bottleComment,
      'bottleRating': bottleRating,
      'bottleImage': bottleImage
    };
    socket.emit('modifyBottle', data);
  }

  void receiveModifyBottle(Function() callback) {
    socket.on("bottleModified", (data) {
      callback();
    });
  }

  void signUp(String username, String password) {
    var data = {'username': username, 'password': password};
    socket.emit('signUp', data);
  }

  void receiveSignUp(Function(List<dynamic>) callback) {
    socket.on("signedUp", (data) {
      callback(data);
    });
  }

  void logIn(String username, String password) {
    var data = {'username': username, 'password': password};
    socket.emit('logIn', data);
  }

  void receiveLogIn(Function(List<dynamic>) callback) {
    socket.on("loggedIn", (data) {
      callback(data);
    });
  }

  void modifyUser(String userID, String username, String password) {
    var data = {'userID': userID, 'username': username, 'password': password};
    socket.emit('modifyUser', data);
  }

  void sendProfilePage(String userID) {
    socket.emit('getProfilePage', userID);
  }

  void receiveProfilePage(Function(List<dynamic>) callback) {
    socket.on('profilePage', ((data) => {callback(data)}));
  }

  void sendDataStats(String userID) {
    socket.emit('getDataStats', userID);
  }

  void receiveDataStats(Function(List<dynamic>) callback) {
    socket.on('dataStats', ((data) => {callback(data)}));
  }

  void updateCaveValue(String caveID, double warning, double critical, String type) {
    var data = {'caveID': caveID, 'warning': warning, 'critical': critical, 'type': type};
    socket.emit('updateCaveValue', data);
  } 

  void connectCave(String caveID) {
    var data = {'caveID': caveID};
    socket.emit('connectCave', data);
  }

  void receiveConnectCave(Function(List<dynamic>) callback) {
    socket.on('caveConnected', ((data) => {callback(data)}));
  }
}
