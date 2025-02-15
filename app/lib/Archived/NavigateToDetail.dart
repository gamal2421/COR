import 'package:corr/Pages/ArchivedCVsDetails.dart';
import 'package:flutter/material.dart';

void navigateToDetail(BuildContext context, Map<String, dynamic> cv) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => archivedt(cv: cv),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    ),
  );
}
