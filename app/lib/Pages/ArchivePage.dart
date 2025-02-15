import 'package:corr/Archived/BottomNavBar.dart';
import 'package:corr/Builders/BuildCVGrid.dart';
import 'package:corr/Builders/BuildSearchBar.dart';
import 'package:corr/Builders/BuildSideBarFilters.dart';
import 'package:flutter/material.dart';
import 'package:corr/Archived/FetchArchivedCVs.dart';
import 'package:corr/Archived/NavigateToDetail.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<Map<String, dynamic>> archivedCVs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchArchivedCVs(
        setState, (data) => archivedCVs = data, _isLoading, context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Archived CVs',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Colors.white), // Custom arrow color
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.red[800],
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () => fetchArchivedCVs(
                setState, (data) => archivedCVs = data, _isLoading, context),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                buildSidebarFilters(screenHeight, setState, context),
                Expanded(
                  child: Column(
                    children: [
                      buildSearchBar(screenWidth, setState, context,
                          "Search archived CVs"),
                      Expanded(
                        child: archivedCVs.isEmpty
                            ? const Center(
                                child: Text(
                                  'No archived CVs found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : buildCVGridd(
                                context,
                                archivedCVs,
                                (cv) => navigateToDetail(context, cv),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: buildBottomNavBar(),
    );
  }
}
