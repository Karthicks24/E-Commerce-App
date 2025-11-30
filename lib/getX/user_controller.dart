import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController extends GetxController {
  var userName = "Guest User".obs;
  var userEmail = "".obs;
  var isLoggedIn = false.obs;
  var noPassword = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen for login/logout changes
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        isLoggedIn.value = true;
        await fetchUser(user.uid);
      } else {
        isLoggedIn.value = false;
        userName.value = "Guest User";
        userEmail.value = "";
        noPassword.value = false;
      }
    });
  }

  // Future<void> fetchUser(String uid) async {
  //   final doc =
  //       await FirebaseFirestore.instance.collection("users").doc(uid).get();
  //   if (doc.exists) {
  //     userName.value = doc["name"] ?? "No Name";
  //     userEmail.value = doc["email"] ?? "";
  //   }
  // }

  Future<void> fetchUser(String uid) async {
    debugPrint("Fetching user for UID: $uid");

    try {
      final doc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      debugPrint("Firestore document exists? ${doc.exists}");
      debugPrint("Document data: ${doc.data()}");

      if (doc.exists) {
        userName.value = doc["name"] ?? "No Name";
        userEmail.value = doc["email"] ?? "";
        noPassword.value = doc["password"] == "password" ? true : false;
        debugPrint("Updated username to: ${userName.value}");
      }
    } catch (e) {
      debugPrint("No user document found! $e");
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      // Update Firebase Auth password
      await user.updatePassword(password);

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "password": password,
      });

      // Update UI state
      noPassword.value = false;
      Fluttertoast.showToast(
          msg: "Password updated successfully!",
        );
      Get.snackbar("Success", "Password updated successfully!");
    } catch (e) {
      // Get.snackbar("Error", e.toString());
      Fluttertoast.showToast(msg: "Some error occured, try again later", backgroundColor: Colors.red);
    }
  }


  void changeLogStatus(bool value) {
    isLoggedIn.value = value;
  }
}
