import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:learning_app/auth/firebase_auth.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/bottom_nav_controller.dart';
import 'package:learning_app/getX/loading_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/main_screen.dart';
import 'package:learning_app/utils/global.dart';
import 'package:learning_app/widgets/buttons.dart';
import 'package:learning_app/widgets/other_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _signUpGlobalKey = GlobalKey<FormState>();

  final LoadingController loader = Get.find<LoadingController>();

  String _username = "";
  String _mail = "";
  String _password = "";
  String _confirmPassword = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isFormValid = false;

  final navController = Get.find<BottomNavController>();
  final userController = Get.find<UserController>();
  final FirstTime firstimeController = Get.find<FirstTime>();

  void _updateFormValidity() {
    final isValid = _signUpGlobalKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _mailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  Future<void> _signUp() async {
    if (_signUpGlobalKey.currentState!.validate()) {
      _signUpGlobalKey.currentState!.save();

      final ctxt = context;

      loader.showLoading();

      String res = await AuthServices().signUpUser(
          email: _mailController.text,
          password: _passwordController.text,
          name: _nameController.text);

      loader.closeLoading();

      if (!ctxt.mounted) return;

      if (res == "success") {
        Fluttertoast.showToast(
          msg: "Account created successfully!",
        );
        navController.resetIndex();
        userController.changeLogStatus(true);
        Navigator.of(ctxt).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false, //this remove all previous routes
        );
      } else {
        print("Firebase error: $res");
        Fluttertoast.showToast(msg: res, backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColor.darkBg1,
        body: Obx(
          () => loader.isLoading.value
              ? const CustomLoader()
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 42.h),
                      Padding(
                        padding: EdgeInsets.only(left: 24.w, right: 12.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                color: AppColor.primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 32.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                navController.resetIndex();
                                firstimeController.toggleGuestLog(true);
                                Get.offAll(
                                    () => const MainScreen()); // Guest mode
                              },
                              child: const Text("Skip for now"),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 25.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 0.h),
                          decoration: BoxDecoration(
                            color: AppColor.darkBg2,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              spacing: 30.h,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Form(
                                      key: _signUpGlobalKey,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      onChanged: _updateFormValidity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        spacing: 30.h,
                                        children: [
                                          buildTextField(
                                              controller: _nameController,
                                              label: "Your name",
                                              obscureText: false,
                                              inputType: TextInputType.name,
                                              onSaved: (val) {
                                                _username = val!;
                                              },
                                              validator: (val) {
                                                return val!.isEmpty
                                                    ? "Enter your name"
                                                    : null;
                                              }),
                                          buildTextField(
                                            controller: _mailController,
                                            label: "Your Email",
                                            obscureText: false,
                                            inputType:
                                                TextInputType.emailAddress,
                                            validator: (value) => value!.isEmpty
                                                ? "Enter a valid email"
                                                : null,
                                            onSaved: (value) => _mail = value!,
                                          ),
                                          buildTextField(
                                            controller: _passwordController,
                                            label: "Password",
                                            obscureText: !_isPasswordVisible,
                                            suffix: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 0.w),
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible;
                                                  });
                                                },
                                                child: _isPasswordVisible
                                                    ? SvgPicture.asset(
                                                        "assets/icons/show-password.svg",
                                                        height: 24.h,
                                                        width: 24.w,
                                                        colorFilter:
                                                            const ColorFilter
                                                                .mode(
                                                                Colors.white,
                                                                BlendMode
                                                                    .srcIn),
                                                      )
                                                    : SvgPicture.asset(
                                                        "assets/icons/view-off.svg",
                                                        height: 24.h,
                                                        width: 24.w,
                                                        colorFilter:
                                                            const ColorFilter
                                                                .mode(
                                                                Colors.white,
                                                                BlendMode
                                                                    .srcIn),
                                                      ),
                                              ),
                                            ),
                                            inputType:
                                                TextInputType.visiblePassword,
                                            validator: (value) {
                                              if (value == null) {
                                                return "Enter some text";
                                              }
                                              if (value.isEmpty) {
                                                return "Enter some text";
                                              }
                                              if (RegExp(r"\s")
                                                  .hasMatch(value)) {
                                                return "Password cannot contain spaces";
                                              }
                                              if (value.length < 6) {
                                                return "Password must be at least 6 characters";
                                              }
                                              return null;
                                            },
                                            onSaved: (value) =>
                                                _password = value!,
                                          ),
                                          buildTextField(
                                            controller:
                                                _confirmPasswordController,
                                            label: "Confirm Password",
                                            obscureText:
                                                !_isConfirmPasswordVisible,
                                            suffix: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 0.w),
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isConfirmPasswordVisible =
                                                        !_isConfirmPasswordVisible;
                                                  });
                                                },
                                                child: _isConfirmPasswordVisible
                                                    ? SvgPicture.asset(
                                                        "assets/icons/show-password.svg",
                                                        height: 24.h,
                                                        width: 24.w,
                                                        colorFilter:
                                                            const ColorFilter
                                                                .mode(
                                                                Colors.white,
                                                                BlendMode
                                                                    .srcIn),
                                                      )
                                                    : SvgPicture.asset(
                                                        "assets/icons/view-off.svg",
                                                        height: 24.h,
                                                        width: 24.w,
                                                        colorFilter:
                                                            const ColorFilter
                                                                .mode(
                                                                Colors.white,
                                                                BlendMode
                                                                    .srcIn),
                                                      ),
                                              ),
                                            ),
                                            inputType:
                                                TextInputType.visiblePassword,
                                            validator: (value) {
                                              if (value == null) {
                                                return "Enter some text";
                                              }
                                              if (value.isEmpty) {
                                                return "Enter some text";
                                              }
                                              if (value.trim().contains(' ')) {
                                                return 'Password cannot contain space';
                                              }
                                              if (value.length < 6) {
                                                return "Password must be at least 6 characters";
                                              }
                                              return null;
                                            },
                                            onSaved: (value) =>
                                                _confirmPassword = value!,
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          customFillButton(
                                            _isFormValid
                                                ? () {
                                                    _signUp();
                                                  }
                                                : () {},
                                            content: "Create account",
                                            bg: _isFormValid
                                                ? AppColor.primaryColor
                                                : AppColor.primaryColor
                                                    .withAlpha(150),
                                          )
                                        ],
                                      )),
                                ),
                                Row(
                                  // spacing: 40.w,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColor.secondaryText,
                                      ),
                                    ),
                                    customTextButton(() {
                                      Navigator.pop(context);
                                    },
                                        content: "Log In",
                                        color: AppColor.primaryColor)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
