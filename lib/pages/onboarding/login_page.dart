import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:light_app/rest/AuthService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_control_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    errorMessage = null;

    if (_formKey.currentState.validate()) {
      print('${emailController.text}, ${passwordController.text}');
      var login = await AuthService.login(
          emailController.text, passwordController.text);

      Map resp = jsonDecode(login.body);
      if (login.statusCode == HttpStatus.unauthorized) {
        if (resp.containsKey('message')) {
          errorMessage = resp['message'];
        }
      } else if (login.statusCode == HttpStatus.created) {
        var token = resp['token'];
        var sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('token', token);
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainControlPage()));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 900,
            child: ClipPath(
              clipper: GreenClipper(),
              child: Container(
                color: Color.fromRGBO(129, 199, 132, 1),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 400,
                child: Stack(
                  children: [
                    Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/light-1.png'))),
                        )),
                    Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/light-2.png'))),
                        )),
                    Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/clock.png'))),
                        )),
                    Positioned(
                        child: Container(
                      margin: EdgeInsets.only(top: 50),
                      child: Center(
                          child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      )),
                    )),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 500),
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(129, 199, 132, 0.2),
                                blurRadius: 20,
                                offset: Offset(0, 10))
                          ]),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[100]))),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                controller: emailController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Email',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400])),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              child: TextFormField(
                                onFieldSubmitted: (value) => login(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Password',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400])),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => login(),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                Color.fromRGBO(129, 199, 132, 1.0),
                                Color.fromRGBO(129, 199, 132, 0.6)
                              ])),
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: 30,
                        child: Center(
                            child: errorMessage != null
                                ? Text(errorMessage,
                                    style: TextStyle(
                                        color: Colors.red[300],
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))
                                : Container())),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: Color.fromRGBO(129, 199, 132, 1),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      )),
    );
  }
}

class GreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height / 3.25);
    var firstControlPoint = Offset(size.width / 4, size.height / 2.5);
    var firstEndPoint = Offset(size.width / 2, size.height / 2.5 - 60);
    var secondControlPoint =
        Offset(size.width - (size.width / 4), size.height / 3 - 65);
    var secondEndPoint = Offset(size.width, size.height / 2.5 - 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
