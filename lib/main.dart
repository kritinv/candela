import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bq_version/Home/HomeScreen.dart';
import 'package:bq_version/SearchScreen.dart';
import 'Completed.dart';
import 'Registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bq_version/UserProfile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

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
        theme: ThemeData(
          primaryColor: Color(0xFFDC143C),
          primaryColorLight: Colors.red[300],
        ),
        home: AuthenticationWrapper(),
        onGenerateRoute: (settings) {
          if (settings.name == "/home")
            return PageRouteBuilder(pageBuilder: (_, __, ___) => HomeScreen());
          else if (settings.name == "/search")
            return PageRouteBuilder(
                pageBuilder: (_, __, ___) => SearchScreen());
          else if (settings.name == "/completed")
            return PageRouteBuilder(pageBuilder: (_, __, ___) => Completed());
          else if (settings.name == "/user")
            return PageRouteBuilder(pageBuilder: (_, __, ___) => UserProfile());
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
    try {
      await _firebaseAuth.signOut();
      return "";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
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
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (authResult.additionalUserInfo.isNewUser) {
        String name = FirebaseAuth.instance.currentUser.displayName;
        String photoURL = FirebaseAuth.instance.currentUser.photoURL;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set({
          "meeting": {},
          "favorite": [],
          "bio": "",
          "headline": "",
          "name": name,
          "photoURL": photoURL,
          "status": "normal",
        });
      }
      print("Added to user");
      return "";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
