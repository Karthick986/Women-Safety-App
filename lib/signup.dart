import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:safety_application/home.dart';
import 'package:safety_application/main.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  bool _isHidden = true;

  final formKey = new GlobalKey<FormState>();
  bool isLoading = false;

  late String email, password, name;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _submit() {
    formKey.currentState!.save();
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    signUp(email: email, password: password)
        .then((result) {
      FirebaseFirestore.instance
          .collection("Users").doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'name': name, 'email': email, 'rmail': 'rokadeshubham0000@gmail.com', 'rmobile': '9226738659'});
      if (result == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        _scaffoldKey.currentState!.showSnackBar(
            SnackBar(
              content: Text(result),
            )
        );
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {

    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Form(
                key: formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 50.0,
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Text("Signup",
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold))),
                      Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Text("or create your account",
                              style: TextStyle(
                                  fontSize: 15.0))),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(margin: EdgeInsets.only(left: 10.0, right: 10.0), child: TextFormField(
                        keyboardType: TextInputType.name,
                        textAlign: TextAlign.left,
                        onSaved: (value) => name = value!,
                        validator: (input) => input!.isEmpty
                            ? "Enter name!"
                            : null,
                        style:
                        TextStyle(fontSize: 15.0),
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: " Your Name",
                          hintStyle: TextStyle( fontSize: 15.0),
                        ),
                      ),),
                      SizedBox(
                        height: 15.0,
                      ),
                      Container(margin: EdgeInsets.only(left: 10.0, right: 10.0), child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.left,
                        onSaved: (value) => email = value!,
                        validator: (input) => input!.isEmpty
                            ? "Enter email!"
                            : null,
                        style:
                        TextStyle(fontSize: 15.0),
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: " Email",
                          hintStyle: TextStyle( fontSize: 15.0),
                        ),
                      ),),
                      SizedBox(
                        height: 15.0,
                      ),
                      Container(margin: EdgeInsets.only(left: 10.0, right: 10.0), child: TextFormField(
                        obscureText: _isHidden,
                        textAlign: TextAlign.left,
                        onSaved: (value) => password = value!,
                        validator: (input) => input!.isEmpty
                            ? "Enter password!"
                            : null,
                        style:
                        TextStyle(fontSize: 15.0),
                        decoration: InputDecoration(
                          hintText: " Password",
                          suffix: InkWell(
                            onTap: () {
                              setState(() {
                                _isHidden = !_isHidden;
                              });
                            },
                            child: Icon(
                              _isHidden ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                          hintStyle: TextStyle(fontSize: 15.0),
                        ),
                      ),),
                      SizedBox(
                        height: 20.0,
                      ),
                      (isLoading) ? Container(child: CircularProgressIndicator(),) : Material(
                        elevation: 4,
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(5.0),
                        child: MaterialButton(
                          padding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          onPressed: () {
                            _submit();
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      GestureDetector(child: Container(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          margin: EdgeInsets.only(top: 15.0),
                          child: Text("Already Registered! Login here",
                              style: TextStyle(
                                  fontSize: 14.0))),
                        onTap: () =>
                            Navigator.pushReplacement(
                                context, MaterialPageRoute(builder: (context) => Login())),
                      ),
                    ])
            ),
          ),
        ));
  }
}