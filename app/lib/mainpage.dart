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
    try {
      final querySnapshot = await cvCollection.get();
      allCVs = querySnapshot.map((doc) {
        final data = doc.map;
        return {"id": doc.id, ...data};
      }).toList();
      setState(() {
        displayedCVs = allCVs.take(_itemsPerPage).toList();
      });
    } catch (e) {
      _showSnackbar("Error retrieving CVs: $e", Colors.red);
    }
  }

  void _loadMore() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _currentPage++;
        int startIndex = _currentPage * _itemsPerPage;
        int endIndex = startIndex + _itemsPerPage;
        if (startIndex < allCVs.length) {
          displayedCVs.addAll(allCVs.sublist(
              startIndex, endIndex < allCVs.length ? endIndex : allCVs.length));
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

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('CV\'s Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Row(
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
      floatingActionButton: FloatingActionButton(
        onPressed: getData,
        backgroundColor: Colors.red[800],
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04), // Adjust padding based on screen width
      child: Align(
        alignment: Alignment.topRight, // Align search bar to the right
        child: TextField(
          onChanged: (value) => setState(() {
            searchQuery = value.toLowerCase();
            displayedCVs = allCVs
                .where((cv) => cv['Full Name'].toLowerCase().contains(searchQuery))
                .take(_itemsPerPage)
                .toList();
          }),
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
      height: screenHeight, // Make the filters take the full height of the screen
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildFilterSection('Category', ['Technical', 'Creative']),
          const Divider(),
          _buildFilterSection('Status', ['Reviewed', 'Pending']),
          const Divider(),
          _buildFilterSection('Experience', ['Junior', 'Senior']),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        ...options.map((option) => CheckboxListTile(
          value: false,
          onChanged: (v) {},
          title: Text(option),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        )).toList(),
      ],
    );
  }

  Widget _buildCVGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
        ),
        itemCount: displayedCVs.length + 1,
        itemBuilder: (context, index) {
          if (index == displayedCVs.length) {
            return _buildLoadingIndicator();
          }
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
                cv["Position"] ?? "No Position",
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(color: Colors.red),
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