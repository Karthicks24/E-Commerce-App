import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:learning_app/Model/product_model.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/products_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/all_products_page.dart';
import 'package:learning_app/screens/cart_screen.dart';
import 'package:learning_app/widgets/login_dialog.dart';
import 'package:learning_app/widgets/texts.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final userController = Get.find<UserController>();
  final ProductController productController = Get.find<ProductController>();

  int dotsCurrentIndex = 0;
  int productQuantity = 1;

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
          pendingAction = action == productController.toggleCart
              ? PendingAction.cart
              : PendingAction.wishlist;
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

  // 1. Confirmation Dialog
  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true, // User can tap outside to cancel
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Confirm Purchase'),
          content: const Text('Are you sure you want to buy this item now?'),
          backgroundColor: Colors.white,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            // Cancel Button: Closes the dialog and returns false
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColor.primaryColor),
              ),
            ),
            // Confirm Button: Confirms purchase and returns true
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 2. Success Dialog
  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must press OK to close
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          actionsAlignment: MainAxisAlignment.center,
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Success Icon
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFF4CAF50),
                size: 60,
              ),
              SizedBox(height: 16),
              // Success Message
              Text(
                'Order Successful!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColor.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Your purchase has been processed.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            // OK Button
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Button onPressed handler logic
  void _handleBuyNow(BuildContext context) async {
    // Show confirmation dialog and wait for the result
    final bool? isConfirmed = await _showConfirmationDialog(context);

    // If confirmation is true, proceed to show success
    if (isConfirmed == true) {
      // Simulate purchase processing delay (e.g., calling an API)
      await Future.delayed(const Duration(milliseconds: 500));

      // Show the success pop-up
      _showSuccessDialog(context);
    }
    // If isConfirmed is false or null (cancelled/dismissed), do nothing.
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.fetchSingleProductById(widget.productId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Product id ======== ${widget.productId}");
    return Scaffold(
      backgroundColor: const Color(0XFFF4F6F8),
      // backgroundColor: AppColor.darkBg1,
      // appBar: AppBar(
      //   backgroundColor: AppColor.darkBg1,
      //   iconTheme: const IconThemeData(color: Colors.white),
      // ),
      bottomSheet: Container(
        // Optional: Add padding/elevation/shadow here for a cleaner look
        decoration: BoxDecoration(
          color: AppColor.darkBg1, // Ensure the background is solid
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -2), // Shadow pointing up
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),

        // Add bottom padding only if device needs it (e.g., iPhone safe area)
        child: SafeArea(
          child: Row(
            children: [
              // ----------------- Add to Cart Button -----------------
              Expanded(
                child: Obx(() {
                  // 1. Retrieve the product and perform a null check
                  final product = productController.currentProduct.value;

                  // If product is still null (e.g., loading or not found), show a disabled button
                  if (product == null) {
                    return ElevatedButton(
                      onPressed: null, // Disabled
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const CustomAutoSizeText2(
                        text: "Loading...",
                        lightTextColor: Colors.white,
                      ),
                    );
                  }
                  // 1. Read the reactive state here to trigger the rebuild
                  final bool isInCart = product.isAddedToCart.value;

                  // 2. Define the button properties based on the state
                  final String buttonText = isInCart ? "Added" : "Add to Cart";
                  const Color buttonColor = Colors.white;
                  const Color textColor = AppColor.primaryColorDark;
                  return ElevatedButton(
                    onPressed: () {
                      // Handle Add to Cart action
                      if (userController.isLoggedIn.value) {
                        productController.toggleCart(product);
                      } else {
                        showLoginDialog(
                          context,
                          product: product,
                          action: productController.toggleCart,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor, // Light/secondary color
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: CustomAutoSizeText2(
                      text: buttonText,
                      lightTextColor: textColor,
                    ),
                  );
                }),
              ),

              const SizedBox(width: 12), // Space between buttons

              // ----------------- Buy Now Button -----------------
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Buy Now action
                    _handleBuyNow(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColor.primaryColor, // Primary action color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const CustomAutoSizeText2(
                    text: "Buy now",
                    lightTextColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final product = productController.currentProduct.value;

          if (product == null && productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // final product = productController.currentProduct.value;

          if (product == null) {
            return const Center(child: Text("Product not found"));
          }

          const double kExpandedHeight = 370.0;
          const double kCollapsedHeight =
              kToolbarHeight + 40.0; // Standard toolbar height + padding

          final double currentPrice = product.price; // Gets 9.99
          final double discountRate =
              product.discountPercentage / 100.0; // Gets 0.0717
          // Calculate the original price (Price / (1 - Discount Rate))
          final double originalPrice = currentPrice / (1.0 - discountRate);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0XFFF4F6F8),
                expandedHeight: kExpandedHeight,
                pinned: true,
                flexibleSpace: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30), // Example radius
                    bottomRight: Radius.circular(30), // Example radius
                  ),
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    final topPadding = MediaQuery.of(context).padding.top;
                    final currentHeight = constraints.biggest.height;

                    // Calculate how much the app bar has shrunk (0.0 when fully expanded, 1.0 when fully collapsed)
                    const double kFadeStartFraction = 0.8;

                    // The total distance the app bar shrinks (minus necessary padding)
                    final totalShrinkDistance =
                        kExpandedHeight - kCollapsedHeight - topPadding;

                    // Calculate the scroll distance AFTER the fade start point
                    final scrollAfterFadeStart =
                        (kExpandedHeight - currentHeight) -
                            (totalShrinkDistance * kFadeStartFraction);

                    // New Collapse Factor: This new value will be 0 until scrollAfterFadeStart > 0
                    final newCollapseFactor = scrollAfterFadeStart /
                        (totalShrinkDistance * (1 - kFadeStartFraction));

                    // Use clamp to ensure the value stays between 0.0 (transparent) and 1.0 (opaque)
                    final opacity = newCollapseFactor.clamp(0.0, 1.0);
                    return FlexibleSpaceBar(
                      title: Opacity(
                          opacity: opacity,
                          child: CustomAutoSizeText2(text: product.title)),
                      background: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            // Set a specific height for the horizontal list of images
                            // height: 250,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: const BoxDecoration(
                              color: Color(0XFFF4F6F8),
                              // borderRadius: BorderRadius.circular(10)
                            ),
                            child: PageView.builder(
                              // Ensure the list scrolls horizontally
                              scrollDirection: Axis.horizontal,
                              // itemCount: product.images.length,
                              itemCount: product.images.length > 1
                                  ? 99999
                                  : product.images.length,
                              onPageChanged: (value) {
                                final realIndex = value % product.images.length;
                                if (dotsCurrentIndex != realIndex) {
                                  setState(() {
                                    dotsCurrentIndex = realIndex;
                                  });
                                }
                              },
                              itemBuilder: (context, index) {
                                // Get the single image URL for the current index
                                // final imageUrl = product.images[index];
                                final realImageIndex =
                                    index % product.images.length;
                                final imageUrl = product.images[
                                    realImageIndex]; // Use the real index

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    // 💡 Pass the single URL string here!
                                    imageUrl: imageUrl,
                                    width: MediaQuery.of(context).size.width *
                                        0.9, // Make images wide
                                    fit: BoxFit.fitHeight,

                                    // Your existing placeholder and error widgets
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        color: Colors.white,
                                        height: 250,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error,
                                            size: 40, color: Colors.red),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                                onTap: () {
                                  if (userController.isLoggedIn.value) {
                                    Get.to(() => const CartScreen());
                                  } else {
                                    showLoginDialog(context)
                                        .then((isSuccessful) {
                                      if (isSuccessful == true) {
                                        Get.to(() => const CartScreen());
                                      }
                                    });
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 10),
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    158, 158, 158, 0.1),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ]),
                                        child: const Icon(
                                          Icons.shopping_cart,
                                          size: 24,
                                          color: Colors.black87,
                                        )),
                                    Obx(() => Visibility(
                                          visible:
                                              productController.cart.isNotEmpty,
                                          child: Positioned(
                                              top: -2,
                                              right: 0,
                                              child: Container(
                                                height: 16,
                                                width: 16,
                                                // padding: const EdgeInsets.all(6),
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: CustomAutoSizeText2(
                                                  text:
                                                      "${productController.cart.length}",
                                                  lightTextColor: Colors.white,
                                                  fontSize: 2,
                                                  maxAllowedFontSize: 2,
                                                  fontWeight: FontWeight.w400,
                                                  maxLines: 1,
                                                ),
                                              )),
                                        ))
                                  ],
                                )),
                          ),
                          Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: DotsIndicator(
                                position: dotsCurrentIndex,
                                dotsCount: product.images.length,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                decorator: DotsDecorator(
                                    size: const Size.square(9),
                                    activeColor: AppColor.darkBg2,
                                    // activeSize: Size(24, 8),
                                    activeShape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                              )),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  // margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                  decoration: const BoxDecoration(
                      color: AppColor.darkBg1,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30), // Example radius
                        topRight: Radius.circular(30), // Example radius
                      )),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAutoSizeText2(
                          text: product.brand,
                          lightTextColor: AppColor.lightText,
                          fontSize: 14,
                          maxAllowedFontSize: 14,
                          fontWeight: FontWeight.w600,
                          maxLines: 3,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 12,
                          children: [
                            Flexible(
                              child: CustomAutoSizeText2(
                                text: product.title,
                                lightTextColor: AppColor.primaryText,
                                fontSize: 20,
                                maxAllowedFontSize: 22,
                                fontWeight: FontWeight.w700,
                                maxLines: 3,
                              ),
                            ),
                            GestureDetector(
                                onTap: () {
                                  if (userController.isLoggedIn.value) {
                                    productController.toggleWishlist(product);
                                  } else {
                                    showLoginDialog(
                                      context,
                                      product: product,
                                      action: productController.toggleWishlist,
                                    );
                                  }
                                  // setState(() {});
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: const BoxDecoration(
                                    // color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Obx(
                                    () => SvgPicture.asset(
                                      product.isLiked.value
                                          ? "assets/icons/heart-liked.svg"
                                          : "assets/icons/heart.svg",
                                      width: 28,
                                      colorFilter: product.isLiked.value
                                          ? null
                                          : const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        // Category
                        GestureDetector(
                          onTap: () {
                            Get.to(() => ProductsScreen(
                                categoryName: (product.category.isNotEmpty)
                                    ? product.category
                                    : ''));
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomAutoSizeText2(
                              text: product.category,
                              lightTextColor: Colors.black,
                              fontSize: 10,
                              maxAllowedFontSize: 10,
                              fontWeight: FontWeight.w500,
                              maxLines: 3,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),

                        /// Product Price
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12,
                          children: [
                            CustomAutoSizeText2(
                              text: "\$${product.price}",
                              fontSize: 26,
                              maxAllowedFontSize: 26,
                              lightTextColor: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            CustomAutoSizeText2(
                                text:
                                    "\$${originalPrice.toStringAsFixed(2)}", // price + 20%
                                fontSize: 14,
                                lightTextColor: Colors.grey,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.lineThrough),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        // Stock
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 6,
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                  color: product.stock < 6
                                      ? Colors.red
                                      : product.stock < 20
                                          ? Colors.orange
                                          : Colors.green,
                                  shape: BoxShape.circle),
                            ),
                            CustomAutoSizeText2(
                              text: "In stock : ${product.stock}",
                              lightTextColor: product.stock < 6
                                  ? Colors.red
                                  : product.stock < 20
                                      ? Colors.orange
                                      : Colors.green,
                              fontSize: 12,
                              maxAllowedFontSize: 12,
                              fontWeight: FontWeight.w500,
                              maxLines: 3,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CustomAutoSizeText2(
                              text: "Select Quantity",
                              lightTextColor: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),

                            // The Quantity Control Buttons
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor
                                    .darkBg2, // Use a contrasting background
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  // Decrement Button
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.white, size: 20),
                                    onPressed: () {
                                      if (productQuantity > 1) {
                                        setState(() {
                                          productQuantity--;
                                        });
                                      }
                                    }, // Call controller method
                                  ),

                                  // Quantity Display (Uses Obx to react to changes)
                                  CustomAutoSizeText2(
                                    text: '$productQuantity',
                                    lightTextColor: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),

                                  // Increment Button
                                  IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.white, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        productQuantity++;
                                      });
                                    }, // Call controller method
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        // Warranty and shipping
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 24,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  const Icon(
                                    Icons
                                        .verified_user, // Replaced Icon(Icons.) with Icons.verified_user
                                    color: Colors
                                        .white, // Assuming the parent color is white
                                    size: 24,
                                  ),
                                  CustomAutoSizeText2(
                                    text: product.warrantyInformation,
                                    lightTextColor: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  const Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  CustomAutoSizeText2(
                                    text: product.shippingInformation,
                                    lightTextColor: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        const CustomAutoSizeText2(
                          text: "Description",
                          lightTextColor: Colors.white,
                          fontSize: 18,
                          maxAllowedFontSize: 18,
                          fontWeight: FontWeight.w600,
                          maxLines: 3,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        ExpandableTextWidget(text: product.description),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CustomAutoSizeText2(
                                text: "Reviews",
                                lightTextColor: Colors.white,
                                fontSize: 18,
                                maxAllowedFontSize: 18,
                                fontWeight: FontWeight.w600,
                                maxLines: 3,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 4,
                                children: [
                                  const Icon(
                                    Icons.star_rate_rounded,
                                    size: 20,
                                    color: Colors.amberAccent,
                                  ),
                                  CustomAutoSizeText2(
                                    text: "${product.rating}",
                                    lightTextColor: Colors.white,
                                    fontSize: 16,
                                    maxAllowedFontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ]),
                        const SizedBox(
                          height: 10,
                        ),
                        ...List.generate(product.reviews.length, (index) {
                          final review = product.reviews[index];
                          final formattedDate = review.date.split('T')[0];
                          return Container(
                            margin:
                                EdgeInsets.only(bottom: 16, left: 4, right: 4),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColor.darkBg2,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(58, 58, 58,
                                      0.2), // Slightly darker shadow for visibility
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomAutoSizeText2(
                                      text: review.reviewerName,
                                      lightTextColor: AppColor.secondaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    CustomAutoSizeText2(
                                      text: formattedDate,
                                      lightTextColor: AppColor.lightText,
                                      fontSize: 10,
                                      maxAllowedFontSize: 10,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Generate star icons based on the review rating
                                      ...List.generate(5, (starIndex) {
                                        return Icon(
                                          // Solid star if index is less than rating, else outline star
                                          starIndex < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors
                                              .amber, // Classic star color
                                          size: 20,
                                        );
                                      }),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${review.rating}.0',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomAutoSizeText2(
                                  text: review.comment,
                                  lightTextColor: AppColor.primaryText,
                                )
                              ],
                            ),
                          );
                        }),

                        const SizedBox(
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
