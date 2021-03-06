import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:south_fitness/pages/home/Home.dart';
import 'package:south_fitness/services/net.dart';

import '../common.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool teamClicked = false;

  var birthDate = DateTime.now();
  var team = "FINANCE DIVISION";
  var code;
  bool login = false;
  bool loadingState = true;

  late SharedPreferences prefs;
  final format = DateFormat("yyyy-MM-dd");
  var date = new DateTime.now();

  var username = "";
  var firstname = "";
  var lastname = "";
  var email = "";
  var posting = false;
  bool isUploading = false;

  Color mainColor = Colors.white;
  String id = '';
  late File avatarImageFile;
  var avatarImagePath = "";
  var image = "https://res.cloudinary.com/dolwj4vkq/image/upload/v1618227174/South_Fitness/profile_images/GREEN_AVATAR.jpg";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    permissions();
    setPrefs();
  }
  var img = "https://res.cloudinary.com/dolwj4vkq/image/upload/v1618227174/South_Fitness/profile_images/GREEN_AVATAR.jpg";

  setPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      firstname = prefs.getString("first_name")!;
      lastname = prefs.getString("last_name")!;
      username = prefs.getString("username")!;
      email = prefs.getString("email")!;
      image = prefs.getString("image")!;

      img = prefs.getString("institute_logo")!;

      var institutePrimaryColor = prefs.getString("institute_primary_color");
      List colors = institutePrimaryColor!.split(",");
      mainColor = Color.fromARGB(255,int.parse(colors[0]),int.parse(colors[1]),int.parse(colors[2]));
      loadingState = false;
    });
  }

  getImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    var path = image!.path;
    setState(() {
      avatarImagePath = path;
      avatarImageFile = File(path);
      isUploading = true;
    });
    cloudReviewUpload(path,"profile_image");
  }

  cloudReviewUpload(var path, var name) async {
    FormData formData = new FormData.fromMap({
      "upload_preset": "South_Fitness",
      "cloud_name": "dolwj4vkq",
      "file": await MultipartFile.fromFile(path,filename: name),
    });
    var imageUrl = await Authentication().uploadProfileImage(formData);
    setState(() {
      image = imageUrl;
      isUploading = false;
    });
  }

  permissions() async {
    bool camera = await Permission.camera.isGranted;
    bool storage = await Permission.storage.isGranted;
    if (!camera) {
      await Permission.camera.request();
    }
    if (!storage) {
      await Permission.storage.request();
    }
  }

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
                  child: Column(
                    children: [
                      SizedBox(height: _height(9)),

                      Container(
                        height: _height(17),
                        width: _width(80),

                        child: Row(
                          children: [
                            Container(
                                height: _height(15),
                                width: _height(15),
                                margin: EdgeInsets.all(_width(2)),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                      child: Stack(
                                        children: [
                                          avatarImagePath != "" ? Container(
                                            height: _height(15),
                                            width: _height(15),
                                            child: Image.file(
                                              avatarImageFile,
                                              height: _height(15),
                                              width: _height(15),
                                              fit: BoxFit.cover,
                                            ),
                                          ) : Container(
                                            height: _height(15),
                                            width: _height(15),
                                            child: Image.network(
                                              image,
                                              height: _height(15),
                                              width: _height(15),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.bottomRight,
                                        child: InkWell(
                                          onTap: (){
                                            getImage();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(_width(1)),
                                            height: _width(7),
                                            width: _width(7),
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.all(Radius.circular(50))
                                            ),
                                            child: Center(
                                                child: Icon(Icons.add, color: Colors.white, size: 15,)
                                            ),
                                          ),
                                        )
                                    ),
                                  ],
                                )
                            ),
                            Spacer()
                          ]
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(right: _width(2), top: _height(2)),
                        child: Card(
                          color: Colors.white,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          shadowColor: Colors.grey[100],
                          child: Container(
                            height: _height(7),
                            width: _width(80),
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Text(
                                  "First Name: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  ),
                                ),
                                Container(
                                  width: _width(40),
                                  child: TextField(
                                    onChanged: (value){
                                      setState(() {
                                        firstname = value;
                                      });
                                    },
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(fontSize: 13, color: Color.fromARGB(200, 169, 169, 169)),
                                        hintText: firstname
                                    ),
                                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(right: _width(2), top: _height(2)),
                        child: Card(
                          color: Colors.white,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          shadowColor: Colors.grey[100],
                          child: Container(
                            height: _height(7),
                            width: _width(80),
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Last Name: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  ),
                                ),
                                Container(
                                  width: _width(40),
                                  child: TextField(
                                    onChanged: (value){
                                      setState(() {
                                        lastname = value;
                                      });
                                    },
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(fontSize: 13, color: Color.fromARGB(200, 169, 169, 169)),
                                        hintText: lastname
                                    ),
                                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(right: _width(2), top: _height(2)),
                        child: Card(
                          color: Colors.white,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          shadowColor: Colors.grey[100],
                          child: Container(
                            height: _height(7),
                            width: _width(80),
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Username: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  ),
                                ),
                                Container(
                                  width: _width(40),
                                  child: TextField(
                                    onChanged: (value){
                                      setState(() {
                                        username = value;
                                      });
                                    },
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(fontSize: 13, color: Color.fromARGB(200, 169, 169, 169)),
                                        hintText: username
                                    ),
                                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(right: _width(2), top: _height(2)),
                        child: Card(
                          color: Colors.white,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          shadowColor: Colors.grey[100],
                          child: Container(
                            height: _height(7),
                            width: _width(80),
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Email Address: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  ),
                                ),
                                Container(
                                  width: _width(40),
                                  child: TextField(
                                    enabled: false,
                                    onChanged: (value){
                                      setState(() {
                                        email = value;
                                      });
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(fontSize: 13, color: Color.fromARGB(200, 169, 169, 169)),
                                      hintText: email
                                    ),
                                    style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(right: _width(2), top: _height(2)),
                        child: Card(
                          color: Colors.white,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          shadowColor: Colors.grey[100],
                          child: Container(
                            height: _height(7),
                            width: _width(80),
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Date of birth: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width: _width(40),
                                  child: DateTimeField(
                                    format: format,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '${birthDate.toString()}',
                                      hintStyle: TextStyle(fontSize: 13, color: Color.fromARGB(175, 169, 169, 169)),
                                    ),
                                    style: TextStyle(fontSize: 13, color: Color.fromARGB(175, 0, 0, 0)),
                                    onShowPicker: (context, currentValue) {
                                      return showDatePicker(
                                        context: context,
                                        firstDate: DateTime(date.year - 120),
                                        initialDate: currentValue ?? DateTime.now(),
                                        lastDate: DateTime.now(),
                                      );
                                    },
                                    onChanged: ((value){
                                      birthDate = value!;
                                    }),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   height: _height(7),
                      //   width: _width(80),
                      //   margin: EdgeInsets.only(right: _width(2), top: _height(2)),
                      //   padding: EdgeInsets.only(left: 10),
                      //   decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.all(Radius.circular(15)),
                      //       border: Border.all(
                      //           width: 0.5,
                      //           color: Colors.grey
                      //       )
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         "Team: ",
                      //         style: TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.black
                      //         ),
                      //       ),
                      //       Spacer(),
                      //       Container(
                      //         width: _width(60),
                      //         child: DropdownButton<String>(
                      //           isExpanded: true,
                      //           style: TextStyle(
                      //             color: Color.fromARGB(255, 137, 138, 143),
                      //             fontSize: 12,
                      //             fontFamily: ".SF NS Text",
                      //           ),
                      //           items: [
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'FINANCE DIVISION',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'FINANCE DIVISION',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'BUSINESS DEVELOPMENT',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'BUSINESS DEVELOPMENT',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'CORPORATE SECURITY DIVISION',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'CORPORATE SECURITY DIVISION',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'COPs - COMMERCIAL',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'COPs - COMMERCIAL',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'GREATER WESTERN & RIFT - COMMERCIAL',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'GREATER WESTERN & RIFT - COMMERCIAL',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'FINANCIAL SERVICES DIVISION',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'FINANCIAL SERVICES DIVISION',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'RESOURCES DIVISION',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'RESOURCES DIVISION',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'TECHNOLOGY DIVISION',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'TECHNOLOGY DIVISION',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'NAIROBI EAST COAST REGION - COMMERCIAL',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'NAIROBI EAST COAST REGION - COMMERCIAL',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'CEOs OFFICE',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'CEOs OFFICE',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'NAIROBI WEST & MOUNTAIN - COMMERCIAL',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'NAIROBI WEST & MOUNTAIN - COMMERCIAL',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'CORPORATE AFFAIRS DIVISION',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'CORPORATE AFFAIRS DIVISION',
                      //             ),
                      //             DropdownMenuItem<String>(
                      //               child: Text(
                      //                 'ENTERPRISE BUSINESS UNIT',
                      //                 style: TextStyle(
                      //                     color: Color.fromARGB(255, 137, 138, 143),
                      //                     fontSize: 14,
                      //                     fontFamily: ".SF NS Text",
                      //                     fontWeight: FontWeight.w400),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               value: 'ENTERPRISE BUSINESS UNIT',
                      //             ),
                      //           ],
                      //           onChanged: (String value) {
                      //             setState(() {
                      //               team = value;
                      //             });
                      //           },
                      //           hint: Text(
                      //             'Select Team',
                      //             style: TextStyle(
                      //                 color: Colors.white70,
                      //                 fontSize: 14,
                      //                 fontFamily: ".SF NS Text",
                      //                 fontWeight: FontWeight.w400),
                      //             textAlign: TextAlign.left,
                      //           ),
                      //           value: team,
                      //         ),
                      //       ),
                      //       Spacer()
                      //     ],
                      //   ),
                      // ),

                      SizedBox(height: _height(10)),
                      Center(
                        child: InkWell(
                          onTap: () async {
                            if(email == null || firstname == null|| lastname == null ||username == null || birthDate == null || team == null){
                              Fluttertoast.showToast(msg: "Please fill all entries", backgroundColor: Colors.red);
                            }else{
                              setState(() {
                                login = true;
                              });
                              prefs = await SharedPreferences.getInstance();

                              prefs.setString("username", username);
                              prefs.setString("lastname", lastname);
                              prefs.setString("firstname", firstname);
                              prefs.setString("email", email);
                              prefs.setString("birthDate", birthDate.toString());
                              // prefs.setString("team", team);

                              var profileData = {
                                "fullname": "$firstname $lastname",
                                "username": username,
                                "email": email,
                                "birthDate": birthDate.toString(),
                                // "team": "team",
                                "image": image
                              };
                              var result = await Authentication().updateProfile(profileData);
                              if(result["success"]){
                                prefs.setString("email", email);
                                prefs.setString("username", username);
                                Fluttertoast.showToast(msg: "Profile updated successfully", backgroundColor: Colors.green);
                                Common().newActivity(context, HomeView());
                              }else{
                                Fluttertoast.showToast(msg: "Profile update failed", backgroundColor: Colors.deepOrangeAccent);
                              }
                            }
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            shadowColor: Colors.grey[100],
                            child: Container(
                              height: _height(7),
                              width: _width(80),
                              decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Center(
                                child: login ? SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 15,
                                ) : Text(
                                  "Update Profile",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _height(3)),

                    ],
                  ),
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
                ),
              ],
            )
        ),
      ),
      drawer: Common().navDrawer(context, username, email, "profile", image),
    );
  }

  _height(size){
    return Common().componentHeight(context, size);
  }

  _width(size){
    return Common().componentWidth(context, size);
  }
}
