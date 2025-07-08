import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';

import 'package:stadium_food/src/data/services/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../../data/services/firestore_db.dart';
import '../../data/models/user.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      emit(RegisterLoading());

      try {
        FirebaseAuth firebaseAuth = FirebaseAuth.instance;

        await FirebaseAuthService(firebaseAuth).createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        String userUid=firebaseAuth.currentUser!.uid;

        final user = User(
          email: event.email,
          phone: '',
          id:userUid,
          firstName: '',
          lastName: '',
          fcmToken: '',
          createdAt: DateTime.now(),
        );
        
        await FirestoreDatabase().addUserDocument('customers', userUid, user.toMap());
        var box = Hive.box('myBox');
        box.put('email', event.email);
        box.put('id', userUid);
        emit(RegisterSuccess());
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(RegisterError(error: e.toString()));
      }
    });
  }
}
