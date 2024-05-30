import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../../models/course.dart';
import 'components/course_card.dart';
import 'components/secondary_course_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Recent Events",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('topics').orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<DocumentSnapshot> documents = snapshot.data!.docs;
                    return Row(
                      children: documents.map((document) {
                        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

                        if (data == null) {
                          return SizedBox(); // Return an empty widget or handle null case as per your requirement
                        }

                        String title = data['name'] ?? '';
                        String iconSrc = data['iconSrc'] ?? 'assets/icons/ios.svg';
                        Color color = data['color'] ?? const Color(0xFF7553F6); // Provide a default color

                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: CourseCard(
                            title: title,
                            iconSrc: iconSrc,
                            color: color,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Topics",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              ...recentCourses
                  .map((course) => Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: SecondaryCourseCard(
                          title: course.title,
                          iconsSrc: course.iconSrc,
                          colorl: course.color,
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
