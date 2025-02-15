import 'package:flutter/material.dart';

Widget buildBottomNavBar() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: Colors.red[800]),
    child: Row(
      children: [
        const SizedBox(width: 30),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'images/ntgschool.png',
            width: 80,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'NTG School',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          '2025',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        const Spacer(),
      ],
    ),
  );
}
