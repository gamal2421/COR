import 'package:corr/Builders/BuildCVGrid.dart';
import 'package:corr/Builders/BuildSearchBar.dart';
import 'package:corr/Builders/BuildSideBarFilters.dart';
import 'package:corr/Data%20retriving/getData.dart';
import 'package:corr/DataAdding/PythonRunner.dart';
import 'package:corr/DataAdding/filePicker.dart';
import 'package:corr/Else/Variables.dart'; // Global variables
import 'package:corr/Pages/ArchivePage.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import 'package:corr/Data%20retriving/Filters.dart';
import 'package:corr/Charts/Charts.dart';

const projectId = 'ocrcv-1e6fe';

void main() async {
  Firestore.initialize(projectId);
  runApp(const FireStoreApp());
}

class FireStoreApp extends StatelessWidget {
  const FireStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CV Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FireStoreHome(),
    );
  }
}

class FireStoreHome extends StatefulWidget {
  const FireStoreHome({super.key});

  @override
  _FireStoreHomeState createState() => _FireStoreHomeState();
}

class _FireStoreHomeState extends State<FireStoreHome> {
  @override
  void initState() {
    super.initState();
    getData(setState, context);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.red[800],
          title: Column(
            children: [
              const Text(
                'CV\'s Dashboard',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Count of retrieved CVs: $cvCount',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              )
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ArchivePage()));
                },
                icon: Icon(
                  Icons.archive,
                  color: Colors.white,
                )),
            IconButton(
              onPressed: () {
                getData(setState, context);
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4.0,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 14),
            tabs: [
              Tab(text: 'Cvs'),
              Tab(text: "Charts"),
            ],
          ),
        ),
        body: Row(
          children: [
            buildSidebarFilters(screenHeight, setState, context),
            Expanded(
              child: TabBarView(
                children: [
                  // Data Tab: Search Bar + Grid
                  Column(
                    children: [
                      buildSearchBar(
                          screenWidth, setState, context, "Search CVs"),
                      Expanded(child: buildCVGrid(context)),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: categoryCounts.isNotEmpty
                              ? buildCategoryChart(categoryCounts)
                              : const Text("No data available"),
                        ),
                        // Certifications Overview Chart
                        const Text(
                          "Certifications Overview",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        certificationCounts.isNotEmpty
                            ? buildCertificationsOverviewChart(
                                certificationCounts)
                            : const Text("No certifications data available"),
                        const SizedBox(height: 100),
                        // Education Timeline Chart
                        const Text(
                          "Education Timeline",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        educationTimeline.isNotEmpty
                            ? buildEducationTimelineChart(educationTimeline)
                            : const Text("No education data available"),
                        const SizedBox(height: 20),
                        // Projects Contribution Filter Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            DropdownButton<String>(
                              value: selectedProjectFilter,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedProjectFilter = newValue!;
                                });
                                filterProjects(
                                    projectNames,
                                    allCVs,
                                    selectedProjectFilter,
                                    selectedTechnologyFilter,
                                    filteredBarGroups,
                                    setState);
                              },
                              items: projectList.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            DropdownButton<String>(
                              value: selectedTechnologyFilter,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedTechnologyFilter = newValue!;
                                });
                                filterProjects(
                                    projectNames,
                                    allCVs,
                                    selectedProjectFilter,
                                    selectedTechnologyFilter,
                                    filteredBarGroups,
                                    setState);
                              },
                              items: technologyList
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        // Projects Contribution Chart
                        const Text(
                          "Projects Contribution",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        filteredBarGroups.isNotEmpty
                            ? buildProjectsContributionChart(
                                filteredBarGroups, animateChart)
                            : const Text(
                                "No project contribution data available"),
                        const SizedBox(height: 120),
                        // Languages Proficiency Chart
                        const Text(
                          "Languages Proficiency",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        languageCounts.isNotEmpty
                            ? buildLanguagesProficiencyChart(languageCounts)
                            : const Text("No languages data available"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "Add",
          onPressed: isUploading
              ? null
              : () {
                  pickFiles(context, setState, selectedFiles, runPythonScript);
                },
          backgroundColor: Colors.red[800],
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: Container(
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
        ),
      ),
    );
  }
}
