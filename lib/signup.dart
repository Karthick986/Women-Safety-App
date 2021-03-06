import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safety_application/home.dart';
import 'package:safety_application/main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isHidden = true;
  bool _hidden = true;

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late String email, password, name, repaasword;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _submit() {
    formKey.currentState!.save();
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (password.length<6 || repaasword.length<6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters!");
    } else if (password!=repaasword) {
      Fluttertoast.showToast(msg: "Password didn't match!");
    }

    else {
      setState(() {
        isLoading = true;
      });

      signUp(email: email, password: password)
          .then((result) {
        FirebaseFirestore.instance
            .collection("Users").doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'name': name,
          'email': email,
          'rmail': 'rokadeshubham0000@gmail.com',
          'rmobile': '9226738659',
          'password': password
        });
        if (result == null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const HomePage()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
        constraints: const BoxConstraints.expand(),
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage("assets/images/background.jpg"),
    fit: BoxFit.cover)),
    child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Form(
                key: formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 50.0,
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
                          child: Text("Register",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.white))),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Text("or create your account",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white))),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(margin: const EdgeInsets.only(left: 10.0, right: 10.0), child: TextFormField(
                        keyboardType: TextInputType.name,
                        textAlign: TextAlign.left,
                        onSaved: (value) => name = value!,
                        validator: (input) => input!.isEmpty
                            ? "Enter name!"
                            : null,
                        style:
                        const TextStyle(fontSize: 15.0, color: Colors.white),
                        onChanged: (value) {},
                        decoration: const InputDecoration(
                          hintText: " Your Name",
                          hintStyle: TextStyle( fontSize: 15.0, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white),
                          ),
                        ),
                      ),),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Container(margin: const EdgeInsets.only(left: 10.0, right: 10.0), child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.left,
                        onSaved: (value) => email = value!,
                        validator: (input) => input!.isEmpty
                            ? "Enter email!"
                            : null,
                        style:
                        const TextStyle(fontSize: 15.0, color: Colors.white),
                        onChanged: (value) {},
                        decoration: const InputDecoration(
                          hintText: " Email",
                          hintStyle: TextStyle( fontSize: 15.0, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white),
                          ),
                        ),
                      ),),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Container(margin: const EdgeInsets.only(left: 10.0, right: 10.0), child: TextFormField(
                        obscureText: _isHidden,
                        textAlign: TextAlign.left,
                        onSaved: (value) => password = value!,
                        validator: (input) => input!.isEmpty
                            ? "Enter password!"
                            : null,
                        style:
                        const TextStyle(fontSize: 15.0, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: " Password",
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white),
                          ),
                          suffix: InkWell(
                            onTap: () {
                              setState(() {
                                _isHidden = !_isHidden;
                              });
                            },
                            child: Icon(
                              _isHidden ? Icons.visibility_off : Icons.visibility, color: Colors.white
                            ),
                          ),
                          hintStyle: const TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                      ),),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Container(margin: const EdgeInsets.only(left: 10.0, right: 10.0), child: TextFormField(
                        obscureText: _hidden,
                        textAlign: TextAlign.left,
                        onSaved: (value) => repaasword = value!,
                        validator: (input) => input!.isEmpty
                            ? "Re-enter password!"
                            : null,
                        style:
                        const TextStyle(fontSize: 15.0, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: " Confirm Password",
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white),
                          ),
                          suffix: InkWell(
                            onTap: () {
                              setState(() {
                                _hidden = !_hidden;
                              });
                            },
                            child: Icon(
                                _hidden ? Icons.visibility_off : Icons.visibility, color: Colors.white
                            ),
                          ),
                          hintStyle: const TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                      ),),
                      const SizedBox(
                        height: 20.0,
                      ),
                      (isLoading) ? const CircularProgressIndicator() : Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(5))
                        ),
                        child: Material(
                          elevation: 4,
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(5.0),
                          child: MaterialButton(
                            padding:
                            const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            onPressed: () {
                              _submit();
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(child: Container(
                          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          margin: const EdgeInsets.only(top: 15.0),
                          child: const Text("Already have an account?",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.white))),
                        onTap: () =>
                            Navigator.pushReplacement(
                                context, MaterialPageRoute(builder: (context) => const Login())),
                      ),
                    ])
            ),
          ),
        )));
  }
}