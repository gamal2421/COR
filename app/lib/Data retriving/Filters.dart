// Filters.dart (or wherever applyFilters is defined)
import 'package:corr/Else/Variables.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<String> getActiveFilterFields(
    bool isSkillsChecked,
    bool isCertificationChecked,
    bool isEducationChecked,
    bool isLanguageChecked) {
  List<String> activeFields = [];
  if (isSkillsChecked) activeFields.add('Skills');
  if (isCertificationChecked) activeFields.add('Certifications');
  if (isEducationChecked) activeFields.add('Education');
  if (isLanguageChecked) activeFields.add('Languages');
  // If no filters active, we at least search in 'Full Name'
  if (activeFields.isEmpty) activeFields.add('Full Name');
  return activeFields;
}

void applyFilters(
    List<Map<String, dynamic>> allCVs,
    bool isSkillsChecked,
    bool isCertificationChecked,
    bool isEducationChecked,
    bool isLanguageChecked,
    String searchQuery,
    BuildContext context,
    Function setState) {
  List<Map<String, dynamic>> filtered;

  // If no filters and no search query, then display all CVs.
  if (!isSkillsChecked &&
      !isCertificationChecked &&
      !isEducationChecked &&
      !isLanguageChecked &&
      searchQuery.trim().isEmpty) {
    filtered = List.from(allCVs);
  } else {
    filtered = allCVs.where((cv) {
      // Check filters: if a filter is active but the corresponding field is empty, skip this CV.
      if (isEducationChecked &&
          (cv['Education'] == null ||
              cv['Education'].toString().trim().isEmpty)) {
        return false;
      }
      if (isSkillsChecked &&
          (cv['Skills'] == null || cv['Skills'].toString().trim().isEmpty)) {
        return false;
      }
      if (isCertificationChecked &&
          (cv['Certifications'] == null ||
              cv['Certifications'].toString().trim().isEmpty)) {
        return false;
      }
      if (isLanguageChecked &&
          (cv['Languages'] == null ||
              cv['Languages'].toString().trim().isEmpty)) {
        return false;
      }
      if (searchQuery.trim().isNotEmpty) {
        final searchTerms = searchQuery
            .split(RegExp(r'\s+'))
            .where((term) => term.isNotEmpty)
            .toList();
        bool matchesAllTerms = searchTerms.every((term) {
          return getActiveFilterFields(
                  isSkillsChecked, isCertificationChecked, isEducationChecked, isLanguageChecked)
              .any((field) {
            final fieldValue = (cv[field] ?? '').toString().toLowerCase();
            return fieldValue.contains(term.toLowerCase());
          });
        });
        if (!matchesAllTerms) return false;
      }
      return true;
    }).toList();
  }
  setState(() {
    displayedCVs.clear();
    displayedCVs.addAll(filtered);
  });
}


void filterProjects(
   List<String> projectNames,
  List<Map<String, dynamic>> allCVs,
  String selectedProjectFilter,
    String selectedTechnologyFilter,
      List<BarChartGroupData> filteredBarGroups,
    Function func
) {
    List<BarChartGroupData> barGroups = [];
    Map<String, int> projectCounts = {};
    projectNames = [];

    for (var cv in allCVs) {
      if (cv['Projects'] is List) {
        for (var project in cv['Projects']) {
          if (project is Map && project['Name'] is String) {
            // Apply Project Name Filter
            bool projectMatch = selectedProjectFilter == "All Projects" ||
                project['Name'] == selectedProjectFilter;
            // Apply Technology Filter
            bool techMatch = selectedTechnologyFilter == "All Technologies" ||
                (project['Technologies'] is List &&
                    (project['Technologies'] as List).any(
                        (tech) => tech['Name'] == selectedTechnologyFilter));

            if (projectMatch && techMatch) {
              String projectName = project['Name'];
              projectCounts[projectName] =
                  (projectCounts[projectName] ?? 0) + 1;
            }
          }
        }
      }
    }

    int index = 0;
    projectCounts.forEach((projectName, count) {
      projectNames.add(projectName);
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blue,
              width: 20,
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      index++;
    });

    func(() {
      filteredBarGroups = barGroups; // Ensure this is set
    });
  } 
  bool isFieldEmpty(dynamic value) {
  if (value == null) return true;
  if (value is String && value.trim().isEmpty) return true;
  if (value is List && value.isEmpty) return true;
  return false;
}