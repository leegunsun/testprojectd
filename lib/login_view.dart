import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_authenticator/src/enums/signin_types.dart';
import 'package:amplify_authenticator/src/widgets/component.dart';
import 'package:amplify_authenticator/src/widgets/form_field.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용자 로그인')),
      body: AuthenticatorForm(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const FlutterLogo(size: 100), // 커스텀 로고 추가
              // SignInFormField.username(
              //   validator: (UsernameInput? input) {
              //     final username = input?.username;
              //     if (username == null || username.isEmpty) {
              //       return '사용자 이름을 입력하세요.';
              //     }
              //     if (!username.contains('amplify')) {
              //       return '사용자 이름에 "amplify"를 포함해야 합니다.';
              //     }
              //     return null;
              //   },
              // ),
              SignInFormField.password(),
            ],
          ),
        ),
      ),
    );
  }
}