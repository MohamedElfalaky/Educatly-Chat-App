import 'package:chat_test/services/firebase_servises/auth_service.dart';
import 'package:chat_test/utils/validators.dart';
import 'package:chat_test/utils/widgets/password_form_field.dart';
import 'package:chat_test/views/registration/registration_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("email")),
                  controller: mailController,
                  validator: (value) => Validators.validateEmail(value),
                ),
                const SizedBox(
                  height: 20,
                ),
                PasswordFormField(
                  controller: passwordController,
                  hintText: '',
                  validator: (value) =>
                      Validators.validateStrongPassword(value),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await AuthService().userLogin(
                            mailController.text, passwordController.text);
                      }
                    },
                    child: const Text("Login")),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("you dont have an account?"),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const RegistrationScreen(),
                            ),
                          );
                        },
                        child: const Text("register"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
