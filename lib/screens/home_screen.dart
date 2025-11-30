import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:learning_app/Model/product_model.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/products_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/all_products_page.dart';
import 'package:learning_app/screens/cart_screen.dart';
import 'package:learning_app/screens/product_detail_page.dart';
import 'package:learning_app/screens/wishlist_screen.dart';
import 'package:learning_app/widgets/home_screen_widgets.dart';
import 'package:learning_app/widgets/login_dialog.dart';
import 'package:learning_app/widgets/texts.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userController = Get.find<UserController>();

  late ProductController productController;

  // late List<Product> randomProducts;

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

  @override
  void initState() {
    super.initState();
    productController = Get.find<ProductController>();
    productController.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColor.darkBg2,
        appBar: AppBar(
          backgroundColor: AppColor.darkBg1,
          toolbarHeight: 64.h,
          title: Obx(() => HelloUser(
                userName: userController.userName.value,
              )),
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (userController.isLoggedIn.value) {
                      Get.to(() => const WishlistScreen());
                    } else {
                      showLoginDialog(context).then((isSuccessful) {
                        // This is the crucial navigation after login:
                        if (isSuccessful == true) {
                          Get.to(() => const WishlistScreen());
                        }
                      });
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(4),
                    child: SvgPicture.asset(
                      "assets/icons/heart-liked.svg",
                      width: 24,
                    ),
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (userController.isLoggedIn.value) {
                          Get.to(() => const CartScreen());
                        } else {
                          showLoginDialog(context).then((isSuccessful) {
                            if (isSuccessful == true) {
                              Get.to(() => const CartScreen());
                            }
                          });
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.shopping_cart,
                            size: 24,
                            color: Colors.white,
                          )),
                    ),
                    Obx(
                      () => Visibility(
                        visible: productController.cart.isNotEmpty,
                        child: Positioned(
                            top: -2,
                            right: 10,
                            child: Container(
                              height: 16,
                              width: 16,
                              padding: const EdgeInsets.all(0),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: CustomAutoSizeText(
                                text: "${productController.cart.length}",
                                lightTextColor: Colors.white,
                                fontSize: 9,
                              ),
                            )),
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
        body: Obx(
          () {
            final products = productController.products;

            if (products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            /// Generate random products dynamically here (every rebuild)
            final randomProducts = List<Product>.from(products)..shuffle();
            final top8 = randomProducts.take(8).toList();
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16.h,
                    ),
                    // const HelloUser(),
                    // SizedBox(
                    //   height: 20.h,
                    // ),
                    // const SearchBar(),
                    const SearchBox(),
                    SizedBox(
                      height: 15.h,
                    ),
                    Banners(),
                    SizedBox(
                      height: 10.h,
                    ),
                    // Your Cart is waiting
                    Visibility(
                      visible: productController.cart.isNotEmpty,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 16.h,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Your Cart is waiting",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: AppColor.primaryText),
                              ),
                              Visibility(
                                visible: productController.cart.length > 6,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CartScreen()));
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 6),
                                    child: CustomAutoSizeText2(
                                      text: "See all",
                                      lightTextColor: AppColor.lightText,
                                      fontSize: 12,
                                      maxAllowedFontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                spacing: 12,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // runSpacing: 12,
                                // runAlignment: WrapAlignment.spaceBetween,
                                children: productController.cart
                                    .take(6)
                                    .map((product) {
                                  return ProductCardSmall(
                                    imageUrl: product.thumbnail,
                                    title: product.title,
                                    price: "${product.price}",
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      Get.to(() => ProductDetailPage(
                                          productId: product.id));
                                    },
                                  );
                                }).toList()),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                        ],
                      ),
                    ),
                    // Your recent favorites
                    Visibility(
                      visible: productController.wishlist.isNotEmpty,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 16.h,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Your Recent Favorites",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: AppColor.primaryText),
                              ),
                              Visibility(
                                visible: productController.wishlist.length > 6,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const WishlistScreen()));
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 6),
                                    child: CustomAutoSizeText2(
                                      text: "See all",
                                      lightTextColor: AppColor.lightText,
                                      fontSize: 12,
                                      maxAllowedFontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                spacing: 12,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // runSpacing: 12,
                                // runAlignment: WrapAlignment.spaceBetween,
                                children: productController.wishlist
                                    .take(6)
                                    .map((product) {
                                  return ProductCardSmall(
                                    imageUrl: product.thumbnail,
                                    title: product.title,
                                    price: "${product.price}",
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      Get.to(() => ProductDetailPage(
                                          productId: product.id));
                                    },
                                  );
                                }).toList()),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                        ],
                      ),
                    ),
                    // Top Products
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 16.h,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Top Products",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: AppColor.primaryText),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProductsScreen()));
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 6),
                                child: CustomAutoSizeText2(
                                  text: "See all",
                                  lightTextColor: AppColor.lightText,
                                  fontSize: 12,
                                  maxAllowedFontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Wrap(
                        //     spacing: 12,
                        //     runSpacing: 12,
                        //     runAlignment: WrapAlignment.spaceBetween,
                        //     children:
                        //         productController.randomProducts.take(6).map((product) {
                        //       return ProductCardSmall(
                        //         imageUrl: product.thumbnail,
                        //         title: product.title,
                        //         price: "${product.price}",
                        //         onTap: () {
                        //           FocusScope.of(context).unfocus();
                        //           Get.to(() =>
                        //               ProductDetailPage(productId: product.id));
                        //         },
                        //       );
                        //     }).toList()),
                        Wrap(
                          // physics: const ScrollPhysics(),
                          // shrinkWrap: true,
                          // gridDelegate:
                          //     const SliverGridDelegateWithFixedCrossAxisCount(
                          //   crossAxisCount: 2,
                          //   crossAxisSpacing: 20,
                          //   mainAxisSpacing: 20,
                          //   childAspectRatio: 0.75,
                          // ),
                          spacing: 12,
                          runSpacing: 12,
                          runAlignment: WrapAlignment.spaceBetween,
                          children: top8.map((product) {
                            return ProductCardSmall(
                              imageUrl: product.thumbnail,
                              title: product.title,
                              price: "${product.price}",
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Get.to(() =>
                                    ProductDetailPage(productId: product.id));
                              },
                            );
                          }).toList(),
                          // itemCount: 6,
                          // itemBuilder: (_, int index) {
                          //   return ProductCardSmall(
                          //     imageUrl:
                          //         "https://images.pexels.com/photos/32757439/pexels-photo-32757439.jpeg",
                          //     title: "Title",
                          //     price: "price",
                          //     onTap: () {},
                          //     onButtonTap: () {},
                          //   );}
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final double discountPercentage;
  final String category;
  final RxBool isLiked;
  final RxBool isAddedToCart;
  final VoidCallback onTap;
  final VoidCallback onTapCategory;
  final VoidCallback onTapCart;
  final VoidCallback onTapWish; // 👈 for button action

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.discountPercentage,
    required this.category,
    required this.isLiked,
    required this.isAddedToCart,
    required this.onTap,
    required this.onTapCategory,
    required this.onTapCart,
    required this.onTapWish,
  });

  @override
  Widget build(BuildContext context) {
    final double currentPrice = double.parse(price.substring(1)); // Gets 9.99
    final double discountRate = discountPercentage / 100.0; // Gets 0.0717

// Calculate the original price (Price / (1 - Discount Rate))
    final double originalPrice = currentPrice / (1.0 - discountRate);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // height: 190,
        // width: MediaQuery.of(context).size.width * 0.4,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 244, 244),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(158, 158, 158, 0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          spacing: 12,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                // height: 150,
                width: MediaQuery.of(context).size.width * 0.28,
                fit: BoxFit.fitHeight,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white, height: 100),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, size: 40, color: Colors.red),
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Product Title
                  CustomAutoSizeText2(
                    text: title,
                    maxLines: 2,
                    fontWeight: FontWeight.w600,
                  ),

                  GestureDetector(
                    onTap: onTapCategory,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomAutoSizeText2(
                        text: category,
                        lightTextColor: Colors.white,
                        maxLines: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Product Price
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      CustomAutoSizeText2(
                        text: price,
                        fontSize: 18,
                        maxAllowedFontSize: 20,
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
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColor.primaryColor, // button color
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: onTapCart,
                        child: Obx(
                          () => Text(
                              isAddedToCart.value ? "Added" : "Add to Cart",
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                      GestureDetector(
                          onTap: onTapWish,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                                border: Border.all(color: AppColor.darkBg1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Obx(
                              () => SvgPicture.asset(
                                isLiked.value
                                    ? "assets/icons/heart-liked.svg"
                                    : "assets/icons/heart.svg",
                                width: 24,
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCardSmall extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final VoidCallback onTap; // 👈 for button action

  const ProductCardSmall({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.435,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(158, 158, 158, 0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white, height: 100),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, size: 40, color: Colors.red),
              ),
            ),
            const SizedBox(height: 8),

            /// Product Title
            CustomAutoSizeText2(
              text: title,
              maxLines: 2,
              fontWeight: FontWeight.w600,
            ),

            const SizedBox(height: 6),

            /// Product Price
            Text(
              "\$ $price",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
