import 'package:cctv_kota_medan_v2/models/camera_model.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class PlayerDisplay extends StatefulWidget {
  const PlayerDisplay({
    required this.camera,
    super.key,
  });

  final CameraModel camera;

  @override
  State<PlayerDisplay> createState() => _PlayerDisplayState();
}

class _PlayerDisplayState extends State<PlayerDisplay> {
  late VideoPlayerController _controller;
  bool _isStarted = false;
  bool _isError = false;
  bool _isStillWaiting = false;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
  }

  void _initializeVideo() {
    setState(() {
      _isStarted = false;
      _isError = false;
      _isStillWaiting = false;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.camera.url))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _isStarted = true;

        if (mounted) {
          setState(() {});
          _controller.play();
        }
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (mounted) {
            setState(() {
              _isError = true;
            });
          }
        },
      ).catchError((error) {
        if (mounted) {
          setState(() {
            _isError = true;
          });
        }
      });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
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
    return Container(
      height: 500.0,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            widget.camera.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: Center(
              child: _isError
                  ? InkWell(
                      onTap: () {
                        _initializeVideo();
                      },
                      child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "Gagal memutar video, klik untuk mencoba lagi",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    )
                  : _isStarted
                      ? SizedBox(
                          height: 400.0,
                          child: PhotoView.customChild(
                            childSize: Size(
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.width /
                                      _controller.value.aspectRatio +
                                  32.0,
                            ),
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
                            const CircularProgressIndicator(),
                            const SizedBox(height: 8.0),
                            _isStillWaiting
                                ? const Text(
                                    "Masih menunggu video dari server...")
                                : Container(),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
