// buildSidebarFilters.dart
import 'package:corr/Else/Variables.dart';
import 'package:corr/Data%20retriving/Filters.dart';
import 'package:flutter/material.dart';

Widget buildSidebarFilters(double screenHeight, Function setState, BuildContext context) {
  return Container(
    width: 250,
    height: screenHeight,
    color: Colors.grey[100],
    padding: const EdgeInsets.all(16.0),
    child: ListView(
      children: [
        const Text(
          'Filters',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text(
              'Skills',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Checkbox(
              value: isSkillsChecked,
              onChanged: (bool? newValue) {
                setState(() {
                  isSkillsChecked = newValue!;
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
              activeColor: Colors.red,
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            const Text(
              'Certifications',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Checkbox(
              value: isCertificationChecked,
              onChanged: (bool? newValue) {
                setState(() {
                  isCertificationChecked = newValue!;
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
              activeColor: Colors.red,
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            const Text(
              'Education',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Checkbox(
              value: isEducationChecked,
              onChanged: (bool? newValue) {
                setState(() {
                  isEducationChecked = newValue!;
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
              activeColor: Colors.red,
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            const Text(
              'Languages',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Checkbox(
              value: isLanguageChecked,
              onChanged: (bool? newValue) {
                setState(() {
                  isLanguageChecked = newValue!;
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
              activeColor: Colors.red,
            ),
          ],
        ),
      ],
    ),
  );
}
