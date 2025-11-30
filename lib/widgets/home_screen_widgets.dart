import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/screens/all_products_page.dart';
import 'package:learning_app/screens/product_detail_page.dart';
import 'package:learning_app/widgets/other_widgets.dart';
import 'package:learning_app/widgets/texts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class HelloUser extends StatelessWidget {
  const HelloUser({super.key, this.userName = "Guest User from widget"});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAutoSizeText2(
            text: "Welcome home",
            lightTextColor: AppColor.secondaryText,
            fontSize: 14,
            maxAllowedFontSize: 14,
          ),
          CustomAutoSizeText2(
            text:
                "${userName.substring(0, 1).toUpperCase()}${userName.substring(1)}",
            lightTextColor: AppColor.primaryText,
            fontSize: 24,
            maxAllowedFontSize: 24,
            fontWeight: FontWeight.bold,
          )
        ],
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  const SearchBox({
    super.key,
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchProduct> _suggestions = [];
  bool _isLoading = false;
  // The maximum number of suggestions to display before "Show More"
  final int _suggestionLimit = 6;

  // 2. Mock API Call for fetching suggestions
  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Construct the API URL using the query
      final url = Uri.parse('https://dummyjson.com/products/search?q=$query');

      // 2. Make the HTTP GET Request
      final response = await http.get(url);

      // 3. Check for a successful response (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON body
        final Map<String, dynamic> data = json.decode(response.body);

        // Extract the list of products from the 'products' key
        final List<dynamic> productsJson = data['products'];

        // 4. Map the JSON list to a List of SearchProduct objects
        final List<SearchProduct> fetchedProducts = productsJson
            .map((jsonItem) => SearchProduct(
                  id: jsonItem['id'],
                  title: jsonItem['title'],
                  category: jsonItem['category'],
                  // Add other necessary fields here
                ))
            .toList();

        // 5. Update the UI state with the fetched results
        setState(() {
          _suggestions = fetchedProducts;
          _isLoading = false;
        });
      } else {
        // Handle non-200 responses (e.g., 404, 500)
        // For a real app, you might show a snackbar with the error.
        debugPrint(
            'Failed to load search results. Status code: ${response.statusCode}');
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle network errors (e.g., no internet connection)
      debugPrint('Error fetching search results: $e');
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which items to display (up to the limit)
    final List<SearchProduct> displaySuggestions =
        _suggestions.take(_suggestionLimit).toList();

    // Check if the search field has text
    final bool hasQuery = _searchController.text.isNotEmpty;

    // Check if there are no suggestions and the query is active (not loading)
    final bool noMatchesFound = hasQuery && !_isLoading && _suggestions.isEmpty;

    // Check if there are more results than the display limit
    final bool hasMoreResults = _suggestions.length > _suggestionLimit;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _fetchSuggestions,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: AppColor.primaryText),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                child: iconWithBgColor(
                    iconPath: "assets/icons/search_icon.svg",
                    color: AppColor.primaryText,
                    h: 14,
                    w: 14),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _suggestions = [];
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 2.h),
                          child: const Icon(
                            Icons.cancel_rounded,
                            color: Colors.white,
                          )),
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              hintText: "Find your products etc..",
              hintStyle: TextStyle(color: AppColor.lightText, fontSize: 14.sp),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Optional: Adds a rounded border
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: const Color(0xFF4A4E5A),
            ),
          ),
          // Loading Indicator
          if (_isLoading) const LinearProgressIndicator(color: Colors.white),
          if (noMatchesFound)
            // 1. No Matches Found Text
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A4E5A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "No matches found",
                style: TextStyle(color: AppColor.lightText, fontSize: 16),
              ),
            ),
          if (displaySuggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(
                maxHeight: 250, // prevents overflow when keyboard opens
              ),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A4E5A), // Match search box background
                borderRadius: BorderRadius.circular(10),
              ),
              // Use ListView.builder within a constrained height for the suggestions
              child: ListView.builder(
                shrinkWrap:
                    true, // Important: allows the list to take only necessary height
                physics:
                    const ClampingScrollPhysics(), // Prevents scrolling within the suggestion box itself
                itemCount: displaySuggestions.length,
                itemBuilder: (context, index) {
                  final product = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColor.lightText),
                    title: Text(
                      product.title,
                      style: const TextStyle(
                          color: AppColor.primaryText, fontSize: 16),
                    ),
                    subtitle: Text(
                      product.category,
                      style: TextStyle(
                          color: AppColor.lightText.withOpacity(0.8),
                          fontSize: 12),
                    ),
                    onTap: () {
                      // Navigate to the product detail page
                      Get.to(() => ProductDetailPage(productId: product.id));

                      // Clear search field and suggestions after selection
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _suggestions = [];
                      });
                    },
                  );
                },
              ),
            ),
          // Show More Results Button
          if (hasMoreResults)
            TextButton(
              onPressed: () {
                // Navigate to the ProductsScreen, passing the current search query
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductsScreen(
                            searchQuery: _searchController.text))).then((_) {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _suggestions = [];
                  });
                });

                // Clear search field after navigation
                // // _searchController.clear();
                // FocusScope.of(context).unfocus();
                // setState(() {
                //   _suggestions = [];
                // });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: AppColor.primaryText, // Text color
                backgroundColor: Colors.transparent, // Background color
              ),
              child: const Text(
                "Show more results...",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueAccent),
              ),
            ),
        ],
      ),
    );
  }
}

//For Dots
class BannerDotsController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

class Banners extends StatelessWidget {
  Banners({
    super.key,
  }) : pageController = PageController(
            initialPage: Get.find<BannerDotsController>().currentIndex.value);

  final BannerDotsController dotsController = Get.put(BannerDotsController());
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 325.w,
          height: 170.h,
          child: PageView(
            controller: pageController,
            onPageChanged: (index) {
              dotsController.changeIndex(index);
            },
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsScreen()));
                },
                behavior: HitTestBehavior.opaque,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl:
                        "https://static.vecteezy.com/system/resources/previews/002/822/446/large_2x/sale-banner-template-design-big-sale-special-offer-promotion-discount-banner-vector.jpg",
                    // height: 150,
                    width: double.maxFinite,
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white, height: 100),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, size: 40, color: Colors.red),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProductsScreen(categoryName: "womens-dresses")));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl:
                        "https://www.creativefabrica.com/wp-content/uploads/2021/04/26/Creative-Fashion-Sale-Banner-Graphics-11345601-1.jpg",
                    // height: 150,
                    width: double.maxFinite,
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white, height: 100),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, size: 40, color: Colors.red),
                  ),
                ),
              ),
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(10.r),
              //   child: CachedNetworkImage(
              //     imageUrl:
              //         "https://static.vecteezy.com/system/resources/previews/002/822/446/large_2x/sale-banner-template-design-big-sale-special-offer-promotion-discount-banner-vector.jpg",
              //     // height: 150,
              //     width: double.maxFinite,
              //     fit: BoxFit.fitWidth,
              //     placeholder: (context, url) => Shimmer.fromColors(
              //       baseColor: Colors.grey[300]!,
              //       highlightColor: Colors.grey[100]!,
              //       child: Container(color: Colors.white, height: 100),
              //     ),
              //     errorWidget: (context, url, error) =>
              //         const Icon(Icons.error, size: 40, color: Colors.red),
              //   ),
              // ),
              // Container(
              //   width: 325.w,
              //   height: 160.h,
              //   decoration: BoxDecoration(
              //       image: const DecorationImage(
              //           image: NetworkImage(
              //               "https://www.creativefabrica.com/wp-content/uploads/2021/04/26/Creative-Fashion-Sale-Banner-Graphics-11345601-1.jpg"),
              //           // image: AssetImage("assets/images/thumbnail-2.jpg"),
              //           fit: BoxFit.fill),
              //       borderRadius: BorderRadius.all(Radius.circular(10.r))),
              // ),
              GestureDetector(
                onTap: () {
                  // Id 81
                  FocusScope.of(context).unfocus();
                  Get.to(() => const ProductDetailPage(productId: 81));
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 325.w,
                  height: 160.h,
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.r))),
                  child: Row(
                    spacing: 16,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomAutoSizeText2(
                              text: "Highest sale of the week",
                              fontSize: 20,
                              maxAllowedFontSize: 22,
                              maxLines: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://m.media-amazon.com/images/I/71NHJXu1C+L._AC_.jpg",
                          // height: 150,
                          // height: 60,
                          // width: 200,
                          // width: MediaQuery.of(context).size.width * 0.28,
                          fit: BoxFit.fitHeight,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white, height: 100),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              size: 40,
                              color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Obx(() => DotsIndicator(
              position: dotsController.currentIndex.value, //for now
              dotsCount: 3,
              // mainAxisAlignment: MainAxisAlignment.center,
              decorator: DotsDecorator(
                  size: const Size.square(9),
                  activeSize: Size(24.w, 8.h),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r))),
            ))
      ],
    );
  }
}

class SearchProduct {
  final int id;
  final String title;
  final String category;

  SearchProduct(
      {required this.id, required this.title, required this.category});

  factory SearchProduct.fromJson(Map<String, dynamic> json) {
    return SearchProduct(
      id: json['id'],
      title: json['title'],
      category: json['category'],
    );
  }
}
