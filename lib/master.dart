import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Dashboard',
      theme: ThemeData.light(),
      home: TaskDashboard(),
    );
  }
}

class TaskDashboard extends StatefulWidget {
  @override
  _TaskDashboardState createState() => _TaskDashboardState();
}

class _TaskDashboardState extends State<TaskDashboard> {
  final List<Map<String, String>> tasks = [
    {
      'Project': 'Develop IT Management Apps',
      'Milestone': 'Configure Web Environment',
      'Task': 'Identify Server Requirements',
      'Assignee': 'Tameka Hall',
      'Start Date': '02-DEC-2019',
      'End Date': '03-DEC-2019',
      'Cost': '\$2,000',
      'Complete': 'Y'
    },
    {
      'Project': 'Develop IT Management Apps',
      'Milestone': 'Configure Web Environment',
      'Task': 'Install Web Development Tool',
      'Assignee': 'Mei Yu',
      'Start Date': '04-DEC-2019',
      'End Date': '04-DEC-2019',
      'Cost': '\$1,000',
      'Complete': 'Y'
    },
    {
      'Project': 'Develop IT Management Apps',
      'Milestone': 'Train Developers',
      'Task': 'Prepare Course Outline',
      'Assignee': 'Madison Smith',
      'Start Date': '02-DEC-2019',
      'End Date': '06-DEC-2019',
      'Cost': '\$250',
      'Complete': 'N'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: Row(
        children: [
          // Sidebar for Filters
          Expanded(
            flex: 2,
            child: SidebarFilters(),
          ),
          // Main Content (Task Table)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Project')),
                  DataColumn(label: Text('Milestone')),
                  DataColumn(label: Text('Task')),
                  DataColumn(label: Text('Assignee')),
                  DataColumn(label: Text('Start Date')),
                  DataColumn(label: Text('End Date')),
                  DataColumn(label: Text('Cost')),
                  DataColumn(label: Text('Complete')),
                ],
                rows: tasks
                    .map(
                      (task) => DataRow(cells: [
                    DataCell(Text(task['Project']!)),
                    DataCell(Text(task['Milestone']!)),
                    DataCell(Text(task['Task']!)),
                    DataCell(Text(task['Assignee']!)),
                    DataCell(Text(task['Start Date']!)),
                    DataCell(Text(task['End Date']!)),
                    DataCell(Text(task['Cost']!)),
                    DataCell(Text(task['Complete']!)),
                  ]),
                )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}

class SidebarFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: ListView(
        children: [
          ListTile(title: Text('Project', style: TextStyle(fontWeight: FontWeight.bold))),
          ExpansionTile(
            title: Text('Develop IT Management Apps'),
            children: [CheckboxListTile(value: true, onChanged: (v) {}, title: Text('Task 1'))],
          ),
          Divider(),
          ListTile(title: Text('Milestone', style: TextStyle(fontWeight: FontWeight.bold))),
          ExpansionTile(
            title: Text('Train Developers'),
            children: [CheckboxListTile(value: true, onChanged: (v) {}, title: Text('Prepare Course Outline'))],
          ),
          Divider(),
          ListTile(title: Text('Assignee', style: TextStyle(fontWeight: FontWeight.bold))),
          CheckboxListTile(value: true, onChanged: (v) {}, title: Text('Tameka Hall')),
          CheckboxListTile(value: false, onChanged: (v) {}, title: Text('Mei Yu')),
        ],
      ),
    );
  }
}
