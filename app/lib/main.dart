import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
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
  int _currentPage = 0;
  final int _itemsPerPage = 6;
  final ScrollController _scrollController = ScrollController();

  // Filter checkboxes (independent of each other)
  bool isSkillsChecked = false;
  // Removed isProgrammingLanguageChecked, isGraduationYearChecked, and isInstitutionChecked
  bool isCertificationChecked = false;
  bool isEducationChecked = false; // New checkbox for Education
  bool isLanguageChecked = false;

  // Variable to track loading state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(_loadMore);
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
      final querySnapshot = await cvCollection.get();
      allCVs = querySnapshot.map((doc) {
        final data = doc.map;
        return {"id": doc.id, ...data};
      }).toList();
      // Apply filters (if any) after data is loaded
      _applyFilters();
    } catch (e) {
      _showSnackbar("Error retrieving CVs: $e", Colors.red);
    }
    setState(() {
      isLoading = false;
    });
  }

  void _loadMore() {
    // Disable pagination when a search query is active or when filtering
    if (searchQuery.isNotEmpty) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _currentPage++;
        int startIndex = _currentPage * _itemsPerPage;
        int endIndex = startIndex + _itemsPerPage;
        if (startIndex < allCVs.length) {
          displayedCVs.addAll(
            allCVs.sublist(
              startIndex,
              endIndex < allCVs.length ? endIndex : allCVs.length,
            ),
          );
        }
      });
    }
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

  /// Returns a list of fields to filter by based on the active checkboxes.
  /// If no filter checkbox is active, we default to filtering by "Full Name."
  List<String> _getActiveFilterFields() {
    List<String> activeFields = [];
    if (isSkillsChecked) activeFields.add('Skills');
    if (isCertificationChecked) activeFields.add('Certifications');
    if (isEducationChecked) activeFields.add('Education');
    if (isLanguageChecked) activeFields.add('Languages');
    if (activeFields.isEmpty) activeFields.add('Full Name');
    return activeFields;
  }

  /// Applies the filters based on the selected checkboxes and search query.
  /// Only CVs that have a non-empty value for each selected attribute will be shown.
  void _applyFilters() {
    List<Map<String, dynamic>> filtered = allCVs.where((cv) {
      // Check for Education if that filter is active.
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

      // If a search query is provided, then check that at least one of the active fields
      // contains the search query.
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
      _currentPage = 0;
      // For simplicity, we take only the first page of results.
      displayedCVs = filtered.take(_itemsPerPage).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text(
          'CV\'s Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar filters on the left side taking full height
              _buildSidebarFilters(screenHeight),
              // Main content area for search bar and CV grid
              Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(screenWidth), // Search bar on the top-right
                    Expanded(child: _buildCVGrid()), // CV grid below the search bar
                  ],
                ),
              ),
            ],
          ),
          // Bottom bar remains unchanged.
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
                    borderRadius: BorderRadius.circular(10), // Adjust as needed
                    child: Image.asset(
                      'assets\\img\\sclog.jpg',
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
                  const SizedBox(width: 480),
                  const Text(
                    'V 0.1.1',
                    textAlign: TextAlign.left,
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
      floatingActionButton: FloatingActionButton(
        onPressed: getData,
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
      height: screenHeight, // Full height sidebar
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Skills Checkbox
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
          // Certifications Checkbox
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
          // Education Checkbox
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
          // Languages Checkbox
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
    // If still loading, show the red circular progress indicator.
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    // If no CVs are available after filtering, show a "No data found" message.
    if (displayedCVs.isEmpty) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 10,
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