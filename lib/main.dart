import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;

//xdd
void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GeolocationApp(),
    );
  }
}

class GeolocationApp extends StatefulWidget {
  const GeolocationApp({super.key});

  @override
  State<GeolocationApp> createState() => _GeolocationAppState();
}

class _GeolocationAppState extends State<GeolocationApp> {
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;

  String _currentAdress = "";
  String _currentStreet = "";
  String _currpos = "";

  Future<Position> _getCurrentLocation() async{
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission){
      print("all good");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  _getAdressFromCoordinates() async{
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude, _currentLocation!.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAdress = "${[place.locality]} \n ${place.country}";
      });
    } catch(e){
      print(e);
      print("xdd");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Получение данных геолокации"),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 180
              ),
              Text("Координаты:",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                  height: 6
              ),
              Text("Широта = ${_currentLocation?.latitude} ; Долгота = ${_currentLocation?.longitude}"),
              SizedBox(height: 30),
              Text("Местонахождение",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                  height: 6
              ),
              Text("${_currentAdress} \n ${_currentStreet}"),

              SizedBox(
                  height: 50
              ),
              ElevatedButton(onPressed: () async {
                setState(() async {
                  _currentLocation =  await _getCurrentLocation();
                  _currentStreet =  await get_street();
                  await _getAdressFromCoordinates();
                  print("${_currentLocation}, \n currLoc");
                  print("${_currentAdress}, \n currAdr");
                });
              }, child: Text("Get Location")),


              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                          onPressed: (){
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SecondRoute()),
                          );}
                               , child: const Text('go to Gyro page'))))
              // ElevatedButton(onPressed: () async {
              //   setState(() async {
              //     _currentLocation =  await _getCurrentLocation();
              //     _currentStreet =  await get_street();
              //     await _getAdressFromCoordinates();
              //     print("${_currentLocation}, \n currLoc");
              //     print("${_currentAdress}, \n currAdr");
              //   });
              // }, child: Text("Second page"))
        ],
      )),
    );


  }
  Future<String> get_street() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token a29000408ff35f96119caf675e6714e746d6391d',
    };

    final data = '{ "lat": ${_currentLocation?.latitude}, "lon": ${_currentLocation?.longitude} }';

    final url = Uri.parse('https://suggestions.dadata.ru/suggestions/api/4_1/rs/geolocate/address');

    final res = await http.post(url, headers: headers, body: data);
    final status = res.statusCode;
    if (status != 200) throw Exception('http.post error: statusCode= $status');
    return json.decode(res.body)["suggestions"][0]["value"];
    // print(res.body);
  }
}

class SecondRoute extends StatefulWidget  {
  const SecondRoute({super.key});

  State<SecondRoute> createState() => _SecondRoute();
}

class _SecondRoute extends State<SecondRoute> {
  double x = 0, y = 0, z = 0;
  double abs_x = 0, abs_y = 0, abs_z = 0;
  String direction = "";
  String orient = "Ориентация: ";
  late Orientation orientation;


  @override
  void initState() {
    gyroscopeEvents.listen((GyroscopeEvent event) {
      print(event);

      orientation = MediaQuery.of(context).orientation;

      x = event.x;
      y = event.y;
      z = event.z;

      abs_x = x.abs();
      abs_y = y.abs();
      abs_z = z.abs();

      if (abs_x > abs_y) {
        if (abs_x > abs_z) {
          if (x > 0){
            direction = "Телефон накланён назад";
          } else direction = "Телефон накланён вперёд";
        }
      }

      if (abs_x > abs_z) {
        if (abs_x > abs_y) {
          if (x > 0){
            direction = "Телефон накланён назад";
          } else direction = "Телефон накланён вперёд";
        }
      }

      if (abs_z > abs_x) {
        if (abs_z > abs_y) {
          if (z > 0){
            direction = "Телефон накланён налево";
          } else direction = "Телефон накланён направо";
        }
      }

      if (abs_z > abs_y) {
        if (abs_z > abs_x) {
          if (z > 0){
            direction = "Телефон накланён налево";
          } else direction = "Телефон накланён направо";
        }
      }

      if (abs_y > abs_x) {
        if (abs_y > abs_z) {
          if (y > 0){
            direction = "Телефон накланён налево";
          } else direction = "Телефон накланён направо";
        }
      }

      if (abs_y > abs_z) {
        if (abs_y > abs_x) {
          if (y > 0){
            direction = "Телефон накланён налево";
          } else direction = "Телефон накланён направо";
        }
      }
      print("${(MediaQuery.of(context).orientation)}");

      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        orient = "Ориентация: вертикальная";
      } else {
        orient = "Ориентация: горизонатльная";
      }


      if (x!= 0.0){
        if (y!= 0.0){
          if (z!= 0.0){
            setState(() {
            });
          }
        }
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gyro page'),
        centerTitle: true,
      ),
      body: Center(
          child:
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${direction} \n ${orient} \n",
                  style: TextStyle(fontSize: 30)),
                Text("\n\nx = ${x}  \n y = ${y} \n z = ${z}",
                  style: TextStyle(fontSize: 30)),


                Expanded(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            }
                            , child: const Text('go to Position page!')))),
              ])),
    );
  }
}