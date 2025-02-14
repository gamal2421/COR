import 'dart:convert';
import 'dart:io';
import 'package:firedart/firedart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:process_run/process_run.dart';
import 'package:flutter/material.dart'; // Only Material Design
import 'CVDetailedPage.dart';

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
        primarySwatch: Colors.red, // Material Colors
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
  CollectionReference cvCollection = Firestore.instance.collection('CV');
  List<File> selectedFiles = [];
  bool isUploading = false;

  List<Map<String, dynamic>> allCVs = [];
  List<Map<String, dynamic>> displayedCVs = [];
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  // Filter checkboxes
  bool isSkillsChecked = false;
  bool isCertificationChecked = false;
  bool isEducationChecked = false;
  bool isLanguageChecked = false;

  // Variable to track loading state
  bool isLoading = false;
  int cvCount = 0;

  // Chart data
  Map<String, int> categoryCounts = {};

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
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

      // Filter out CVs where the required fields are null or empty.
      // (Here we assume "Full Name" and "Email address" are required.)
      allCVs = docs.where((cv) {
        return !isFieldEmpty(cv["Full Name"]) &&
            !isFieldEmpty(cv["Email address"]);
      }).toList();

      // Update the CV count.
      cvCount = allCVs.length;

      // Update the chart data based on the full data set
      _processCategoryData();

      // Apply any additional filters (checkboxes, search query, etc.)
      _applyFilters();
    } catch (e) {
      _showSnackbar("Error retrieving CVs: $e", Colors.red);
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<String> _getActiveFilterFields() {
    List<String> activeFields = [];
    if (isSkillsChecked) activeFields.add('Skills');
    if (isCertificationChecked) activeFields.add('Certifications');
    if (isEducationChecked) activeFields.add('Education');
    if (isLanguageChecked) activeFields.add('Languages');
    if (activeFields.isEmpty) activeFields.add('Full Name');
    return activeFields;
  }

  bool isFieldEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String && value.trim().isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    return false;
  }

  // Updated to optionally use filtered data if needed.
  void _applyFilters() {
    List<Map<String, dynamic>> filtered = allCVs.where((cv) {
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
      if (searchQuery.isNotEmpty) {
        // Split the query into individual terms (ignoring extra spaces)
        final searchTerms = searchQuery
            .split(RegExp(r'\s+'))
            .where((term) => term.isNotEmpty)
            .toList();

        // Check that every term is found in at least one of the active fields
        bool matchesAllTerms = searchTerms.every((term) {
          return _getActiveFilterFields().any((field) {
            final fieldValue = (cv[field] ?? '').toString().toLowerCase();
            return fieldValue.contains(term);
          });
        });

        if (!matchesAllTerms) return false;
      }

      return true;
    }).toList();

    // If you want the chart to reflect filtered data,
    // call _processCategoryData(filtered) here instead.
    // For now, we'll keep chart based on full data.
    // _processCategoryData(filtered);

    setState(() {
      displayedCVs = filtered;
    });
  }

  /// 🔹 **File Picker**
  Future<void> pickFiles() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      _showSnackbar("⚠ Permission denied!", Colors.orange);
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFiles = result.files.map((file) => File(file.path!)).toList();
      });

      for (var file in selectedFiles) {
        await runPythonScript(file.path);
      }
    }
  }

  void _processCategoryData() {
    categoryCounts.clear();
    categoryCounts["Skills"] =
        allCVs.where((cv) => cv["Skills"] != null).length;
    categoryCounts["Certifications"] =
        allCVs.where((cv) => cv["Certifications"] != null).length;
    categoryCounts["Languages"] =
        allCVs.where((cv) => cv["Languages"] != null).length;
    categoryCounts["Education"] =
        allCVs.where((cv) => cv["Education"] != null).length;
    setState(() {}); // Refresh UI after processing
  }

  /// 🔹 **Run Python Script**
  Future<void> runPythonScript(String filePath) async {
  setState(() => isUploading = true);

  try {
    const pythonPath = 'python'; // Or 'python3'
    const scriptPath = 'assets/scripts/extract_text.py';

    int retryCount = 0;
    const maxRetries = 3;
    Map<String, dynamic>? jsonData;

    while (retryCount < maxRetries) {
      final result = await runExecutableArguments(
        pythonPath,
        [scriptPath, filePath],
      );

      if (result.exitCode == 0) {
        jsonData = jsonDecode(result.stdout.trim());

        // Check if the extracted data is valid (not null or empty)
        if (jsonData != null && jsonData.isNotEmpty) {
          // 🔹 Add the isAssigned field here
          jsonData["isAssigned"] = "No"; 
          break;
        } else {
          retryCount++;
          _showSnackbar(
              "⚠ Retrying extraction... Attempt $retryCount", Colors.orange);
        }
      } else {
        _showSnackbar("❌ Error running script: ${result.stderr}", Colors.red);
        return;
      }
    }

    if (jsonData != null && jsonData.isNotEmpty) {
      await uploadDataToFirestore(jsonData);
    } else {
      _showSnackbar(
          "❌ Failed to extract valid data after $maxRetries attempts",
          Colors.red);
    }
  } catch (e) {
    _showSnackbar("❌ Error: $e", Colors.red);
  } finally {
    setState(() => isUploading = false);
  }
}


  /// 🔹 **Upload Data to Firestore**
  Future<void> uploadDataToFirestore(Map<String, dynamic> data) async {
    try {
      final document = await cvCollection.add(data);
      _showSnackbar(
          "✅ Data uploaded to Firestore: ${document.id}", Colors.green);
      getData();
    } catch (e) {
      _showSnackbar("❌ Error uploading data: $e", Colors.red);
    }
  }

  Widget buildCategoryChart(Map<String, int> categoryCounts) {
    List<PieChartSectionData> sections = categoryCounts.entries.map((entry) {
      return PieChartSectionData(
        color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
        value: entry.value.toDouble(),
        title: '${entry.key}\n(${entry.value})',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 50,
          sectionsSpace: 3,
        ),
      ),
    );
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
                getData();
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white, // Color of the tab indicator
            indicatorWeight: 4.0, // Thickness of the indicator
            labelColor: Colors.white, // Color of the selected tab text
            unselectedLabelColor:
                Colors.white70, // Color of unselected tab text
            labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold), // Selected tab text style
            unselectedLabelStyle:
                TextStyle(fontSize: 14), // Unselected tab text style
            tabs: [
              Tab(text: 'Cvs'),
              Tab(text: "Charts"),
            ],
          ),
        ),
        body: Row(
          children: [
            _buildSidebarFilters(screenHeight),
            Expanded(
              child: TabBarView(
                children: [
                  // Data Tab: Search Bar + Grid
                  Column(
                    children: [
                      _buildSearchBar(screenWidth),
                      Expanded(child: _buildCVGrid()),
                    ],
                  ),
                  // Chart Tab
                  Center(
                    child: categoryCounts.isNotEmpty
                        ? buildCategoryChart(categoryCounts)
                        : const Text("No data available"),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "Add",
          onPressed: isUploading ? null : pickFiles,
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

  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Align(
        alignment: Alignment.topRight,
        child: TextField(
          onChanged: (value) {
            searchQuery = value.toLowerCase();
            _applyFilters();
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.red[800]),
            hintText: 'Search CVs...',
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

  Widget _buildSidebarFilters(double screenHeight) {
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
                  _applyFilters();
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
                  _applyFilters();
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
                  _applyFilters();
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
                  _applyFilters();
                },
                activeColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCVGrid() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (displayedCVs.isEmpty) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(
              fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
        ),
        itemCount: displayedCVs.length,
        itemBuilder: (context, index) {
          return _buildCVCard(displayedCVs[index]);
        },
      ),
    );
  }

  Widget _buildCVCard(Map<String, dynamic> cv) {
    return InkWell(
      onTap: () => _navigateToDetail(cv),
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cv["Full Name"] ?? "No Name",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                cv["Email address"] ?? "No Email",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> cv) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => CVDetailPage(cv: cv),
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
}
