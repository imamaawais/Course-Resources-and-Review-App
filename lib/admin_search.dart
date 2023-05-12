import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'std_course_details.dart';

class AdminSearch extends StatefulWidget {
  final String searchQuery;

  const AdminSearch({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<AdminSearch> createState() => _AdminSearchState();
}

class _AdminSearchState extends State<AdminSearch> {
  var db = FirebaseFirestore.instance;

  Future<List<String>> fetchCourses() async {
    final courseCollection = db.collection('courses');
    final courseDocs = await courseCollection.get();
    final courseNames =
        courseDocs.docs.map((doc) => doc.data()['name'] as String).toList();
    final courses = courseNames
        .where((name) =>
            name.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = widget.searchQuery;
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$searchQuery"'),
      ),
      body: FutureBuilder(
        future: fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          } else {
            final courses = snapshot.data as List<String>;
            return courses.isEmpty
                ? Center(
                    child: Text(
                      'Sorry, no results were found for your search.',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )
                : ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final courseName = courses[index];
                      return ListTile(
                        title: Text(courseName),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/admin_course_details',
                            arguments: {
                              'name': courseName,
                              // Add any other course information here
                            },
                          );
                        },
                      );
                    },
                  );
          }
        },
      ),
    );
  }
}
