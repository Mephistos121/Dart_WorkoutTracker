import 'dart:convert';

import 'package:untitled/models/exercise.dart';

/**
 * classe pour les Routines, contenants les Exercises
 */
class Routine {
  String id;
  String name;
  List<Exercise> exercises;

  Routine({required this.id, required this.name, required this.exercises});

  /**
   * convertis la Routine en une Map<String, dynamic>
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }

  void setName(String name) {
    this.name = name;
  }
}
