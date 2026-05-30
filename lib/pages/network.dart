import 'dart:io';
import 'package:flutter/material.dart';
import 'package:websocket_universal/websocket_universal.dart';

class Network extends StatefulWidget { // Changed to StatefulWidget
  const Network({super.key});

  @override
  State<Network> createState() => _Network();
}

class _Network extends State<Network> {
  String brightness = 'Null';
  String humidity = 'Null';
  String tempereture = 'Null';


  //Connect to the web socket and get json file

  //Parse json file to get the data.


  //Sending data
    double updateTemperetureData(){

    }

    double updateHumidityData(){

    }

    double updateBrightnessData(){

    }
}