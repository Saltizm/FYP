import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubmissionsBrowser extends StatefulWidget {
  const SubmissionsBrowser({super.key, required this.rootPath});

  final String rootPath;

  @override
  State<SubmissionsBrowser> createState() => _SubmissionsBrowserState();
}

class _SubmissionsBrowserState extends State<SubmissionsBrowser> {
  late Future<List<_WebSubmissionEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
  }

  Future<List<_WebSubmissionEntry>> _loadEntries() async {
    final basePath = widget.rootPath.endsWith('/')
        ? widget.rootPath.substring(0, widget.rootPath.length - 1)
        : widget.rootPath;
    final indexUrl = '$basePath/index.json';

    final raw = await NetworkAssetBundle(Uri.base).loadString(indexUrl);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['entries'] is! List<dynamic>) {
      throw Exception('Invalid submissions index format at $indexUrl');
    }

    final entries = <_WebSubmissionEntry>[];
    for (final item in decoded['entries'] as List<dynamic>) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final name = item['name'] as String?;
      final path = item['path'] as String?;
      final type = item['type'] as String?;
      if (name == null || path == null || type == null) {
        continue;
      }

      entries.add(
        _WebSubmissionEntry(
          name: name,
          path: path,
          isDirectory: type == 'directory',
        ),
      );
    }

    entries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder<List<_WebSubmissionEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Could not load web submissions index at ${widget.rootPath}/index.json\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final entries = snapshot.data ?? <_WebSubmissionEntry>[];
          if (entries.isEmpty) {
            return const Center(
              child: Text('No files found in /submissions.'),
            );
          }

          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                leading: Icon(entry.isDirectory ? Icons.folder : Icons.insert_drive_file),
                title: Text(entry.name),
                subtitle: Text('${widget.rootPath}/${entry.path}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _WebSubmissionEntry {
  const _WebSubmissionEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
  });

  final String name;
  final String path;
  final bool isDirectory;
}
