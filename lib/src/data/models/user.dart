import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:stadium_food/src/data/models/payment_method.dart';
import 'package:hive/hive.dart';

// ignore: must_be_immutable
class User extends Equatable {
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String? image;
  final String fcmToken;
  final List<DocumentReference>? favoriteFoods;
  final List<DocumentReference>? favoriteRestaurants;
  final DateTime createdAt;
  final bool isActive;
  String id;

  User({
    required this.email,
    required this.phone,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    this.image,
    required this.fcmToken,
    this.favoriteFoods,
    this.favoriteRestaurants,
    this.isActive = true,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      id: map['id'],
      phone: map['phone'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      image: map['image'],
      favoriteFoods: map['favoriteFoods'] != null
          ? List<DocumentReference>.from(
              map['favoriteFoods']?.map(
                (x) => x,
              ),
            )
          : null,
      favoriteRestaurants: map['favoriteRestaurants'] != null
          ? List<DocumentReference>.from(
              map['favoriteRestaurants']?.map(
                (x) => x,
              ),
            )
          : null,

      createdAt: map['createdAt'].toDate(),
      fcmToken: map['fcmToken'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'image': image,
      'favoriteFoods': favoriteFoods,
      'favoriteRestaurants': favoriteRestaurants,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'isActive': isActive,
      'type': 'customer',
      'fcmToken': fcmToken,
    };
  }

  factory User.fromHive() {
    var box = Hive.box('myBox');
    return User(
      email: box.get('email', defaultValue: ''),
      id: box.get('id', defaultValue: ''),
      phone: box.get('phone', defaultValue: ''),
      firstName: box.get('firstName', defaultValue: ''),
      lastName: box.get('lastName', defaultValue: ''),
      image: box.get('image', defaultValue: null),
      favoriteFoods: box.get('favoriteFoods') != null
          ? List<DocumentReference>.from(
              box.get('favoriteFoods'),
            )
          : null,
      favoriteRestaurants: box.get('favoriteRestaurants') != null
          ? List<DocumentReference>.from(
              box.get('favoriteRestaurants'),
            )
          : null,

      createdAt: box.get('createdAt', defaultValue: DateTime.now()),
      fcmToken: box.get('fcmToken'),
      isActive: box.get('isActive', defaultValue: true),
    );
  }

  Future<void> saveToHive() async {
    var box = Hive.box('myBox');

    box.put('id', id);
    box.put('email', email);
    box.put('phone', phone);
    box.put('firstName', firstName);
    box.put('lastName', lastName);
    box.put('image', image);
    box.put('favoriteFoods', favoriteFoods);
    box.put('favoriteRestaurants', favoriteRestaurants);
    box.put('createdAt', createdAt);
    box.put('fcmToken', fcmToken);
    box.put('isActive', isActive);
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';
  String get username => email.split('@')[0];
  String get photoUrl => image ?? 'https://ui-avatars.com/api/?name=$firstName+$lastName';

  @override
  List<Object?> get props => [
        email,
        phone,
        firstName,
        lastName,
        image,
        favoriteFoods,
        favoriteRestaurants,
        createdAt,
        fcmToken,
        isActive,
      ];
}
