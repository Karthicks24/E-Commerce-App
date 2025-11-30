import 'package:riverpod_annotation/riverpod_annotation.dart';
// part 'sign_up_details.g.dart';


class SignUpDetails {
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;
  
  const SignUpDetails(
    {
    required this.userName, 
    required this.email, 
    required this.password, 
    required this.confirmPassword
    });
}

// @riverpod
// class RegisterNotifier extends _$RegisterNotifier{
  
//   @override
//   RegisterState build(){
//     return RegisterState();
//   }

//   void onUserNameChange(String name){
//     state = state.copywith(username : name);
//   }
// }

class LoginRequest{
  int? type;
  String? name;
  String? description;
  String? email;
  String? phone;
  String? avatar;
  String? openId;
  int? online;

  LoginRequest({
    this.type,
    this.name,
    this.description,
    this.email,
    this.phone,
    this.avatar,
    this.openId,
    this.online
  });
}

class UserLoginResponse{
  int? code;
  String? msg;
  UserProfile? data;

  UserLoginResponse({
    this.code,
    this.msg,
    this.data
  });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json){
    return UserLoginResponse(
      code: json["code"],
      msg: json["msg"],
      data: UserProfile.fromJson(json["data"])
    );
  }
}

class UserProfile{
  String? accessToken;
  String? token;
  String? name;
  String? description;
  String? avatar;
  int? online;
  int? type;

  UserProfile({
    this.accessToken,
    this.token,
    this.name,
    this.description,
    this.avatar,
    this.online,
    this.type
  });

  factory UserProfile.fromJson(Map<String, dynamic> json){
    return UserProfile(
      accessToken: json["accessToken"],
      token: json["token"],
      name: json["name"],
      description: json["description"],
      avatar: json["avatar"],
      online: json["online"],
      type: json["type"]
      );
  }
  Map <String, dynamic> toJson()=>{
        "accessToken" : accessToken,
        "token" : token,
        "name" : name,
        "description" : description,
        "avatar" : avatar,
        "online" : online,
        "type" : type
      };
}