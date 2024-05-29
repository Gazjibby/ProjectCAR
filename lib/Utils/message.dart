import 'package:flutter/material.dart';

void error(BuildContext? context, {required String message}) {
  ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: const Color.fromARGB(230, 224, 17, 17),
  ));
}

void success(BuildContext? context, {required String message}) {
  ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: const Color.fromARGB(230, 3, 133, 255),
  ));
}
