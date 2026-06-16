import 'package:websocket_universal/websocket_universal.dart';
import 'dart:convert';

class network {
  //Networking objects
  String targetAddress = 'ws://10.0.0.97:81'; 

  network._internal();

  static final network _instance = network._internal();

  factory network(){
    return _instance;
  }

  final connectionConfig = SocketConnectionOptions(
    pingIntervalMs: 1500,
    timeoutConnectionMs: 6000,
    skipPingMessages: false,
  );

  //Data values
  String brightness = 'Null';
  String humidity = 'Null';
  String temperature = 'Null';
  String moisture = 'Null';
  String anger = 'Null';

    //Connect to the web socket and get json file

  late final IWebSocketHandler<String, String> socketHandler = 
    IWebSocketHandler<String, String>.createClient(
    targetAddress,
    SocketSimpleTextProcessor(),
    connectionOptions: connectionConfig,
  );

  Future<void> connectSocket() async {
    bool activeConnection = await socketHandler.connect();
    if(!activeConnection){
      while(!activeConnection){
        activeConnection = await socketHandler.connect();
      }
      brightness = 'Failed to fetch';
      humidity = 'Failed to fetch';
      temperature = 'Failed to fetch';
      moisture = 'Failed to fetch';
      print("Connection failed");
    }
    else{
      print("Connection Success");
      socketHandler.incomingMessagesStream.listen(
          (message) {
          parseSocket(message);
        },
        onError: (error) => print('Stream error:' + error),
        onDone: () => print('Connection closed'),
      );
    }
  }

  Future<void> disconnectSocket() async {
    await socketHandler.disconnect('disconnecting...');
    print('Disconnected Success');
  }
  

  //Parse json file to get the data.
  void parseSocket(String jsonMessage){
   try {
      final Map<String, dynamic> data = jsonDecode(jsonMessage);

      brightness = data['brightness']?.toString()  ?? brightness;
      humidity = data['humidity']?.toString()    ?? humidity;
      temperature = data['temperature']?.toString() ?? temperature;
      moisture = data['moisture']?.toString() ?? moisture;
      anger = data['anger']?.toString() ?? anger;

      print('brightness=$brightness  humidity=$humidity  temperature=$temperature moisture=$moisture anger=$anger');
    } catch (e) {
      print('JSON parse error: $e');
    }
  }
}