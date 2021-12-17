import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safety_application/home.dart';
import 'package:telephony/telephony.dart';

class VideoRecorder extends StatefulWidget {
  String imagePathB, imagePathF, lat, long, rEmail, rMobile, email, password, name;

  VideoRecorder(
      {Key? key,
      required this.imagePathB,
      required this.imagePathF,
      required this.lat,
      required this.long, required this.email, required this.rEmail, required this.rMobile, required this.password,
      required this.name})
      : super(key: key);

  @override
  _VideoRecorderState createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  CameraController? controller;
  // String? videoPath;

  List<CameraDescription>? cameras;
  int selectedCameraIdx = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future sendEmail(videoPath) async {
    String username = widget.email;
    String password = widget.password;

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, widget.name)
      ..recipients.add(widget.rEmail)
      ..subject = 'Please Help! I am ${widget.name}!'
      ..text =  'I am in danger, please find my attached pics/video.\n\nMy Current location is -\n'
          'https://www.google.com/maps/search/?api=1&query=${widget.lat},${widget.long}'
    ..attachments = [FileAttachment(File(widget.imagePathF)), FileAttachment(File(widget.imagePathB)), FileAttachment(File(videoPath))];

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      Fluttertoast.showToast(msg: "Message sent");
    } on MailerException catch (e) {
      print('Message not sent.');
      Fluttertoast.showToast(msg: "Message not sent");
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras!.isNotEmpty) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _onCameraSwitched(cameras![selectedCameraIdx]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Take a Video'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: _cameraPreviewWidget(),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color:
                      controller != null && controller!.value.isRecordingVideo
                          ? Colors.redAccent
                          : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _captureControlRowWidget(),
                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  // Display 'Loading' text when the camera is still loading.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller == null ? 1.0 : controller!.value.aspectRatio,
      child: CameraPreview(controller!),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null) {
      return Row();
    }

    CameraDescription selectedCamera = cameras![selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: _onSwitchCamera,
            icon: Icon(_getCameraLensIcon(lensDirection)),
            label: Text(
                "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}")),
      ),
    );
  }

  /// Display the control bar with buttons to record videos.
  Widget _captureControlRowWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.videocam),
              color: Colors.blue,
              onPressed: controller != null &&
                      controller!.value.isInitialized &&
                      !controller!.value.isRecordingVideo
                  ? _onRecordButtonPressed
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              color: Colors.red,
              onPressed: controller != null &&
                      controller!.value.isInitialized &&
                      controller!.value.isRecordingVideo
                  ? _onStopButtonPressed
                  : null,
            )
          ],
        ),
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller!.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${controller!.value.errorDescription}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras!.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras![selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    _startVideoRecording().then((filePath) {
      Fluttertoast.showToast(
          msg: 'Recording video started',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    });
  }

  final Telephony telephony = Telephony.instance;

  final SmsSendStatusListener listener = (SendStatus status) {
    Fluttertoast.showToast(msg: "Alert SMS Sent!");
  };

  Future sendSmsBtn()async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted!) {
      telephony.sendSms(
          to: widget.rMobile,
          message: "Please Help! I am in danger.\n\nMy current Location is -"
              "\nhttps://www.google.com/maps/search/?api=1&query=${widget.lat},${widget.long}",
          statusListener: listener
      );
    } else {
      Fluttertoast.showToast(msg: "SMS Access Denied!");
    }
  }

  void _onStopButtonPressed() {
    _stopVideoRecording().then((file) {
      // videoPath = file.toString();
      if (mounted) setState(() {});
      Fluttertoast.showToast(
          msg: 'Video recorded to $file',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
      // print(videoPath.toString());
      sendSmsBtn().whenComplete(() => sendEmail(file.toString()).then((value) {
            Navigator.pop(context);
            Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const HomePage()));
          }));
    });
  }

  Future _startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      Fluttertoast.showToast(
          msg: 'Please wait',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    }

    // Do nothing if a recording is on progress
    if (controller!.value.isRecordingVideo) {}

    try {
      await controller!.startVideoRecording();
      // videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  Future _stopVideoRecording() async {
    XFile? file;
    // if (!controller!.value.isRecordingVideo) {
    //   return file!.path;
    // }
    // else {
    try {
      file = await controller!.stopVideoRecording();
      return file.path;
    } on CameraException catch (e) {
      _showCameraException(e);
    // }
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    Fluttertoast.showToast(
        msg: 'Error: ${e.code}\n${e.description}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }
}
