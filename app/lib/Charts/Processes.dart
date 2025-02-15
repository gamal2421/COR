void processCertificationsOverview(
    Map<String, int> certificationCounts, List<Map<String, dynamic>> allCVs) {
  certificationCounts.clear();

  certificationCounts["Completed"] =
      allCVs.where((cv) => cv["Certifications"] != null).length;
  certificationCounts["In Progress"] =
      allCVs.where((cv) => cv["Certifications"] == null).length;
}

// 🔹 3. Education Timeline
void processEducationTimeline(List<Map<String, String>> educationTimeline,
    List<Map<String, dynamic>> allCVs) {
  educationTimeline.clear();

  for (var cv in allCVs) {
    if (cv['Education'] is List) {
      for (var edu in cv['Education']) {
        if (edu is Map && edu['Degree'] is String) {
          educationTimeline.add({
            "Degree": edu['Degree'],
            "DatesAttended": edu['DatesAttended'] ?? ""
          });
        }
      }
    }
  }
}

// 🔹 4. Languages Proficiency
void processLanguagesProficiency(
    Map<String, int> languageCounts, List<Map<String, dynamic>> allCVs) {
  languageCounts.clear();

  for (var cv in allCVs) {
    if (cv['Languages'] is List) {
      for (var language in cv['Languages']) {
        languageCounts[language] = (languageCounts[language] ?? 0) + 1;
      }
    }
  }
}

void processProjectsContribution(
    Map<String, int> projectContributions, List<Map<String, dynamic>> allCVs) {
  projectContributions.clear();

  for (var cv in allCVs) {
    if (cv['Projects'] is List) {
      for (var project in cv['Projects']) {
        if (project is Map && project['Role'] is String) {
          projectContributions[project['Role']] =
              (projectContributions[project['Role']] ?? 0) + 1;
        }
      }
    }
  }
}

// 🔹 6. Job Applications Status
void processJobApplicationsStatus(Map<String, int> applicationStatusCounts,
    List<Map<String, dynamic>> allCVs) {
  applicationStatusCounts.clear();

  applicationStatusCounts["Submitted"] = allCVs
      .where((cv) =>
          cv["ApplicationTracking"] != null &&
          cv["ApplicationTracking"]["Status"] == "Submitted")
      .length;
  applicationStatusCounts["Interview Scheduled"] = allCVs
      .where((cv) =>
          cv["ApplicationTracking"] != null &&
          cv["ApplicationTracking"]["Status"] == "Interview Scheduled")
      .length;
  applicationStatusCounts["Accepted"] = allCVs
      .where((cv) =>
          cv["ApplicationTracking"] != null &&
          cv["ApplicationTracking"]["Status"] == "Accepted")
      .length;
  applicationStatusCounts["Rejected"] = allCVs
      .where((cv) =>
          cv["ApplicationTracking"] != null &&
          cv["ApplicationTracking"]["Status"] == "Rejected")
      .length;
}

void processCategoryData(Map<String, int> categoryCounts,
    List<Map<String, dynamic>> allCVs, Function func) {
  categoryCounts.clear();
  categoryCounts["Skills"] = allCVs.where((cv) => cv["Skills"] != null).length;
  categoryCounts["Certifications"] =
      allCVs.where((cv) => cv["Certifications"] != null).length;
  categoryCounts["Languages"] =
      allCVs.where((cv) => cv["Languages"] != null).length;
  categoryCounts["Education"] =
      allCVs.where((cv) => cv["Education"] != null).length;
  func(() {}); // Refresh UI after processing
}
