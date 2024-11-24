import 'package:chat_test/services/firebase_servises/auth_service.dart';
import 'package:chat_test/utils/validators.dart';
import 'package:chat_test/utils/widgets/password_form_field.dart';
import 'package:chat_test/views/login/login_screen.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Registration",
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(label: Text("user name")),
                    controller: userNameController,
                    validator: (value) => Validators.validateName(value),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(label: Text("email")),
                    controller: emailController,
                    validator: (value) => Validators.validateEmail(value),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  PasswordFormField(
                    hintText: '',
                    controller: passwordController,
                    validator: (value) =>
                        Validators.validateStrongPassword(value),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  PasswordFormField(
                    lable: 'Re-Enter password',
                    hintText: '',
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "passwords dont match";
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          AuthService().userRegister(
                              mail: emailController.text,
                              password: passwordController.text,
                              username: userNameController.text);
                        }
                      },
                      child: const Text("Register")),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("you have an account?"),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text("Login"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
