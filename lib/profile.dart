import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safety_application/home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rEmailController = TextEditingController();
  final TextEditingController _rMobController = TextEditingController();

  bool isLoading=false;
  String email="";

  Future getData() async {
    var document = FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid);
    document.get().then((value) {
      setState(() {
        _nameController.text = value["name"];
        _rEmailController.text = value["rmail"];
        _rMobController.text = value["rmobile"];
        email = value["email"];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
      image: DecorationImage(
      image: AssetImage("assets/images/background.jpg"),
      fit: BoxFit.cover)),
      child: email.isEmpty
              ? const Center(
                  child: CircularProgressIndicator())
              : SingleChildScrollView(
        padding: const EdgeInsets.all(8),
                child: Column(
        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            elevation: 4.0,
                            margin: const EdgeInsets.all(4.0),
                            shadowColor: Colors.black26,
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(child: const Text("Your Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),),
                                    margin: const EdgeInsets.all(8.0), alignment: Alignment.center,),
                                Container(
                                    child:
                                    const Text('Username:', style: TextStyle(fontSize: 16, color: Colors.white),),
                                    margin: const EdgeInsets.fromLTRB(8, 8, 8, 0)),
                                Container(
                                    child:
                                        TextField(style: const TextStyle(fontSize: 16, color: Colors.white),
                                        controller: _nameController,
                                        keyboardType: TextInputType.name,
                                        decoration: const InputDecoration(
                                          hintText: "Enter Name",
                                          hintStyle: TextStyle(color: Colors.white)
                                        ),),
                                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 8)),
                                Container(
                                    child:
                                        Text('Email: ' + email, style: const TextStyle(fontSize: 16, color: Colors.white),
                                        maxLines: 3,),
                                    margin: const EdgeInsets.fromLTRB(8, 12, 8, 12)),
                              ],
                            ),
                          ),
                      Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.all(4.0),
                      shadowColor: Colors.black26,
                      color: Colors.transparent,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Container(child: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),),
                              margin: const EdgeInsets.fromLTRB(8.0, 16, 8, 8), alignment: Alignment.center,),
                          Container(
                              child:
                              const Text('Receipent\'s Mail: ', style: TextStyle(fontSize: 16, color: Colors.white),),
                              margin: const EdgeInsets.fromLTRB(8, 8, 8, 0)),
                          Container(
                              child:
                              TextField(style: const TextStyle(fontSize: 16, color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                controller: _rEmailController,
                                decoration: const InputDecoration(
                                  hintText: "Enter email",
                                  hintStyle: TextStyle(color: Colors.white)
                                ),),
                              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8)),
                          Container(
                              child:
                              const Text('Receipent\'s Mobile No: ', style: TextStyle(fontSize: 16, color: Colors.white),),
                              margin: const EdgeInsets.fromLTRB(8, 12, 8, 0)),
                          Container(
                              child:
                              TextField(style: const TextStyle(fontSize: 16, color: Colors.white),
                                controller: _rMobController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: "Enter mobile",
                                  hintStyle: TextStyle(color: Colors.white)
                                ),),
                              margin: const EdgeInsets.fromLTRB(8.0, 0, 8, 12)),])),
                          const SizedBox(height: 8,),
                          isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
                              : ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) => Colors.blue,
                                ),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    )
                                ),
                              ),
                              onPressed: () {
                                if (_nameController.text.isEmpty || _rEmailController.text.isEmpty || _rMobController.text.isEmpty) {
                                  Fluttertoast.showToast(msg: "Enter all fields");
                                } else {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  FirebaseFirestore.instance
                                      .collection("Users").doc(
                                      FirebaseAuth.instance.currentUser!.uid)
                                      .update({
                                    'name': _nameController.text,
                                    'rmail': _rEmailController.text,
                                    'rmobile': _rMobController.text
                                  });
                                  Fluttertoast.showToast(msg: "Changes updated!");
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/4,
                                    right: MediaQuery.of(context).size.width/4),
                                child: const Text(
                                  "Save",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              )
                          ),
                        ],
                      ),
              )));
  }
}
