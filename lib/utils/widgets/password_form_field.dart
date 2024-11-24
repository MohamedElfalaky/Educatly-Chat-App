import 'package:flutter/material.dart';

final class PasswordFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? lable;
  final Function(String?) validator;

  const PasswordFormField(
      {super.key,
      this.controller,
      required this.hintText,
      this.lable,
      required this.validator});

  @override
  // ignore: library_private_types_in_public_api
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => widget.validator(value),
      controller: widget.controller,
      obscureText: _obscureText,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      keyboardType: null,
      decoration: InputDecoration(
        label: Text(widget.lable ?? "password"),
        errorMaxLines: 3,
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              key: ValueKey<bool>(_obscureText),
              color: Colors.white,
            ),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
