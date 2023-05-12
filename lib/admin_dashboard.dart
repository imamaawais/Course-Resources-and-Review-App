import 'package:flutter/material.dart';
import 'admin_search.dart';
import 'login_page.dart';

class AdminDashboard extends StatelessWidget {
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
                      child: Text('Admin Actions'),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.list),
                    title: Text('Approval History'),
                    onTap: () {
                      // TODO: Implement view all courses functionality
                      Navigator.pushNamed(context, '/approvalHistory');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Course'),
                    onTap: () {
                      // TODO: Implement add course functionality
                      Navigator.pushNamed(context, '/adminAddCourse');
                    },
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
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchQueryController,
              decoration: InputDecoration(
                hintText: 'Search Courses',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminSearch(
                          searchQuery: _searchQueryController.text,
                        ),
                      ),
                    );
                  },
                ),
              ),
              onSubmitted: (String value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminSearch(searchQuery: value),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14.0),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/viewAllCourses');
              },
              child: const Text('View All Courses'),
            ),
          ),
          const SizedBox(height: 14.0),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pendingReviews');
              },
              child: const Text('View Pending Reviews'),
            ),
          ),
          const SizedBox(height: 14.0),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pendingResources');
              },
              child: const Text('View Pending Resources'),
            ),
          ),
          // const SizedBox(height: 14.0),
          // SizedBox(
          //   width: 200,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       Navigator.pushNamed(context, '/approvalHistory');
          //     },
          //     child: const Text('Approval History'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
