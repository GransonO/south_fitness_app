import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:video_player/video_player.dart';

import '../common.dart';
import '../home/Home.dart';

class VideoRating extends StatefulWidget {
  @override
  _VideoRatingState createState() => _VideoRatingState();
}

class _VideoRatingState extends State<VideoRating> {


  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool play = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = VideoPlayerController.network(
      "https://res.cloudinary.com/dolwj4vkq/video/upload/v1612826611/South_Fitness/yoga.mp4",
    );

    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: _height(100),
            width: _width(100),
            child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
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
                                        "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in as some form, by injected humour",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(height: _height(5),),

                                    Container(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Video Rating",
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

                                    Container(
                                      height: _width(70),
                                      width: _width(90),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            child: Container(
                                              height: _width(70),
                                              width: _width(90),
                                              margin: EdgeInsets.only(top: _height(2), bottom: _height(4)),
                                              child: FutureBuilder(
                                                future: _initializeVideoPlayerFuture,
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.done) {
                                                    // If the VideoPlayerController has finished initialization, use
                                                    // the data it provides to limit the aspect ratio of the VideoPlayer.
                                                    return AspectRatio(
                                                      aspectRatio: _controller.value.aspectRatio,
                                                      // Use the VideoPlayer widget to display the video.
                                                      child: VideoPlayer(_controller),
                                                    );
                                                  } else {
                                                    // If the VideoPlayerController is still initializing, show a
                                                    // loading spinner.
                                                    return Center(child: CircularProgressIndicator());
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: InkWell(
                                                onTap: (){
                                                  setState(() {
                                                    // If the video is playing, pause it.
                                                    if (_controller.value.isPlaying) {
                                                      play = false;
                                                      _controller.pause();
                                                    } else {
                                                      play = true;
                                                      // If the video is paused, play it.
                                                      _controller.play();
                                                    }
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: play ? Icon(Icons.pause_circle_filled, color: Colors.lightGreen, size: 50,) : Icon(Icons.play_circle_filled_sharp, color: Colors.lightGreen, size: 50,),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    // startVideo ?
                                    Container(
                                        width: _width(100),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: _width(100),
                                              height: _height(10),
                                              child: Container(
                                                width: _width(100),
                                                height: _height(15),
                                                margin: EdgeInsets.only(right: _width(3), left: _width(3), bottom: _height(1)),
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: _width(3),),
                                                    Container(
                                                      height: _height(5),
                                                      width: _width(30),
                                                      child: Text(
                                                        "Rate today's Workout",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: _height(5),
                                                      width: _width(50),
                                                      child: RatingBar.builder(
                                                        initialRating: 0,
                                                        minRating: 1,
                                                        direction: Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemSize: 35.0,
                                                        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                        itemBuilder: (context, _) => Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate: (rating) {
                                                          print(rating);
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(width: _width(3),),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: _width(100),
                                              height: _height(10),
                                              child: Container(
                                                width: _width(100),
                                                height: _height(15),
                                                margin: EdgeInsets.only(right: _width(3), left: _width(3), bottom: _height(1)),
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: _width(3),),
                                                    Container(
                                                      height: _height(5),
                                                      width: _width(30),
                                                      child: Text(
                                                        "Rate today's Trainer",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: _height(5),
                                                      width: _width(50),
                                                      child: RatingBar.builder(
                                                        initialRating: 0,
                                                        minRating: 1,
                                                        direction: Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemSize: 35.0,
                                                        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                        itemBuilder: (context, _) => Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate: (rating) {
                                                          print(rating);
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(width: _width(3),),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                    ),


                                    SizedBox( height: _height(5)),
                                    Center(
                                      child: InkWell(
                                        onTap: (){
                                          Common().newActivity(context, HomeView());
                                        },
                                        child: Container(
                                          height: _height(5),
                                          width: _width(80),
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(255,110,180,63),
                                              borderRadius: BorderRadius.all(Radius.circular(15))
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Back Home",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox( height: _height(8))
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: _height(7),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  SizedBox(width: _width(3),),
                                  Common().logoOnBar(context),
                                  Spacer(),
                                  Icon(Icons.notifications_none, size: 30,),
                                  SizedBox(width: _width(4),),
                                ],
                              ),
                            ),
                          ]
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
                        Icon(Icons.notifications_none, size: 30,),
                        SizedBox(width: _width(4),),
                      ],
                    ),
                  ),
                ]
            ),
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
}