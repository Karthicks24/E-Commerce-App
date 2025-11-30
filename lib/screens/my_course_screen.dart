import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_app/basic/theme_color.dart';

class MyCourseScreen extends StatelessWidget {
  const MyCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBg2,
        appBar: AppBar(
          backgroundColor: AppColor.darkBg1,
          title: Text(
            "My Course Screen", 
            style: TextStyle(
              color: AppColor.primaryText,
              fontSize: 20.sp
            ),),
        ),
    );
  }
}