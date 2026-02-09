import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../data_provider/database_config.dart';

/// Model representing a chat user
class ChatUserModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String image;
  final String deviceToken;
  final bool status;
  final bool isOnline;
  final DateTime? lastSeen;

  const ChatUserModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.image = '',
    this.deviceToken = '',
    this.status = false,
    this.isOnline = false,
    this.lastSeen,
  });

  /// Full name of the user
  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isEmpty && last.isEmpty) {
      return email.isNotEmpty ? email.split('@').first : 'Unknown User';
    }
    return '$first $last'.trim();
  }

  /// Check if user has a profile image
  bool get hasProfileImage => image.trim().isNotEmpty;

  /// Create a copy with modified fields
  ChatUserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? image,
    String? deviceToken,
    bool? status,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ChatUserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      deviceToken: deviceToken ?? this.deviceToken,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DatabaseConfig.fieldUserId: id,
      DatabaseConfig.fieldFirstName: firstName,
      DatabaseConfig.fieldLastName: lastName,
      DatabaseConfig.fieldEmail: email,
      DatabaseConfig.fieldPhone: phone,
      DatabaseConfig.fieldImage: image,
      DatabaseConfig.fieldDeviceToken: deviceToken,
      DatabaseConfig.fieldStatus: status,
      DatabaseConfig.fieldIsOnline: isOnline,
      DatabaseConfig.fieldLastSeen: lastSeen != null
          ? Timestamp.fromDate(lastSeen!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firebase Map
  factory ChatUserModel.fromMap(Map<String, dynamic> map) {
    DateTime? lastSeenDate;
    final lastSeenValue = map[DatabaseConfig.fieldLastSeen];
    if (lastSeenValue != null) {
      if (lastSeenValue is Timestamp) {
        lastSeenDate = lastSeenValue.toDate();
      } else if (lastSeenValue is String) {
        lastSeenDate = DateTime.tryParse(lastSeenValue);
      }
    }

    return ChatUserModel(
      id: map[DatabaseConfig.fieldUserId] as String? ?? '',
      firstName: map[DatabaseConfig.fieldFirstName] as String? ?? '',
      lastName: map[DatabaseConfig.fieldLastName] as String? ?? '',
      email: map[DatabaseConfig.fieldEmail] as String? ?? '',
      phone: map[DatabaseConfig.fieldPhone] as String? ?? '',
      image: map[DatabaseConfig.fieldImage] as String? ?? '',
      deviceToken: map[DatabaseConfig.fieldDeviceToken] as String? ?? '',
      status: map[DatabaseConfig.fieldStatus] as bool? ?? false,
      isOnline: map[DatabaseConfig.fieldIsOnline] as bool? ?? false,
      lastSeen: lastSeenDate,
    );
  }

  /// Create from Firebase DocumentSnapshot
  factory ChatUserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return ChatUserModel.fromMap({...data, DatabaseConfig.fieldUserId: doc.id});
  }

  String toJson() => json.encode(toMap());

  factory ChatUserModel.fromJson(String source) =>
      ChatUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    image,
    deviceToken,
    status,
    isOnline,
    lastSeen,
  ];
}
