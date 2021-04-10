import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:south_fitness/pages/home/sessions.dart';

import '../common.dart';

class TBT extends StatefulWidget {
  @override
  _TBTState createState() => _TBTState();
}

class _TBTState extends State<TBT> {

  var username = "";
  var email = "";
  SharedPreferences prefs;

  bool all = true;
  bool joined = false;
  var image = "https://res.cloudinary.com/dolwj4vkq/image/upload/v1565367393/jade/profiles/user.jpg";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var saturday =  {
    "image": "https://res.cloudinary.com/dolwj4vkq/image/upload/v1617201729/South_Fitness/suggested_activities/Rectangle_28.png",
    "title": "Satur Day",
    "time": "45 mins",
    "videoUrl": "https://res.cloudinary.com/dolwj4vkq/video/upload/v1612826611/South_Fitness/cross.mp4"
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setPrefs();
  }

  setPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username");
      email = prefs.getString("email");
      image = prefs.getString("image") != null ? prefs.getString("image") : image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: _height(9)),
                child: Column(
                  children: [
                    SizedBox(height: _height(3),),
                    Container(
                      margin: EdgeInsets.only(left: _width(4), right: _width(4)),
                      child: Row(
                          children: [
                            InkWell(
                              onTap: (){
                                setState(() {
                                  joined = false;
                                  all = true;
                                });
                              },
                              child: Text(
                                "Challenges",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: all ? Colors.green : Colors.black
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text("|",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(width: 10,),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  joined = true;
                                  all = false;
                                });
                              },
                              child: Text("Joined",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: joined ? Colors.green : Colors.black
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),

                          ]
                      ),
                    ),
                    SizedBox( height: _height(2)),
                    Container(
                      height: _height(80),
                      padding: EdgeInsets.only(left: _width(4), right: _width(4)),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                      ),
                      child: SingleChildScrollView(
                        child: all ? Column(
                          children: [
                            SizedBox(height: _height(3),),
                            InkWell(
                              onTap: (){
                                Common().newActivity(context, Session(
                                    "TBT",
                                    "https://res.cloudinary.com/dolwj4vkq/video/upload/v1617255977/South_Fitness/VID-20210122-WA0012.mp4",
                                    "27354",
                                    ""
                                  )
                                );
                              },
                              child: Container(
                                  height: _height(30),
                                  width: _height(100),
                                  margin: EdgeInsets.only(bottom: _height(3)),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: SpinKitThreeBounce(
                                          color: Colors.lightGreen,
                                          size: 20,
                                        ),
                                      ),
                                      Container(
                                        height: _height(30),
                                        width: _height(100),
                                        child: ClipRRect(
                                          child: Image.network(
                                            "https://res.cloudinary.com/dolwj4vkq/image/upload/v1617256436/South_Fitness/video_images/IMG-20210131-WA0000.jpg",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                            margin: EdgeInsets.only(top: _height(10.5)),
                                            color: Colors.white,
                                            height: _height(6),
                                            width: _height(100),
                                            child: Column(
                                                children: [
                                                  Spacer(),
                                                  Container(
                                                    margin: EdgeInsets.only(left: _width(2)),
                                                    width: _height(100),
                                                    child: Text("TBT",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    margin: EdgeInsets.only(left: _width(2)),
                                                    width: _height(100),
                                                    child: Text("30 Days Challenge", style: TextStyle(
                                                        fontSize: 11
                                                    ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                ]
                                            )
                                        ),
                                      )
                                    ],
                                  )
                              ),
                            ),
                          ],
                        ) : Column(
                          children: [
                            SizedBox(height: _height(3),),
                            Center(
                              child: Container(
                                child: Text("You haven't joined a challenge yet"),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: _height(7),
              color: Colors.white,
              child: Row(
                children: [
                  Common().logoOnBar(context),
                  Spacer(),
                  InkWell(
                    onTap: (){
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Icon(Icons.menu, size: 30, color: Colors.lightGreen,),
                  ),
                  SizedBox(width: _width(4),),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Common().navDrawer(context, username, email, "tbt", image),
    );
  }

  _height(size){
    return Common().componentHeight(context, size);
  }

  _width(size){
    return Common().componentWidth(context, size);
  }
}