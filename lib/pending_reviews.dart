import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

class PendingReviewsPage extends StatefulWidget {
  PendingReviewsPage({Key? key}) : super(key: key);

  @override
  _PendingReviewsPageState createState() => _PendingReviewsPageState();
}

class _PendingReviewsPageState extends State<PendingReviewsPage> {
  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  List<Map<String, dynamic>> _pendingReviews = [];
  List _docIDs = [];

  var db = FirebaseFirestore.instance;

  void fetchReviews() async {
    final reviewCollection = db.collection('reviews');
    final reviewDocs = await reviewCollection.get();
    final pendingReviews =
        reviewCollection.where("status", isEqualTo: "Pending").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          // print('${docSnapshot.id} => ${docSnapshot.data()}');
          setState(() {
            _pendingReviews.add(docSnapshot.data());
            _docIDs.add(docSnapshot.id);
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    // print(pendingReviews);
    // final pendingReviews =
    //     reviewDocs.docs.map((doc) => doc.data()['name'] as String).toList();
    // courseNames.sort();
    // setState(() {
    //   _pendingReviews = pendingReviews;
    // });
    // if (pendingReviews.isEmpty) {
    //   //Navigator.of(context).pop(); // go back to previous screen
    // }
  }

  void removeReview(int index) {
    setState(() {
      _pendingReviews.removeAt(index);
      _docIDs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Reviews'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _pendingReviews.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  title: Text(
                    _pendingReviews[index]['review'],
                    // style: TextStyle(
                    //   fontWeight: FontWeight.bold,
                    //   fontSize: 18.0,
                    // ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      Text(
                        "User: " + _pendingReviews[index]['userEmail'],
                        // style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        "Course: " + _pendingReviews[index]['course'],
                        // style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _pendingReviews[index]['status'] = "Approved";
                        _pendingReviews[index]['approvedOn'] =
                            FieldValue.serverTimestamp();

                        db
                            .collection("reviews")
                            .doc(_docIDs[index])
                            .set(_pendingReviews[index]);

                        removeReview(index);
                      },
                      child: Text("Approve"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _pendingReviews[index]['status'] = "Denied";
                        _pendingReviews[index]['approvedOn'] =
                            FieldValue.serverTimestamp();

                        db
                            .collection("reviews")
                            .doc(_docIDs[index])
                            .set(_pendingReviews[index]);

                        removeReview(index);
                      },
                      child: Text("Deny"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
