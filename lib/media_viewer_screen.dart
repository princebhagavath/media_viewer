import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';

class MediaViewerScreen extends StatefulWidget {
  const MediaViewerScreen({super.key});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  final TextEditingController _controller = TextEditingController();
  String imageUrl = '';
  bool showMenu = false;
  bool _isFilled = false;

  @override
  void initState() {
    super.initState();

    /// Injects the javascript at the initState() of the page
    _injectJavaScript();
  }

  /// Injects JavaScript functions into the browser to handle fullscreen mode.
  ///
  /// These functions allow toggling, entering, and exiting fullscreen mode.
  void _injectJavaScript() {
    js.context.callMethod('eval', [
      """
      window.toggleFullscreen = function() {
        if (!document.fullscreenElement) {
          document.documentElement.requestFullscreen();
        } else {
          document.exitFullscreen();
        }
      };

      window.enterFullscreen = function() {
        if (!document.fullscreenElement) {
          document.documentElement.requestFullscreen();
        }
      };

      window.exitFullscreen = function() {
        if (document.fullscreenElement) {
          document.exitFullscreen();
        }
      };
      """
    ]);
  }

  /// Updates the image size based on `_isFilled` state.
  ///
  /// When `_isFilled` is true, the image expands to fill the screen;
  /// otherwise, it resets to a default 500px size.
  void _updateImageSize() {
    final imgElement = html.querySelector('#image') as html.ImageElement?;
    if (imgElement != null) {
      imgElement.style.width = _isFilled ? '100%' : '500px';
      imgElement.style.height = _isFilled ? '100%' : '500px';
    }
  }

  /// Loads the image from the user-provided URL and inserts it into the HTML container.
  ///
  /// - Creates an `<img>` element with the given `imageUrl`.
  /// - Sets up a double-click listener to toggle fullscreen mode.
  void _loadImage() {
    setState(() {
      imageUrl = _controller.text.trim();
    });

    if (imageUrl.isNotEmpty) {
      final imgElement = html.ImageElement()
        ..src = imageUrl
        ..id = 'image'
        ..style.width = '500px'
        ..style.height = '500px'
        ..style.cursor = 'pointer'
        ..onDoubleClick.listen((_) {
          setState(() {
            _isFilled = !_isFilled;
          });
          _updateImageSize();
          js.context.callMethod('toggleFullscreen');
        });

      final container = html.DivElement()
        ..id = 'imageContainer'
        ..style.display = 'flex'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center'
        ..style.height = '100%'
        ..style.width = '100%'
        ..children = [imgElement];

      final imageDiv = html.querySelector('#flutterImageContainer');
      imageDiv?.children.clear();
      imageDiv?.append(container);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: showMenu ? Colors.black.withOpacity(0.5) : Colors.white,
      appBar: AppBar(
        title: const Text('Media Viewer'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Image URL',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _loadImage,
            child: const Text("Load Image"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: HtmlElementView(viewType: 'flutterImageContainer'),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          if (showMenu)
            GestureDetector(
              onTap: () => setState(() => showMenu = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          Positioned(
            bottom: 80,
            right: 20,
            child: AnimatedOpacity(
              opacity: showMenu ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    /// Expands the image and browser to fullscreen when pressed.
                    TextButton(
                      onPressed: () {
                        js.context.callMethod('enterFullscreen');
                        setState(() {
                          _isFilled = true;
                          showMenu = false;
                        });
                        _updateImageSize();
                      },
                      child: const Text("Enter Fullscreen"),
                    ),

                    /// Exits fullscreen mode and resets the image size.
                    TextButton(
                      onPressed: () {
                        js.context.callMethod('exitFullscreen');
                        setState(() {
                          _isFilled = false;
                          showMenu = false;
                        });
                        _updateImageSize();
                      },
                      child: const Text("Exit Fullscreen"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Floating action button to show/hide the menu.
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => setState(() => showMenu = !showMenu),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
