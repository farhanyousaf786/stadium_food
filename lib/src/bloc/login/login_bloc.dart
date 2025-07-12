import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:stadium_food/src/data/services/firebase_auth.dart';
import 'package:stadium_food/src/data/services/firestore_db.dart';
import 'package:stadium_food/src/data/models/user.dart' as model;
import 'package:hive_flutter/hive_flutter.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginEvent>((event, emit) {});
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      try {
        FirebaseAuth firebaseAuth = FirebaseAuth.instance;

        // sign in with email and password
        await FirebaseAuthService(firebaseAuth).signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        var userDocument = (await FirestoreDatabase().getDocument(
          "customers",
          firebaseAuth.currentUser!.uid
        ));
        
        // Check if account is active
        final userData = userDocument.data() as Map<String, dynamic>;
        final bool isActive = userData['isActive'] ?? true;
        
        if (!isActive) {
          // Sign out the user since their account is inactive
          await firebaseAuth.signOut();
          emit(LoginError(
            error: 'Your account has been deleted. Please contact support to reactivate your account. Contact: switch2future@gmail.com',
          ));
          return;
        }

        // Update FCM token
        await FirestoreDatabase().updateUserDocument(
          'customers',
          userDocument.id,
          {'fcmToken': event.fcmToken},
        );

        // save user data to Hive
        model.User user = model.User.fromMap(userData);
        user.id = userDocument.id;

        user.saveToHive();
        var box = Hive.box("myBox");
        box.put("isRegistered", true);

        // emit success
        emit(LoginSuccess());
      } on FirebaseAuthException catch (e) {
        emit(
          LoginError(
            error: FirebaseAuthService(FirebaseAuth.instance).getErrorString(
              e.code,
            ),
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(LoginError(error: e.toString()));
      }
    });
  }
}
