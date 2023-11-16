import 'package:flutter/material.dart';

class FormInputField extends StatelessWidget {
  const FormInputField({
    Key? key,
    required this.ispassword,
    required this.labelText,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.onchanged,
  }) : super(key: key);

  final String labelText;
  final bool ispassword;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final void Function(String?) onchanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextFormField(
        style: const TextStyle(
          height: 1.5,
          fontSize: 17,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              width: 0.0,
              color: Colors.black,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              width: 0.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 0.0,
            ),
          ),
          labelStyle: const TextStyle(fontSize: 15, color: Colors.black),
          labelText: labelText,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.black26,
              width: 1.0,
            ),
          ),
          errorStyle: const TextStyle(
            fontSize: 14,
          ),
        ),
        keyboardType: TextInputType.text,
        obscureText: ispassword,
        validator: validator,
        onChanged: onchanged,
      ),
    );
  }
}
