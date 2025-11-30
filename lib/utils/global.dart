import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/auth/sign_up_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class FirstTime extends GetxController{
  RxBool isFirstTime = true.obs;
  RxBool isGuestUser = false.obs;

  @override
  void onInit(){
    super.onInit();
    _loadFirstTime();
    _loadGuestLog();
  }

  void _loadFirstTime()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime.value = prefs.getBool("isFirstTime") ?? true;
  }

  void notAFirstTime()async{
    isFirstTime.value = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  void _loadGuestLog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isGuestUser.value = prefs.getBool("isGuestUser") ?? false;
  }

  void toggleGuestLog(bool value) async {
    isGuestUser.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuestUser', value);
  }
}

// class UserController extends GetxController{
//   RxString userName = "".obs;

//   void changeName()async{

//   }
//   getUser()async{
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   // var jsonValue = prefs.getString("");
//   String jsonValue = jsonEncode({
//     "name" : "pradeep",
//     "age" : 12
//   });
//   var loginData = jsonDecode(jsonValue);
//   var userProfile = UserProfile(name: loginData["name"]);
//   return userProfile;
// }
// }