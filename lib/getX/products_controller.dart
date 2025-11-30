import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learning_app/Model/category_model.dart';
import 'dart:convert';

import 'package:learning_app/Model/product_model.dart';

class ProductController extends GetxController {
  RxList products = <Product>[].obs;
  RxBool isLoading = false.obs;
  RxList<Product> wishlist = <Product>[].obs;
  RxList<Product> cart = <Product>[].obs;
  var hasMore = true.obs;
  var skip = 0;
  final int limit = 10; // Load 10 products at a time

  final Rx<Product?> currentProduct = Rx<Product?>(null);

  final RxList<Category> categories = <Category>[].obs;
  final RxBool isCategoryLoading = false.obs; // To track category loading state

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reactive user ID
  RxnString currentUserId = RxnString(null);

  @override
  void onInit() {
    // fetchProducts();
    super.onInit();
    // Authentication
    _auth.authStateChanges().listen((User? user) {
      currentUserId.value = user?.uid;
      if (user != null) {
        // User logged in
        syncListsFromFirestore();
      } else {
        // user logged out
        wishlist.clear();
        cart.clear();
        // Clear the products
        for (var product in products) {
          product.isLiked.value = false;
          product.isAddedToCart.value = false;
        }
      }
    });
  }

  // final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  // Helper method to get the user document reference
  DocumentReference get _userDocRef {
    final uid = currentUserId.value;
    if (uid == null) {
      // Handle the case where the user is not logged in (throw or return a dummy ref)
      throw Exception("User is not logged in. Cannot update Firestore.");
    }
    return _db.collection('users').doc(uid);
  }

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;

    if (!loadMore) {
      skip = 0;
      products.clear();
      hasMore.value = true;
    }

    final url =
        'https://dummyjson.com/products?limit=$limit&skip=$skip&select=id,title,price,thumbnail,category,discountPercentage';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productList = data['products'];

        if (productList == null || productList.isEmpty) {
          hasMore.value = false;
        } else {
          // Add new products
          final newProducts =
              productList.map((json) => Product.fromJson(json)).toList();
          products.addAll(newProducts);
          await syncListsFromFirestore();
          // load next page
          skip += limit;

          // stop loading if less than limit
          if (newProducts.length < limit) hasMore.value = false;
        }
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductsByCategory(
      {required String categoryName, bool loadMore = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;

    if (!loadMore) {
      skip = 0;
      products.clear();
      hasMore.value = true;
    }

    final url =
        'https://dummyjson.com/products/category/$categoryName?limit=$limit&skip=$skip&select=id,title,price,thumbnail,category,discountPercentage';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productList = data['products'];

        if (productList == null || productList.isEmpty) {
          hasMore.value = false;
        } else {
          // Add new products
          final newProducts =
              productList.map((json) => Product.fromJson(json)).toList();
          products.addAll(newProducts);
          await syncListsFromFirestore();
          // load next page
          skip += limit;

          // stop loading if less than limit
          if (newProducts.length < limit) hasMore.value = false;
        }
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      print('Error fetching products: $e');
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchProducts(
      {required String query, bool loadMore = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;

    if (!loadMore) {
      skip = 0;
      products.clear();
      hasMore.value = true;
    }

    final encodedQuery =
        Uri.encodeComponent(query); // Always encode user input!
    final url =
        'https://dummyjson.com/products/search?q=$encodedQuery&limit=$limit&skip=$skip&select=id,title,price,thumbnail,category,discountPercentage';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productList = data['products'];

        if (productList == null || productList.isEmpty) {
          hasMore.value = false;
        } else {
          // Add new products
          final newProducts =
              productList.map((json) => Product.fromJson(json)).toList();
          products.addAll(newProducts);
          await syncListsFromFirestore();
          // load next page
          skip += limit;

          // stop loading if less than limit
          if (newProducts.length < limit) hasMore.value = false;
        }
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      print('Error fetching products: $e');
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Product?> fetchSingleProductById(String id) async {
    try {
      isLoading(true);
      currentProduct.value = null; // reset!
      final response =
          await http.get(Uri.parse("https://dummyjson.com/products/$id"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newProduct = Product.fromJson(data);
        // Syncing
        await syncListsFromFirestore(singleProduct: newProduct);

        currentProduct.value = newProduct;
        return newProduct;
      } else {
        debugPrint("Error Failed to load products");
        currentProduct.value = null;
        return null;
      }
    } catch (e) {
      debugPrint("Error ${e.toString()}");
      currentProduct.value = null;
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    if (isCategoryLoading.value || categories.isNotEmpty) {
      return; // Prevent double fetch
    }
    isCategoryLoading.value = true;
    const url = 'https://dummyjson.com/products/categories';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> categoryList = json.decode(response.body);

        final newCategories =
            categoryList.map((json) => Category.fromJson(json)).toList();

        categories
            .assignAll(newCategories); // Use assignAll to fully replace list
      } else {
        debugPrint('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isCategoryLoading.value = false;
    }
  }

  // --- Wishlist Functions ---

  // 🎯 UPDATED: We now update a Map with a timestamp value
  void toggleWishlist(Product product) async {
    if (currentUserId.value == null) {
      debugPrint("User not logged in. Cannot toggle wishlist.");
      return;
    }

    // 1. Update local reactive state immediately
    product.isLiked.value = !product.isLiked.value;
    final isAdding = product.isLiked.value;

    // 2. Update local list and wait for Firestore
    if (isAdding) {
      // Add locally first
      wishlist.add(product);
    } else {
      // Remove locally first
      wishlist.removeWhere((p) => p.id == product.id);
    }

    // 3. Update Firestore using the new Map structure
    await _updateFirestoreMap(
        fieldName: 'wishlistItems', productId: product.id, isAdding: isAdding);

    // 4. Re-sync to ensure list order is correct (optional but safe)
    await syncListsFromFirestore();

    debugPrint(
        "Wishlist toggled for product ID ${product.id}. New state: $isAdding. Current wishlist size: ${wishlist.length}");
  }

  // Symmetric method for Cart
  void toggleCart(Product product) async {
    if (currentUserId.value == null) {
      debugPrint("User not logged in. Cannot toggle cart.");
      return;
    }

    product.isAddedToCart.value = !product.isAddedToCart.value;
    final isAdding = product.isAddedToCart.value;

    if (isAdding) {
      cart.add(product);
    } else {
      cart.removeWhere((p) => p.id == product.id);
    }

    // Use a separate key for cart items
    await _updateFirestoreMap(
        fieldName: 'cartItems', productId: product.id, isAdding: isAdding);

    await syncListsFromFirestore();
    debugPrint(
        "Cart toggled for product ID ${product.id}. New state: $isAdding. Current cart size: ${cart.length}");
  }

  // void toggleWishlist(Product product) {
  //   if (currentUserId.value == null){
  //     return;
  //   }
  //   // 1. Update local reactive state immediately for snappy UI
  //   product.isLiked.value = !product.isLiked.value;

  //   // 2. Update local list
  //   if (product.isLiked.value) {
  //     wishlist.add(product);
  //     _updateFirestoreList(
  //         fieldName: 'wishlistIds', productId: product.id, isAdding: true);
  //   } else {
  //     wishlist.removeWhere((p) => p.id == product.id);
  //     _updateFirestoreList(
  //         fieldName: 'wishlistIds', productId: product.id, isAdding: false);
  //   }
  // }

  // --- Cart Functions ---

  // void toggleCart(Product product) {
  //   if (currentUserId.value == null) {
  //     // Handle requirement for login here
  //     return;
  //   }
  //   // 1. Update local reactive state immediately
  //   product.isAddedToCart.value = !product.isAddedToCart.value;

  //   // 2. Update local list
  //   if (product.isAddedToCart.value) {
  //     cart.add(product);
  //     _updateFirestoreList(
  //         fieldName: 'cartIds', productId: product.id, isAdding: true);
  //   } else {
  //     cart.removeWhere((p) => p.id == product.id);
  //     _updateFirestoreList(
  //         fieldName: 'cartIds', productId: product.id, isAdding: false);
  //   }
  // }

  // Future<void> _updateFirestoreList({
  //   required String fieldName, // 'cartIds' or 'wishlistIds'
  //   required int productId,
  //   required bool isAdding,
  // }) async {
  //   if (currentUserId.value == null) return; // Skip if user is not logged in

  //   try {
  //     final updateData = {
  //       fieldName: isAdding
  //           ? FieldValue.arrayUnion(
  //               [productId]) // Atomically adds if not exists
  //           : FieldValue.arrayRemove(
  //               [productId]), // Atomically removes if exists
  //     };

  //     await _userDocRef.set(
  //       updateData,
  //       SetOptions(merge: true), // Ensures only the specified field is modified
  //     );
  //   } catch (e) {
  //     // Log or handle the error (e.g., if Firestore rules prevent writing)
  //     debugPrint('Error updating $fieldName in Firestore: $e');
  //     // OPTIONAL: Rollback the local state if the database update fails
  //   }
  // }

  Future<void> _updateFirestoreList({
    required String fieldName,
    required int productId,
    required bool isAdding,
  }) async {
    try {
      if (isAdding) {
        // Add the ID to the list using ArrayUnion
        await _userDocRef.set({
          fieldName: FieldValue.arrayUnion([productId])
        }, SetOptions(merge: true));
      } else {
        // Remove the ID from the list using ArrayRemove
        await _userDocRef.set({
          fieldName: FieldValue.arrayRemove([productId])
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Firestore update failed for $fieldName: $e");
    }
  }

  Future<void> _updateFirestoreMap({
    required String fieldName,
    required int productId,
    required bool isAdding,
  }) async {
    try {
      final String idKey = productId.toString();

      if (isAdding) {
        // Add the product ID as a key with the current timestamp (milliseconds since epoch)
        await _userDocRef.set({
          fieldName: {
            idKey: FieldValue.serverTimestamp()
          } // Note: Using serverTimestamp is better
        }, SetOptions(merge: true));

        // Note: For merge to work with FieldValue.serverTimestamp() inside a map,
        // you might need to fetch the existing data, update the map locally, and then set it back.
        // However, this simple merge should work for atomic updates in most Firestore SDKs.
        // For robustness, we will switch to using client-side timestamp (millisecondsSinceEpoch)
        // which guarantees the value is available immediately for sync.

        await _userDocRef.set({
          fieldName: {idKey: DateTime.now().millisecondsSinceEpoch}
        }, SetOptions(merge: true));
      } else {
        // Remove the product ID from the map using FieldValue.delete()
        await _userDocRef.update({'$fieldName.$idKey': FieldValue.delete()});
      }
    } catch (e) {
      debugPrint("Firestore map update failed for $fieldName: $e");
    }
  }

  // Future<void> syncListsFromFirestore({Product? singleProduct}) async {
  //   if (currentUserId.value == null) return;

  //   try {
  //     final docSnapshot = await _userDocRef.get();
  //     if (!docSnapshot.exists) return; // Exit if no user document
  //     if (docSnapshot.exists) {
  //       final data = docSnapshot.data() as Map<String, dynamic>;

  //       final List<int> remoteWishlistIds =
  //           (data['wishlistIds'] as List?)?.cast<int>() ?? [];
  //       final List<int> remoteCartIds =
  //           (data['cartIds'] as List?)?.cast<int>() ?? [];

  //       // Helper function to process and update flags/lists
  //       void updateProductStatus(Product product) {
  //         // Check Wishlist
  //         final bool shouldBeLiked = remoteWishlistIds.contains(product.id);
  //         product.isLiked.value = shouldBeLiked;

  //         // Check Cart
  //         final bool shouldBeInCart = remoteCartIds.contains(product.id);
  //         product.isAddedToCart.value = shouldBeInCart;

  //         // Update global reactive lists (wishlist and cart) if necessary
  //         // This is crucial for the badge count on the AppBar
  //         if (shouldBeLiked && !wishlist.any((p) => p.id == product.id)) {
  //           wishlist.add(product);
  //         } else if (!shouldBeLiked) {
  //           wishlist.removeWhere((p) => p.id == product.id);
  //         }

  //         if (shouldBeInCart && !cart.any((p) => p.id == product.id)) {
  //           cart.add(product);
  //         } else if (!shouldBeInCart) {
  //           cart.removeWhere((p) => p.id == product.id);
  //         }
  //       }

  //       // 1. If a single product is provided (Detail Page scenario)
  //       if (singleProduct != null) {
  //         updateProductStatus(singleProduct);
  //         return; // Done with single product sync
  //       }

  //       // 1. Clear local lists before syncing
  //       wishlist.clear();
  //       cart.clear();

  //       // 2. Iterate through ALL products and update their local state
  //       // (You must have access to your main product list here, e.g., in productsController.products)
  //       // This is conceptual, assuming a way to iterate all loaded products:
  //       // final productController = Get.find<ProductController>();

  //       for (var product in products) {
  //         // Reset product flags
  //         product.isLiked.value = false;
  //         product.isAddedToCart.value = false;

  //         updateProductStatus(product);

  //         // if (remoteWishlistIds.contains(product.id)) {
  //         //   product.isLiked.value = true;
  //         //   wishlist.add(product);
  //         // }
  //         // if (remoteCartIds.contains(product.id)) {
  //         //   product.isAddedToCart.value = true;
  //         //   cart.add(product);
  //         // }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error syncing lists from Firestore: $e');
  //   }
  // }

  Future<Product?> _fetchProductDetails(int id) async {
    try {
      final response =
          await http.get(Uri.parse("https://dummyjson.com/products/$id"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming Product.fromJson correctly handles the data
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching details for ID $id: $e");
      return null;
    }
  }

  // Future<void> syncListsFromFirestore({Product? singleProduct}) async {
  //   if (currentUserId.value == null) return;

  //   try {
  //     final docSnapshot = await _userDocRef.get();
  //     if (!docSnapshot.exists) return;

  //     final data = docSnapshot.data() as Map<String, dynamic>;

  //     final List<int> remoteWishlistIds =
  //         (data['wishlistIds'] as List?)?.cast<int>() ?? [];
  //     final List<int> remoteCartIds =
  //         (data['cartIds'] as List?)?.cast<int>() ?? [];

  //     // --- Helper function for processing a single product ---
  //     // This is used for the ProductDetailPage (singleProduct != null)
  //     // and for the main list iteration below.
  //     void updateProductStatus(Product product) {
  //       // 1. Check Wishlist
  //       final bool shouldBeLiked = remoteWishlistIds.contains(product.id);
  //       product.isLiked.value = shouldBeLiked;

  //       // 2. Check Cart
  //       final bool shouldBeInCart = remoteCartIds.contains(product.id);
  //       product.isAddedToCart.value = shouldBeInCart;

  //       // 3. Update global lists if necessary (Crucial for UI lists/badge counts)
  //       if (shouldBeLiked && !wishlist.any((p) => p.id == product.id)) {
  //         wishlist.add(product);
  //       } else if (!shouldBeLiked) {
  //         wishlist.removeWhere((p) => p.id == product.id);
  //       }

  //       if (shouldBeInCart && !cart.any((p) => p.id == product.id)) {
  //         cart.add(product);
  //       } else if (!shouldBeInCart) {
  //         cart.removeWhere((p) => p.id == product.id);
  //       }
  //     }

  //     // --- CASE 1: Detail Page Sync ---
  //     if (singleProduct != null) {
  //       updateProductStatus(singleProduct);
  //       return;
  //     }

  //     // --- CASE 2: Full List Sync (for Home/Wishlist/Cart Screens) ---
  //     // The main lists are fully rebuilt here
  //     wishlist.clear();
  //     cart.clear();

  //     // Collect IDs that are *not* currently loaded in the main `products` list.
  //     final Set<int> neededWishlistIds = remoteWishlistIds.toSet();
  //     final Set<int> neededCartIds = remoteCartIds.toSet();

  //     // Step A: Iterate over all currently loaded products (from API fetch)
  //     // This covers most products already seen by the user.
  //     for (var product in products) {
  //       updateProductStatus(product);
  //       // Remove IDs that were found in the main product list.
  //       neededWishlistIds.remove(product.id);
  //       neededCartIds.remove(product.id);
  //     }

  //     // Step B: Fetch product details for the remaining (unloaded) IDs.
  //     final Set<int> missingIds = neededWishlistIds.union(neededCartIds);

  //     if (missingIds.isNotEmpty) {
  //       // Fetch details for all missing products concurrently (or sequentially if concurrency fails)
  //       final List<Future<Product?>> fetchFutures =
  //           missingIds.map((id) => _fetchProductDetails(id)).toList();

  //       final List<Product?> fetchedProducts = await Future.wait(fetchFutures);

  //       for (final product in fetchedProducts) {
  //         if (product != null) {
  //           // Once fetched, update its status and add to the correct local lists.
  //           updateProductStatus(product);

  //           // OPTIONAL: Add fetched product to the main `products` list
  //           // so it's available next time without re-fetching.
  //           if (!products.any((p) => p.id == product.id)) {
  //             products.add(product);
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error syncing lists from Firestore: $e');
  //   }
  // }

  // 🎯 CRITICAL FIX: This function MUST NOT add to the `products` list.
  Future<void> syncListsFromFirestore({Product? singleProduct}) async {
    if (currentUserId.value == null) return;

    try {
      final docSnapshot = await _userDocRef.get();
      if (!docSnapshot.exists) return;

      final data = docSnapshot.data() as Map<String, dynamic>? ?? {};

      // Get sorted IDs from Firestore (using the timestamp order)
      final remoteWishlistMap =
          (data['wishlistItems'] as Map<String, dynamic>?) ?? {};
      final remoteCartMap = (data['cartItems'] as Map<String, dynamic>?) ?? {};

      final sortedWishlistIds = remoteWishlistMap.entries.toList()
        ..sort((a, b) => (b.value as int).compareTo(a.value as int));
      final remoteWishlistKeys =
          sortedWishlistIds.map((e) => int.parse(e.key)).toList();

      final sortedCartIds = remoteCartMap.entries.toList()
        ..sort((a, b) => (b.value as int).compareTo(a.value as int));
      final remoteCartKeys =
          sortedCartIds.map((e) => int.parse(e.key)).toList();

      // --- CRITICAL FIX: Handle single product directly ---
      if (singleProduct != null) {
        final id = singleProduct.id;
        singleProduct.isLiked.value = remoteWishlistKeys.contains(id);
        singleProduct.isAddedToCart.value = remoteCartKeys.contains(id);
        // Do not proceed with rebuilding global lists if only syncing a single product
        return;
      }
      // --- End Critical Fix ---

      // 1. Create a map of currently loaded products for quick lookup
      final allProductsMap = {for (var p in products) p.id: p};

      // 2. UPDATE FLAGS: This is the primary function when syncing with the main list.
      // We iterate over the main list and set the flags based on remote state.
      for (var product in products) {
        product.isLiked.value = remoteWishlistKeys.contains(product.id);
        product.isAddedToCart.value = remoteCartKeys.contains(product.id);
      }

      // 3. IDENTIFY & FETCH MISSING: Only fetch product details needed for the
      // dedicated Wishlist/Cart views that haven't been loaded in the main catalog yet.
      final neededIds = {...remoteWishlistKeys, ...remoteCartKeys}
          .where((id) => !allProductsMap.containsKey(id))
          .toSet();

      final List<Product> fetchedProducts = [];
      if (neededIds.isNotEmpty) {
        final List<Future<Product?>> fetchFutures =
            neededIds.map((id) => _fetchProductDetails(id)).toList();
        final results = await Future.wait(fetchFutures);

        for (final product in results) {
          if (product != null) {
            product.isLiked.value = remoteWishlistKeys.contains(product.id);
            product.isAddedToCart.value = remoteCartKeys.contains(product.id);
            fetchedProducts.add(product);

            // ❌ IMPORTANT: NO CODE HERE MUST ADD TO products.
          }
        }
      }

      final lookupMap = {
        ...allProductsMap,
        for (var p in fetchedProducts) p.id: p
      };

      // 4. REBUILD DEDICATED LISTS: Build the wishlist/cart lists using the sorted IDs.
      wishlist.clear();
      for (int id in remoteWishlistKeys) {
        final product = lookupMap[id];
        if (product != null) {
          wishlist.add(product);
        }
      }

      cart.clear();
      for (int id in remoteCartKeys) {
        final product = lookupMap[id];
        if (product != null) {
          cart.add(product);
        }
      }
    } catch (e) {
      debugPrint('Error syncing lists from Firestore: $e');
    }
  }

  // // Cart Functions
  // void toggleWishlist(Product product) {
  //   product.isLiked.value = !product.isLiked.value;
  //   if (product.isLiked.value) {
  //     wishlist.add(product);
  //   } else {
  //     wishlist.removeWhere((p) => p.id == product.id);
  //   }
  // }

  // // Wishlist Functions
  // void toggleCart(Product product) {
  //   product.isAddedToCart.value = !product.isAddedToCart.value;
  //   if (product.isAddedToCart.value) {
  //     cart.add(product);
  //   } else {
  //     cart.removeWhere((p) => p.id == product.id);
  //   }
  // }
}
