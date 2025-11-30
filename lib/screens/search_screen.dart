import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:learning_app/Model/category_model.dart';
import 'package:learning_app/Model/product_model.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/products_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/all_products_page.dart';
import 'package:learning_app/screens/cart_screen.dart';
import 'package:learning_app/screens/wishlist_screen.dart';
import 'package:learning_app/widgets/home_screen_widgets.dart';
import 'package:learning_app/widgets/login_dialog.dart';
import 'package:learning_app/widgets/texts.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final userController = Get.find<UserController>();
  final productController = Get.find<ProductController>();

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColor.darkBg2,
        appBar: AppBar(
          backgroundColor: AppColor.darkBg1,
          title: const CustomAutoSizeText2(
            text: "Explore Categories",
            lightTextColor: AppColor.primaryText,
            fontSize: 20,
          ),
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
        body: const CategoryGridScreen(),
      ),
    );
  }
}

class CategoryGridScreen extends StatefulWidget {
  const CategoryGridScreen({super.key});

  @override
  State<CategoryGridScreen> createState() => _CategoryGridScreenState();
}

class _CategoryGridScreenState extends State<CategoryGridScreen> {
  late ProductController productController;

  @override
  void initState() {
    super.initState();
    productController = Get.find<ProductController>();
    productController.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Box (as per your request)
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
          child: SearchBox(),
        ),

        Expanded(
          child: Obx(() {
            // Show shimmer loading state
            if (productController.isCategoryLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show empty state
            if (productController.categories.isEmpty) {
              return const Center(child: Text("No categories found."));
            }

            // Show the responsive GridView of category cards
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // Square cards
              ),
              itemCount: productController.categories.length,
              itemBuilder: (context, index) {
                final category = productController.categories[index];
                return SpotifyCategoryCard(
                  category: category,
                  onTap: () {
                    // Navigate to ProductsScreen, passing the category slug
                    Get.to(() => ProductsScreen(
                          categoryName: category.slug,
                        ));
                  },
                  index: index,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// 🎯 OPTION 1: Using a more stylized placeholder with color mixing
// Helper to generate a unique placeholder image based on the category name
// String _getCategoryImageUrl(String slug) {
//   final seed = slug.hashCode % 1000;
//   // Using placehold.co for image URL placeholders, changing size for grid view
//   return 'https://placehold.co/150x150/000000/FFFFFF/png?text=${slug.toUpperCase()}';
// }

// 🎯 OPTION 2: Using the 'picsum' service for randomized real photos
// Uncomment this if you prefer random photographic backgrounds.
// String _getCategoryImageUrl(String slug) {
//   // Use slug hash to deterministically pick an image from the 1084 available images
//   final seed = slug.hashCode % 1084;
//   // Format: https://picsum.photos/seed/{seed}/width/height
//   return 'https://picsum.photos/seed/$seed/150/150';
// }

// 🎯 FIX: Explicitly forcing PNG output format in the URL
// String _getCategoryImageUrl(String slug) {
//   // Use slug hash to generate a unique, vibrant color (HSL color generation algorithm)
//   final int hash = slug.hashCode;

//   // Calculate a unique background color (Hex format)
//   final colorValue = 0xFF000000 | (hash * 0xFFFFFF).toInt().abs() % 0xFFFFFF;
//   final color = Color(colorValue).withOpacity(1.0);

//   // Determine if the color is light or dark for optimal text contrast
//   final double luminance =
//       (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
//   final String textColor =
//       luminance > 0.5 ? '000000' : 'FFFFFF'; // Black or White text

//   // Use placehold.co for reliable solid color generation
//   // NOTE: Added /png path segment to force PNG format for decoding compatibility
//   final String bgColorHex =
//       color.value.toRadixString(16).substring(2).toUpperCase();

//   // We use the capitalized first letter of the slug as the placeholder text
//   final String placeholderText = slug.substring(0, 1).toUpperCase();

//   // 💥 THE CRITICAL FIX IS HERE: appending '/png'
//   return 'https://placehold.co/150x150/$bgColorHex/$textColor/png?text=$placeholderText';
// }

// 🎯 Hardcoded list of relevant image URLs
const List<String> _category_Image_Urls = [
  // Index 0: Beauty (Example link: source.unsplash for product shots)
  'https://img.freepik.com/premium-photo/placeholder-beauty-care-bottle-style-background_1119669-429.jpg?w=996',
  // Index 1: Fragrances
  'https://wallpapers.com/images/hd/perfume-pictures-vwt44lw3l6zoolga.jpg',
  // Index 2: Furniture
  'https://brownbreadfurniture.com/images/main.jpg',
  // Index 3: Groceries
  'https://tse1.mm.bing.net/th/id/OIP.laInRJsJqlbUerairk1asAHaEy?rs=1&pid=ImgDetMain&o=7&rm=3',
  // Index 4: Home Decoration
  'https://m.media-amazon.com/images/I/71VP2phVneL.jpg',
  // Index 5: Kitchen accessories
  'https://res.cloudinary.com/dvjytl1np/image/upload/f_webp,c_limit,w_2560,h_2560,q_72/migrated/355761',
  // Index 6: Laptops
  'https://static.vecteezy.com/system/resources/previews/048/635/823/non_2x/laptop-mockup-with-professional-background-for-app-and-web-design-free-photo.jpg',
  // Index 7: Men shirts
  'https://i.pinimg.com/736x/bd/a8/28/bda828ca517aab57263a7d3b83cc9984.jpg',
  // Index 8: Men shoes
  'https://rukminim3.flixcart.com/image/1114/972/xif0q/shopsy-shoe/b/y/z/8-uxs50-begone-white-original-imaghnjh6yum2emv.jpeg?q=60&crop=false',
  // Index 9: Men watches
  'https://tse3.mm.bing.net/th/id/OIP.H3NtQQalXSeD5Lkjl_D6JAHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',
  // Index 10: Mobile Accessories
  'https://www.portronics.com/cdn/shop/files/Mobile_Accessories_Hero_Banner_Mobile.png?v=1708432569',
  // Index 11: Motorcycle
  'https://www.eaglelights.com/cdn/shop/files/8900BG3-4-ai.png?v=1744220461&width=900',
  // Index 12: Skin care
  'https://revivedskinclinic.com/cdn/shop/files/ProductsP2-87_1.jpg?v=1743358199&width=1500',
  // Index 13: Smartphones
  'https://cdn.pixabay.com/photo/2023/04/05/13/58/phone-7901600_1280.jpg',
  // Index 14: Sports accessories
  'https://media.istockphoto.com/photos/sport-equipments-on-floor-picture-id917899790?k=6&m=917899790&s=612x612&w=0&h=dw1kcNJEtag7dC8uu-Tk3d1T7dgR-0g5o7l_GqcQmqg=',
  // Index 15: Sunglassses
  'https://img.freepik.com/premium-photo/sun-glasses_1037171-24537.jpg',
  // Index 16: Tablets
  'https://i5.walmartimages.com/asr/a81ae665-e81f-4d14-9f05-ebadf6097ef4.1f1be41e95cd4937e04e9906c18a4ce7.jpeg',
  // Index 17: Tops
  'https://assets.myntassets.com/h_200,w_200,c_fill,g_auto/h_1440,q_100,w_1080/v1/assets/images/29184280/2024/4/25/92b75846-40a7-49e2-a9f0-d39000a81af5171403069769920DressesWomenRawEdgeT-shirt1.jpg',
  // Index 18: Vehicle
  'https://wallpaperaccess.com/full/5084449.jpg',
  // Index 19: Womens bags
  'https://img.freepik.com/premium-photo/photograph-capturing-fashionable-women-with-bags_847512-962.jpg?w=996',
  // Index 20: Womens dresses
  'https://assets.myntassets.com/h_200,w_200,c_fill,g_auto/h_1440,q_100,w_1080/v1/assets/images/20465878/2023/1/9/9238fee9-d0d3-4055-9288-fda3b8beaa771673244915658-4WRD-by-Dressberry-Women-Tops-4771673244914866-1.jpg',
  // Index 21: Womens jewellery
  'https://www.dhresource.com/webp/m/wedding-jewelry-sets-4-fashionable-and-luxurious/f3-albu-jc-m-17-e25b437e-9f2c-4c0d-bd33-621e41f57120.jpg',
  // Index 22: Women shoes
  'https://images.pexels.com/photos/27398612/pexels-photo-27398612.png?cs=srgb&dl=pexels-jose-martin-segura-benites-1422456152-27398612.jpg&fm=jpg',
  // Index 23: Women watches
  'https://cdn.luxe.digital/media/2020/09/17134727/best-women-watches-vincero-luxe-digital.jpg',
];

String _getCategoryImageUrl(String slug, int index) {
  // 1. Check if we have a specific image link for this index
  if (index >= 0 && index < _category_Image_Urls.length) {
    return _category_Image_Urls[index];
  }

  // 2. Fallback: Use the reliable unique color block generator if index is out of bounds
  final int hash = slug.hashCode;
  final colorValue = 0xFF000000 | (hash * 0xFFFFFF).toInt().abs() % 0xFFFFFF;
  final color = Color(colorValue).withOpacity(1.0);
  final double luminance =
      (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
  final String textColor = luminance > 0.5 ? '000000' : 'FFFFFF';
  final String bgColorHex =
      color.value.toRadixString(16).substring(2).toUpperCase();
  final String placeholderText = slug.substring(0, 1).toUpperCase();

  // Explicitly request PNG for reliable decoding
  return 'https://placehold.co/150x150/$bgColorHex/$textColor/png?text=$placeholderText';
}

class SpotifyCategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final int index;

  const SpotifyCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = _getCategoryImageUrl(category.slug, index);

    // Extracting the color for the primary color/fallback state
    final Color primaryColor = _category_Image_Urls.contains(imageUrl)
        ? Colors.blueGrey.shade900 // Use a neutral color for photo backgrounds
        : Color(int.parse(
            '0xFF${imageUrl.split('/')[4].substring(0, 6)}')); // Extract from placehold URL
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0, // Make it square
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) => Container(
                      color: Colors.blueGrey,
                      child: const Center(
                          child: Icon(Icons.category, color: Colors.white))),
                ),
              ),

              // 2. Light Black Overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // 3. Category Name (positioned at the bottom-left)
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    // Capitalize the first letter of the category name
                    category.name.capitalizeFirst!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
