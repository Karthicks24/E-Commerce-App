import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:learning_app/Model/product_model.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/products_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/cart_screen.dart';
import 'package:learning_app/screens/home_screen.dart';
import 'package:learning_app/screens/product_detail_page.dart';
import 'package:learning_app/screens/wishlist_screen.dart';
import 'package:learning_app/widgets/Shimmers/product_shimmer.dart';
import 'package:learning_app/widgets/home_screen_widgets.dart';
import 'package:learning_app/widgets/login_dialog.dart';
import 'package:learning_app/widgets/texts.dart';
import 'package:learning_app/utils/global.dart';

class ProductsScreen extends StatelessWidget {
  final String? searchQuery;
  final String? categoryName;
  ProductsScreen({super.key, this.searchQuery, this.categoryName});

  final userController = Get.find<UserController>();
  final ProductController productController = Get.put(ProductController());

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
  Widget build(BuildContext context) {
    final String title = searchQuery != null && searchQuery!.isNotEmpty
        ? "Results for \"$searchQuery\""
        : categoryName != null && categoryName!.isNotEmpty
            ? "${categoryName?[0].toUpperCase()}${categoryName?.substring(1)}" ??
                ""
            : "All products";
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColor.darkBg2,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: AppColor.darkBg1,
          title: CustomAutoSizeText2(
            text: title,
            lightTextColor: AppColor.primaryText,
            fontSize: 20,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
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
        body: SafeArea(
            child: ProductGrid(
          searchQuery: searchQuery,
          categoryName: categoryName,
        )),
      ),
    );
  }
}

class ProductGrid extends StatefulWidget {
  final String? searchQuery;
  final String? categoryName;
  const ProductGrid({super.key, this.searchQuery, this.categoryName});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> with RouteAware {
  late ProductController productController;
  final UserController userController = Get.find<UserController>();
  final ScrollController _allProductsScrollController = ScrollController();

  void _handleProtectedAction(
      BuildContext context, Product product, Function(Product) action) {
    FocusScope.of(context).unfocus();

    if (userController.isLoggedIn.value) {
      // User is logged in, perform the action immediately
      action(product);
    } else {
      // User is not logged in, show the login dialog
      showLoginDialog(context, product, action);
    }
  }

  void showLoginDialog(
      BuildContext context, Product product, Function(Product) action) {
    // Use showModalBottomSheet to display the login UI you provided
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Pass the pending action details to the LoginDialog's state
        return LoginDialog(
          productToToggle: product,
          pendingAction: action == productController.toggleCart
              ? PendingAction.cart
              : PendingAction.wishlist,
        );
      },
    ).then((isSuccessful) {
      // This callback runs after the dialog is closed
      if (isSuccessful == true) {
        // Re-run the desired action after successful login
        action(product);
      }
    });
  }

  // final RouteObserver routeObserver = RouteObserver();

  @override
  void initState() {
    super.initState();

    productController = Get.find<ProductController>();
    // productController.fetchProducts();
    debugPrint("Search Query ====== ${widget.searchQuery}");
    debugPrint("Category Name ====== ${widget.categoryName}");
    // 1. Initial data fetch logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _initialDataFetch(loadMore: false);

      // When returning back
      final route = ModalRoute.of(context);

      if (route is PageRoute) {
        routeObserver.subscribe(this, route);
      }

      _initialDataFetch(loadMore: false);
    });
    // _initialDataFetch(loadMore: false);

    _allProductsScrollController.addListener(() {
      if (_allProductsScrollController.position.pixels >=
          _allProductsScrollController.position.maxScrollExtent - 200) {
        // Load next page when 200px near bottom
        if (productController.hasMore.value &&
            !productController.isLoading.value) {
          // productController.fetchProducts(
          //   loadMore: true,
          // );
          _initialDataFetch(
              loadMore: true); // Use the same gatekeeper for pagination
        }
      }
    });
  }

  @override
  void didPopNext() {
    // User returned back to this screen

    final noFilter =
        (widget.searchQuery == null || widget.searchQuery!.isEmpty) &&
            (widget.categoryName == null || widget.categoryName!.isEmpty);

    if (noFilter) {
      // restore default all products
      _initialDataFetch(loadMore: false);
    }

    setState(() {}); // rebuild to refresh PageStorageKey
  }

  // @override
  // void didUpdateWidget(covariant ProductGrid oldWidget) {
  //   debugPrint("Did update widget called");
  //   super.didUpdateWidget(oldWidget);

  //   // Check if the source of data (category or search) has changed.
  //   bool categoryChanged = widget.categoryName != oldWidget.categoryName;
  //   bool searchChanged = widget.searchQuery != oldWidget.searchQuery;

  //   // If either the category or search query changes, perform a fresh fetch.
  //   if (categoryChanged || searchChanged) {
  //     _initialDataFetch(loadMore: false);
  //   }
  // }

  // Gatekeeper function to decide which controller method to call
  void _initialDataFetch({required bool loadMore}) {
    final effectiveSearchQuery = widget.searchQuery?.trim();
    final effectiveCategoryName = widget.categoryName?.trim();

    if (effectiveCategoryName != null && effectiveCategoryName.isNotEmpty) {
      // If a category is provided, fetch by category
      productController.fetchProductsByCategory(
        categoryName: effectiveCategoryName,
        loadMore: loadMore,
      );
    } else if (effectiveSearchQuery != null &&
        effectiveSearchQuery.isNotEmpty) {
      // If a search query is provided, run the search
      productController.searchProducts(
        query: effectiveSearchQuery,
        loadMore: loadMore,
      );
    } else {
      // Default: Fetch all products
      productController.fetchProducts(
        loadMore: loadMore,
      );
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String storageKey =
        widget.categoryName ?? widget.searchQuery ?? 'AllProductsGridKey';
    return Column(
      children: [
        // SingleChildScrollView(
        //   scrollDirection: Axis.horizontal,
        //   child: Row(
        //     children: [
        //       ...List.generate(10, (int index) {
        //         return Container(
        //             margin: EdgeInsets.only(left: 12, bottom: 12, top: 12),
        //             padding:
        //                 EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        //             decoration: BoxDecoration(
        //                 color: Colors.white,
        //                 borderRadius: BorderRadius.circular(6)),
        //             child: CustomAutoSizeText(text: "Category $index"));
        //       }),
        //       const SizedBox(
        //         width: 12,
        //       )
        //     ],
        //   ),
        // ),
        const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
            child: SearchBox()),
        Expanded(
          child: Obx(() {
            if (productController.products.isEmpty) {
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
                await Future.delayed(
                    const Duration(milliseconds: 300)); // for smooth animation
                _initialDataFetch(loadMore: false);
              },
              child: ListView.builder(
                key: PageStorageKey(storageKey), // Unique ID for storage
                controller: _allProductsScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: productController.products.length +
                    (productController.hasMore.value ? 1 : 0),
                itemBuilder: (_, index) {
                  if (index < productController.products.length) {
                    final product = productController.products[index];
                    return ProductCard(
                      imageUrl: product.thumbnail,
                      title: product.title,
                      price: "\$${product.price}",
                      discountPercentage: product.discountPercentage ?? 1.2,
                      category: (product.category?.isNotEmpty ?? false)
                          ? '${product.category![0].toUpperCase()}${product.category!.substring(1)}'
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
                        if (widget.categoryName == null) {
                          Get.to(() => ProductsScreen(
                              categoryName:
                                  (product.category?.isNotEmpty ?? false)
                                      ? '${product.category!}'
                                      : ''));
                        } else {
                          () {};
                        }
                      },
                      onTapCart: () {
                        _handleProtectedAction(
                          context,
                          product,
                          productController.toggleCart,
                        );
                        // productController.toggleCart(product);
                      },
                      onTapWish: () {
                        _handleProtectedAction(
                          context,
                          product,
                          productController.toggleWishlist,
                        );
                        // productController.toggleWishlist(product);
                      },
                    );
                  } else {
                    // Loader while fetching next page
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
