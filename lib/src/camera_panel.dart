import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class InterviewCameraPanel extends StatefulWidget {
  const InterviewCameraPanel({super.key, required this.onViolation});
  final ValueChanged<String> onViolation;

  @override
  State<InterviewCameraPanel> createState() => _InterviewCameraPanelState();
}

class _InterviewCameraPanelState extends State<InterviewCameraPanel>
    with WidgetsBindingObserver {
  CameraController? controller;
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
  String? message;
  bool processingFrame = false;
  bool validFaceSeen = false;
  int invalidFrames = 0;
  DateTime lastAlert = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  Future<void> initialize() async {
    try {
      final devices = await availableCameras();
      if (devices.isEmpty) throw CameraException('notFound', 'No camera found');
      final front =
          devices
              .where(
                (camera) => camera.lensDirection == CameraLensDirection.front,
              )
              .firstOrNull ??
          devices.first;
      final camera = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await camera.initialize();
      if (!mounted) {
        return camera.dispose();
      }
      setState(() => controller = camera);
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        await camera.startImageStream(processCameraImage);
      }
    } on CameraException catch (error) {
      if (mounted) {
        setState(
          () => message = error.description ?? 'Camera permission is required.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Camera is unavailable on this device.');
      }
    }
  }

  Future<void> processCameraImage(CameraImage image) async {
    if (processingFrame || !mounted || image.planes.isEmpty) return;
    processingFrame = true;
    try {
      final rotation =
          InputImageRotationValue.fromRawValue(
            controller!.description.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null || image.planes.length != 1) return;
      final input = InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
      final faces = await faceDetector.processImage(input);
      if (faces.length == 1) {
        validFaceSeen = true;
        invalidFrames = 0;
        return;
      }
      if (!validFaceSeen) return;
      invalidFrames++;
      final requiredFrames = faces.length > 1 ? 3 : 8;
      if (invalidFrames < requiredFrames ||
          DateTime.now().difference(lastAlert) < const Duration(seconds: 8)) {
        return;
      }
      lastAlert = DateTime.now();
      invalidFrames = 0;
      widget.onViolation(
        faces.length > 1
            ? 'More than one person was detected automatically.'
            : 'The candidate face is missing from the camera frame.',
      );
    } catch (_) {
      // Unsupported frame formats are ignored; camera preview remains usable.
    } finally {
      processingFrame = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
      controller = null;
    } else if (state == AppLifecycleState.resumed) {
      initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (message != null) return _CameraPlaceholder(message: message!);
    if (controller == null || !controller!.value.isInitialized) {
      return const _CameraPlaceholder(message: 'Starting front camera…');
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: CameraPreview(controller!),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    height: 180,
    decoration: BoxDecoration(
      color: const Color(0xff10233f),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_outlined, color: Colors.white, size: 34),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}
