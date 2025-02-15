// buildSearchBar.dart
import 'package:corr/Else/Variables.dart';
import 'package:corr/Data%20retriving/Filters.dart';
import 'package:flutter/material.dart';

Widget buildSearchBar(double screenWidth, Function setState, BuildContext context, String text) {
  return Padding(
    padding: EdgeInsets.all(screenWidth * 0.04),
    child: Align(
      alignment: Alignment.topRight,
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
          applyFilters(
              allCVs,
              isSkillsChecked,
              isCertificationChecked,
              isEducationChecked,
              isLanguageChecked,
              searchQuery,
              context,
              setState);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.red[800]),
          hintText: text,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[800]!, width: 2),
          ),
        ),
      ),
    ),
  );
}
