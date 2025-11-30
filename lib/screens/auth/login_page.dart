import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:learning_app/auth/firebase_auth.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/bottom_nav_controller.dart';
import 'package:learning_app/getX/loading_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/auth/sign_up_page.dart';
import 'package:learning_app/screens/main_screen.dart';
import 'package:learning_app/utils/global.dart';
import 'package:learning_app/widgets/buttons.dart';
import 'package:learning_app/widgets/other_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginGlobalKey = GlobalKey<FormState>();

  final LoadingController loader = Get.find<LoadingController>();

  String _mail = "";
  String _password = "";

  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  bool _isFormValid = false;
  final BottomNavController navController = Get.find<BottomNavController>();
  final UserController userController = Get.find<UserController>();
  final FirstTime firstimeController = Get.find<FirstTime>();

  final AuthServices authServices = AuthServices(); // Mock Service

  void _updateFormValidity() {
    final isValid = _loginGlobalKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mailController.dispose();
    _passwordController.dispose();
  }

  Future<void> _login() async {
    if (_loginGlobalKey.currentState!.validate()) {
      _loginGlobalKey.currentState!.save();

      final ctxt = context; //Storing context before async operation

      loader.showLoading();

      String res = await AuthServices().loginUser(
        email: _mailController.text,
        password: _passwordController.text,
      );

      loader.closeLoading();

      if (!ctxt.mounted) return;

      if (res == "success") {
        Fluttertoast.showToast(
          msg: "Welcome back!",
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

  void _handleSuccessfulLogin(BuildContext ctxt) {
    // 1. Show Success Message
    Fluttertoast.showToast(
      msg: "Welcome back!",
    );
    // 2. Reset navigation state (if using a persistent bottom bar)
    navController.resetIndex();
    // 3. Update global user log status
    userController.changeLogStatus(true);
    // 4. Navigate to the main screen, clearing the login history
    Navigator.of(ctxt).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false, // remove all previous routes
    );
  }

  Future<void> _signInWithGoogle() async {
    final ctxt = context;

    loader.showLoading();

    // Call the Auth Service (using the new method from the previous response)
    String res = await authServices.signInWithGoogle();

    loader.closeLoading();

    if (!ctxt.mounted) return;

    // if (res == "success") {
    if (res != "Some error occurred" &&
        res != "Google sign-in cancelled by user." &&
        res != "Missing ID token!") {
      final uid = res;
      await userController.fetchUser(uid);
      _handleSuccessfulLogin(ctxt); // Use unified handler
    } else {
      print("Google Sign-In Error: $res");
      Fluttertoast.showToast(
          msg: "$res, Try again later", backgroundColor: Colors.red);
    }
  }

  Future<void> _signInWithFacebook() async {
    final ctxt = context;

    loader.showLoading();

    // Call the Auth Service (using the new method from the previous response)
    String res = await authServices.signInWithFacebook();

    loader.closeLoading();

    if (!ctxt.mounted) return;

    // if (res == "success") {
    if (res != "Some error occurred" &&
        res != "Google sign-in cancelled by user." &&
        res != "Missing ID token!") {
      final uid = res;
      await userController.fetchUser(uid);
      _handleSuccessfulLogin(ctxt); // Use unified handler
    } else {
      debugPrint("Facebook Sign-In Error: $res");
      Fluttertoast.showToast(msg: res, backgroundColor: Colors.red);
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
                              "Log In",
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
                                  child: Text(
                                    "Welcome back! Sign in using your social\naccount or email to continue us",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColor.secondaryText,
                                    ),
                                  ),
                                ),
                                Row(
                                  spacing: 40.w,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: _signInWithGoogle,
                                      child: SvgPicture.asset(
                                        "assets/icons/google-icon.svg",
                                        height: 36.h,
                                        width: 36.h,
                                      ),
                                    ),
                                    // TextButton(
                                    //   onPressed: _signInWithFacebook,
                                    //   child: SvgPicture.asset(
                                    //     "assets/icons/facebook-icon.svg",
                                    //     height: 36.h,
                                    //     width: 36.h,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0XFF858597),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.w),
                                      child: Text(
                                        "Or login with",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColor.secondaryText,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0XFF858597),
                                      ),
                                    )
                                  ],
                                ),
                                Form(
                                    key: _loginGlobalKey,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onChanged: _updateFormValidity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      spacing: 30.h,
                                      children: [
                                        buildTextField(
                                          controller: _mailController,
                                          label: "Your Email",
                                          obscureText: false,
                                          inputType: TextInputType.emailAddress,
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
                                                              BlendMode.srcIn),
                                                    )
                                                  : SvgPicture.asset(
                                                      "assets/icons/view-off.svg",
                                                      height: 24.h,
                                                      width: 24.w,
                                                      colorFilter:
                                                          const ColorFilter
                                                              .mode(
                                                              Colors.white,
                                                              BlendMode.srcIn),
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
                                            if (RegExp(r"\s").hasMatch(value)) {
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
                                        customTextButton(() {},
                                            content: "Forgot Password?",
                                            decoration:
                                                TextDecoration.underline),
                                        customFillButton(() {
                                          if (_isFormValid) {
                                            _login();
                                          } else {}
                                        },
                                            content: "Log In",
                                            bg: _isFormValid
                                                ? AppColor.primaryColor
                                                : AppColor.primaryColor
                                                    .withAlpha(150))
                                      ],
                                    )),
                                Row(
                                  // spacing: 40.w,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColor.secondaryText,
                                      ),
                                    ),
                                    customTextButton(() {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  const SignUpPage()));
                                    },
                                        content: "Sign up",
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
