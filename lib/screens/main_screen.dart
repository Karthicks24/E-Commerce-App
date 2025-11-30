import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/bottom_nav_controller.dart';
import 'package:learning_app/screens/cart_screen.dart';
import 'package:learning_app/screens/home_screen.dart';
import 'package:learning_app/screens/my_course_screen.dart';
import 'package:learning_app/screens/search_screen.dart';
import 'package:learning_app/screens/user_screen.dart';
import 'package:learning_app/widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final navController = Get.find<BottomNavController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.darkBg2,
        // appBar: AppBar(
        //   backgroundColor: AppColor.darkBg1,
        //   title: Text(
        //     "Home Screen", 
        //     style: TextStyle(
        //       color: AppColor.primaryText,
        //       fontSize: 20.sp
        //     ),),
        // ),
        bottomNavigationBar: CustomBottomNavBar(),
        body: Obx(()=>
        (_pages[navController.currentIndex.value])
      )
      );
  }
}

List _pages = [
  HomeScreen(),
  SearchScreen(),
  const CartScreen(),
  UserScreen(),
];