import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:south_fitness/pages/home/Home.dart';
import 'package:south_fitness/services/net.dart';

import '../common.dart';

class DailyRun extends StatefulWidget {
  var state = "";
  var myLat = 0.0;
  var myLong = 0.0;

  DailyRun(value, lat, long){
    state = value;
    myLat = lat;
    myLong = long;
  }

  @override
  _DailyRunState createState() => _DailyRunState(state, myLat, myLong);
}

class _DailyRunState extends State<DailyRun> {
  var startRun = false;
  var stopRun = false;
  var postToServer = false;
  var posting = false;
  var loadingState = true;
  var distance = 0;
  var calories = 0.0;

  var myLat = -1.2878286;
  var myLong = 36.8180403;
  var startLat = 0.0;
  var startLong = 0.0;
  var endLat = 0.0;
  var endLong = 0.0;

  var prevLat = 0.0;
  var prevLon = 0.0;
  var avgPace = 0.0;
  var state = "";
  bool showCalories = false;
  var challengeData = {};

  late StreamSubscription _getPositionSubscription;

  _DailyRunState(value, lat, long){
    state = value;
    myLat = lat;
    myLong = long;

    startLat = lat;
    startLong = long;
  }

  Color mainColor = Colors.white;
  var distanceInKm = 0.0;

  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyAl_2qJ7T8UFxRRz_TZAs0hoW6vflnJ8ug";

  var image = "https://res.cloudinary.com/dolwj4vkq/image/upload/v1618227174/South_Fitness/profile_images/GREEN_AVATAR.jpg";

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?';
  var _steps = 0;
  String team = "";

  late var marker;
  late var movingMarker;
  late var mapTarget;
  bool showMaps = false;

  late Timer _timer;
  int seconds = 0;
  int minutes = 0;
  int hours = 0;

  var secDis = "00";
  var minDis = "00";
  var hourDis = "00";
  late BitmapDescriptor bitmap;

  var duration = 0; // time covered in seconds

  var username = "";
  var email = "";
  var user_id = "";
  var startTime = DateTime.now();
  late SharedPreferences prefs;

  late bool serviceEnabled;
  late LocationPermission permission;
  var img = "https://res.cloudinary.com/dolwj4vkq/image/upload/v1618227174/South_Fitness/profile_images/GREEN_AVATAR.jpg";

  final Map<String, Marker> _markers = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    permissions();
    checkUsage();
    setPrefs();
  }

  permissions() async {
    bool activityRecognition = await Permission.activityRecognition.isGranted;
    if (!activityRecognition) {
      await Permission.activityRecognition.request();
    }
  }

  @override
  void dispose(){
    super.dispose();
    _getPositionSubscription.cancel();
  }

  setPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
      email = prefs.getString("email")!;
      team = prefs.getString("team")!;
      image = prefs.getString("image")!;
      user_id = prefs.getString("user_id")!;
      img = prefs.getString("institute_logo")!;
      var institutePrimaryColor = prefs.getString("institute_primary_color");
      List colors = institutePrimaryColor!.split(",");
      mainColor = Color.fromARGB(255,int.parse(colors[0]),int.parse(colors[1]),int.parse(colors[2]));
      loadingState = false;
    });
  }


  getBitmapImage() async {
    var icon = state == "Running" ? "assets/images/run/run.png" : state == "Walking" ? "assets/images/run/walk.png" : "assets/images/run/cycling.png";
    var descriptor = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)), icon);
    setState(() {
      bitmap = descriptor;
    });
  }

  void checkUsage() async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a network.
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Please enable your location",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (serviceEnabled) {
        // is locations enabled
        setState(() {
          serviceEnabled = true;
        });
        Position currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        setState(() {
          myLat = currentLocation.latitude;
          myLong = currentLocation.longitude;
          print("Lat : $myLat, Lon : $myLong");

          _markers.clear();

          marker = Marker(
            markerId: MarkerId("curr_loc"),
            position: LatLng(myLat, myLong),
            infoWindow: InfoWindow(title: 'You are currently here'),
          );

          movingMarker = Marker(
              markerId: MarkerId("person"),
              position: LatLng(myLat, myLong),
              infoWindow: InfoWindow(title: 'You are here'),
              icon: bitmap
          );

          mapTarget = LatLng(myLat, myLong);
          _markers["Start Location"] = marker;
          _markers["Current Location"] = movingMarker;
        });

        /// origin marker
        // _addMarker(LatLng(myLat, myLong), "start_point", "Start Location",
        //     BitmapDescriptor.defaultMarker);

      } else {
        //Enable location
        Fluttertoast.showToast(
            msg: "Please enable your location",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Timer(Duration(seconds: 3), () => checkUsage());
      }
    } else {
      // No connectivity
      Fluttertoast.showToast(
          msg: "Please check your internet connection",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Timer(Duration(seconds: 3), () => checkUsage());
    }
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 0;
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: loadingState ? Container(
          height: _height(100),
          width: _width(100),
          child: Center(
            child: SpinKitThreeBounce(
              color: Colors.grey,
              size: 30,
            ),
          ),
        ) : Container(
          height: _height(100),
          width: _width(100),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: _height(9), left: _width(4), right: _width(4)),
                  child: Column(
                    children: [
                      Container(
                        width: _width(100),
                        child: Text(
                          "Hello, $username",
                          style: TextStyle(
                              fontSize: 13
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: _height(1),),

                      Container(
                        width: _width(100),
                        child: Text(
                          "Today's $state Challenge",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: _height(1),),

                      Container(
                          width: _width(100),
                          child: Column(
                            children: [
                              Container(
                                width: _width(100),
                                child: Text(
                                  startRun ? "${distanceInKm.toStringAsFixed(2)}" : "00:00",
                                  style: TextStyle(
                                      fontSize: 75,
                                      fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                width: _width(100),
                                child: Text(
                                  "Kilometres",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          )
                      ),
                      SizedBox(height: _height(2),),

                      Container(
                          child: Row(
                              children: [
                                Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: _width(30),
                                          child: Text(
                                            startRun ? "$hourDis:$minDis:$secDis" : "00:00:00",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Container(
                                          width: _width(30),
                                          child: Text(
                                            "Duration",
                                            style: TextStyle(
                                              fontSize: 13,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                                Spacer(),
                                Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: _width(30),
                                          child: Text(
                                            "${paceCounter().toStringAsFixed(2)}",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Container(
                                          width: _width(30),
                                          child: Text(
                                            "Pace(Km/Min)",
                                            style: TextStyle(
                                              fontSize: 13,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                                showCalories ? Spacer() : Container(),
                                showCalories ? Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: _width(20),
                                          child: Text(
                                            stopRun ? "${calories.toStringAsFixed(2)}" : "--",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Container(
                                          width: _width(20),
                                          child: Text(
                                            "Calories(KC)",
                                            style: TextStyle(
                                              fontSize: 13,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    )
                                ) : Container(),
                              ]
                          )
                      ),
                      SizedBox( height: _height(3)),
                      Card(
                        color: Colors.grey[50],
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        shadowColor: Colors.grey[50],
                        child: Container(
                          width: _width(100),
                          height: _height(45),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: Stack(
                                children: [
                                  myLong == 0.0 ? Container() : (startRun ? GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(target: LatLng(myLat, myLong), zoom: 15),
                                    myLocationEnabled: true,
                                    tiltGesturesEnabled: true,
                                    compassEnabled: true,
                                    scrollGesturesEnabled: true,
                                    zoomGesturesEnabled: true,
                                    onMapCreated: _onMapCreated,
                                    markers: Set<Marker>.of(markers.values),
                                    polylines: Set<Polyline>.of(polylines.values),
                                  ) : GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      // Set initial location to Nairobi
                                      target: LatLng(myLat, myLong),
                                      zoom: 12,
                                    ),
                                    markers: _markers.values.toSet(),
                                  )),
                                ]
                            ),
                          ),
                        ),
                      ),
                      SizedBox( height: _height(3)),

                      posting ? Center(
                        child: Container(
                          height: _height(5),
                          width: _width(100),
                          child: Center(
                            child: SpinKitThreeBounce(color: mainColor, size: 30,),
                          ),
                        ),
                      ) : postToServer ? Center(
                        child: InkWell(
                          onTap: (){
                            postFinalData();
                          },
                          child: Card(
                            color: Colors.grey[50],
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            shadowColor: Colors.grey[100],
                            child: Container(
                              height: _height(5),
                              width: _width(100),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: Text(
                                  "Post the challenge",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ) : Center( child: InkWell(
                          onTap: (){
                            setState(() {
                              if(startRun == true){
                                stopRun = true;
                                calories = getCaloriesBurnt();
                                stopTimer();
                                postChallengeData();
                              }else{
                                // readSteps();
                                startRun = true;
                                startTimer();
                                startLocationUpdate();
                                startStepsCounter();
                                startTime = DateTime.now();
                              }
                            });
                          },
                          child: Card(
                            color: Colors.grey[50],
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            shadowColor: Colors.grey[100],
                            child: Container(
                              height: _height(5),
                              width: _width(100),
                              decoration: BoxDecoration(
                                  color: startRun ? Color.fromARGB(255,232,196,40): Color.fromARGB(255,110,180,63),
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Center(
                                child: Text(
                                  startRun ? "FINISH":"START",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ), ),
                      SizedBox( height: _height(3)),
                    ],
                  ),
                )
              ),
              Container(
                height: _height(7),
                color: Colors.white,
                child: Row(
                  children: [
                    Common().logoOnBar(context, img),
                    Spacer(),
                    InkWell(
                      onTap: (){
                        _scaffoldKey.currentState!.openDrawer();
                      },
                      child: Icon(Icons.menu, size: 30, color: mainColor,),
                    ),
                    SizedBox(width: _width(4),),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      drawer: Common().navDrawer(context, username, email, "run", image),
    );
  }

  _height(size){
    return Common().componentHeight(context, size);
  }

  _width(size){
    return Common().componentWidth(context, size);
  }

  void startTimer() {
    
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
              duration = duration + 1;
              if (seconds < 0) {
                timer.cancel();
              } else {
                seconds = seconds + 1;
                secDis = "$seconds";
                if(seconds < 10){
                  secDis = "0$seconds";
                }
                if (seconds > 59) {
                  minutes += 1;
                  seconds = 0;
                  minDis = "$minutes";
                  if(minutes < 10){
                    minDis = "0$minutes";
                  }
                  secDis = "$seconds";
                  if(seconds < 10){
                    secDis = "0$seconds";
                  }
                  if (minutes > 59) {
                    hours += 1;
                    minutes = 0;
                    hourDis = "$hours";
                    if(hours < 10){
                      hourDis = "0$hours";
                    }
                    minDis = "$minutes";
                    if(minutes < 10){
                      minDis = "0$minutes";
                    }
                  }
                }
              }
        },
      ),
    );
  }

  void stopTimer(){
    _timer.cancel();
    _getPositionSubscription.cancel();
  }

  startLocationUpdate() async {
    bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
    SharedPreferences authPrefs = await SharedPreferences.getInstance();
    var startLatitude = authPrefs.getDouble("startLatitude");
    var startLong = authPrefs.getDouble("startLongitude");
    if(isLocationServiceEnabled){
      checkUsage();
      _getPositionSubscription = Geolocator.getPositionStream(distanceFilter: 5, desiredAccuracy: LocationAccuracy.high, intervalDuration: Duration(seconds: 5)).listen(
              (Position position) {
                setState(() {
                  if(prevLat == 0.0 ){
                    // Starting point
                    distanceInKm = double.parse((Geolocator.distanceBetween(startLatitude!, startLong!, position.latitude, position.longitude) / 1000).toStringAsFixed(2));
                  }else{
                    // Subsequent calls
                    distanceInKm = distanceInKm + double.parse((Geolocator.distanceBetween(prevLat, prevLon, position.latitude, position.longitude) / 1000).toStringAsFixed(2));
                  }
                  prevLat = position.latitude;
                  prevLon = position.longitude;

                  endLat = position.latitude;
                  endLong = position.longitude;

                  movingMarker = Marker(
                      markerId: MarkerId("person"),
                      position: LatLng(position.latitude, position.longitude),
                      infoWindow: InfoWindow(title: 'You are here'),
                      icon: bitmap
                  );

                });
                _markers.clear();
                _markers["Current Location"] = movingMarker;
                print("------------------------------------------- $distanceInKm");
          });
    }else{
      Fluttertoast.showToast(
          msg: "Please enable your location",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }


  postChallengeData() async {
    _getPositionSubscription.cancel();
    setState(() {
      postToServer = true;

      var startMonth = startTime.month < 10 ? "0${startTime.month}" : startTime.month;
      var startDay = startTime.day < 10 ? "0${startTime.day}" : startTime.day;
      var startHour = startTime.hour < 10 ? "0${startTime.hour}" : startTime.hour;
      var startMin = startTime.minute < 10 ? "0${startTime.minute}" : startTime.minute;
      var startSec = startTime.second < 10 ? "0${startTime.second}" : startTime.second;

      challengeData = {
        "challengeType": state,
        "team": team,
        "user_id": user_id,
        "steps_count": _steps,
        "distance": distanceInKm.toInt(),
        "caloriesBurnt": getCaloriesBurnt().toInt(),
        "startTime": "${startTime.year}-$startMonth-$startDay $startHour:$startMin:$startSec",
        "startLat": startLat,
        "startLong": startLong,
        "endLat": endLat,
        "endLong": endLong,
      };
    });

    print("challenge value ========= : $challengeData");
  }

  postFinalData() async {
    setState(() {
      posting = true;
    });
    var result = await HomeResources().postChallenge(challengeData);
    setState(() {
      posting = false;
    });
    if(result["success"]){
      Common().newActivity(context, HomeView());
    }else{
      Fluttertoast.showToast(msg: "Challenge Posting failed", textColor: Colors.white, backgroundColor: Colors.red);
    }
   }

  startStepsCounter() async {
    initPlatformState();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  paceCounter(){
    if(distanceInKm == 0.0){
      return 0;
    }
    return distanceInKm / (duration/60);
  }

  getCaloriesBurnt(){
    if(distanceInKm < 0.1){
      Fluttertoast.showToast(msg: "You haven't covered enough distance to calculate calories");
      return 0.0;
    }
    var gender = prefs.getString("gender");
    var height = prefs.getDouble("height"); // in metres
    var weight = prefs.getDouble("weight"); // in Kg
    var weightMultiple = gender == "Female" ? 0.035 : 0.065;
    var standardMultiple = gender == "Female" ? 0.029 : 0.035;
    var velocity = (distanceInKm * 1000)/(duration);
    setState(() {
      showCalories = true;
    });

    return ((weightMultiple * weight!) + ((velocity * velocity) / height!) * (standardMultiple) * (weight)).toDouble();
  }

}
