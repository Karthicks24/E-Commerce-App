import 'package:flutter/material.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/widgets/pageview_content.dart';

class GetStarted extends StatelessWidget {
  GetStarted({super.key});

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBg1,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          children: [
            OnboardingWidget(
                controller: _controller,
                imagepath: "assets/images/onboard-1.png",
                boldText: "Discover Amazing\nDeals Daily",
                normalText:
                    "Browse thousands of products\nand snag exclusive flash sales",
                index: 0),
            OnboardingWidget(
              controller: _controller,
              imagepath: "assets/images/onboard-2.png",
              boldText: "Checkout is\nFast and Easy",
              normalText:
                  "Securely save your details\nfor quick, one-tap purchases",
              index: 1,
            ),
            OnboardingWidget(
                controller: _controller,
                imagepath: "assets/images/onboard-3.png",
                boldText: "Shop Smarter,\nNot Harder",
                normalText:
                    "Create personalized wishlists\nand track your favorite items",
                index: 2),
          ],
        ),
      ),
    );
  }
}
