import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:process_run/process_run.dart';
import 'dart:convert';
import 'CVDetailedPage.dart';

const projectId = 'ocrcv-1e6fe';

void main() async {
  Firestore.initialize(projectId);
  runApp(const FireStoreApp());
}

class FireStoreApp extends StatelessWidget {
  const FireStoreApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CV\'s Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FireStoreHome(),
    );
  }
}

class FireStoreHome extends StatefulWidget {
  const FireStoreHome({Key? key}) : super(key: key);

  @override
  _FireStoreHomeState createState() => _FireStoreHomeState();
}

class _FireStoreHomeState extends State<FireStoreHome> {
  CollectionReference cvCollection = Firestore.instance.collection('CV');
  List<Map<String, dynamic>> allCVs = [];
  List<Map<String, dynamic>> displayedCVs = [];
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  // Filter checkboxes (independent of each other)
  bool isSkillsChecked = false;
  bool isCertificationChecked = false;
  bool isEducationChecked = false;
  bool isLanguageChecked = false;

  // Variable to track loading state
  bool isLoading = false;
  int cvCount = 0;

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

      // Now update the cvCount with the count of only valid CVs.
      cvCount = allCVs.length;

      // Apply any additional filters (for checkboxes, search query, etc.)
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

  // This function retrieves the count by fetching all documents

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = allCVs.where((cv) {
      if (isEducationChecked && isFieldEmpty(cv['Education'])) {
        return false;
      }
      if (isSkillsChecked && isFieldEmpty(cv['Skills'])) {
        return false;
      }
      if (isCertificationChecked && isFieldEmpty(cv['Certifications'])) {
        return false;
      }
      if (isLanguageChecked && isFieldEmpty(cv['Languages'])) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        List<String> fields = _getActiveFilterFields();
        bool matches = fields.any((field) {
          final fieldValue = (cv[field] ?? '').toString().toLowerCase();
          return fieldValue.contains(searchQuery);
        });
        if (!matches) return false;
      }
      return true;
    }).toList();

    setState(() {
      displayedCVs = filtered;
    });
  }

  /// ---------------
  /// File Processing
  /// ---------------

  /// Picks a file (or files) then runs the Python script for each.
  Future<void> pickAndProcessFile() async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      _showSnackbar("⚠ Permission denied!", Colors.orange);
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.first.path!;
      await runPythonScript(filePath);
    }
  }

  /// Runs the Python script to process the file and upload data to Firestore.
  Future<void> runPythonScript(String filePath) async {
    setState(() => isLoading = true);

    try {
      // Set the Python executable (adjust if needed for your environment)
      const pythonPath = 'python'; // Or 'python3'
      // Path to your Python script (ensure this is correct)
      const scriptPath = 'assets/scripts/extract_text.py';

      // Run the Python script with the file path as an argument
      final result = await runExecutableArguments(
        pythonPath,
        [scriptPath, filePath],
      );

      if (result.exitCode == 0) {
        final jsonData = jsonDecode(result.stdout.trim());
        await uploadDataToFirestore(jsonData);
      } else {
        _showSnackbar("❌ Error running script: ${result.stderr}", Colors.red);
      }
    } catch (e) {
      _showSnackbar("❌ Error: $e", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> uploadDataToFirestore(Map<String, dynamic> data) async {
    try {
      final document = await cvCollection.add(data);
      _showSnackbar("✅ Data uploaded: ${document.id}", Colors.green);
      getData();
    } catch (e) {
      _showSnackbar("❌ Error uploading data: $e", Colors.red);
    }
  }

  /// ---------------
  /// End File Processing
  /// ---------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
              'Count of retrived cvs: $cvCount',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            )
          ],
        ),
        centerTitle: true,
        actions: [
          // Refresh button to reload data.
          IconButton(
            onPressed: () {
              getData();
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          // New button to get and display the document count.
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              _buildSidebarFilters(screenHeight),
              Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(screenWidth),
                    Expanded(child: _buildCVGrid()),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
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
                  const SizedBox(width: 400),
                  const Text(
                    'V 0.1.1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating action button to initiate file picking and processing.
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : () async => await pickAndProcessFile(),
        backgroundColor: Colors.red[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// The search bar applies both the text query and the filter (checkbox) requirements.
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
