import 'package:flutter/material.dart';
import 'package:bq_version/main.dart';
import 'package:provider/provider.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  Widget body;
  void changeToSignUp() {
    setState(() {
      body = SignUp(changeState: changeToLogin);
    });
  }

  void changeToLogin() {
    setState(() {
      body = SignInMain(changeState: changeToSignUp);
    });
  }

  @override
  void initState() {
    body = SignInMain(changeState: changeToLogin);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: body);
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM SIGN UP PAGE

class SignInMain extends StatefulWidget {
  final Function changeState;
  SignInMain({this.changeState});

  @override
  _SignInMainState createState() => _SignInMainState();
}

class _SignInMainState extends State<SignInMain> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: AssetImage("images/fire.jpg"),
            radius: 80,
          ),
          SizedBox(height: 60),
          Text("Reinventing Consulting", style: TextStyle(fontSize: 20)),
          SizedBox(height: 30),
          SignInButton(
              text: "Sign in with email", onPressed: () {}, icon: Icons.email),
          SizedBox(height: 30),
          SignInButton(
              text: "Sign in with Google",
              onPressed: () async {
                print("yoyoyo");
                await context.read<AuthenticationService>().signInWithGoogle();
              },
              icon: Icons.g_translate),
          SizedBox(height: 30),
          SignInButton(
              text: "Sign in with phone", onPressed: () {}, icon: Icons.phone),
          SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              widget.changeState();
            },
            child: Text.rich(
              TextSpan(text: 'Don\'t have an account', children: [
                TextSpan(
                  text: ' Sign Up',
                  style: TextStyle(color: Color(0xffFF8F00)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM SIGN UP PAGE

class SignUp extends StatefulWidget {
  final Function changeState;
  SignUp({this.changeState});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final Widget inputSpacer = SizedBox(height: 30.0);
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircleAvatar(
        backgroundImage: AssetImage("images/fire.jpg"),
        radius: 80,
      ),
      SizedBox(height: 60.0),
      Input(textState: false, hintText: "First Name", controller: firstName),
      inputSpacer,
      Input(textState: false, hintText: "Last Name", controller: lastName),
      inputSpacer,
      Input(textState: false, hintText: "Email", controller: email),
      inputSpacer,
      Input(textState: true, hintText: "Password", controller: password),
      inputSpacer,
      Container(
        width: double.infinity,
        child: RaisedButton(
            child: Text(' Sign Up'),
            color: Color(0xffFF8F00),
            onPressed: () async {
              // String a = await context.read<AuthenticationService>().signUp(
              //   email: email.text.trim(),
              //   password: password.text.trim(),
              //   firstName: firstName.text.trim(),
              //   lastName: lastName.text.trim(),
              // );
              // setState(() {
              //   errorMessage = a;
              //   errorMessage = a;
              // });
            }),
      ),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Forget password?',
          style: TextStyle(fontSize: 12.0),
        ),
      ),
      SizedBox(height: 20.0),
      GestureDetector(
        onTap: () {
          widget.changeState();
        },
        child: Text.rich(
          TextSpan(text: 'Already have an account', children: [
            TextSpan(
              text: ' Sign In',
              style: TextStyle(color: Color(0xffFF8F00)),
            ),
          ]),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 30),
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.amber[800],
            fontSize: 10,
          ),
        ),
      )
    ]);
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET SIGN IN BUTTONS
class SignInButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final IconData icon;
  SignInButton({this.onPressed, this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      padding: EdgeInsets.symmetric(vertical: 5),
      color: Color(0xFFDC143C),
      width: double.infinity,
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 25),
        title: Text(
          text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// CUSTOM WIDGET TEXT INPUT

class Input extends StatelessWidget {
  final bool textState;
  final String hintText;
  final TextEditingController controller;

  Input({this.textState, this.hintText, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: textState,
        decoration: InputDecoration(
          fillColor: Colors.grey[50],
          filled: true,
          contentPadding: EdgeInsets.all(5.0),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
