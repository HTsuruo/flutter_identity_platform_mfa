import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_identity_platform_mfa/auth_repository.dart';
import 'package:flutter_identity_platform_mfa/scaffold_messagener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsuruo_kit/tsuruo_kit.dart';

final signInUpController = Provider(
  (ref) => SignInUpController(ref.read),
);

class SignInUpController {
  SignInUpController(this._read);
  final Reader _read;
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  ScaffoldMessengerState get _messenger =>
      _read(scaffoldMessengerProvider).currentState!;

  Future<void> signUp() async {
    final result = await _read(progressController).executeWithProgress(
      () => _read(authRepository).createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      ),
    );
    if (!result.success) {
      _messenger.showSnackBar(
        SnackBar(content: Text(result.exception!.code)),
      );
      return;
    }
  }

  Future<void> signIn() async {
    final result = await _read(progressController).executeWithProgress(
      () => _read(authRepository).signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      ),
    );
    if (!result.success) {
      _messenger.showSnackBar(
        SnackBar(content: Text(result.exception!.code)),
      );
      return;
    }
  }
}
