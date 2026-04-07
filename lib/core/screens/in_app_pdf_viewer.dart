import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppPdfViewer extends StatefulWidget {
  final String? url;
  final String? localPath;
  final String title;

  const InAppPdfViewer({
    super.key,
    this.url,
    this.localPath,
    this.title = 'Document',
  }) : assert(url != null || localPath != null,
            'Provide either url or localPath');

  @override
  State<InAppPdfViewer> createState() => _InAppPdfViewerState();
}

class _InAppPdfViewerState extends State<InAppPdfViewer> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;

  // flutter_pdfview only supports Android and iOS
  bool get _isMobileSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    if (!_isMobileSupported) {
      setState(() => _isLoading = false);
      return;
    }
    if (widget.localPath != null) {
      _localPath = widget.localPath;
      _isLoading = false;
    } else {
      _download();
    }
  }

  Future<void> _download() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse(widget.url!));
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/kc_doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) setState(() { _localPath = file.path; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load the document.\n${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
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
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Windows / macOS / Linux — show open-in-browser fallback
    if (!_isMobileSupported) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, size: 72, color: AppColors.blue),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Text(
                'In-app PDF viewing is available on Android & iOS.\nTap below to open in your browser.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              if (widget.url != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14)),
                  icon: const Icon(Icons.open_in_browser, color: Colors.white),
                  label: const Text('Open in Browser',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => launchUrl(
                    Uri.parse(widget.url!),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.blue),
            SizedBox(height: 16),
            Text('Loading document...', style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: _download,
                    child: const Text('Retry'),
                  ),
                  if (widget.url != null) ...[
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue),
                      onPressed: () => launchUrl(
                        Uri.parse(widget.url!),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: const Text('Open in Browser',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation: false,
          onRender: (pages) {
            if (mounted) setState(() => _totalPages = pages ?? 0);
          },
          onError: (error) {
            if (mounted) setState(() => _error = error.toString());
          },
          onPageError: (_, __) {},
          onPageChanged: (page, total) {
            if (mounted) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? _totalPages;
              });
            }
          },
        ),
        if (_totalPages > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
