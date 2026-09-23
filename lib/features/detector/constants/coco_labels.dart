import 'dart:ui';

/// The 80 COCO object classes recognized by standard SSD MobileNet models.
class CocoLabels {
  CocoLabels._();

  static const List<String> labels = [
    'person',
    'bicycle',
    'car',
    'motorcycle',
    'airplane',
    'bus',
    'train',
    'truck',
    'boat',
    'traffic light',
    'fire hydrant',
    'stop sign',
    'parking meter',
    'bench',
    'bird',
    'cat',
    'dog',
    'horse',
    'sheep',
    'cow',
    'elephant',
    'bear',
    'zebra',
    'giraffe',
    'backpack',
    'umbrella',
    'handbag',
    'tie',
    'suitcase',
    'frisbee',
    'skis',
    'snowboard',
    'sports ball',
    'kite',
    'baseball bat',
    'baseball glove',
    'skateboard',
    'surfboard',
    'tennis racket',
    'bottle',
    'wine glass',
    'cup',
    'fork',
    'knife',
    'spoon',
    'bowl',
    'banana',
    'apple',
    'sandwich',
    'orange',
    'broccoli',
    'carrot',
    'hot dog',
    'pizza',
    'donut',
    'cake',
    'chair',
    'couch',
    'potted plant',
    'bed',
    'dining table',
    'toilet',
    'tv',
    'laptop',
    'mouse',
    'remote',
    'keyboard',
    'cell phone',
    'microwave',
    'oven',
    'toaster',
    'sink',
    'refrigerator',
    'book',
    'clock',
    'vase',
    'scissors',
    'teddy bear',
    'hair drier',
    'toothbrush',
  ];

  /// Resolves the human-readable label for a class index.
  /// Handles both 0-indexed and 1-indexed model outputs safely.
  static String getLabel(int classId) {
    if (classId >= 0 && classId < labels.length) {
      return labels[classId];
    } else if (classId - 1 >= 0 && (classId - 1) < labels.length) {
      // 1-indexed fallback (e.g. 1 == person)
      return labels[classId - 1];
    }
    return 'Object';
  }

  /// Returns a vivid, distinct color based on the object's category for clear visual identification.
  static Color getColorForCategory(String label) {
    final lower = label.toLowerCase();
    if (lower == 'person') {
      return const Color(0xFF0077FE); // Electric Blue for people
    } else if (['bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', 'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter'].contains(lower)) {
      return const Color(0xFFFF6D00); // Vibrant Amber / Orange for vehicles & traffic
    } else if (['bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe'].contains(lower)) {
      return const Color(0xFF00C853); // Emerald Green for animals
    } else if (['backpack', 'umbrella', 'handbag', 'tie', 'suitcase'].contains(lower)) {
      return const Color(0xFFD500F9); // Magenta / Pink for personal accessories
    } else if (['frisbee', 'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard', 'tennis racket'].contains(lower)) {
      return const Color(0xFF651FFF); // Deep Violet for sports gear
    } else if (['bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake'].contains(lower)) {
      return const Color(0xFFFF1744); // Crimson / Coral for food & dining
    } else if (['chair', 'couch', 'potted plant', 'bed', 'dining table', 'toilet'].contains(lower)) {
      return const Color(0xFF00BFA5); // Teal for furniture
    } else if (['tv', 'laptop', 'mouse', 'remote', 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink', 'refrigerator'].contains(lower)) {
      return const Color(0xFF9C27B0); // Purple / Indigo for electronics & appliances
    }
    return const Color(0xFFFFAB00); // Gold / Amber default
  }
}
