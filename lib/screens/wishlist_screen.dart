import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/products_controller.dart';
import 'package:learning_app/screens/all_products_page.dart';
import 'package:learning_app/screens/home_screen.dart';
import 'package:learning_app/screens/product_detail_page.dart';
import 'package:learning_app/widgets/Shimmers/product_shimmer.dart';
import 'package:learning_app/widgets/home_screen_widgets.dart';
import 'package:learning_app/widgets/texts.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBg2,
      appBar: AppBar(
        backgroundColor: AppColor.darkBg1,
        title: const CustomAutoSizeText2(
          text: "Your favorite items",
          lightTextColor: AppColor.primaryText,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const SafeArea(child: WishlistProductGrid()),
    );
  }
}

class WishlistProductGrid extends StatefulWidget {
  const WishlistProductGrid({
    super.key,
  });

  @override
  State<WishlistProductGrid> createState() => _WishlistProductGridState();
}

class _WishlistProductGridState extends State<WishlistProductGrid>
    with RouteAware {
  final ProductController productController = Get.find();
  // final UserController userController = Get.find<UserController>();
  final ScrollController _wishlistScrollController = ScrollController();
  final Key storageKey = const PageStorageKey('wishlistScrollPosition');

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
            if (productController.wishlist.isEmpty &&
                productController.isLoading.isFalse) {
              return const Center(
                  child: CustomAutoSizeText2(
                text: "Your wishlist is empty.",
                lightTextColor: Colors.white,
              ));
            }
            if (productController.isLoading.isTrue &&
                productController.wishlist.isEmpty) {
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
                  controller: _wishlistScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: productController.wishlist.length,
                  itemBuilder: (_, index) {
                    final product = productController.wishlist[index];
                    return ProductCard(
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
