import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:telephony/telephony.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'dart:io' as IO;
import 'package:safety_application/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_application/profile.dart';
import 'package:safety_application/video_demo.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Location location = Location();
  String lat = "", long = "", rMail="", rMobile="", name="", password="", email="";

  IO.File? _imageFileFront, _imageFileBack;

  final Telephony telephony = Telephony.instance;

  final SmsSendStatusListener listener = (SendStatus status) {
    Fluttertoast.showToast(msg: "Alert SMS Sent!");
  };

  Future sendSmsBtn()async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted!) {
      telephony.sendSms(
          to: rMobile,
          message: "Please Help! I am in danger.\n\nMy current Location is -"
                    "\nhttps://www.google.com/maps/search/?api=1&query=$lat,$long",
          statusListener: listener
      );
    } else {
      Fluttertoast.showToast(msg: "SMS Access Denied!");
    }
  }

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
    Fluttertoast.showToast(msg: "Current Location found!");
  }

  _callNumber(String number) async{
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Future redirect() async {
    await pickFrontCamera().whenComplete(() => pickBackCamera().whenComplete(() =>
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VideoRecorder(imagePathB: _imageFileBack!.path.toString(),
              imagePathF: _imageFileFront!.path.toString(), lat: lat, long: long, rEmail: rMail, rMobile: rMobile, name: name, email: email, password: password)))
    ));
  }

  Future _progressDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return
            const Center(
              child: CircularProgressIndicator(),
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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const Login())));
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

  Future getData() async {
    var document = FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid);
    document.get().then((value) {
      setState(() {
        name = value["name"];
        rMail = value["rmail"];
        rMobile = value["rmobile"];
        email = value["email"];
        password = value["password"];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
    Firebase.initializeApp();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(child: const Icon(Icons.person_pin_sharp),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },),
            const SizedBox(width: 16,),
            const Text("Safety Application"),
          ],
        ),
        actions: [
          InkWell(
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.logout),
            ),
            onTap: () {
              showLogout(context);
            },
          )
        ],
      ),
      body: Container(
    constraints: const BoxConstraints.expand(),
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage("assets/images/background.jpg"),
    fit: BoxFit.cover)),
    child: name.isEmpty
          ? const Center(
          child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2),
                              color: Colors.redAccent),
                          child: const Center(child: Text("Alert",
                            style: TextStyle(
                                color: Colors.white, fontSize: 25),)),
                        ),
                        onTap: () {
                          _progressDialog(context);
                          getLatLng().whenComplete(() => redirect());
                        },
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2),
                              color: Colors.green),
                          child: const Center(child: Text("Watch Me",
                            style: TextStyle(
                                color: Colors.white, fontSize: 23),)),
                        ),
                        onTap: () {
                          _progressDialog(context);
                          getLatLng().whenComplete(() => sendSmsBtn());
                        },
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2),
                              color: Colors.blueAccent),
                          child: const Center(child: Text("Dummy Call",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),)),
                        ),
                        onTap: () => _callNumber(rMobile)
                      ),
                    ),
                  ],
                ),
          )));
  }
}
