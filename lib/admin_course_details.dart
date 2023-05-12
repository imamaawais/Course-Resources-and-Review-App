import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminCourseDetails extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const AdminCourseDetails({Key? key, required this.courseData})
      : super(key: key);

  @override
  _AdminCourseDetailsState createState() => _AdminCourseDetailsState();
}

class _AdminCourseDetailsState extends State<AdminCourseDetails> {
  String _resource = '';
  String _review = '';
  String _description = '';
  double _rating = 0;
  bool _showForm = false;
  bool _alreadyReviewed = false;
  double _aggrRating = 0;

  void initState() {
    super.initState();

    calculateAggrRating();
  }

  void calculateAggrRating() {
    double numRatings = 0;
    double totalRatings = 0;
    final reviewCollection = FirebaseFirestore.instance.collection('reviews');
    final approvedReviews = reviewCollection
        .where("course", isEqualTo: widget.courseData['name'])
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          Map<String, dynamic> data = docSnapshot.data();
          setState(() {
            numRatings++;
            totalRatings += data['rating'];

            _aggrRating = totalRatings / numRatings;
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseData = widget.courseData;

    return DefaultTabController(
      length: 2, // number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(courseData['name']),
              SizedBox(
                width: 20,
              ),
              // Text(
              //   _aggrRating.toString(),
              //   style: TextStyle(
              //     fontSize: 18, // Specify the font size here
              //   ),
              // ),
              RatingBarIndicator(
                rating: _aggrRating,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20.0,
                direction: Axis.horizontal,
              ),
              // Icon(
              //   Icons.star,
              //   size: 18.0,
              //   color: Colors.amber,
              // ),
              // Text(')'),
            ],
          ),
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
            // Review Course tab content
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('reviews')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading');
                              }

                              List<Map<String, dynamic>> reviewsList = [];
                              snapshot.data!.docs
                                  .forEach((DocumentSnapshot document) {
                                Map<String, dynamic> reviewData =
                                    document.data() as Map<String, dynamic>;
                                if (reviewData['course'] ==
                                        courseData['name'] &&
                                    reviewData['status'] == 'Approved') {
                                  reviewsList.add(reviewData);
                                }
                              });

                              if (reviewsList.isEmpty) {
                                return Text('No reviews yet');
                              }

                              return SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: reviewsList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Map<String, dynamic> reviewData =
                                        reviewsList[index];

                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Row(
                                            children: [
                                              Text(
                                                "Added by:${reviewData['userEmail']}",
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: RatingBarIndicator(
                                                    rating:
                                                        reviewData['rating'],
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    itemCount: 5,
                                                    itemSize: 20.0,
                                                    direction: Axis.horizontal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(reviewData['review']),
                                        ),
                                        Divider(
                                          height: 1,
                                          color: Colors.grey[
                                              400], // Set the color of the divider
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 150,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Resources tab content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('resources')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading');
                        }

                        List<Map<String, dynamic>> approvedResourcesList = [];
                        snapshot.data!.docs
                            .forEach((DocumentSnapshot document) {
                          Map<String, dynamic> resourceData =
                              document.data() as Map<String, dynamic>;
                          if (resourceData['course'] == courseData['name'] &&
                              resourceData['status'] == 'Approved') {
                            approvedResourcesList.add(resourceData);
                          }
                        });

                        approvedResourcesList.sort((a, b) {
                          final aApprovedOn = a['approvedOn'] as Timestamp;
                          final bApprovedOn = b['approvedOn'] as Timestamp;
                          return bApprovedOn.compareTo(aApprovedOn);
                        });

                        if (approvedResourcesList.isEmpty) {
                          return Text('No approved resources yet');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: approvedResourcesList.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> resourceData =
                                approvedResourcesList[index];
                            final resourceTitle = resourceData['resource'];
                            final resourceUrl = resourceData['resource'];
                            final resourceDescription =
                                resourceData['description'];

                            return Column(
                              children: [
                                ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Added by: ${resourceData['userEmail']}',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      GestureDetector(
                                        child: Text(
                                          resourceTitle,
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(33, 150, 243, 1),
                                            //decoration: TextDecoration.underline,
                                          ),
                                        ),
                                        onTap: () async {
                                          if (await canLaunchUrlString(
                                              resourceUrl)) {
                                            await launchUrlString(resourceUrl);
                                          } else {
                                            print(
                                                'Could not launch URL: $resourceUrl');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    'Description: ${resourceData['description']}',
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: Colors.grey[
                                      400], // Set the color of the divider
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
