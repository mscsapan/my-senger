import 'dart:convert';

import 'package:equatable/equatable.dart';

class Errors extends Equatable {
  final List<String> name;
  final List<String> title;
  final List<String> details;
  final List<String> description;
  final List<String> image;
  final List<String> categoryId;
  final List<String> username;
  final List<String> email;
  final List<String> phone;
  final List<String> password;
  final List<String> address;
  final List<String> designation;
  final List<String> serviceArea;
  final List<String> country;
  final List<String> state;
  final List<String> city;
  final List<String> subject;
  final List<String> message;
  final List<String> review;
  final List<String> totalFollower;
  final List<String> totalFollowing;
  final List<String> tags;
  final List<String> packageFeatures;

  final List<String> shortName;
  final List<String> shopName;
  final List<String> slug;
  final List<String> thumbImage;
  final List<String> category;
  final List<String> shortDescription;
  final List<String> longDescription;
  final List<String> price;
  final List<String> status;
  final List<String> weight;
  final List<String> quantity;
  final List<String> zipCode;
  final List<String> openAt;
  final List<String> closedAt;
  final List<String> greeting;
  final List<String> aboutMe;

  final List<String> methodId;
  final List<String> withdrawAmount;
  final List<String> accountInfo;
  final List<String> day;
  final List<String> startTime;
  final List<String> endTime;
  final List<String> currentPassword;

  const Errors({
    required this.email,
    required this.username,
    required this.title,
    required this.phone,
    required this.password,
    required this.designation,
    required this.serviceArea,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.subject,
    required this.message,
    required this.review,
    required this.shortName,
    required this.name,
    required this.image,
    required this.details,
    required this.description,
    required this.categoryId,
    required this.shopName,
    required this.slug,
    required this.thumbImage,
    required this.category,
    required this.shortDescription,
    required this.longDescription,
    required this.price,
    required this.status,
    required this.weight,
    required this.quantity,
    required this.zipCode,
    required this.openAt,
    required this.closedAt,
    required this.greeting,
    required this.aboutMe,
    required this.methodId,
    required this.withdrawAmount,
    required this.accountInfo,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.currentPassword,
    required this.totalFollower,
    required this.totalFollowing,
    required this.tags,
    required this.packageFeatures,
  });

  Errors copyWith({
    List<String>? email,
    List<String>? phone,
    List<String>? password,
    List<String>? designation,
    List<String>? serviceArea,
    List<String>? username,
    List<String>? title,
    List<String>? country,
    List<String>? state,
    List<String>? city,
    List<String>? subject,
    List<String>? message,
    List<String>? review,
    List<String>? shortName,
    List<String>? name,
    List<String>? image,
    List<String>? details,
    List<String>? description,
    List<String>? categoryId,
    List<String>? shopName,
    List<String>? slug,
    List<String>? thumbImage,
    List<String>? category,
    List<String>? shortDescription,
    List<String>? longDescription,
    List<String>? price,
    List<String>? status,
    List<String>? weight,
    List<String>? quantity,
    List<String>? zipCode,
    List<String>? openAt,
    List<String>? closedAt,
    List<String>? greeting,
    List<String>? aboutMe,
    List<String>? methodId,
    List<String>? withdrawAmount,
    List<String>? address,
    List<String>? accountInfo,
    List<String>? day,
    List<String>? startTime,
    List<String>? endTime,
    List<String>? currentPassword,
    List<String>? totalFollower,
    List<String>? totalFollowing,
    List<String>? tags,
    List<String>? packageFeatures,
  }) {
    return Errors(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      username: username ?? this.username,
      title: title ?? this.title,
      designation: designation ?? this.designation,
      serviceArea: serviceArea ?? this.serviceArea,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      subject: subject ?? this.subject,
      address: address ?? this.address,
      message: message ?? this.message,
      review: review ?? this.review,
      name: name ?? this.name,
      image: image ?? this.image,
      details: details ?? this.details,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      shopName: shopName ?? this.shopName,
      shortName: shortName ?? this.shortName,
      thumbImage: thumbImage ?? this.thumbImage,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      status: status ?? this.status,
      weight: weight ?? this.weight,
      zipCode: zipCode ?? this.zipCode,
      openAt: openAt ?? this.openAt,
      closedAt: closedAt ?? this.closedAt,
      greeting: greeting ?? this.greeting,
      aboutMe: aboutMe ?? this.aboutMe,
      methodId: methodId ?? this.methodId,
      withdrawAmount: withdrawAmount ?? this.withdrawAmount,
      accountInfo: accountInfo ?? this.accountInfo,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      currentPassword: currentPassword ?? this.currentPassword,
      totalFollower: totalFollower ?? this.totalFollower,
      totalFollowing: totalFollowing ?? this.totalFollowing,
      tags: tags ?? this.tags,
      packageFeatures: packageFeatures ?? this.packageFeatures,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'title': title,
      'image': image,
      'details': details,
      'description': description,
      'category_id': categoryId,
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
      'designation': designation,
      'address': address,
      'service_area': serviceArea,
      'country': country,
      'state': state,
      'city': city,
      'subject': subject,
      'message': message,
      'review': review,
      'shop_name': shopName,
      'short_name': shortName,
      'thumb_image': thumbImage,
      'slug': slug,
      'category': category,
      'price': price,
      'quantity': quantity,
      'short_description': shortDescription,
      'long_description': longDescription,
      'status': status,
      'weight': weight,
      'zip_code': weight,
      'opens_at': openAt,
      'closed_at': closedAt,
      'greeting_msg': greeting,
      'method_id': methodId,
      'withdraw_amount': withdrawAmount,
      'account_info': accountInfo,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'current_password': currentPassword,
      'total_follower': totalFollower,
      'total_following': totalFollowing,
      'tags': tags,
      'package_features': packageFeatures,
    };
  }

  factory Errors.fromMap(Map<String, dynamic> map) {
    return Errors(
      username: map['username'] != null
          ? List<String>.from(map['username'].map((x) => x))
          : [],
      title: map['title'] != null
          ? List<String>.from(map['title'].map((x) => x))
          : [],
      email: map['email'] != null
          ? List<String>.from(map['email'].map((x) => x))
          : [],
      phone: map['phone'] != null
          ? List<String>.from(map['phone'].map((x) => x))
          : [],
      password: map['password'] != null
          ? List<String>.from(map['password'].map((x) => x))
          : [],
      address: map['address'] != null
          ? List<String>.from(map['address'].map((x) => x))
          : [],
      serviceArea: map['service_area'] != null
          ? List<String>.from(map['service_area'].map((x) => x))
          : [],
      designation: map['designation'] != null
          ? List<String>.from(map['designation'].map((x) => x))
          : [],
      country: map['country'] != null
          ? List<String>.from(map['country'].map((x) => x))
          : [],
      state: map['state'] != null
          ? List<String>.from(map['state'].map((x) => x))
          : [],
      city: map['city'] != null
          ? List<String>.from(map['city'].map((x) => x))
          : [],
      subject: map['subject'] != null
          ? List<String>.from(map['subject'].map((x) => x))
          : [],
      message: map['message'] != null
          ? List<String>.from(map['message'].map((x) => x))
          : [],
      review: map['review'] != null
          ? List<String>.from(map['review'].map((x) => x))
          : [],
      name: map['name'] != null
          ? List<String>.from(map['name'].map((x) => x))
          : [],
      image: map['image'] != null
          ? List<String>.from(map['image'].map((x) => x))
          : [],
      details: map['details'] != null
          ? List<String>.from(map['details'].map((x) => x))
          : [],
      description: map['description'] != null
          ? List<String>.from(map['description'].map((x) => x))
          : [],
      categoryId: map['category_id'] != null
          ? List<String>.from(map['category_id'].map((x) => x))
          : [],
      shopName: map['shop_name'] != null
          ? List<String>.from(map['shop_name'].map((x) => x))
          : [],
      shortName: map['short_name'] != null
          ? List<String>.from(map['short_name'].map((x) => x))
          : [],
      thumbImage: map['thumb_image'] != null
          ? List<String>.from(map['thumb_image'].map((x) => x))
          : [],
      slug: map['slug'] != null
          ? List<String>.from(map['slug'].map((x) => x))
          : [],
      category: map['category'] != null
          ? List<String>.from(map['category'].map((x) => x))
          : [],
      price: map['price'] != null
          ? List<String>.from(map['price'].map((x) => x))
          : [],
      quantity: map['quantity'] != null
          ? List<String>.from(map['quantity'].map((x) => x))
          : [],
      shortDescription: map['short_description'] != null
          ? List<String>.from(map['short_description'].map((x) => x))
          : [],
      longDescription: map['long_description'] != null
          ? List<String>.from(map['long_description'].map((x) => x))
          : [],
      status: map['status'] != null
          ? List<String>.from(map['status'].map((x) => x))
          : [],
      weight: map['weight'] != null
          ? List<String>.from(map['weight'].map((x) => x))
          : [],
      zipCode: map['zip_code'] != null
          ? List<String>.from(map['zip_code'].map((x) => x))
          : [],
      openAt: map['opens_at'] != null
          ? List<String>.from(map['opens_at'].map((x) => x))
          : [],
      closedAt: map['closed_at'] != null
          ? List<String>.from(map['closed_at'].map((x) => x))
          : [],
      greeting: map['greeting_msg'] != null
          ? List<String>.from(map['greeting_msg'].map((x) => x))
          : [],
      aboutMe: map['about_me'] != null
          ? List<String>.from(map['about_me'].map((x) => x))
          : [],
      methodId: map['method_id'] != null
          ? List<String>.from(map['method_id'].map((x) => x))
          : [],
      withdrawAmount: map['withdraw_amount'] != null
          ? List<String>.from(map['withdraw_amount'].map((x) => x))
          : [],
      accountInfo: map['account_info'] != null
          ? List<String>.from(map['account_info'].map((x) => x))
          : [],
      day:
          map['day'] != null ? List<String>.from(map['day'].map((x) => x)) : [],
      startTime: map['start_time'] != null
          ? List<String>.from(map['start_time'].map((x) => x))
          : [],
      endTime: map['end_time'] != null
          ? List<String>.from(map['end_time'].map((x) => x))
          : [],
      currentPassword: map['current_password'] != null
          ? List<String>.from(map['current_password'].map((x) => x))
          : [],
      totalFollower: map['total_follower'] != null
          ? List<String>.from(map['total_follower'].map((x) => x))
          : [],
      totalFollowing: map['total_following'] != null
          ? List<String>.from(map['total_following'].map((x) => x))
          : [],
      tags: map['tags'] != null
          ? List<String>.from(map['tags'].map((x) => x))
          : [],
      packageFeatures: map['package_features'] != null
          ? List<String>.from(map['package_features'].map((x) => x))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Errors.fromJson(String source) =>
      Errors.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        name,
        title,
        image,
        categoryId,
        details,
        description,
        shopName,
        email,
        phone,
        country,
        state,
        city,
        shortName,
        thumbImage,
        slug,
        category,
        price,
        quantity,
        shortDescription,
        longDescription,
        status,
        weight,
        zipCode,
        openAt,
        closedAt,
        greeting,
        aboutMe,
        methodId,
        withdrawAmount,
        accountInfo,
        designation,
        day,
        startTime,
        endTime,
        username,
        email,
        phone,
        totalFollower,
        totalFollowing,
        tags,
        packageFeatures,
        serviceArea,
        designation,
        country,
        state,
        city,
        subject,
        message,
        slug,
        price,
        currentPassword,
      ];
}
