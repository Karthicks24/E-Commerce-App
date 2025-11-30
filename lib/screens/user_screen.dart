import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:learning_app/auth/firebase_auth.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/auth/login_page.dart';
import 'package:learning_app/utils/global.dart';
import 'package:learning_app/widgets/buttons.dart';
import 'package:learning_app/widgets/other_widgets.dart';
import 'package:learning_app/widgets/texts.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirstTime firstimeController = Get.find<FirstTime>();

  final userController = Get.find<UserController>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _changePasswordGlobalKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFormValid = false;

  String _password = "";
  String _confirmPassword = "";

  void _updateFormValidity() {
    final isValid = _changePasswordGlobalKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBg2,
      appBar: AppBar(
        backgroundColor: AppColor.darkBg1,
        title: const CustomAutoSizeText2(
          text: "My Profile",
          lightTextColor: AppColor.primaryText,
          fontSize: 20,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Obx(() {
                if (userController.noPassword.value) {
                  return Form(
                    key: _changePasswordGlobalKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: _updateFormValidity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomAutoSizeText2(
                          text:
                              "Update your password to log in from other devices",
                          maxLines: 3,
                          lightTextColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
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
                          validator: (value) {
                            if (value == null) {
                              return "Enter some password";
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
                          onSaved: (value) => _password = value!,
                        ),
                        const SizedBox(height: 20),
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
                          onSaved: (value) => _confirmPassword = value!,
                        ),
                        const SizedBox(height: 40),
                        customFillButton(
                          _isFormValid
                              ? () {
                                  if (_passwordController.text.trim() ==
                                      _confirmPasswordController.text.trim()) {
                                    userController.updatePassword(
                                        _passwordController.text.trim());
                                  }
                                }
                              : () {},
                          content: "Update Password",
                          bg: _isFormValid
                              ? AppColor.primaryColor
                              : AppColor.primaryColor.withAlpha(150),
                        ),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              customFillButton(() async {
                final ctxt = context;
                await AuthServices().signOutUser();

                if (!ctxt.mounted) return;

                Navigator.pushAndRemoveUntil(
                  ctxt,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const LoginPage()),
                  (route) => false,
                );

                firstimeController.toggleGuestLog(false);
                userController.changeLogStatus(false);
              }, content: "Sign Out"),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
