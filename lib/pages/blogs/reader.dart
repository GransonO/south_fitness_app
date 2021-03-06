import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:south_fitness/services/net.dart';

import '../common.dart';

class Reader extends StatefulWidget {
  var blog;
  Reader(var details){
    blog = details;
  }

  @override
  _ReaderState createState() => _ReaderState(blog);
}

class _ReaderState extends State<Reader> {

  var reader = {};
  _ReaderState(blog){
    reader = blog;
  }

  bool notesClicked = false;

  var username = "";
  var email = "";
  var user_id = "";
  var comments = [];
  var comment = "Tell us what's on your mind";
  bool addComment = false;
  bool isPosting = false;
  late SharedPreferences prefs;
  var image = "https://res.cloudinary.com/dolwj4vkq/image/upload/v1618227174/South_Fitness/profile_images/GREEN_AVATAR.jpg";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setPrefs();
  }

  setPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username")!;
      email = prefs.getString("email")!;
      image = prefs.getString("image")!;
      user_id = prefs.getString("user_id")!;
      comments = reader["comments"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: _height(100),
          width: _width(100),
          child: Stack(
            children: [
              Container(
                height: _height(40),
                width: _width(100),
                child: Image.network(
                  "${reader["image_url"]}",
                  fit: BoxFit.cover,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: _height(35),),
                    Container(
                      width: _width(100),
                      padding: EdgeInsets.only(top: _height(2), left: _width(2), right: _width(2)),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: _width(100),
                            child: Text(
                              "${reader["title"]}",
                              style: GoogleFonts.rubik(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          Container(
                            height: _height(4),
                            width: _width(100),
                            child: Text(
                              "By ${reader["uploaded_by"]}",
                              style: GoogleFonts.rubik(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          Container(
                              height: _height(4),
                              width: _width(100),
                              child: Row(
                                children: [
                                  Text(
                                    "${reader["reading_duration"]}",
                                    style: GoogleFonts.rubik(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${reader["comments_count"]} Comments",
                                    style: GoogleFonts.rubik(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${convertDate(reader["updatedAt"])}",
                                    style: GoogleFonts.rubik(
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Spacer(),

                                ],
                              )
                          ),
                          Container(
                              width: _width(90),
                              margin: EdgeInsets.only(top: _height(1), bottom: _height(2)),
                              child: Html(
                                data: reader["body"],
                              )
                          ),
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  "Readers comments",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          SizedBox( height: _height(2)),
                          addComment ? Container(): InkWell(
                            onTap: (){
                              setState(() {
                                addComment = true;
                              });
                            },
                            child: Card(
                              color: Colors.lightGreen,
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              shadowColor: Colors.grey[100],
                              child: Container(
                                width: _width(100),
                                height: _height(5),
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Add Comment",
                                    style: GoogleFonts.rubik(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                )
                              ),
                            ),
                          ),
                          addComment ? Card(
                            color: Colors.white,
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            shadowColor: Colors.grey[100],
                            child: Container(
                              width: _width(100),
                              padding: EdgeInsets.all(5),
                              child: TextField(
                                onChanged: (value){
                                  setState(() {
                                    comment = value;
                                  });
                                },
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 13, color: Color.fromARGB(200, 169, 169, 169)),
                                    hintText: comment
                                ),
                                style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                            ),
                          ) : Container(),
                          addComment ? InkWell(
                            onTap: () async {
                              if(comment == "Tell us what's on your mind"){
                                Fluttertoast.showToast(msg: "Enter your comment before posting");
                                return;
                              }
                              // post comment $ refresh
                              setState(() {
                                isPosting = true;
                              });
                              var result = await HomeResources().postBlogComment(
                                  {
                                    "blog_id": reader["blog_id"],
                                    "username": "$username",
                                    "uploader_id": "$user_id",
                                    "body": comment,
                                    "user_image": "$image"
                                  }
                              );
                              if(result){
                                Fluttertoast.showToast(msg: "Posting success", backgroundColor: Colors.green, textColor: Colors.white);
                                setState(() {
                                  addComment = false;
                                  isPosting = false;
                                  comment = "Tell us what's on your mind";
                                });
                                getComments();
                              }else{
                                Fluttertoast.showToast(msg: "Posting error, try again later", backgroundColor: Colors.red, textColor: Colors.white);
                                setState(() {
                                  isPosting = false;
                                });
                              }
                            },
                            child: Card(
                              color: Colors.lightGreen,
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              shadowColor: Colors.grey[100],
                              child: Container(
                                  width: _width(100),
                                  height: _height(5),
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: isPosting ? SpinKitThreeBounce(
                                      size: 15,
                                      color: Colors.white,
                                    ) : Text(
                                      "Post Comment",
                                      style: GoogleFonts.rubik(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  )
                              ),
                            ),
                          ) : Container(),
                          Column(
                            children: displayComments(),
                          ),
                          SizedBox( height: _height(8))
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _height(size){
    return Common().componentHeight(context, size);
  }

  _width(size){
    return Common().componentWidth(context, size);
  }

  displayComments(){
    var children = <Widget>[];
    comments.forEach((element) {
      children.add(
          Card(
            color: Colors.white,
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            shadowColor: Colors.grey[100],
            child: Container(
              width: _width(100),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              padding: EdgeInsets.all(8.0,),
              child: Column(
                children: [
                  SizedBox(height: _height(1),),
                  Container(
                    height: _height(4),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              height: _height(5),
                              width: _height(5),
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.cover, image: new NetworkImage(element["profile_image"])
                                  )
                              )
                          ),
                        ),
                        SizedBox(width: _width(1),),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: _width(70),
                            child: Text(
                              element["username"],
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _width(2),),
                  Container(
                      padding: EdgeInsets.only(left: 5),
                      width: _width(100),
                      child: Text(
                        element["body"],
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                            fontSize: 12
                        ),
                      )
                  ),
                  SizedBox(height: _width(2),),
                  Container(
                      width: _width(100),
                      padding: EdgeInsets.only(right: 5),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            convertDate(element["updatedAt"]),
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 10
                            ),
                          )
                      )
                  ),
                  SizedBox(height: _height(1),),
                ],
              ),
            ),
          )
      );
    });
    return children;
  }

  getComments() async {
    var commentX = await HomeResources().getBlogComments(reader["blog_id"]);
    setState(() {
      comments = commentX;
    });
  }

  convertDate(date) {
    var dateItem = DateTime.parse(date);
    return DateFormat('EEE d MMM, yyyy').format(dateItem);
  }
}
