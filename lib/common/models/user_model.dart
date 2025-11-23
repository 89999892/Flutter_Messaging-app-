import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a user in the messaging app
class UserModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? status;
  final bool isOnline;
  final DateTime? lastSeen;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.status,
    this.isOnline = false,
    this.lastSeen,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      status: json['status'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? (json['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? status,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoURL,
        status,
        isOnline,
        lastSeen,
      ];
}
