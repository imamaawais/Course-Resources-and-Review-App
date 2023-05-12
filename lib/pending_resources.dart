import 'dart:collection';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'firebase_options.dart';

class PendingResourcesPage extends StatefulWidget {
  PendingResourcesPage({Key? key}) : super(key: key);

  @override
  _PendingResourcesPageState createState() => _PendingResourcesPageState();
}

class _PendingResourcesPageState extends State<PendingResourcesPage> {
  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  List<Map<String, dynamic>> _pendingResources = [];
  List _docIDs = [];

  var db = FirebaseFirestore.instance;

  void fetchReviews() async {
    final resourceCollection = db.collection('resources');
    final resourceDocs = await resourceCollection.get();
    final pendingResource =
        resourceCollection.where("status", isEqualTo: "Pending").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          // print('${docSnapshot.id} => ${docSnapshot.data()}');
          setState(() {
            _pendingResources.add(docSnapshot.data());
            _docIDs.add(docSnapshot.id);
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    // print(pendingResource);
    // final pendingResource =
    //     resourceDocs.docs.map((doc) => doc.data()['name'] as String).toList();
    // courseNames.sort();
    // setState(() {
    //   _pendingResources = pendingResource;
    // });
    // if (pendingResource.isEmpty) {
    //   //Navigator.of(context).pop(); // go back to previous screen
    // }
  }

  void removeResource(int index) {
    setState(() {
      _pendingResources.removeAt(index);
      _docIDs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Resources'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _pendingResources.length,
          itemBuilder: (context, index) {
            final resource = _pendingResources[index]['resource'];
            final url = _pendingResources[index]['resource'];

            return Column(
              children: [
                ListTile(
                  title: GestureDetector(
                    child: Text(
                      resource,
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
                  subtitle: Text("User: " +
                      _pendingResources[index]['userEmail'] +
                      "\nCourse: " +
                      _pendingResources[index]['course']),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _pendingResources[index]['status'] = "Approved";
                        _pendingResources[index]['approvedOn'] =
                            FieldValue.serverTimestamp();

                        db
                            .collection("resources")
                            .doc(_docIDs[index])
                            .set(_pendingResources[index]);

                        removeResource(index);
                      },
                      child: Text("Approve"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _pendingResources[index]['status'] = "Denied";
                        _pendingResources[index]['approvedOn'] =
                            FieldValue.serverTimestamp();

                        db
                            .collection("resources")
                            .doc(_docIDs[index])
                            .set(_pendingResources[index]);

                        removeResource(index);
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
