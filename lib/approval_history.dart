import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

class ApprovalHistoryPage extends StatefulWidget {
  ApprovalHistoryPage({Key? key}) : super(key: key);

  @override
  _ApprovalHistoryPageState createState() => _ApprovalHistoryPageState();
}

class _ApprovalHistoryPageState extends State<ApprovalHistoryPage> {
  @override
  void initState() {
    super.initState();
    fetchReviews();
    fetchResources();
  }

  List<Map<String, dynamic>> _checkedReviews = [];
  List<Map<String, dynamic>> _checkedResources = [];

  Map<String, dynamic> data = {};
  Map<String, dynamic> dataresource = {};

  var db = FirebaseFirestore.instance;

  void fetchReviews() async {
    final reviewCollection = db.collection('reviews');
    final reviewDocs = await reviewCollection.get();

    final approvedReviews =
        reviewCollection.where("status", isEqualTo: "Approved").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          // print('${docSnapshot.id} => ${docSnapshot.data()}');
          setState(() {
            data = docSnapshot.data();
            data["docID"] = docSnapshot.id;

            _checkedReviews.add(data);
            _checkedReviews
                .sort((a, b) => b['approvedOn'].compareTo(a['approvedOn']));
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    final deniedReviews =
        reviewCollection.where("status", isEqualTo: "Denied").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          // print('${docSnapshot.id} => ${docSnapshot.data()}');
          setState(() {
            data = docSnapshot.data();
            data["docID"] = docSnapshot.id;

            _checkedReviews.add(data);
            _checkedReviews
                .sort((a, b) => b['approvedOn'].compareTo(a['approvedOn']));
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
    //   _checkedReviews = pendingReviews;
    // });
    // if (pendingReviews.isEmpty) {
    //   //Navigator.of(context).pop(); // go back to previous screen
    // }
  }

  void fetchResources() async {
    final resourceCollection = db.collection('resources');

    final resourceDocs = await resourceCollection.get();

    final approvedResources =
        resourceCollection.where("status", isEqualTo: "Approved").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          setState(() {
            dataresource = docSnapshot.data();
            dataresource["docID"] = docSnapshot.id;

            _checkedResources.add(dataresource);
            _checkedResources
                .sort((a, b) => b['approvedOn'].compareTo(a['approvedOn']));
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    final deniedResources =
        resourceCollection.where("status", isEqualTo: "Denied").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          //print('${docSnapshot.id} => ${docSnapshot.data()}');
          setState(() {
            dataresource = docSnapshot.data();
            dataresource["docID"] = docSnapshot.id;

            _checkedResources.add(dataresource);
            _checkedResources
                .sort((a, b) => b['approvedOn'].compareTo(a['approvedOn']));
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  void removeReview(int index) {
    setState(() {
      _checkedReviews.removeAt(index);
    });
  }

  void removeResource(int index) {
    setState(() {
      _checkedResources.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Approval History'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Reviews',
              ),
              Tab(
                text: 'Resources',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: _checkedReviews.length,
              itemBuilder: (context, index) {
                // Render review
                return Column(
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Added by: " + _checkedReviews[index]['userEmail'],
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            "Added on: ${DateFormat('dd-MM-yyyy HH:mm').format(_checkedReviews[index]['approvedOn'].toDate())}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            "Status: ${_checkedReviews[index]['status']}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            "Course: " + _checkedReviews[index]['course'],
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _checkedReviews[index]['review'],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.undo),
                            onPressed: () {
                              _checkedReviews[index]['status'] = "Pending";
                              _checkedReviews[index]['approvedOn'] = "";

                              db
                                  .collection("reviews")
                                  .doc(_checkedReviews[index]["docID"])
                                  .update(
                                      {"status": "Pending", "approvedOn": ""});

                              removeReview(index);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey),
                  ],
                );
              },
            ),
            ListView.builder(
              itemCount: _checkedResources.length,
              itemBuilder: (context, index) {
                // Render resource
                final resourceIndex = index;
                final url = _checkedResources[resourceIndex]['resource'];
                return Column(
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Added by: " +
                                _checkedResources[resourceIndex]['userEmail'],
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            "Added on: ${DateFormat('dd-MM-yyyy HH:mm').format(_checkedResources[index]['approvedOn'].toDate())}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            "Status: ${_checkedResources[index]['status']}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            "Course: " +
                                _checkedResources[resourceIndex]['course'],
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            child: Text(
                              _checkedResources[resourceIndex]['resource'],
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onTap: () async {
                              if (await canLaunchUrlString(url)) {
                                await launchUrlString(url);
                              } else {
                                print('Could not launch URL: $url');
                              }
                            },
                          ),
                          Text(_checkedResources[resourceIndex]['description'])
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.undo),
                            onPressed: () {
                              _checkedResources[resourceIndex]['status'] =
                                  "Pending";
                              _checkedResources[resourceIndex]['approvedOn'] =
                                  "";

                              db
                                  .collection("resources")
                                  .doc(
                                      _checkedResources[resourceIndex]["docID"])
                                  .update(
                                      {"status": "Pending", "approvedOn": ""});

                              removeResource(resourceIndex);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
