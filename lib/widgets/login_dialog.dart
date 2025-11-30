import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:learning_app/Model/product_model.dart';
import 'package:learning_app/auth/firebase_auth.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/bottom_nav_controller.dart';
import 'package:learning_app/getX/loading_controller.dart';
import 'package:learning_app/getX/products_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/auth/sign_up_page.dart';
import 'package:learning_app/widgets/buttons.dart';
import 'package:learning_app/widgets/other_widgets.dart';

enum PendingAction { none, cart, wishlist }

class LoginDialog extends StatefulWidget {
  final Product? productToToggle;
  final PendingAction? pendingAction;
  const LoginDialog(
      {super.key, required this.productToToggle, required this.pendingAction});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _loginGlobalKey = GlobalKey<FormState>();

  String _loginMail = "";
  String _loginPassword = "";

  final TextEditingController _loginMailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  final LoadingController loader = Get.find<LoadingController>();
  final BottomNavController navController = Get.find<BottomNavController>();
  final UserController userController = Get.find<UserController>();

  final AuthServices authServices = AuthServices(); // Mock Service

  bool _isLoginPasswordVisible = false;

  bool _isLoginFormValid = false;

  bool _isLoginMode = true;

  void _updateLoginFormValidity() {
    final isValid = _loginGlobalKey.currentState?.validate() ?? false;
    setState(() {
      _isLoginFormValid = isValid;
    });
  }

  Future<void> _login() async {
    if (_loginGlobalKey.currentState!.validate()) {
      _loginGlobalKey.currentState!.save();

      final ctxt = context; //Storing context before async operation

      loader.showLoading();

      String res = await AuthServices().loginUser(
        email: _loginMailController.text,
        password: _loginPasswordController.text,
      );

      loader.closeLoading();

      if (!ctxt.mounted) return;

      if (res == "success") {
        Fluttertoast.showToast(
          msg: "Welcome back!",
        );
        userController.changeLogStatus(true);
        // 🌟 NEW LOGIC: Check and perform the pending action
        if (widget.pendingAction != PendingAction.none) {
          final productController = Get.find<ProductController>();

          if (widget.pendingAction == PendingAction.cart) {
            // Note: We don't toggle here, we return true to the ProductCard to toggle it.
          } else if (widget.pendingAction == PendingAction.wishlist) {
            // Note: We don't toggle here, we return true to the ProductCard to toggle it.
          }
        }
        // 🌟 Close the dialog and pass the success result (true) back
        Navigator.pop(ctxt, true);
      } else {
        debugPrint("Firebase error: $res");
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
    // navController.resetIndex();
    // 3. Update global user log status
    userController.changeLogStatus(true);
    // 🌟 NEW LOGIC: Check and perform the pending action
    if (widget.pendingAction != PendingAction.none) {
      final productController = Get.find<ProductController>();

      if (widget.pendingAction == PendingAction.cart) {
        // Note: We don't toggle here, we return true to the ProductCard to toggle it.
      } else if (widget.pendingAction == PendingAction.wishlist) {
        // Note: We don't toggle here, we return true to the ProductCard to toggle it.
      }
    }
    // 🌟 Close the dialog and pass the success result (true) back
    Navigator.pop(ctxt, true);
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
      debugPrint("Google Sign-In Error: $res");
      Fluttertoast.showToast(msg: "Some error occured, Try again later", backgroundColor: Colors.red);
    }
  }

  
  final _signUpGlobalKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isFormValid = false;

  String _username = "";
  String _mail = "";
  String _password = "";
  String _confirmPassword = "";

  void _updateFormValidity() {
    final isValid = _signUpGlobalKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid;
    });
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
        userController.changeLogStatus(true);
        // 🌟 NEW LOGIC: Check and perform the pending action
        if (widget.pendingAction != PendingAction.none) {
          final productController = Get.find<ProductController>();

          if (widget.pendingAction == PendingAction.cart) {
            // Note: We don't toggle here, we return true to the ProductCard to toggle it.
          } else if (widget.pendingAction == PendingAction.wishlist) {
            // Note: We don't toggle here, we return true to the ProductCard to toggle it.
          }
        }
        // 🌟 Close the dialog and pass the success result (true) back
        Navigator.pop(ctxt, true);
      } else {
        debugPrint("Firebase error: $res");
        Fluttertoast.showToast(msg: res, backgroundColor: Colors.red);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _loginMailController.dispose();
    _loginPasswordController.dispose();
    _nameController.dispose();
    _mailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(top: 25.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: AppColor.darkBg2,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.8, // Adjust height
      child: _isLoginMode
          ? SingleChildScrollView(
              child: Padding(
                // Ensure padding includes space for the keyboard viewInsets
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
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
                        //   onPressed: () {},
                        //   child: SvgPicture.asset(
                        //     "assets/icons/facebook-icon.svg",
                        //     height: 36.h,
                        //     width: 36.h,
                        //   ),
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Color(0XFF858597),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: _updateLoginFormValidity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 30.h,
                          children: [
                            buildTextField(
                              controller: _loginMailController,
                              label: "Your Email",
                              obscureText: false,
                              inputType: TextInputType.emailAddress,
                              validator: (value) =>
                                  value!.isEmpty ? "Enter a valid email" : null,
                              onSaved: (value) => _loginMail = value!,
                            ),
                            buildTextField(
                              controller: _loginPasswordController,
                              label: "Password",
                              obscureText: !_isLoginPasswordVisible,
                              suffix: Padding(
                                padding: EdgeInsets.only(right: 0.w),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isLoginPasswordVisible =
                                          !_isLoginPasswordVisible;
                                    });
                                  },
                                  child: _isLoginPasswordVisible
                                      ? SvgPicture.asset(
                                          "assets/icons/show-password.svg",
                                          height: 24.h,
                                          width: 24.w,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/view-off.svg",
                                          height: 24.h,
                                          width: 24.w,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        ),
                                ),
                              ),
                              inputType: TextInputType.visiblePassword,
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
                              onSaved: (value) => _loginPassword = value!,
                            ),
                            customTextButton(() {},
                                content: "Forgot Password?",
                                decoration: TextDecoration.underline),
                            customFillButton(() {
                              if (_isLoginFormValid) {
                                _login();
                              } else {}
                            },
                                content: "Log In",
                                bg: _isLoginFormValid
                                    ? AppColor.primaryColor
                                    : AppColor.primaryColor.withAlpha(150))
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
                          setState(() {
                            _isLoginMode = false;
                          });
                        }, content: "Sign up", color: AppColor.primaryColor)
                      ],
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                spacing: 30.h,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Form(
                        key: _signUpGlobalKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: _updateFormValidity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                              inputType: TextInputType.emailAddress,
                              validator: (value) =>
                                  value!.isEmpty ? "Enter a valid email" : null,
                              onSaved: (value) => _loginMail = value!,
                            ),
                            buildTextField(
                              controller: _passwordController,
                              label: "Password",
                              obscureText: !_isPasswordVisible,
                              suffix: Padding(
                                padding: EdgeInsets.only(right: 0.w),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  child: _isPasswordVisible
                                      ? SvgPicture.asset(
                                          "assets/icons/show-password.svg",
                                          height: 24.h,
                                          width: 24.w,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/view-off.svg",
                                          height: 24.h,
                                          width: 24.w,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        ),
                                ),
                              ),
                              inputType: TextInputType.visiblePassword,
                              validator: (value) => value!.length < 6
                                  ? "Password must be at least 6 characters"
                                  : null,
                              onSaved: (value) => _loginPassword = value!,
                            ),
                            buildTextField(
                              controller: _confirmPasswordController,
                              label: "Confirm Password",
                              obscureText: !_isConfirmPasswordVisible,
                              suffix: Padding(
                                padding: EdgeInsets.only(right: 0.w),
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
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/view-off.svg",
                                          height: 24.h,
                                          width: 24.w,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        ),
                                ),
                              ),
                              inputType: TextInputType.visiblePassword,
                              validator: (value) =>
                                  value != _passwordController.text
                                      ? "Passwords do not match"
                                      : null,
                              onSaved: (value) => _confirmPassword = value!,
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
                                  : AppColor.primaryColor.withAlpha(150),
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
                        setState(() {
                          _isLoginMode = true;
                        });
                      }, content: "Log In", color: AppColor.primaryColor)
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
