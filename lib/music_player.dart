import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo,this.changeTrack,this.key}):super(key: key);

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double maxValue = 0.0, minValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '';
  bool isPlaying = false;

  final AudioPlayer audioPlayer = AudioPlayer();

  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  void dispose() {
    super.dispose();
    audioPlayer?.dispose();
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await audioPlayer.setUrl(songInfo.uri);
    currentValue = minValue;
    maxValue = audioPlayer.duration.inMilliseconds.toDouble();

    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maxValue);
    });
    isPlaying = false;
    changeState();
    audioPlayer.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentValue);
      });
    });
  }

  void changeState() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      audioPlayer.play();
    } else {
      audioPlayer.pause();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((e) => e.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(5, 100, 5, 0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: widget.songInfo.albumArtwork == null
                  ? AssetImage('assets/images/profile_pic.jpg')
                  : FileImage(File(widget.songInfo.albumArtwork)),
              radius: 150,
            ),
            SizedBox(
              height: 120,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 24, 0, 7),
              child: Text(
                widget.songInfo.title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
              child: Text(
                widget.songInfo.artist,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Slider(
              inactiveColor: Colors.black12,
              activeColor: Colors.black,
              min: minValue,
              max: maxValue,
              value: currentValue,
              onChanged: (value) {
                currentValue = value;
                audioPlayer.seek(Duration(milliseconds: currentValue.round()));
              },
            ),
            Container(
              transform: Matrix4.translationValues(0, -5, 0),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    endTime,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.black,
                      size: 55,
                    ),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      widget.changeTrack(false);
                    },
                  ),
                  GestureDetector(
                    child: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: Colors.black,
                      size: 75,
                    ),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      changeState();
                    },
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.skip_next_rounded,
                      color: Colors.black,
                      size: 55,
                    ),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      widget.changeTrack(true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
