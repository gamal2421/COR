import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';

import 'AssignDetailedPage.dart';

class AssignPage extends StatefulWidget {
  @override
  _AssignPageState createState() => _AssignPageState();
}

class _AssignPageState extends State<AssignPage> {
  List<Map<String, dynamic>> assignedCVs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAssignedData();
  }

  Future<void> getAssignedData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch data from the 'Assign' collection
      final querySnapshot = await Firestore.instance.collection('Assign').get();

      // Map the documents to a list of maps
      assignedCVs = querySnapshot.map((doc) {
        final data = doc.map;
        return {"id": doc.id, ...data};
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching assigned CVs: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned CVs', style: TextStyle(color: Colors.white)),
        leading:
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  getAssignedData();
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
            ],

        backgroundColor: Colors.red[800],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red))
          : assignedCVs.isEmpty
          ? Center(
        child: Text(
          'No assigned CVs found',
          style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: assignedCVs.length,
          itemBuilder: (context, index) {
            return _buildCVCard(assignedCVs[index]);
          },
        ),
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
      MaterialPageRoute(
        builder: (context) => AssignDetailedPage(cv: cv), // Navigate to the new page
      ),
    );
  }
}