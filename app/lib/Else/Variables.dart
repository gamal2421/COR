// Variables.dart
import 'dart:io';
import 'package:firedart/firedart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Firestore Collection
CollectionReference cvCollection = Firestore.instance.collection('CV');

// File Picker Variables
List<File> selectedFiles = [];
bool isUploading = false;

// CV Data Variables
List<Map<String, dynamic>> allCVs = [];
List<Map<String, dynamic>> displayedCVs = [];
String searchQuery = "";
final ScrollController scrollController = ScrollController();

// Filter checkboxes
bool isSkillsChecked = false;
bool isCertificationChecked = false;
bool isEducationChecked = false;
bool isLanguageChecked = false;

// Loading and Count
bool isLoading = false;
int cvCount = 0;

// Chart Data Variables
Map<String, int> categoryCounts = {};
Map<String, int> certificationCounts = {};
List<Map<String, String>> educationTimeline = [];
Map<String, int> languageCounts = {};
Map<String, int> projectContributions = {};
Map<String, int> applicationStatusCounts = {};
List<String> projectList = ["All Projects"];
List<String> technologyList = ["All Technologies"];
List<BarChartGroupData> filteredBarGroups = [];
List<String> projectNames = [];
String selectedProjectFilter = "All Projects";
String selectedTechnologyFilter = "All Technologies";
bool animateChart = false;
