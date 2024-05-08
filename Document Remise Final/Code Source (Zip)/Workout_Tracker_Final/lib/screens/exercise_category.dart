import 'package:flutter/material.dart';
import 'package:untitled/models/exercise.dart';

class ExerciseCategory {
  final String name;
  final List<Exercise> exercises;

  ExerciseCategory({required this.name, required this.exercises});
}

/**
 * liste de tous les exercices de base, en categorie
 */
List<ExerciseCategory> categories = [
  ExerciseCategory(name: 'Dos', exercises: [
    Exercise.preset(name: 'Pull-Up'),
    Exercise.preset(name: 'Chin-Up'),
    Exercise.preset(name: 'Lat-Pulldown'),
    Exercise.preset(name: 'Barbell-Row'),
    Exercise.preset(name: 'T-Bar Row'),
    Exercise.preset(name: 'Seated Cable Row'),
    Exercise.preset(name: 'Deadlift'),
    Exercise.preset(name: 'Rack-Pull'),
    Exercise.preset(name: 'Dumbell-Shrug'),
    Exercise.preset(name: 'Barbell-Shrug')
  ]),
  ExerciseCategory(name: 'Biceps', exercises: [
    Exercise.preset(name: 'Barbell Curl'),
    Exercise.preset(name: 'Cable Curl'),
    Exercise.preset(name: 'Dumbell Concentration Curl'),
    Exercise.preset(
      name: 'Dumbell Curl',
    ),
    Exercise.preset(name: 'Dumbell Hammer Curl'),
    Exercise.preset(name: 'Dumbell Preacher Curl'),
    Exercise.preset(name: 'Ez-Bar Curl'),
    Exercise.preset(name: 'Ez-Bar Preacher Curl'),
    Exercise.preset(name: 'Seated Incline Dumbbel Curl'),
    Exercise.preset(name: 'Seated Machine Curl'),
    Exercise.preset(name: 'Gymnast Pull'),
  ]),
  ExerciseCategory(name: 'Épaules', exercises: [
    Exercise.preset(name: 'Arnold Dumbbell Press'),
    Exercise.preset(name: 'Cable Face Pull'),
    Exercise.preset(name: 'Front Dumbbell Raise'),
    Exercise.preset(
      name: 'Lateral Dumbbell Raise',
    ),
    Exercise.preset(name: 'Lateral Machine Raise'),
    Exercise.preset(name: 'Log Press'),
    Exercise.preset(name: 'Overhead Press'),
    Exercise.preset(name: 'Rear Delt Dumbell Raise'),
    Exercise.preset(name: 'Seated Dumbbell Lateral Raise'),
    Exercise.preset(name: 'Seated Dumbbell Press'),
    Exercise.preset(name: 'Smith Machine Overhead Press'),
  ]),
  ExerciseCategory(name: 'Jambes', exercises: [
    Exercise.preset(name: 'Barbell Calf Raise'),
    Exercise.preset(name: 'Barbell Front Squat'),
    Exercise.preset(name: 'Barbell Squat'),
    Exercise.preset(
      name: 'Glute-Ham Raise',
    ),
    Exercise.preset(name: 'Leg Extension Machine'),
    Exercise.preset(name: 'Leg Press'),
    Exercise.preset(name: 'Lunges'),
    Exercise.preset(name: 'Lying Leg Curl Machine'),
    Exercise.preset(name: 'Seated Calf Raise Machine'),
    Exercise.preset(name: 'Stiff-Legged Deadlift'),
    Exercise.preset(name: 'Sumo Deadlift'),
  ]),
  ExerciseCategory(name: 'Triceps', exercises: [
    Exercise.preset(name: 'Cable Overhead Tricep Extension'),
    Exercise.preset(name: 'Close Grip Barbell Bench Press'),
    Exercise.preset(name: 'Dumbbell Overhead Tricep Extension'),
    Exercise.preset(
      name: 'Ez-Bar Skullcrusher',
    ),
    Exercise.preset(name: 'Lying Triceps Extension'),
    Exercise.preset(name: 'Parallel Bar Triceps Dip'),
    Exercise.preset(name: 'Ring Dip'),
    Exercise.preset(name: 'Rope Push Down'),
    Exercise.preset(name: 'V-Bar Push Down'),
  ]),
  ExerciseCategory(name: 'Poitrine', exercises: [
    Exercise.preset(name: 'Cable Crossover'),
    Exercise.preset(name: 'Decline Barbell Bench Press'),
    Exercise.preset(name: 'Flat Barbell Bench Press'),
    Exercise.preset(
      name: 'Flat Dumbbell Bench Press',
    ),
    Exercise.preset(name: 'Incline Barbell Bench Press'),
    Exercise.preset(name: 'Incline Dumbbell Bench Press'),
    Exercise.preset(name: 'One Arm Cable Cross Over'),
    Exercise.preset(name: 'Seated Machine Fly'),
  ])
];

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  void _navigateToCategoryDetailScreen(
      BuildContext context, ExerciseCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: category),
      ),
    );
  }

  /**
   * ecran ou s'affiche les categories, quand une est selectionee, les exercices de la categorie s'affiche
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Exercice'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          ExerciseCategory category = categories[index];
          return ListTile(
            title: Text(category.name),
            onTap: () => _navigateToCategoryDetailScreen(context, category),
          );
        },
      ),
    );
  }
}
/**
 * affiche et retourne l'exercice selectionner pour se faire ajouter dans la routine
 */
class CategoryDetailScreen extends StatefulWidget {
  final ExerciseCategory category;

  const CategoryDetailScreen({Key? key, required this.category})
      : super(key: key);

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: ListView.builder(
        itemCount: widget.category.exercises.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Text(widget.category.exercises[index].name),
              onTap: () {
                Exercise exercise = widget.category.exercises[index];
                Navigator.pop(context);
                Navigator.pop(context, exercise);
              });
        },
      ),
    );
  }
}
