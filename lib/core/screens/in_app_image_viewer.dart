import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shows an image either from a network URL or from in-memory bytes.
/// Use [bytes] for private/authenticated images downloaded via Supabase storage.
/// Use [imageUrl] for public URLs (e.g. chat attachments).
class InAppImageViewer extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? bytes;
  final String title;

  const InAppImageViewer({
    super.key,
    this.imageUrl,
    this.bytes,
    this.title = 'Image',
  }) : assert(imageUrl != null || bytes != null,
            'Provide either imageUrl or bytes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: bytes != null
              ? Image.memory(
                  bytes!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _errorWidget(),
                )
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => _errorWidget(),
                ),
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, color: Colors.white60, size: 64),
        SizedBox(height: 12),
        Text('Failed to load image', style: TextStyle(color: Colors.white60)),
      ],
    );
  }
}
