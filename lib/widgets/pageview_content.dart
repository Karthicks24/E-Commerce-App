import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/screens/auth/login_page.dart';
import 'package:learning_app/utils/global.dart';
import 'package:learning_app/widgets/buttons.dart';

Widget onboarding(
  PageController controller,
  BuildContext context,
  {
  String imagepath = "assets/images/onboard-1.png",
  String boldText = "title",
  String normalText = "text",
  int index = 0,
}){
  return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              SizedBox(height: 68.h,),
              Image.asset(
                imagepath, 
                width: 260.w,
                height: 260.h,),
                SizedBox(height: 38.h,),
                Text(boldText,
                textAlign: TextAlign.center, 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                  color: AppColor.primaryText
                ),),
                SizedBox(height: 18.h,),
                Text(normalText, 
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColor.primaryText,
                ),
                ),
                const Spacer(),
                // SizedBox(height: 20.h,),
                if (index == 2)
                  customFillButton(
                    (){
                      final FirstTime globalController = Get.find<FirstTime>();
                      globalController.notAFirstTime();
                      Navigator.pushReplacement(context, 
                      MaterialPageRoute(builder: (BuildContext context)=>const LoginPage()));
                    },
                    content: "Get Started",
                    textColor: AppColor.primaryText,
                    bg: AppColor.primaryColor,
                    fg: AppColor.primaryText,
                    ),
                SizedBox(height: 10.h,)
          ],
        ),
    
        if (index < 2)
          Positioned(
            top: 72.h,
            right: 23.w,
            child: 
                // skipButton(index, controller),
                TextButton(
                onPressed: (){
                  if (index < 2){
                    controller.animateToPage(2, 
                    duration: const Duration(milliseconds: 300), 
                    curve: Curves.linear);
                  }
                }, 
                child: Text("Skip",
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.secondaryText
                ),
                )
                ),)
      ],
    );
}

class OnboardingWidget extends StatelessWidget {
  final PageController controller;
  final String imagepath;
  final String boldText;
  final String normalText;
  final int index;

  const OnboardingWidget({
    super.key, 
    required this.controller, 
    this.imagepath = "assets/images/onboard-1.png", 
    this.boldText = "title", 
    this.normalText = "text", 
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              SizedBox(height: 68.h,),
              Image.asset(
                imagepath, 
                width: 260.w,
                height: 260.h,),
                SizedBox(height: 38.h,),
                Text(boldText,
                textAlign: TextAlign.center, 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                  color: AppColor.primaryText
                ),),
                SizedBox(height: 18.h,),
                Text(normalText, 
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColor.primaryText,
                ),
                ),
                const Spacer(),
                // SizedBox(height: 20.h,),
                if (index == 2)
                  customFillButton(
                    (){
                      final FirstTime globalController = Get.find<FirstTime>();
                      globalController.notAFirstTime();
                      Navigator.pushReplacement(context, 
                      MaterialPageRoute(builder: (BuildContext context)=>const LoginPage()));
                    },
                    content: "Get Started",
                    textColor: AppColor.primaryText,
                    bg: AppColor.primaryColor,
                    fg: AppColor.primaryText,
                    ),
                SizedBox(height: 10.h,)
          ],
        ),
    
        if (index < 2)
          Positioned(
            top: 30.h,
            right: 15,
            child: 
                // skipButton(index, controller),
                TextButton(
                onPressed: (){
                  if (index < 2){
                    controller.animateToPage(2, 
                    duration: const Duration(milliseconds: 300), 
                    curve: Curves.linear);
                  }
                }, 
                child: Text("Skip",
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.secondaryText
                ),
                )
                ),)
      ],
    );
  }
}