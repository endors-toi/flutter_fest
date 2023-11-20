import 'package:flutter/material.dart';

void mostrarSnackbar(BuildContext context, String mensaje) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }
}
