import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learning_app/basic/theme_color.dart';

Widget buildTextField({
  required String label,
  required bool obscureText,
  Widget? suffix,
  required TextInputType inputType,
  required Function(String?) onSaved,
  required String? Function(String?) validator,
  String? Function(String?)? onChanged,
  required TextEditingController controller,
}) {
  return TextFormField(
    style: const TextStyle(color: AppColor.primaryText),
    keyboardType: inputType,
    obscureText: obscureText,
    controller: controller,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.only(
        left: 8.w,
        right: 8.w,
      ),
      labelText: label,
      labelStyle: const TextStyle(color: AppColor.secondaryText),
      errorStyle: const TextStyle(
        color: AppColor.primaryColorDark,
      ),
      suffix: suffix,
      // border: const OutlineInputBorder(
      //   borderSide: BorderSide(color: AppColor.primaryColor,
      //   ),

      // ),
      // error: Container(
      //   height: 40.h,
      //   width: 300.w,
      //   color: Colors.red,
      //   child: Text(
      //     "Its an error",
      //     style: TextStyle(
      //       color: Colors.white,
      //       backgroundColor: Colors.black,
      //     ),
      //   )
      // ),
    ),
    onChanged: onChanged,
    validator: validator,
    onSaved: onSaved,
  );
}

Widget customFormField(
  variable,
  String label,
) {
  return TextFormField(
    style: const TextStyle(color: AppColor.primaryText),
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
        errorStyle: const TextStyle(color: AppColor.primaryColorDark),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.primaryColor)),
        label: Text(
          label,
          style: const TextStyle(color: AppColor.secondaryText),
        )),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "You must Enter a name";
      }
      return null;
    },
    onSaved: (value) {
      variable = value!;
    },
  );
}

class CustomTextField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final bool obscure;
  final Color color = AppColor.primaryColor;
  final String? validator;
  final Widget? suffix;

  const CustomTextField({
    super.key,
    this.text = "Text",
    required this.controller,
    this.obscure = false,
    required this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.primaryColor)),
          errorStyle: const TextStyle(color: AppColor.primaryColorDark),
          label: Text(
            text,
            style: const TextStyle(color: AppColor.secondaryText),
          ),
          suffix: suffix),
    );
  }
}

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        backgroundColor: AppColor.darkBg1,
        valueColor: AlwaysStoppedAnimation(AppColor.primaryColor),
      ),
    );
  }
}

Widget iconWithBgColor({
  double w = 24,
  double h = 24,
  String iconPath = "assets/icons/home_icon.svg",
  Color color = AppColor.primaryColorDark,
  Color bg = Colors.transparent,
}) {
  return Container(
    padding: EdgeInsets.all(6),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.all(Radius.circular(8.r))),
    child: SvgPicture.asset(
      iconPath,
      width: w,
      height: h,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    ),
  );
}
