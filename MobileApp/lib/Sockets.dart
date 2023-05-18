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

  void sendlistCaves(String userId) {
    socket.emit('getCaves', userId);
  }

  //on receive list of caves from server side
  void receiveCaveList(Function(List<dynamic>) callback) {
    socket.on('cave', ((data) => {
        
          callback(data)
    }));
  }
}
