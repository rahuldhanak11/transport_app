// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:transport_app/google-services-api.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class MapScreen extends StatefulWidget {
//   final LatLng sourceLatLng;
//   final LatLng destinationLatLng;

//   const MapScreen({
//     required this.sourceLatLng,
//     required this.destinationLatLng,
//     Key? key,
//   }) : super(key: key);

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController _mapController;
//   List<LatLng> _routeCoordinates = [];
//   bool _isLoading = true;
//   String distance = '';
//   String duration = '';
//   String fare = '';
//   String carbonFootprint = '';
//   String _selectedMode = 'driving';

//   @override
//   void initState() {
//     super.initState();
//     _fetchRouteAndDistanceMatrix();
//   }

//   Future<void> _fetchRouteAndDistanceMatrix() async {
//     setState(() {
//       _isLoading = true;
//       _routeCoordinates = [];
//       distance = '';
//       duration = '';
//       fare = '';
//       carbonFootprint = '';
//     });

//     await _fetchRoute();
//     await _fetchDistanceMatrix();

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _fetchRoute() async {
//     final directionService = GoogleDirectionService();
//     try {
//       final userSelectionObject = {
//         'src':
//             '${widget.sourceLatLng.latitude},${widget.sourceLatLng.longitude}',
//         'destn':
//             '${widget.destinationLatLng.latitude},${widget.destinationLatLng.longitude}',
//         'mode': _selectedMode,
//       };

//       final coordinates =
//           await directionService.getDirections(userSelectionObject);
//       print('Fetched Coordinates: $coordinates'); // Debugging
//       setState(() {
//         _routeCoordinates = coordinates;
//       });
//     } catch (e) {
//       print('Error fetching route: $e');
//     }
//   }

//   Future<void> _fetchDistanceMatrix() async {
//     final distanceMatrixService = GoogleDistanceMatrixService();
//     try {
//       final requestBody = {
//         'src': [
//           {
//             'lat': widget.sourceLatLng.latitude,
//             'lng': widget.sourceLatLng.longitude
//           }
//         ],
//         'destn': [
//           {
//             'lat': widget.destinationLatLng.latitude,
//             'lng': widget.destinationLatLng.longitude
//           }
//         ],
//         'mode': _selectedMode
//       };

//       final response =
//           await distanceMatrixService.getDistanceMatrix(requestBody);
//       print('Distance Matrix Response: $response'); // Debugging
//       setState(() {
//         if (response['status'] == 'OK' &&
//             response['rows'][0]['elements'][0]['status'] == 'OK') {
//           distance = response['rows'][0]['elements'][0]['distance']['text'];
//           duration = response['rows'][0]['elements'][0]['duration']['text'];
//           if (_selectedMode == 'transit') {
//             fare = response['rows'][0]['elements'][0]['fare']?['text'] ?? 'N/A';
//           }
//           _fetchCarbonFootprint(response['rows'][0]['elements'][0]['distance']['value']);
//         } else {
//           distance = 'N/A';
//           duration = 'N/A';
//           fare = 'N/A';
//           carbonFootprint = 'N/A';
//         }
//       });
//     } catch (e) {
//       print('Error fetching distance matrix: $e');
//       setState(() {
//         distance = 'N/A';
//         duration = 'N/A';
//         fare = 'N/A';
//         carbonFootprint = 'N/A';
//       });
//     }
//   }

//   Future<void> _fetchCarbonFootprint(int distanceInMeters) async {
//     final apiUrl = 'https://green-commute-9o3s.onrender.com/api/carbon-emission/'; // Replace with your carbon footprint API URL
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, dynamic>{
//         'distance': distanceInMeters / 1000, // Convert meters to kilometers
//         'mode': _selectedMode,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         carbonFootprint = data['data'].toString() + ' kg';
//       });
//     } else {
//       setState(() {
//         carbonFootprint = 'N/A';
//       });
//     }
//   }

//   Color _getPolylineColor() {
//     switch (_selectedMode) {
//       case 'walking':
//         return Colors.green;
//       case 'transit':
//         return Colors.red;
//       default:
//         return Colors.blue;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Route Map'),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _selectedMode = 'driving';
//                         });
//                         _fetchRouteAndDistanceMatrix();
//                       },
//                       child: Text('Driving'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _selectedMode == 'driving'
//                             ? Colors.blue
//                             : Colors.grey,
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _selectedMode = 'walking';
//                         });
//                         _fetchRouteAndDistanceMatrix();
//                       },
//                       child: Text('Walking'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _selectedMode == 'walking'
//                             ? Colors.green
//                             : Colors.grey,
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _selectedMode = 'transit';
//                         });
//                         _fetchRouteAndDistanceMatrix();
//                       },
//                       child: Text('Transit'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _selectedMode == 'transit'
//                             ? Colors.red
//                             : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   height: 300,
//                   child: GoogleMap(
//                     onMapCreated: (controller) {
//                       _mapController = controller;
//                       final bounds = LatLngBounds(
//                         southwest: LatLng(
//                           min(widget.sourceLatLng.latitude,
//                               widget.destinationLatLng.latitude),
//                           min(widget.sourceLatLng.longitude,
//                               widget.destinationLatLng.longitude),
//                         ),
//                         northeast: LatLng(
//                           max(widget.sourceLatLng.latitude,
//                               widget.destinationLatLng.latitude),
//                           max(widget.sourceLatLng.longitude,
//                               widget.destinationLatLng.longitude),
//                         ),
//                       );
//                       _mapController.animateCamera(
//                           CameraUpdate.newLatLngBounds(bounds, 50));
//                     },
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(
//                         (widget.sourceLatLng.latitude +
//                                 widget.destinationLatLng.latitude) /
//                             2,
//                         (widget.sourceLatLng.longitude +
//                                 widget.destinationLatLng.longitude) /
//                             2,
//                       ),
//                       zoom: 12,
//                     ),
//                     markers: {
//                       Marker(
//                         markerId: MarkerId('source'),
//                         position: widget.sourceLatLng,
//                         infoWindow: InfoWindow(title: 'Source'),
//                       ),
//                       Marker(
//                         markerId: MarkerId('destination'),
//                         position: widget.destinationLatLng,
//                         infoWindow: InfoWindow(title: 'Destination'),
//                       ),
//                     },
//                     polylines: {
//                       if (_routeCoordinates.isNotEmpty)
//                         Polyline(
//                           polylineId: PolylineId('route'),
//                           color: _getPolylineColor(),
//                           width: 10,
//                           points: _routeCoordinates,
//                         ),
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Card(
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Distance: $distance'),
//                           Text('Duration: $duration'),
//                           if (_selectedMode == 'transit') Text('Fare: $fare'),
//                           Text('Carbon Footprint: $carbonFootprint'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/Screens/RewardNotify.dart';
import 'package:transport_app/google-services-api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  final LatLng sourceLatLng;
  final LatLng destinationLatLng;
  final String username;
  final String email;

  const MapScreen({
    required this.sourceLatLng,
    required this.destinationLatLng,
    required this.username,
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  List<LatLng> _routeCoordinates = [];
  bool _isLoading = true;
  String distance = '';
  String duration = '';
  String fare = '';
  String _selectedMode = 'driving';
  String carbonEmission = ''; // Add a variable for carbon emission

  @override
  void initState() {
    super.initState();
    _fetchRouteAndDistanceMatrix();
  }

  Future<void> _fetchRouteAndDistanceMatrix() async {
    setState(() {
      _isLoading = true;
      _routeCoordinates = [];
      distance = '';
      duration = '';
      fare = '';
      carbonEmission = ''; // Reset carbon emission
    });

    await _fetchRoute();
    await _fetchDistanceMatrix();
    await _fetchCarbonEmission(); // Fetch carbon emission

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchRoute() async {
    final directionService = GoogleDirectionService();
    try {
      final userSelectionObject = {
        'src':
            '${widget.sourceLatLng.latitude},${widget.sourceLatLng.longitude}',
        'destn':
            '${widget.destinationLatLng.latitude},${widget.destinationLatLng.longitude}',
        'mode': _selectedMode,
      };

      final coordinates =
          await directionService.getDirections(userSelectionObject);
      print('Fetched Coordinates: $coordinates'); // Debugging
      setState(() {
        _routeCoordinates = coordinates.expand((list) => list).toList();
      });
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  Future<void> _fetchDistanceMatrix() async {
    final distanceMatrixService = GoogleDistanceMatrixService();
    try {
      final requestBody = {
        'src': [
          {
            'lat': widget.sourceLatLng.latitude,
            'lng': widget.sourceLatLng.longitude
          }
        ],
        'destn': [
          {
            'lat': widget.destinationLatLng.latitude,
            'lng': widget.destinationLatLng.longitude
          }
        ],
        'mode': _selectedMode
      };

      final response =
          await distanceMatrixService.getDistanceMatrix(requestBody);
      print('Distance Matrix Response: $response'); // Debugging
      setState(() {
        if (response['status'] == 'OK' &&
            response['rows'][0]['elements'][0]['status'] == 'OK') {
          distance = response['rows'][0]['elements'][0]['distance']['text'];
          duration = response['rows'][0]['elements'][0]['duration']['text'];
          if (_selectedMode == 'transit') {
            fare = response['rows'][0]['elements'][0]['fare']?['text'] ?? 'N/A';
          }
        } else {
          distance = 'N/A';
          duration = 'N/A';
          fare = 'N/A';
        }
      });
    } catch (e) {
      print('Error fetching distance matrix: $e');
      setState(() {
        distance = 'N/A';
        duration = 'N/A';
        fare = 'N/A';
      });
    }
  }

  Future<void> _fetchCarbonEmission() async {
    final url =
        'https://green-commute-9o3s.onrender.com/api/carbon-emission/'; // Replace with your API URL
    final requestBody = {
      'distance': distance,
      'mode': _selectedMode,
    };

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authToken': '$authToken'
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          carbonEmission = data['data'].toString();
        });
      } else {
        print('Error fetching carbon emission: ${response.statusCode}');
        setState(() {
          carbonEmission = 'N/A';
        });
      }
    } catch (e) {
      print('Error fetching carbon emission: $e');
      setState(() {
        carbonEmission = 'N/A';
      });
    }
  }

  Color _getPolylineColor() {
    switch (_selectedMode) {
      case 'walking':
        return Colors.green;
      case 'transit':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 19, 16, 25),
      appBar: AppBar(
        title: Text(
          'Route Map',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Color.fromARGB(255, 19, 16, 25),
        foregroundColor: Colors.white70,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMode = 'driving';
                        });
                        _fetchRouteAndDistanceMatrix();
                      },
                      child: Text(
                        'Driving',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMode == 'driving'
                            ? Color.fromARGB(255, 250, 30, 78)
                            : Color.fromARGB(255, 19, 16, 25),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMode = 'walking';
                        });
                        _fetchRouteAndDistanceMatrix();
                      },
                      child: Text(
                        'Walking',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMode == 'walking'
                            ? Color.fromARGB(255, 250, 30, 78)
                            : Color.fromARGB(255, 19, 16, 25),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMode = 'transit';
                        });
                        _fetchRouteAndDistanceMatrix();
                      },
                      child: Text(
                        'Transit',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMode == 'transit'
                            ? Color.fromARGB(255, 250, 30, 78)
                            : Color.fromARGB(255, 19, 16, 25),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(19.0),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                        final bounds = LatLngBounds(
                          southwest: LatLng(
                            min(widget.sourceLatLng.latitude,
                                widget.destinationLatLng.latitude),
                            min(widget.sourceLatLng.longitude,
                                widget.destinationLatLng.longitude),
                          ),
                          northeast: LatLng(
                            max(widget.sourceLatLng.latitude,
                                widget.destinationLatLng.latitude),
                            max(widget.sourceLatLng.longitude,
                                widget.destinationLatLng.longitude),
                          ),
                        );
                        _mapController.animateCamera(
                            CameraUpdate.newLatLngBounds(bounds, 50));
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          (widget.sourceLatLng.latitude +
                                  widget.destinationLatLng.latitude) /
                              2,
                          (widget.sourceLatLng.longitude +
                                  widget.destinationLatLng.longitude) /
                              2,
                        ),
                        zoom: 12,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('destination'),
                          position: widget.destinationLatLng,
                          infoWindow: InfoWindow(title: 'Destination'),
                        ),
                      },
                      polylines: {
                        if (_routeCoordinates.isNotEmpty)
                          Polyline(
                            polylineId: PolylineId('route'),
                            color: _getPolylineColor(),
                            width: 5,
                            points: _routeCoordinates,
                          ),
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.map_outlined,
                                  color: Colors.blueAccent),
                              SizedBox(width: 10),
                              Text(
                                'Distance: $distance',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, color: Colors.green),
                              SizedBox(width: 10),
                              Text(
                                'Duration: $duration',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (_selectedMode == 'transit')
                            Row(
                              children: [
                                Icon(Icons.attach_money_outlined,
                                    color: Colors.red),
                                SizedBox(width: 10),
                                Text(
                                  'Fare: $fare',
                                  style: TextStyle(
                                    fontFamily: 'Sans',
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          if (_selectedMode == 'transit') SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.eco_outlined, color: Colors.brown),
                              SizedBox(width: 10),
                              Text(
                                'Carbon Emission: $carbonEmission kg',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Add spacing before the button
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RewardNotify(
                                username: widget.username,
                                email: widget.email)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.fromARGB(255, 250, 30, 78), // Button color
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0), // Control button height
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Less rounded corners
                      ),
                      minimumSize: Size(double.infinity,
                          50), // Make button full width and 50px tall
                    ),
                    child: Text(
                      'Select Journey Mode',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
