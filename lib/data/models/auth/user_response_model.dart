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
  final String name;
  final String email;
  final String phone;
  final String image;
  final String password;
  final String address;

  const UserResponse({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.image = '',
    this.address = '',
  });

  UserResponse copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? image,
    String? address,
  }) {
    return UserResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      image: image ?? this.image,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'image': image,
      'address': address,
    };
  }

  factory UserResponse.fromMap(Map<String, dynamic> map) {
    return UserResponse(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
      image: map['image'] ?? '',
      address: map['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserResponse.fromJson(String source) =>
      UserResponse.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      name,
      email,
      phone,
      password,
      image,
      address,
    ];
  }
}
