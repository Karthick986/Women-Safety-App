import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'dart:io' as IO;
import 'package:safety_application/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_application/video_demo.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Location location = Location();
  String lat = "", long = "";

  IO.File? _imageFileFront, _imageFileBack;

  // late String byteImage;
  // bool isLoading = false;
  final picker = ImagePicker();

  Future pickFrontCamera() async {
    Fluttertoast.showToast(msg: "Take Front Pic!");
    final pickedFile = await picker.getImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

    setState(() {
      _imageFileFront = IO.File(pickedFile!.path);
    });
    print(_imageFileFront);
  }

  Future pickBackCamera() async {
    Fluttertoast.showToast(msg: "Take Back Pic!");
    final pickedFile = await picker.getImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);

    setState(() {
      _imageFileBack = IO.File(pickedFile!.path);
    });
    print(_imageFileBack);
  }

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future checkPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  Future getLatLng() async {
    _locationData = await location.getLocation();
    setState(() {
      lat = _locationData.latitude.toString();
      long = _locationData.longitude.toString();
    });
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "Current Location found!");
    await pickFrontCamera().whenComplete(() => pickBackCamera().whenComplete(() =>
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => VideoRecorder(imagePathB: _imageFileBack!.path.toString(),
          imagePathF: _imageFileFront!.path.toString(), lat: lat, long: long)))
    ));
  }

  Future _progressDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  void showLogout(context) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.canPop(context);
        },
        child: const Text('No'));
    Widget continueButton = TextButton(
        onPressed: () async {
          Navigator.pop(context);
          FirebaseAuth.instance.signOut().then((value) =>
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Login())));
        },
        child: const Text('Yes'));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        'Confirm Logout',
        style: TextStyle(fontSize: 18),
      ),
      content: const Text('Are you sure want to logout ?',
          style: TextStyle(fontSize: 15)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Safety Application"),
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.logout),
            ),
            onTap: () {
              showLogout(context);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Container(
                height: MediaQuery.of(context).size.width/2,
                width: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width/2),
                color: Colors.redAccent),
                child: Center(child: Text("Help!", style: TextStyle(color: Colors.white, fontSize: 25),)),
              ),
              onTap: () {
                _progressDialog(context);
                getLatLng();
              },
            ),
            // SizedBox(height: 16,),
            // FlatButton(
            //     onPressed: () => launch("tel://9579831122"),
            //     child: new Text("Call me")),
          ],
        ),
      ),
    );
  }
}
