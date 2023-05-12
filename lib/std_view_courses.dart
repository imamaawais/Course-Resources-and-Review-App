import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

class StudentViewCourses extends StatefulWidget {
  final String userEmail;
  const StudentViewCourses({Key? key, required this.userEmail})
      : super(key: key);

  @override
  _StudentViewCoursesState createState() => _StudentViewCoursesState();
}

class _StudentViewCoursesState extends State<StudentViewCourses> {
  var db = FirebaseFirestore.instance;

  List<String> courses = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  void fetchCourses() async {
    final courseCollection = db.collection('courses');
    final courseDocs = await courseCollection.get();
    final courseNames =
        courseDocs.docs.map((doc) => doc.data()['name'] as String).toList();
    courseNames.sort();
    setState(() {
      courses = courseNames;
    });
    if (courses.isEmpty) {
      //Navigator.of(context).pop(); // go back to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Courses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemCount: courses.length,
          separatorBuilder: (BuildContext context, int index) =>
              Divider(color: Colors.grey),
          itemBuilder: (BuildContext context, int index) {
            final course = courses[index];
            return Container(
              height: 60, // Fixed height for ListTile
              child: ListTile(
                title: Text(
                  course,
                  //extAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/std_course_details',
                    arguments: {
                      'name': course,
                      'userEmail': widget.userEmail,
                      // Add any other course information here
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
