import 'package:corr/Else/Variables.dart';
import 'package:corr/Else/SnackBar.dart';
import 'package:flutter/material.dart';
import 'package:corr/Charts/Processes.dart';
import 'package:corr/Data%20retriving/Filters.dart';

Future<void> getData(Function setState, BuildContext context) async {
  setState(() {
    isLoading = true;
  });
  try {
    // Retrieve all documents from the collection.
    final querySnapshot = await cvCollection.get();

    // Map the documents to a list of maps.
    List<Map<String, dynamic>> docs = querySnapshot.map((doc) {
      final data = doc.map;
      return {"id": doc.id, ...data};
    }).toList();

    // Update allCVs in place
    allCVs
      ..clear()
      ..addAll(docs.where((cv) {
        return !isFieldEmpty(cv["Full Name"]) &&
            !isFieldEmpty(cv["Email address"]);
      }).toList());

    cvCount = allCVs.length;

    // Process chart and data counts
    processCategoryData(categoryCounts, allCVs, setState);
    processCertificationsOverview(certificationCounts, allCVs);
    processEducationTimeline(educationTimeline, allCVs);
    processLanguagesProficiency(languageCounts, allCVs);
    processProjectsContribution(projectContributions, allCVs);
    processJobApplicationsStatus(applicationStatusCounts, allCVs);

    // Reset filter lists in place
    projectList
      ..clear()
      ..add("All Projects");
    technologyList
      ..clear()
      ..add("All Technologies");

    for (var cv in allCVs) {
      if (cv['Projects'] is List) {
        for (var project in cv['Projects']) {
          if (project is Map && project['Name'] is String) {
            if (!projectList.contains(project['Name'])) {
              projectList.add(project['Name']);
            }
            if (project['Technologies'] is List) {
              for (var tech in project['Technologies']) {
                if (tech is Map &&
                    tech['Name'] is String &&
                    !technologyList.contains(tech['Name'])) {
                  technologyList.add(tech['Name']);
                }
              }
            }
          }
        }
      }
    }

    filterProjects(projectNames, allCVs, selectedProjectFilter,
        selectedTechnologyFilter, filteredBarGroups, setState);
    applyFilters(allCVs, isSkillsChecked, isCertificationChecked,
        isEducationChecked, isLanguageChecked, searchQuery, context, setState);
  } catch (e) {
    showSnackbar("Error retrieving CVs: $e", Colors.red, context);
  }
  setState(() {
    isLoading = false;
  });
}