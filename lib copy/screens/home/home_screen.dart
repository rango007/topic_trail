import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../topic/topic_screen.dart'; // Import TopicPage

import 'components/course_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('topics').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            List<DocumentSnapshot> documents = snapshot.data!.docs;

            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                Map<String, dynamic>? data = documents[index].data() as Map<String, dynamic>?;

                if (data == null) {
                  return SizedBox(); // Return an empty widget or handle null case as per your requirement
                }

                String title = data['name'] ?? '';
                String imageUrl = data['imageUrl'] ?? 'assets/icons/ios.svg';
                Color color = data['color'] ?? const Color(0xFF7553F6); // Provide a default color

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => TopicPage(
                          topicId: documents[index].id,
                          topicName: title,
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          final offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: CourseCard(
                    title: title,
                    imageUrl: imageUrl,
                    color: color,
                    fullScreen: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
