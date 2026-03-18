import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../domain/models/portrait_risk_result.dart';
import '../../domain/services/portrait_risk_service.dart';

class LocalPortraitRiskService implements PortraitRiskService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.08,
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: false,
    ),
  );

  @override
  Future<PortraitRiskResult> analyze(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final faces = await _detector.processImage(input);

    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    final width = decoded?.width ?? 1;
    final height = decoded?.height ?? 1;
    final imageArea = (width * height).toDouble();

    double totalFaceArea = 0;
    double centerWeightedFaces = 0;
    for (final face in faces) {
      final box = face.boundingBox;
      final area = box.width * box.height;
      totalFaceArea += area;

      final centerX = box.left + box.width / 2;
      final centerY = box.top + box.height / 2;
      final isCenter = centerX >= width * 0.25 &&
          centerX <= width * 0.75 &&
          centerY >= height * 0.2 &&
          centerY <= height * 0.8;
      if (isCenter) {
        centerWeightedFaces += 1;
      }
    }

    final faceAreaRatio = imageArea <= 0 ? 0.0 : totalFaceArea / imageArea;
    final faceCountScore = (faces.length * 18).clamp(0, 50);
    final faceAreaScore = (faceAreaRatio * 220).round().clamp(0, 35);
    final centerScore = (centerWeightedFaces * 8).round().clamp(0, 15);
    final score = (faceCountScore + faceAreaScore + centerScore).clamp(0, 100);

    final level = PortraitRiskResult.levelFromScore(score);
    final summary = faces.isEmpty
        ? 'No clear face detected in this image.'
        : 'Detected ${faces.length} face(s) in this image.';
    final recommendation = switch (level) {
      PortraitRiskLevel.low =>
        'Keep current protection level or increase slightly before sharing.',
      PortraitRiskLevel.medium =>
        'Use medium or higher perturbation before sharing.',
      PortraitRiskLevel.high =>
        'Use high perturbation and avoid sharing the original image.',
    };

    return PortraitRiskResult(
      faceCount: faces.length,
      score: score,
      level: level,
      summary: summary,
      recommendation: recommendation,
    );
  }

  Future<void> dispose() => _detector.close();
}
