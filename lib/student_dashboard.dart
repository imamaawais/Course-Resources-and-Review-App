import 'package:flutter/material.dart';
import 'student_search.dart';
import 'package:provider/provider.dart';

class StudentDashboard extends StatelessWidget {
  final TextEditingController _searchQueryController = TextEditingController();
  final String userEmail;

  StudentDashboard({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchQueryController,
              decoration: InputDecoration(
                hintText: 'Search Courses',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/studentSearch',
                      arguments: {
                        'searchQuery': _searchQueryController.text,
                        'userEmail': userEmail,
                      },
                    );
                  },
                ),
              ),
              onSubmitted: (String value) {
                Navigator.pushNamed(
                  context,
                  '/studentSearch',
                  arguments: {
                    'searchQuery': _searchQueryController.text,
                    'userEmail': userEmail,
                  },
                );
              },
            ),
          ),
          SizedBox(height: 14.0),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/stdViewCourses',
                  arguments: userEmail,
                );
              },
              child: Text('View Courses'),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                    height: 60,
                    child: DrawerHeader(
                      child: Text('Student Actions'),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/loginPage',
                              (route) => false,
                            );
                          },
                          child: Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
