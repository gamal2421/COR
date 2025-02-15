

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

  Widget buildCertificationsOverviewChart(
    Map<String, int> certificationCounts,
  ) {
    List<PieChartSectionData> sections =
        certificationCounts.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n(${entry.value})',
        color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 80,
          sectionsSpace: 4,
        ),
      ),
    );
  }

  Widget buildProjectsContributionChart(
     List<BarChartGroupData> filteredBarGroups,
      bool animateChart
  ) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: filteredBarGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 1),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  String projectName = filteredBarGroups[value.toInt()]
                      .barRods
                      .first
                      .toY
                      .toString();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(projectName, style: TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87.withOpacity(0.8),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipRoundedRadius: 8,
            ),
          ),
        ),
        swapAnimationDuration: Duration(
            milliseconds: animateChart ? 800 : 0), // Animation Duration
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  Widget buildLanguagesProficiencyChart(
     Map<String, int> languageCounts,

  ) {
    Map<String, int> displayData = Map<String, int>.from(languageCounts);

    // Ensure at least 3 entries by adding placeholders
    while (displayData.length < 3) {
      displayData["Placeholder ${displayData.length + 1}"] = 0;
    }

    List<RadarDataSet> dataSets = [
      RadarDataSet(
        dataEntries: displayData.entries
            .map((entry) => RadarEntry(value: entry.value.toDouble()))
            .toList(),
        fillColor: Colors.blue.withOpacity(0.4),
        borderColor: Colors.blue,
        entryRadius: 3,
      ),
    ];
    return SizedBox(
      height: 300,
      child: RadarChart(
        RadarChartData(
          dataSets: dataSets,
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          titlePositionPercentageOffset: 0.2,
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: displayData.keys.elementAt(index),
              angle: angle,
            );
          },
        ),
      ),
    );
  }

  Widget buildEducationTimelineChart(
    List<Map<String, String>> educationTimeline
  ) {
    List<FlSpot> spots = [];
    List<String> labels = [];

    for (int i = 0; i < educationTimeline.length; i++) {
      String dates = educationTimeline[i]['DatesAttended'] ?? '';
      String degree = educationTimeline[i]['Degree'] ?? 'Unknown';
      List<String> years = dates.split('–');

      if (years.length == 2) {
        double startYear =
            double.tryParse(years[0].trim().split(' ').last) ?? 0;
        double endYear = double.tryParse(years[1].trim().split(' ').last) ?? 0;

        spots.add(FlSpot(startYear, i.toDouble()));
        spots.add(FlSpot(endYear, i.toDouble()));
        labels.add(degree);
      }
    }

    return SizedBox(
      height: 500,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(value.toInt().toString(),
                        style: TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
