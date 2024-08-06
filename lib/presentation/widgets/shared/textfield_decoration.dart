import 'package:flutter/material.dart';

InputDecoration _getInputDecoration(String labelText, FocusNode focusNode) {
  return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.blue.shade300),
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
      ),
      enabledBorder: focusNode.hasFocus
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
            )
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 0),
            ));
}
