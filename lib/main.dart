import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyPDFApp());
}

class MyPDFApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local PDF Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LocalPDFViewer(),
    );
  }
}

class LocalPDFViewer extends StatefulWidget {
  @override
  _LocalPDFViewerState createState() => _LocalPDFViewerState();
}

class _LocalPDFViewerState extends State<LocalPDFViewer> {
  String? localPdfPath;
  bool isLoading = true;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    loadPdfFromAssets();
  }

  Future<void> loadPdfFromAssets() async {
    try {
      final byteData = await rootBundle.load('assets/sample.pdf');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sample.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      setState(() {
        localPdfPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading PDF: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load PDF')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Local PDF Viewer'), centerTitle: true),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  SfPdfViewer.file(
                    File(localPdfPath!),
                    key: _pdfViewerKey,
                    controller: _pdfViewerController,
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                    enableTextSelection: true,
                    enableDoubleTapZooming: true,
                    pageLayoutMode: PdfPageLayoutMode.continuous,
                  ),
                  Positioned(
                    right: 16,
                    bottom: 32,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'zoom_in',
                          mini: true,
                          child: Icon(Icons.zoom_in),
                          onPressed: () {
                            setState(() {
                              _pdfViewerController.zoomLevel =
                                  (_pdfViewerController.zoomLevel + 0.25).clamp(
                                    1.0,
                                    3.0,
                                  );
                            });
                          },
                        ),
                        SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'zoom_out',
                          mini: true,
                          child: Icon(Icons.zoom_out),
                          onPressed: () {
                            setState(() {
                              _pdfViewerController.zoomLevel =
                                  (_pdfViewerController.zoomLevel - 0.25).clamp(
                                    1.0,
                                    3.0,
                                  );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
