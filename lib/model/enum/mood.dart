import 'package:flutter/material.dart';

enum ActivityMood {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
}

extension MoodExtension on ActivityMood {
  String get name {
    switch (this) {
      case ActivityMood.veryHappy:
        return 'Very Happy';
      case ActivityMood.happy:
        return 'Happy';
      case ActivityMood.neutral:
        return 'Neutral';
      case ActivityMood.sad:
        return 'Sad';
      case ActivityMood.verySad:
        return 'Very Sad';
    }
  }
}

Icon getMoodIconWidget(ActivityMood mood, {double size = 24}) {
  IconData icon;
  Color color;

  switch (mood) {
    case ActivityMood.veryHappy:
      icon = Icons.sentiment_very_satisfied;
      color = Colors.green;
      break;
    case ActivityMood.happy:
      icon = Icons.sentiment_satisfied;
      color = Colors.lightGreen;
      break;
    case ActivityMood.neutral:
      icon = Icons.sentiment_neutral;
      color = Colors.grey;
      break;
    case ActivityMood.sad:
      icon = Icons.sentiment_dissatisfied;
      color = Colors.orange;
      break;
    case ActivityMood.verySad:
      icon = Icons.sentiment_very_dissatisfied;
      color = Colors.red;
      break;
  }

  return Icon(icon, color: color, size: size);
}
