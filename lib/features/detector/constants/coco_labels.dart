import 'dart:ui';

/// The 90 COCO object classes recognized by standard SSD MobileNet models (with gaps aligned).
class CocoLabels {
  CocoLabels._();

  /// Official 90-class COCO label map used by TensorFlow Object Detection SSD MobileNet models.
  /// 1-indexed to match model output classes (1 = person, 2 = bicycle, etc.).
  static const List<String> coco90 = [
    'person', // 1
    'bicycle', // 2
    'car', // 3
    'motorcycle', // 4
    'airplane', // 5
    'bus', // 6
    'train', // 7
    'truck', // 8
    'boat', // 9
    'traffic light', // 10
    'fire hydrant', // 11
    '???', // 12 (gap in COCO)
    'stop sign', // 13
    'parking meter', // 14
    'bench', // 15
    'bird', // 16
    'cat', // 17
    'dog', // 18
    'horse', // 19
    'sheep', // 20
    'cow', // 21
    'elephant', // 22
    'bear', // 23
    'zebra', // 24
    'giraffe', // 25
    '???', // 26 (gap in COCO)
    'backpack', // 27
    'umbrella', // 28
    '???', // 29 (gap in COCO)
    '???', // 30 (gap in COCO)
    'handbag', // 31
    'tie', // 32
    'suitcase', // 33
    'frisbee', // 34
    'skis', // 35
    'snowboard', // 36
    'sports ball', // 37
    'kite', // 38
    'baseball bat', // 39
    'baseball glove', // 40
    'skateboard', // 41
    'surfboard', // 42
    'tennis racket', // 43
    'bottle', // 44
    '???', // 45 (gap in COCO)
    'wine glass', // 46
    'cup', // 47
    'fork', // 48
    'knife', // 49
    'spoon', // 50
    'bowl', // 51
    'banana', // 52
    'apple', // 53
    'sandwich', // 54
    'orange', // 55
    'broccoli', // 56
    'carrot', // 57
    'hot dog', // 58
    'pizza', // 59
    'donut', // 60
    'cake', // 61
    'chair', // 62
    'couch', // 63
    'potted plant', // 64
    'bed', // 65
    '???', // 66 (gap in COCO)
    'dining table', // 67
    '???', // 68 (gap in COCO)
    '???', // 69 (gap in COCO)
    'toilet', // 70
    '???', // 71 (gap in COCO)
    'tv', // 72
    'laptop', // 73
    'mouse', // 74
    'remote', // 75
    'keyboard', // 76
    'cell phone', // 77
    'microwave', // 78
    'oven', // 79
    'toaster', // 80
    'sink', // 81
    'refrigerator', // 82
    '???', // 83 (gap in COCO)
    'book', // 84
    'clock', // 85
    'vase', // 86
    'scissors', // 87
    'teddy bear', // 88
    'hair drier', // 89
    'toothbrush', // 90
  ];

  /// Active 80 COCO classes (excluding empty index slots).
  static List<String> get labels =>
      coco90.where((l) => l != '???').toList(growable: false);

  /// Resolves the human-readable label for a class index.
  /// Handles both 0-indexed, 1-indexed, and COCO-90 extended model outputs safely.
  static String getLabel(int classId) {
    if (classId >= 0 && classId < labels.length) {
      return labels[classId];
    } else if (classId - 1 >= 0 && (classId - 1) < labels.length) {
      return labels[classId - 1];
    } else if (classId >= 1 && classId <= coco90.length) {
      final name = coco90[classId - 1];
      if (name != '???') {
        return name;
      }
    }
    return 'Object';
  }

  /// Map of COCO English labels to natural Hindi terms.
  static const Map<String, String> hindiLabels = {
    'object': 'वस्तु',
    'person': 'व्यक्ति',
    'bicycle': 'साइकिल',
    'car': 'कार',
    'motorcycle': 'मोटरसाइकिल',
    'airplane': 'हवाई जहाज',
    'bus': 'बस',
    'train': 'ट्रेन',
    'truck': 'ट्रक',
    'boat': 'नाव',
    'traffic light': 'ट्रैफिक लाइट',
    'fire hydrant': 'फायर हाइड्रेंट',
    'stop sign': 'स्टॉप साइन',
    'parking meter': 'पार्किंग मीटर',
    'bench': 'बेंच',
    'bird': 'पक्षी',
    'cat': 'बिल्ली',
    'dog': 'कुत्ता',
    'horse': 'घोड़ा',
    'sheep': 'भेड़',
    'cow': 'गाय',
    'elephant': 'हाथी',
    'bear': 'भालू',
    'zebra': 'ज़ेबरा',
    'giraffe': 'जिराफ़',
    'backpack': 'बैग',
    'umbrella': 'छाता',
    'handbag': 'पर्स',
    'tie': 'टाई',
    'suitcase': 'सूटकेस',
    'frisbee': 'फ्रिस्बी',
    'skis': 'स्की',
    'snowboard': 'स्नोबोर्ड',
    'sports ball': 'खेल की गेंद',
    'kite': 'पतंग',
    'baseball bat': 'बेसबॉल बल्ला',
    'baseball glove': 'बेसबॉल दस्ताना',
    'skateboard': 'स्केटबोर्ड',
    'surfboard': 'सर्फ़बोर्ड',
    'tennis racket': 'टेनिस रैकेट',
    'bottle': 'बोतल',
    'wine glass': 'कांच का गिलास',
    'cup': 'कप',
    'fork': 'कांटा',
    'knife': 'चाकू',
    'spoon': 'चम्मच',
    'bowl': 'कटोरा',
    'banana': 'केला',
    'apple': 'सेब',
    'sandwich': 'सैंडविच',
    'orange': 'संतरा',
    'broccoli': 'ब्रोकली',
    'carrot': 'गाजर',
    'hot dog': 'हॉट डॉग',
    'pizza': 'पिज़्ज़ा',
    'donut': 'डोनट',
    'cake': 'केक',
    'chair': 'कुर्सी',
    'couch': 'सोफ़ा',
    'potted plant': 'गमले का पौधा',
    'bed': 'बिस्तर',
    'dining table': 'खाने की मेज़',
    'toilet': 'शौचालय',
    'tv': 'टीवी',
    'laptop': 'लैपटॉप',
    'mouse': 'माउस',
    'remote': 'रिमोट',
    'keyboard': 'कीबोर्ड',
    'cell phone': 'मोबाइल फोन',
    'microwave': 'माइक्रोवेव',
    'oven': 'ओवन',
    'toaster': 'टोस्टर',
    'sink': 'सिंक',
    'refrigerator': 'फ्रिज',
    'book': 'किताब',
    'clock': 'घड़ी',
    'vase': 'फूलदान',
    'scissors': 'कैंची',
    'teddy bear': 'टेडी बियर',
    'hair drier': 'हेयर ड्रायर',
    'toothbrush': 'टूथब्रश',
  };

  /// Returns the localized label for a detected object according to the active language code.
  static String getLocalizedLabel(String label, String languageCode) {
    if (languageCode == 'hi') {
      return hindiLabels[label.toLowerCase()] ?? label;
    }
    return label;
  }

  /// Returns a vivid, distinct color based on the object's category for clear visual identification.
  static Color getColorForCategory(String label) {
    final lower = label.toLowerCase();
    if (lower == 'person') {
      return const Color(0xFF0077FE); // Electric Blue for people
    } else if ([
      'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck',
      'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter'
    ].contains(lower)) {
      return const Color(0xFFFF6D00); // Vibrant Amber / Orange for vehicles & traffic
    } else if ([
      'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear',
      'zebra', 'giraffe'
    ].contains(lower)) {
      return const Color(0xFF00C853); // Emerald Green for animals
    } else if (['backpack', 'umbrella', 'handbag', 'tie', 'suitcase'].contains(lower)) {
      return const Color(0xFFD500F9); // Magenta / Pink for personal accessories
    } else if ([
      'frisbee', 'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat',
      'baseball glove', 'skateboard', 'surfboard', 'tennis racket'
    ].contains(lower)) {
      return const Color(0xFF651FFF); // Deep Violet for sports gear
    } else if ([
      'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl',
      'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot',
      'hot dog', 'pizza', 'donut', 'cake'
    ].contains(lower)) {
      return const Color(0xFFFF1744); // Crimson / Coral for food & dining
    } else if (['chair', 'couch', 'potted plant', 'bed', 'dining table', 'toilet'].contains(lower)) {
      return const Color(0xFF00BFA5); // Teal for furniture
    } else if ([
      'tv', 'laptop', 'mouse', 'remote', 'keyboard', 'cell phone',
      'microwave', 'oven', 'toaster', 'sink', 'refrigerator'
    ].contains(lower)) {
      return const Color(0xFF9C27B0); // Purple / Indigo for electronics & appliances
    }
    return const Color(0xFFFFAB00); // Gold / Amber default
  }
}
