import 'dart:io';

import 'package:flutter/material.dart';

class SubmissionsBrowser extends StatefulWidget {
  const SubmissionsBrowser({super.key, required this.rootPath});

  final String rootPath;

  @override
  State<SubmissionsBrowser> createState() => _SubmissionsBrowserState();
}

class _SubmissionsBrowserState extends State<SubmissionsBrowser> {
  late Future<List<FileSystemEntity>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
  }

  Future<List<FileSystemEntity>> _loadEntries() async {
    final requestedDir = Directory(widget.rootPath);
    if (await requestedDir.exists()) {
      return _sortedEntries(requestedDir);
    }

    final projectLocalDir = Directory('submissions');
    if (await projectLocalDir.exists()) {
      return _sortedEntries(projectLocalDir);
    }

    throw FileSystemException(
      'Could not find directory at ${widget.rootPath} or ./submissions',
    );
  }

  Future<List<FileSystemEntity>> _sortedEntries(Directory directory) async {
    final entries = await directory.list(followLinks: false).toList();
    entries.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    return entries;
  }

  String _nameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isEmpty ? path : parts.last;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder<List<FileSystemEntity>>(
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
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final entries = snapshot.data ?? <FileSystemEntity>[];
          if (entries.isEmpty) {
            return const Center(
              child: Text('No files found in submissions directory.'),
            );
          }

          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entity = entries[index];
              final isDir = entity is Directory;
              final label = _nameFromPath(entity.path);

              return ListTile(
                leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file),
                title: Text(label),
                subtitle: Text(entity.path),
              );
            },
          );
        },
      ),
    );
  }
}
