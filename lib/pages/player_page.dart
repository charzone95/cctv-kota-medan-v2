import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String url;

  const PlayerScreen({required this.title, required this.url});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  bool _isStarted = false;
  bool _isError = false;
  bool _isStillWaiting = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _isStarted = true;

        if (this.mounted) {
          setState(() {});
          _controller.play();
        }
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (this.mounted) {
            setState(() {
              _isError = true;
            });
          }
        },
      ).catchError((error) {
        if (this.mounted) {
          setState(() {
            _isError = true;
          });
        }
      });

    Future.delayed(Duration(seconds: 5), () {
      if (this.mounted) {
        setState(() {
          _isStillWaiting = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    _isStarted = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pantau CCTV",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              _isError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 60.0),
                        Text(
                          "Gagal memutar video",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    )
                  : _isStarted
                      ? SizedBox(
                          height: 400.0,
                          child: PhotoView.customChild(
                            childSize: Size(
                                MediaQuery.of(context).size.width,
                                MediaQuery.of(context).size.width /
                                        _controller.value.aspectRatio +
                                    32.0),
                            minScale: 1.0,
                            backgroundDecoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                    "Anda dapat mencubit layar untuk memperbesar video"),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(height: 8.0),
                            _isStillWaiting
                                ? Text("Masih menunggu video dari server...")
                                : Container(),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
