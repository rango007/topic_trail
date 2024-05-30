import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../topic/topic_screen.dart'; // Import TopicPage
import 'components/course_card.dart';
import 'components/secondary_course_card.dart';

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Latest",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('topics')
                      .where('postType', isEqualTo: 'Recent Events')
                      .where('category', isEqualTo: category)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<DocumentSnapshot> documents = snapshot.data!.docs;

                    if (documents.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Nothing latest in $category',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      );
                    }

                    return Row(
                      children: documents.map((document) {
                        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

                        if (data == null) {
                          return SizedBox(); // Return an empty widget or handle null case as per your requirement
                        }

                        String title = data['name'] ?? '';
                        String imageUrl = data['imageUrl'] ?? 'assets/icons/ios.svg';
                        Color color = data['color'] ?? const Color(0xFF7553F6); // Provide a default color

                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => TopicPage(
                                    topicId: document.id,
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
                            ),
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
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('topics')
                    .where('postType', isEqualTo: 'General Topic')
                    .where('category', isEqualTo: category)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<DocumentSnapshot> documents = snapshot.data!.docs;

                  if (documents.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Nothing found for $category',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
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
                          child: SecondaryCourseCard(
                            name: title,
                            imageUrl: imageUrl,
                            color: color,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
