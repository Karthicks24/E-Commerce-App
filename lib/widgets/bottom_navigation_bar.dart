import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learning_app/Model/product_model.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/bottom_nav_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/widgets/login_dialog.dart';
import 'package:learning_app/widgets/other_widgets.dart';

class CustomBottomNavBar extends StatelessWidget {
  CustomBottomNavBar({super.key});

  final BottomNavController navController = Get.find<BottomNavController>();
  final userController = Get.find<UserController>();
  // final productController = Get.find<ProductController>();

  Future<bool?> showLoginDialog(BuildContext context,
      {Product? product, Function(Product)? action}) {
    // Use showModalBottomSheet to display the login UI you provided
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Pass the pending action details to the LoginDialog's state
        final PendingAction? pendingAction;
        if (action != null && product != null) {
          pendingAction =
              action == null ? PendingAction.cart : PendingAction.wishlist;
        } else {
          pendingAction = null; // No specific product
        }
        return LoginDialog(
          productToToggle: product,
          pendingAction: pendingAction,
        );
      },
    ).then((isSuccessful) {
      // This callback runs after the dialog is closed
      if (isSuccessful == true) {
        // Re-run the desired action after successful login
        if (action != null && product != null) {
          action(product);
        } else {}
      }
      return isSuccessful;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
            color: AppColor.darkBg1,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r))),
        child: BottomNavigationBar(
            backgroundColor: AppColor.darkBg1,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: false,
            showSelectedLabels: false,
            selectedItemColor: AppColor.primaryText,
            unselectedItemColor: AppColor.primaryColor,
            currentIndex: navController.currentIndex.value,
            onTap: (index) {
              if (index == 2) {
                if (userController.isLoggedIn.value) {
                  navController.changeIndex(index);
                } else {
                  showLoginDialog(context).then((isSuccessful) {
                    if (isSuccessful == true) {
                      navController.changeIndex(index);
                    }
                  });
                }
              } else {
                navController.changeIndex(index);
              }
            },
            items: _botNavItems),
      ),
    );
  }
}

var _botNavItems = <BottomNavigationBarItem>[
  BottomNavigationBarItem(
      icon: iconWithBgColor(
          iconPath: "assets/icons/home_icon.svg", color: AppColor.primaryColor),
      label: "Home",
      activeIcon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColor.primaryColor),
        child: iconWithBgColor(
          iconPath: "assets/icons/home_icon.svg",
          color: AppColor.primaryText,
        ),
      )),
  BottomNavigationBarItem(
      icon: iconWithBgColor(
          iconPath: "assets/icons/search_icon.svg",
          color: AppColor.primaryColor),
      label: "Search",
      activeIcon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColor.primaryColor),
        child: iconWithBgColor(
            iconPath: "assets/icons/search_icon.svg",
            color: AppColor.primaryText,
            bg: AppColor.primaryColor),
      )),
  BottomNavigationBarItem(
      icon: iconWithBgColor(
          iconPath: "assets/icons/play_icon.svg", color: AppColor.primaryColor),
      label: "My Course",
      activeIcon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColor.primaryColor),
        child: iconWithBgColor(
            iconPath: "assets/icons/play_icon.svg",
            color: AppColor.primaryText,
            bg: AppColor.primaryColor),
      )),
  BottomNavigationBarItem(
      icon: iconWithBgColor(
          iconPath: "assets/icons/user_icon.svg", color: AppColor.primaryColor),
      label: "User",
      activeIcon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColor.primaryColor),
        child: iconWithBgColor(
            iconPath: "assets/icons/user_icon.svg",
            color: AppColor.primaryText,
            bg: AppColor.primaryColor),
      )),
];
