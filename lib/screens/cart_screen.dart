import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/products_controller.dart';
import 'package:learning_app/screens/all_products_page.dart';
import 'package:learning_app/screens/product_detail_page.dart';
import 'package:learning_app/widgets/Shimmers/product_shimmer.dart';
import 'package:learning_app/widgets/home_screen_widgets.dart';
import 'package:learning_app/widgets/texts.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBg2,
      appBar: AppBar(
        backgroundColor: AppColor.darkBg1,
        title: const CustomAutoSizeText2(
          text: "Your cart",
          lightTextColor: AppColor.primaryText,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const SafeArea(child: CartProductGrid()),
    );
  }
}

class CartProductGrid extends StatefulWidget {
  const CartProductGrid({
    super.key,
  });

  @override
  State<CartProductGrid> createState() => _CartProductGridState();
}

class _CartProductGridState extends State<CartProductGrid> with RouteAware {
  final ProductController productController = Get.find();
  // final UserController userController = Get.find<UserController>();
  final ScrollController _cartScreenScrollController = ScrollController();
  final Key storageKey = const PageStorageKey('cartScrollPosition');

  @override
  void initState() {
    super.initState();
    // Ensure wishlist data is synchronized when the screen loads
    productController.syncListsFromFirestore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
            child: SearchBox()),
        Expanded(
          child: Obx(() {
            if (productController.cart.isEmpty &&
                productController.isLoading.isFalse) {
              return const Center(
                  child: CustomAutoSizeText2(
                text: "Your Cart list is empty.",
                lightTextColor: Colors.white,
              ));
            }
            if (productController.isLoading.isTrue &&
                productController.cart.isEmpty) {
              return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: 10,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return const ProductCardShimmer();
                  });
            }

            return RefreshIndicator(
              // onRefresh: () => productController.fetchProducts(),
              onRefresh: () async {
                await productController.syncListsFromFirestore();
              },
              child: ListView.builder(
                  key: storageKey, // Unique ID for storage
                  controller: _cartScreenScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: productController.cart.length,
                  itemBuilder: (_, index) {
                    final product = productController.cart[index];
                    return CartProductCard(
                      imageUrl: product.thumbnail,
                      title: product.title,
                      price: "\$${product.price}",
                      discountPercentage: product.discountPercentage,
                      category: (product.category.isNotEmpty)
                          ? '${product.category[0].toUpperCase()}${product.category.substring(1)}'
                          : '',
                      isLiked: product.isLiked,
                      isAddedToCart: product.isAddedToCart,
                      onTap: () {
                        // Example: navigate to detail page
                        FocusScope.of(context).unfocus();
                        Get.to(() => ProductDetailPage(productId: product.id));
                      },
                      onTapCategory: () {
                        // Example: navigate to detail page
                        FocusScope.of(context).unfocus();
                        Get.to(() => ProductsScreen(
                            categoryName: (product.category.isNotEmpty)
                                ? product.category
                                : ''));
                      },
                      onTapCart: () {
                        productController.toggleCart(product);
                      },
                      onTapWish: () {
                        productController.toggleWishlist(product);
                      },
                    );
                  }),
            );
          }),
        ),
      ],
    );
  }
}

class CartProductCard extends StatelessWidget {
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

  const CartProductCard({
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
