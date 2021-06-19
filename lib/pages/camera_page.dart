import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:forfarmer/components/image_pop_up.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';

import 'package:tflite/tflite.dart';

class CameraPage extends StatefulWidget {
  // just for E2E test. if true we create our images names from datetime.
  // Else it's just a name to assert image exists
  static const routeName = '/camera-page';

  final bool randomPhotoName;

  CameraPage({this.randomPhotoName = true});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  String? _lastPhotoPath;
  bool _isRecordingVideo = false;

  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.AUTO);
  ValueNotifier<double> _zoomNotifier = ValueNotifier(0);
  ValueNotifier<Size> _photoSize = ValueNotifier(Size(0, 0));
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<bool> _enableAudio = ValueNotifier(true);
  ValueNotifier<CameraOrientations> _orientation =
      ValueNotifier(CameraOrientations.PORTRAIT_UP);

  /// use this to call a take picture
  PictureController _pictureController = new PictureController();

  @override
  void dispose() async {
    // previewStreamSub.cancel();
    _photoSize.dispose();
    _captureMode.dispose();
    await Tflite.close();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      Tflite.loadModel(
        model: 'assets/model/model.tflite',
        labels: 'assets/model/labels.txt',
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          buildFullscreenCamera(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Image.asset('assets/images/img-frame.png'),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 48,
                  color: Colors.black,
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (_switchFlash.value ==
                                      CameraFlashes.AUTO) {
                                    _switchFlash.value = CameraFlashes.NONE;
                                  } else if (_switchFlash.value ==
                                      CameraFlashes.NONE) {
                                    _switchFlash.value = CameraFlashes.ON;
                                  } else if (_switchFlash.value ==
                                      CameraFlashes.ON) {
                                    _switchFlash.value = CameraFlashes.AUTO;
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Image.asset(
                                  _switchFlash.value == CameraFlashes.AUTO
                                      ? 'assets/images/ic-flash-auto.png'
                                      : _switchFlash.value == CameraFlashes.NONE
                                          ? 'assets/images/ic-flash-off.png'
                                          : 'assets/images/ic-flash-on.png',
                                  width: 24,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 148,
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Scan Hama',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final pickedFile = await picker.getImage(
                                        source: ImageSource.gallery);

                                    if (pickedFile != null) {
                                      File croppedFile =
                                          await FlutterNativeImage.cropImage(
                                        pickedFile.path,
                                        300,
                                        200,
                                        400,
                                        400,
                                      );

                                      showDialog(
                                        context: context,
                                        builder: (context) => ImagePopUp(
                                            croppedFile: croppedFile),
                                      );
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/images/ic-gallery.png',
                                    width: 31.5,
                                  ),
                                ),
                                CameraButton(
                                  key: ValueKey('cameraButton'),
                                  captureMode: _captureMode.value,
                                  isRecording: _isRecordingVideo,
                                  onTap: _takePhoto,
                                ),
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      )),
                                      builder: (context) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 20,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              'assets/images/img-camera-guide.png',
                                              color: Color(0xFF03755F),
                                              height: 56,
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                              'Pastikan bagian terindikasi terdapat penyakit tampak jelas pada foto',
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(
                                              height: 32,
                                            ),
                                            SizedBox(
                                              height: 56,
                                              width: double.infinity,
                                              child: OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                style: ButtonStyle(
                                                  side: MaterialStateProperty
                                                      .resolveWith(
                                                    (states) => BorderSide(
                                                      color: Color(0xFF03755F),
                                                    ),
                                                  ),
                                                  shape: MaterialStateProperty
                                                      .resolveWith(
                                                    (states) =>
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Tutup',
                                                  style: TextStyle(
                                                    color: Color(0xFF03755F),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/ic-help.png',
                                    width: 31.5,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _takePhoto() async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir =
        await Directory('${extDir.path}/test').create(recursive: true);
    final String filePath = widget.randomPhotoName
        ? '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg'
        : '${testDir.path}/photo_test.jpg';
    await _pictureController.takePicture(filePath);
    // lets just make our phone vibrate
    HapticFeedback.mediumImpact();
    _lastPhotoPath = filePath;

    if (_lastPhotoPath != null) {
      File croppedFile = await FlutterNativeImage.cropImage(
        _lastPhotoPath!,
        300,
        200,
        400,
        400,
      );

      showDialog(
        context: context,
        builder: (context) => ImagePopUp(croppedFile: croppedFile),
      );
    }
  }

  void _onOrientationChange(CameraOrientations? newOrientation) {
    if (newOrientation != null) {
      _orientation.value = newOrientation;
    }
  }

  void _onPermissionsResult(bool? granted) {
    if (granted == null) {
      return;
    }
    if (!granted) {
      AlertDialog alert = AlertDialog(
        title: Text('Error'),
        content: Text(
            'It seems you doesn\'t authorized some permissions. Please check on your settings and try again.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {});
      // Fluttertoast.showToast(
      //   msg: "Pemberian izin berhasil",
      //   toastLength: Toast.LENGTH_SHORT,
      // );
    }
  }

  // /// this is just to preview images from stream
  // /// This use a bufferTime to take an image each 1500 ms
  // /// you cannot show every frame as flutter cannot draw them fast enough
  // /// [THIS IS JUST FOR DEMO PURPOSE]
  // Widget _buildPreviewStream() {
  //   if (previewStream == null) return Container();
  //   return Positioned(
  //     left: 32,
  //     bottom: 120,
  //     child: StreamBuilder(
  //       stream: previewStream.bufferTime(Duration(milliseconds: 1500)),
  //       builder: (context, snapshot) {
  //         print(snapshot);
  //         if (!snapshot.hasData || snapshot.data == null) return Container();
  //         List<Uint8List> data = snapshot.data;
  //         print(
  //             "...${DateTime.now()} new image received... ${data.last.lengthInBytes} bytes");
  //         return Image.memory(
  //           data.last,
  //           width: 120,
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget buildFullscreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Center(
        child: CameraAwesome(
          onPermissionsResult: _onPermissionsResult,
          captureMode: _captureMode,
          photoSize: _photoSize,
          sensor: _sensor,
          enableAudio: _enableAudio,
          switchFlashMode: _switchFlash,
          zoom: _zoomNotifier,
          selectDefaultSize: (availableSizes) {
            final size = Size(1024.0, 768.0);

            _photoSize.value = size;

            return size;
          },
          onOrientationChanged: _onOrientationChange,
          onCameraStarted: () {
            // camera started here -- do your after start stuff
          },
        ),
      ),
    );
  }
}

class CameraButton extends StatefulWidget {
  final CaptureModes? captureMode;
  final bool? isRecording;
  final Function? onTap;

  CameraButton({
    Key? key,
    this.captureMode,
    this.isRecording,
    this.onTap,
  }) : super(key: key);

  @override
  _CameraButtonState createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  double? _scale;
  Duration _duration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _animationController!.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        key: ValueKey('cameraButton' +
            (widget.captureMode == CaptureModes.PHOTO ? 'Photo' : 'Video')),
        height: 56,
        width: 56,
        child: Transform.scale(
          scale: _scale!,
          child: CustomPaint(
            painter: CameraButtonPainter(
              widget.captureMode ?? CaptureModes.PHOTO,
              isRecording: widget.isRecording!,
            ),
          ),
        ),
      ),
    );
  }

  _onTapDown(TapDownDetails details) {
    _animationController!.forward();
  }

  _onTapUp(TapUpDetails details) {
    Future.delayed(_duration, () {
      _animationController!.reverse();
    });

    this.widget.onTap?.call();
  }

  _onTapCancel() {
    _animationController!.reverse();
  }
}

class CameraButtonPainter extends CustomPainter {
  final CaptureModes captureMode;
  final bool isRecording;

  CameraButtonPainter(
    this.captureMode, {
    this.isRecording = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var bgPainter = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    var radius = size.width / 2;
    var center = Offset(size.width / 2, size.height / 2);
    bgPainter.color = Colors.white.withOpacity(.5);
    canvas.drawCircle(center, radius, bgPainter);

    if (this.captureMode == CaptureModes.VIDEO && this.isRecording) {
      bgPainter.color = Colors.red;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                17,
                17,
                size.width - (17 * 2),
                size.height - (17 * 2),
              ),
              Radius.circular(12.0)),
          bgPainter);
    } else {
      bgPainter.color =
          captureMode == CaptureModes.PHOTO ? Colors.white : Colors.red;
      canvas.drawCircle(center, radius - 8, bgPainter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
