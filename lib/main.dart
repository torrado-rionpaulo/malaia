import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/yolo.dart';
import 'package:ultralytics_yolo/yolo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

YOLO? _yolo;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MALAIA',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Colors.purple[800],
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Colors.purple[800],
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(
            color: Colors.purple[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const ImagePick(),
    );
  }
}

class ImagePick extends StatefulWidget {
  const ImagePick({super.key});

  @override
  _ImagePickState createState() => _ImagePickState();
}

class _ImagePickState extends State<ImagePick> {
  File? selectedImage;
  List<dynamic> results = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadYOLOModel();
  }

  Future<void> _loadYOLOModel() async {
    if (_yolo == null) {
      setState(() => isLoading = true);
      _yolo = YOLO(
        modelPath: 'malaia_v8s.tflite',
        task: YOLOTask.detect,
      );
      await _yolo!.loadModel();
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndDetect() async {
    if (_yolo == null) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        isLoading = true;
      });

      try {
        final imageBytes = await selectedImage!.readAsBytes();
        final detectionResults = await _yolo!.predict(imageBytes);

        setState(() {
          results = detectionResults['boxes'] ?? [];
          isLoading = false;
        });
      } catch (e) {
        print('Error during detection: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple[800]),
        title: Text(
          'MALAIA Image Picker',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        backgroundColor: Colors.purple[100],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 60,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                ),
                child: Text(
                  'MALAIA Info',
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
              ),
            ),
            const ListTile(
              title: Text('(Insert information about research and application)'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedImage != null)
              Container(
                height: 300,
                child: Image.file(selectedImage!),
              ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Text('Detected ${results.length} objects'),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[100],
              ),
              onPressed: _yolo != null ? _pickAndDetect : null,
              child: Text(
                'Pick Image & Detect',
                style: Theme.of(context).textTheme.titleSmall!,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final detection = results[index];
                  return ListTile(
                    title: Text(detection['class'] ?? 'Unknown'),
                    subtitle: Text(
                      'Confidence: ${(detection['confidence'] * 100).toStringAsFixed(1)}%',
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                ),
                child: Text(
                  'To Live Camera',
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const LiveCam(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveCam extends StatefulWidget {
  const LiveCam({super.key});

  @override
  _LiveCamState createState() => _LiveCamState();
}

class _LiveCamState extends State<LiveCam> with TickerProviderStateMixin {
  late final YOLOViewController controller;
  List<YOLOResult> currentResults = [];

  @override
  void initState() {
    super.initState();
    controller = YOLOViewController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple[800]),
        title: Text(
          'MALAIA Live Camera',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        backgroundColor: Colors.purple[100],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 60,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                ),
                child: Text(
                  'MALAIA Info',
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
              ),
            ),
            const ListTile(
              title: Text('(Insert information about research and application)'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          YOLOView(
            modelPath: 'malaia_v8s.tflite',
            task: YOLOTask.detect,
            showNativeUI: true,
            controller: controller,
            onResult: (results) {
              print('Camera working: ${results.length} detections');
              setState(() {
                currentResults = results;
              });
            },
            onStreamingData: (data) {
              print('Streaming data received: ${data.keys}');
            },
            onPerformanceMetrics: (metrics) {
              print('FPS: ${metrics.fps.toStringAsFixed(1)}');
              print('Processing time: ${metrics.processingTimeMs.toStringAsFixed(1)}ms');
            },
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[100],
              ),
              child: Text(
                'To Image Picker',
                style: Theme.of(context).textTheme.titleSmall!,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
