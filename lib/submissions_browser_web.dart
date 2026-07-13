import 'package:flutter/material.dart';

class SubmissionsBrowser extends StatelessWidget {
  const SubmissionsBrowser({super.key, required this.rootPath});

  final String rootPath;

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Direct local folder browsing is not available on web.\n'
            'Run this app on desktop/mobile to browse /submissions.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
