import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:media_viewer/media_viewer_screen.dart';

void main() {
  // Registers the custom HTML container for embedding web content
  registerViewFactory();

  // Runs the Flutter application
  runApp(const MyApp());
}

/// This function sets up a custom HTML container (`flutterImageContainer`)
///
/// Since Flutter Web doesn’t support direct HTML elements in widgets,
/// we use `registerViewFactory` to create a `<div>` where we can insert custom HTML content
void registerViewFactory() {
  ui.platformViewRegistry.registerViewFactory(
    'flutterImageContainer',
    (int viewId) => html.DivElement()..id = 'flutterImageContainer',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Viewer',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MediaViewerScreen(), // Loads the media viewer screen
    );
  }
}
