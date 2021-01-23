import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bq_version/HomeScreen.dart';
import 'package:bq_version/SearchScreen.dart';
import 'NotificationsScreen.dart';
import 'Registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

String currentUser = 'lJExmrgxK61D5dV9aPaf';

////////////////////////////////////////////////////////////////////////////////

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance)),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
        )
      ],
      child: MaterialApp(
        home: AuthenticationWrapper(),
        onGenerateRoute: (settings) {
          if (settings.name == "/home")
            return PageRouteBuilder(pageBuilder: (_, __, ___) => HomeScreen());
          else if (settings.name == "/search")
            return PageRouteBuilder(
                pageBuilder: (_, __, ___) => SearchScreen());
          else if (settings.name == "/notifications")
            return PageRouteBuilder(
                pageBuilder: (_, __, ___) => NotificationsScreen());
          else if (settings.name == "/completed")
            return PageRouteBuilder(
                pageBuilder: (_, __, ___) => SearchScreen());
          else if (settings.name == "/user")
            return PageRouteBuilder(
                pageBuilder: (_, __, ___) => SearchScreen());
          return null;
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// Authentication Stuff

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if (firebaseUser != null) {
      return HomeScreen();
    } else {
      return Registration();
    }
  }
}

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);
  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> signUp(
      {String email,
      String password,
      String firstName,
      String lastName}) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {});
      print("asdf");
      return "";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      print("Authentication flow triggered");

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print("Authentication detail requested");

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("New Credential Created");

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      return "";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
