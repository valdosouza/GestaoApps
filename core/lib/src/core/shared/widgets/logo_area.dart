import 'package:flutter/material.dart';

Widget logoArea() => Center(
      child: Image.asset(
        'packages/core/images/logomarca.png',
        width: 250,
        height: 140,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox(
          width: 250,
          height: 140,
        ),
      ),
    );
