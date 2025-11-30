import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learning_app/auth/sign_up_details.dart';
import 'package:learning_app/getX/loading_controller.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  //loader
  final LoadingController loader = Get.find<LoadingController>();

  //for storing data in cloud firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //for authentication
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool isInitialized = false;

  // 1. Initialize Google Sign-In
  // -------------------------------
  static Future<void> initSignIn() async {
    if (!isInitialized) {
      await _googleSignIn.initialize(
        // serverClientId:
        //     // '484988555302-d91nev5jn5sit0qoe3oehpgpp58pl5mt.apps.googleusercontent.com',
        //     // '1004409688457-iutmhtgu2gofi3oauhkesdkqkltg3e76.apps.googleusercontent.com',
        //     '1004409688457-m464ekq3balrclv34p36iniqqmu18o9t.apps.googleusercontent.com'
        // serverClientId:
        //     "1004409688457-m464ekq3balrclv34p36iniqqmu18o9t.apps.googleusercontent.com",
        // scopes: ['email', 'profile'],
      );
      isInitialized = true;
    }
  }

  //for Signup
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    loader.showLoading(); //show loading
    String res = "Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        //for registration with email and password
        UserCredential credential = await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);

        //for storing user to our cloud firestore
        await _firestore.collection("users").doc(credential.user!.uid).set({
          "name": name,
          "email": email,
          "password": password,
          "uid": credential.user!.uid
        });

        res = "success";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
            msg: "This password is too weak", backgroundColor: Colors.red);
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "This email address has already been registered",
            backgroundColor: Colors.red);
      } else if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
            msg: "User not found", backgroundColor: Colors.red);
      }
    } catch (e) {
      res = e.toString();
    }
    loader.closeLoading(); //close loading
    return res;
  }

  //login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    loader.showLoading();
    String res = "Some error occurred";

    try {
      if (email.isEmpty || password.isEmpty) {
        loader.closeLoading();
        return "Please enter all fields";
      }

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      var user = credential.user;

      if (user != null) {
        String? photoUrl = user.photoURL;
        String? displayName = user.displayName;
        String? mail = user.email;
        String? id = user.uid;

        LoginRequest loginRequest = LoginRequest();

        loginRequest.avatar = photoUrl;
        loginRequest.name = displayName;
        loginRequest.email = mail;
        loginRequest.openId = id;
        loginRequest.type = 1;
      }

      // if(credential.user!.emailVerified){
      //   Fluttertoast.showToast(msg: "You must verify your mail first!");
      //     return
      // }

      // if (credential.user==null){
      //   Fluttertoast.showToast(msg: "User not found");
      //     return
      // } else{
      loader.closeLoading();
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == "wrong-password") {
        Fluttertoast.showToast(msg: "Wrong Password");
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  // Future<String> signInWithGoogle() async {
  //   loader.showLoading();
  //   String res = "Some error occurred";

  //   try {
  //     await initSignIn();
  //     // 1. Trigger the Google sign-in flow
  //     final googleUser = await _googleSignIn.authenticate();

  //     if (googleUser == null) {
  //       // User cancelled the sign-in process
  //       // throw FirebaseAuthException(code: "cancelled");
  //       return "Google sign-in cancelled by user.";
  //     }

  //     final authClient = googleUser.authorizationClient;

  //     // 2. Obtain the authentication details from the request
  //     GoogleSignInClientAuthorization? authorization =
  //         await authClient.authorizationForScopes(["email", "profile"]);

  //     // If no token, request again
  //     if (authorization?.accessToken == null) {
  //       authorization =
  //           await authClient.authorizationForScopes(["email", "profile"]);
  //     }

  //     final idToken = googleUser.authentication.idToken;
  //     final accessToken = authorization?.accessToken;

  //     if (idToken == null || accessToken == null) {
  //       // throw FirebaseAuthException(
  //       //   code: "token_error",
  //       //   message: "Failed to retrieve Google tokens",
  //       // );
  //       return "Missing ID token!";
  //     }

  //     // 3. Create a new credential with the ID token
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: accessToken,
  //       idToken: idToken,
  //     );

  //     // 4. Sign in to Firebase with the credential
  //     final UserCredential userCredential =
  //         await _firebaseAuth.signInWithCredential(credential);
  //     final User? user = userCredential.user;

  //     if (user != null) {
  //       // 5. Check if user data exists in Firestore, or create it
  //       final userDoc =
  //           await _firestore.collection("users").doc(user.uid).get();

  //       if (!userDoc.exists) {
  //         // If this is a new social user, save initial data
  //         await _firestore.collection("users").doc(user.uid).set({
  //           "name": user.displayName,
  //           "email": user.email,
  //           "uid": user.uid,
  //           "loginType": "google",
  //         });
  //       }

  //       // 6. Success and State Update
  //       // loader.setLoggedIn(true);
  //       // userController.changeLogStatus(true);
  //       res = "success";
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     // This catches Firebase-specific errors (e.g., provider not enabled)
  //     res = e.message ?? "Google sign-in failed (Firebase Error).";
  //   } catch (e) {
  //     // This catches platform-specific errors (e.g., connectivity issues)
  //     res = "Google Sign-In Failed: ${e.toString()}";
  //   }

  //   loader.closeLoading();
  //   return res;
  // }

Future<String> signInWithGoogle() async {
  loader.showLoading();
  String res = "Some error occurred";

  print("STEP 1: Initializing Google Sign-In...");
  try {
    await initSignIn();
    print("STEP 2: Calling authenticate()...");

    final googleUser = await _googleSignIn.authenticate();
    print("STEP 3: authenticate() completed, result: $googleUser");

    if (googleUser == null) {
      print("STEP 4: User cancelled");
      return "Google sign-in cancelled by user.";
    }

    print("STEP 5: Getting authorizationClient");
    final authClient = googleUser.authorizationClient;

    print("STEP 6: Requesting authorization...");
    GoogleSignInClientAuthorization? authorization =
        await authClient.authorizationForScopes(["email", "profile"]);

    print("STEP 7: Authorization result: ${authorization?.accessToken}");

    if (authorization?.accessToken == null) {
      print("STEP 7b: Retrying authorization...");
      authorization =
          await authClient.authorizationForScopes(["email", "profile"]);
      print("STEP 7c: Retry result: ${authorization?.accessToken}");
    }

    print("STEP 8: Getting ID token...");
    final idToken = googleUser.authentication.idToken;
    final accessToken = authorization?.accessToken;

    print("STEP 9: idToken=$idToken, accessToken=$accessToken");

    if (idToken == null || accessToken == null) {
      print("STEP 10: Tokens missing");
      return "Missing ID token!";
    }

    print("STEP 11: Creating credential...");
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    print("STEP 12: Signing in to Firebase...");
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    print("STEP 13: Firebase sign-in complete.");

    final User? user = userCredential.user;

    if (user != null) {
      print("STEP 14: Checking Firestore...");
      final userDoc =
          await _firestore.collection("users").doc(user.uid).get();

      if (!userDoc.exists) {
        print("STEP 15: Creating new Firestore user...");
        await _firestore.collection("users").doc(user.uid).set({
          "name": user.displayName,
          "email": user.email,
          "uid": user.uid,
          "password": "password",
        });
      }

      print("STEP 16: SUCCESS");
      // res = "success";
      res = user.uid;
    }

  } catch (e, stack) {
    print("🔥 ERROR OCCURRED");
    print(e);
    print(stack);
    res = "Google Sign-In Failed: $e";
  }

  loader.closeLoading();
  return res;
}


  Future<String> signInWithFacebook() async {
    loader.showLoading();
    String res = "Some error occurred";

    try {
      // 1. Trigger Facebook Sign-In process (MOCKING platform specific step)
      // ⚠️ In a real app, this uses flutter_facebook_auth:
      // final LoginResult result = await FacebookAuth.instance.login();
      // final AccessToken? accessToken = result.accessToken;

      // MOCKING successful platform login and credential creation
      await Future.delayed(const Duration(seconds: 1));
      const String mockToken = 'mock_facebook_token';
      const String mockName = 'Mock Facebook User';

      // 2. Create a Firebase credential
      final AuthCredential credential =
          FacebookAuthProvider.credential(mockToken);

      // 3. Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 4. Check if user data exists in Firestore, or create it
        final userDoc =
            await _firestore.collection("users").doc(user.uid).get();

        if (!userDoc.exists) {
          // If this is a new social user, save initial data
          await _firestore.collection("users").doc(user.uid).set({
            "name": user.displayName ?? mockName,
            "email":
                user.email, // May be null if not requested in Facebook scope
            "uid": user.uid,
            "loginType": "facebook",
          });
        }

        // 5. Success and State Update
        // loader.setLoggedIn(true);
        res = "success";
      }
    } on FirebaseAuthException catch (e) {
      res = e.message ?? "Facebook sign-in failed.";
    } catch (e) {
      // e.g., error during FacebookAuth.instance.login() or cancelled by user
      res = "Facebook sign-in cancelled or failed: ${e.toString()}";
    }

    loader.closeLoading();
    return res;
  }

  Future signOutUser() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
    // await _firebaseAuth.signOut();
  }
}
