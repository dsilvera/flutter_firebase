import 'package:flutter/material.dart';
import 'package:flutter_firebase/common/constants.dart';
import 'package:flutter_firebase/common/loading.dart';
import 'package:flutter_firebase/services/authentication.dart';

class AuthenticateScreen extends StatefulWidget {
  @override
  _AuthenticateScreenState createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  final AuthenticationService _auth = AuthenticationService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  bool showSignIn = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleView() {
    setState(() {
      _formKey.currentState?.reset();
      error = '';
      emailController.text = '';
      nameController.text = '';
      passwordController.text = '';
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.blueGrey,
              elevation: 0.0,
              title: Text(showSignIn ? 'Sign in to Water Social' : 'Register to Water Social'),
              actions: <Widget>[
                TextButton.icon(
                  icon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  label: Text(showSignIn ? "Register" : 'Sign In',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => toggleView(),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    !showSignIn
                        ? TextFormField(
                            controller: nameController,
                            decoration: textInputDecoration.copyWith(hintText: 'name'),
                            validator: (value) =>
                                value == null || value.isEmpty ? "Enter a name" : null,
                          )
                        : Container(),
                    !showSignIn ? SizedBox(height: 10.0) : Container(),
                    TextFormField(
                      controller: emailController,
                      decoration: textInputDecoration.copyWith(hintText: 'email'),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter an email" : null,
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: passwordController,
                      decoration: textInputDecoration.copyWith(hintText: 'password'),
                      obscureText: true,
                      validator: (value) => value != null && value.length < 6
                          ? "Enter a password with at least 6 characters"
                          : null,
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      child: Text(
                        showSignIn ? "Sign In" : "Register",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() == true) {
                          setState(() => loading = true);
                          var password = passwordController.value.text;
                          var email = emailController.value.text;
                          var name = nameController.value.text;

                          dynamic result = showSignIn
                              ? await _auth.signInWithEmailAndPassword(email, password)
                              : await _auth.registerWithEmailAndPassword(name, email, password);
                          if (result == null) {
                            setState(() {
                              loading = false;
                              error = 'Please supply a valid email';
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 15.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
