import 'package:flutter/material.dart';

List<String> getAllActivityCategories() {
  return [
    'Work',
    'Study',
    'Exercise',
    'Chores',
    'Social',
    'Meditation',
    'Reading',
    'Relaxation',
    'Health',
    'Entertainment',
    'Shopping',
    'Travel',
    'Creative',
    'Sleep',
    'Other',
  ];
}

IconData getIconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'work':
      return Icons.work;
    case 'study':
      return Icons.school;
    case 'exercise':
      return Icons.fitness_center;
    case 'chores':
      return Icons.cleaning_services;
    case 'social':
      return Icons.people;
    case 'meditation':
      return Icons.self_improvement;
    case 'reading':
      return Icons.menu_book;
    case 'relaxation':
      return Icons.spa;
    case 'health':
      return Icons.health_and_safety;
    case 'entertainment':
      return Icons.movie;
    case 'shopping':
      return Icons.shopping_cart;
    case 'travel':
      return Icons.flight_takeoff;
    case 'creative':
      return Icons.brush;
    case 'sleep':
      return Icons.bedtime;
    case 'other':
    default:
      return Icons.category;
  }
}
