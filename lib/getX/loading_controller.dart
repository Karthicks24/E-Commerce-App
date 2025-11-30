import 'package:get/get.dart';

class LoadingController extends GetxController{
  RxBool isLoading = false.obs;

  void showLoading(){
    isLoading.value = true;
  }

  void closeLoading(){
    isLoading.value = false;
  }
}