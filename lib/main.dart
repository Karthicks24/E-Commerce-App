import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learning_app/basic/theme_color.dart';
import 'package:learning_app/getX/bottom_nav_controller.dart';
import 'package:learning_app/getX/loading_controller.dart';
import 'package:learning_app/getX/products_controller.dart';
import 'package:learning_app/getX/user_controller.dart';
import 'package:learning_app/screens/get_started.dart';
import 'package:learning_app/screens/main_screen.dart';
import 'package:learning_app/screens/auth/login_page.dart';
import 'package:learning_app/utils/global.dart';
import 'package:learning_app/widgets/other_widgets.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){
    await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAHcEN9MvFIU04ogOxY6yUkukuMOYTI6Qw",
      authDomain: "learning-app-project-52223.firebaseapp.com",
      projectId: "learning-app-project-52223",
      storageBucket: "learning-app-project-52223.firebasestorage.app",
      messagingSenderId: "1004409688457",
      appId: "1:1004409688457:web:c1e487f464acb901d81158",
      measurementId: "G-H1EQFTT2V5"
    ));
  } else{
    await Firebase.initializeApp();
  }
  Get.put(LoadingController()); // Register the controller globally
  Get.put(FirstTime());
  Get.put(UserController()); // initialize after firebas
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final BottomNavController navController = Get.put(BottomNavController());
  final ProductController productController = Get.put(ProductController());
  // final UserController userController = Get.put(UserController());
  // final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final FirstTime globalController = Get.find<FirstTime>();
    return ScreenUtilInit(
      minTextAdapt: true,
      child: GetMaterialApp(
        title: 'E-Commmerce',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          fontFamily: 'Urbanist',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor),
          useMaterial3: true,
        ),
        home: Obx(()=> globalController.isFirstTime.value
        ? GetStarted()
        : StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting){
              return const CustomLoader();
            }
            // 2a. If the user data exists (fully looged in)
            else if (snapshot.hasData){
              if (globalController.isGuestUser.value) {
                globalController.toggleGuestLog(false); // Setting it false for safety
              }
              return const MainScreen();
            }
            // 2b. If no user data (not looged in)
            else {
              // Checking if guest user exists
              if (globalController.isGuestUser.value){
                return const MainScreen();
              } else {
                return const LoginPage();
              }
            }
          }
          // builder: (context, snapshot) {
          //   if(snapshot.connectionState == ConnectionState.waiting){
          //     return const CustomLoader();
          //   } else if(snapshot.hasData){
          //     return const MainScreen();
          //   } else{
          //     return const LoginPage();
          //   }
          // } ,
          )),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
