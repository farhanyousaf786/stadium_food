import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:stadium_food/src/data/services/firestore_db.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(UserProfileInitial()) {
    on<UpdateUserProfile>((event, emit) async {
      emit(UserProfileLoading());

      try {
        final String userUid = FirebaseAuth.instance.currentUser!.uid;
        
        await FirestoreDatabase().updateUserDocument('customers', userUid, {
          'firstName': event.firstName,
          'lastName': event.lastName,
          'phone': event.phone,
          'email': FirebaseAuth.instance.currentUser!.email,
          'photoUrl': event.photoUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        emit(UserProfileSuccess());
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(UserProfileError(error: e.toString()));
      }
    });
  }
}
