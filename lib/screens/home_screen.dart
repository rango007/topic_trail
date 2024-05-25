import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_screen.dart';
import 'create_topic_screen.dart';
import '../widgets/topic_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTopicScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('topics').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No topics found.'));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 topics per row
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String? imageUrl = data.containsKey('imageUrl') ? data['imageUrl'] : null;
              String? resizedImageUrl;
              if (imageUrl != null) {
                final uri = Uri.parse(imageUrl);
                final pathSegments = uri.pathSegments;
                final fileName = pathSegments.last;
                final extensionIndex = fileName.lastIndexOf('.');
                String resizedFileName;
                if (extensionIndex != -1) {
                  resizedFileName = fileName.substring(0, extensionIndex) + '_200x200' + fileName.substring(extensionIndex);
                } else {
                  resizedFileName = fileName + '_200x200';
                }
                resizedImageUrl = uri.replace(pathSegments: [...pathSegments.sublist(0, pathSegments.length - 1), resizedFileName]).toString();
              }
              return AspectRatio(
                aspectRatio: 1, // Square aspect ratio
                child: TopicCard(
                  topicName: data['name'],
                  imageUrl: resizedImageUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionScreen(
                          topicId: document.id,
                          topicName: data['name'], // Pass the topic name to QuestionScreen
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
