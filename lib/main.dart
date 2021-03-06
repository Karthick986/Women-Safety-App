import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:safety_application/home.dart';
import 'package:safety_application/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Widget navigateFirst;
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser != null) {
    navigateFirst = const HomePage();
  } else {
    navigateFirst = const Login();
  }
  runApp(navigateFirst);
}

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: _LoginPage(),
    );
  }
}

class _LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {

  bool _isHidden = true, isLoading = false;

  final formKey = GlobalKey<FormState>();
  // var isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;

  Future signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN OUT METHOD
  // Future signOut() async {
  //   await _auth.signOut();
  //
  //   print('signout');
  // }

  late String email, password;

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

    signIn(email: email, password: password)
        .then((result) {
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
                          child: Text("Login",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.white))),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Text("or use your account",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white))),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(margin: const EdgeInsets.only(left: 10.0, right: 10.0), child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.left,
                        validator: (input) => input!.isEmpty
                            ? "Enter email!"
                            : null,
                        onSaved: (value) => email = value!,
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
                      ),
                      ),
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
                              "Login",
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
                          child: const Text("Create New Account",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.white))),
                        onTap: () => Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => const SignupPage())),
                      ),
                    ])
            ),
          ),
        )));
  }
}