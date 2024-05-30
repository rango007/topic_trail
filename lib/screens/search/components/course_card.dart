import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    this.color = const Color(0xFF7553F6),
  }) : super(key: key);

  final String title, imageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: 260,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
