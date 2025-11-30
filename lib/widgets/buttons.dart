import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learning_app/basic/theme_color.dart';

Widget skipButton(int index, PageController controller){
  return TextButton(
          onPressed: (){
            if (index < 2){
              controller.animateToPage(index+1, duration: const Duration(milliseconds: 300), curve: Curves.easeInBack);
            }
          }, 
          child: Text("Skip", 
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColor.secondaryText
          ),
          )
          );
}

Widget customFillButton(
  final VoidCallback func,
  {
  String content = "content",
  Color textColor = AppColor.primaryText,
  double textSize = 17,
  Color bg = AppColor.primaryColor,
  Color fg = AppColor.primaryText,
}){
  return FilledButton(
          onPressed: func, 
          style: FilledButton.styleFrom(
            fixedSize: Size(314.w, 50.h),
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.circular(30.r)
            )
          ),
          child: Text(
            content, 
          style: TextStyle(
            color: textColor,
            fontSize: textSize.sp
          ),
          )
          );
}

Widget customTextButton (
  final VoidCallback func,
  {
  String content = "content",
  int textSize = 14,
  Color color = AppColor.primaryText,
  TextDecoration decoration = TextDecoration.none, 
}){
  return TextButton
          (onPressed: func, 
          child: Text(content,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: textSize.sp,
            decoration: decoration
          ),
          ));
}