import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserResponseModel extends Equatable {
  final String accessToken;
  final String tokenType;
  final int isVendor;
  final int expireIn;
  final UserResponse? user;

  const UserResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.isVendor,
    required this.expireIn,
    required this.user,
  });

  UserResponseModel copyWith({
    String? accessToken,
    String? tokenType,
    int? isVendor,
    int? expireIn,
    UserResponse? user,
  }) {
    return UserResponseModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      isVendor: isVendor ?? this.isVendor,
      expireIn: expireIn ?? this.expireIn,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'access_token': accessToken,
      'token_type': tokenType,
      'is_vendor': isVendor,
      'expires_in': expireIn,
      'user': user!.toMap(),
    };
  }

  factory UserResponseModel.fromMap(Map<String, dynamic> map) {
    return UserResponseModel(
      accessToken: map['access_token'] ?? '',
      tokenType: map['token_type'] ?? '',
      isVendor: map['is_vendor'] ?? 0,
      expireIn: map['expires_in'] ?? 0,
      user: map['user'] != null
          ? UserResponse.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserResponseModel.fromJson(String source) =>
      UserResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      accessToken,
      tokenType,
      isVendor,
      expireIn,
      user!,
    ];
  }
}

class UserResponse extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String loginEmail;
  final String signUpEmail;
  final String phone;
  final String image;
  final String loginPassword;
  final String signUpPassword;
  final String signUpConPassword;
  final String address;
  final bool isActive;
  final bool showPassword;
  final bool show;
  final bool showConfirm;

  const UserResponse({
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.loginEmail = '',
    this.signUpEmail = '',
    this.phone = '',
    this.image = '',
    this.loginPassword = '',
    this.signUpPassword = '',
    this.signUpConPassword = '',
    this.address = '',
    this.isActive = false,
    this.showPassword = true,
    this.show = true,
    this.showConfirm = false,
  });

  UserResponse copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? loginEmail,
    String? signUpEmail,
    String? phone,
    String? image,
    String? loginPassword,
    String? signUpPassword,
    String? signUpConPassword,
    String? address,
    bool? isActive,
    bool? showPassword,
    bool? show,
    bool? showConfirm,
  }) {
    return UserResponse(
        id : id ?? this.id,
        firstName : firstName ?? this.firstName,
        lastName : lastName ?? this.lastName,
        loginEmail : loginEmail ?? this.loginEmail,
        signUpEmail : signUpEmail ?? this.signUpEmail,
        phone : phone ?? this.phone,
        image : image ?? this.image,
        loginPassword : loginPassword ?? this.loginPassword,
        signUpPassword : signUpPassword ?? this.signUpPassword,
        signUpConPassword : signUpConPassword ?? this.signUpConPassword,
        address : address ?? this.address,
        isActive : isActive ?? this.isActive,
        showPassword : showPassword ?? this.showPassword,
        show : show ?? this.show,
        showConfirm : showConfirm ?? this.showConfirm,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': firstName,
      'email': loginEmail,
      'phone': phone,
      'password': loginPassword,
      'image': image,
      'address': address,
    };
  }

  factory UserResponse.fromMap(Map<String, dynamic> map) {
    return UserResponse(
      id: map['id'] ?? '',
      firstName: map['name'] ?? '',
      loginEmail: map['email'] ?? '',
      phone: map['phone'] ?? '',
      loginPassword: map['password'] ?? '',
      image: map['image'] ?? '',
      address: map['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserResponse.fromJson(String source) => UserResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;


  bool get validateLoginField => [loginEmail,loginPassword].every((e)=>e.trim().isNotEmpty);

  bool get validateSignUpField {

    final fieldsNotEmpty = [signUpEmail, signUpPassword, signUpConPassword].every((e) => e.trim().isNotEmpty);

    final passwordValid = signUpPassword.length >= 6;
    final confirmPasswordValid = signUpConPassword.length >= 6;
    final passwordsMatch = signUpPassword == signUpConPassword;

    return fieldsNotEmpty && passwordValid && confirmPasswordValid && passwordsMatch;
  }

  @override
  List<Object> get props {
    return [
      id,
      firstName,
      lastName,
      loginEmail,
      signUpEmail,
      phone,
      image,
      loginPassword,
      signUpPassword,
      signUpConPassword,
      address,
      isActive,
      showPassword,
      show,
      showConfirm,
    ];
  }
}
