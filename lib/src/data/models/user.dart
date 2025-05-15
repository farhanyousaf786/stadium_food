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
  final List<DocumentReference>? favoriteFoods;
  final List<DocumentReference>? favoriteRestaurants;
  final DateTime createdAt;
  String? id;

  User({
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    this.image,
    this.favoriteFoods,
    this.favoriteRestaurants,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
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
      'isActive': true,
      'type': 'customer'
    };
  }

  factory User.fromHive() {
    var box = Hive.box('myBox');
    return User(
      email: box.get('email', defaultValue: ''),
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
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';

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
      ];
}
