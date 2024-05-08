import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled/exercise_form.dart';
import 'package:untitled/models/routine.dart';
import 'package:untitled/models/exercise.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/screens/exercise_category.dart';

/**
 * Classe qui s'occupe d'afficher et gerer l'ecran pour creer une nouvelle routine.
 */
class AddRoutineScreen extends StatefulWidget {
  @override
  _AddRoutineScreenState createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _routineNameController = TextEditingController();
  List<Exercise> exercises = [];
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _routineNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Routine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _routineNameController,
                decoration: InputDecoration(labelText: 'Nom de la Routine'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Rentrez un nom pour la Routine';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text('Exercices'),
              SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      isThreeLine: true,
                      title: Text(exercises[index].name),
                      subtitle: Text('${exercises[index].nbSets} sets, poids : ${exercises[index].weight}\n${exercises[index].description}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            exercises.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    /**
                     * valide si les informations dans le formulaire sont bonnes et rajoute la routine dans la base de donnee si oui
                     */
                    if (_formKey.currentState!.validate()) {
                      final routineName = _routineNameController.text;
                      final DatabaseReference routineRef = FirebaseDatabase
                          .instance
                          .ref()
                          .child('users/${_auth.currentUser?.uid}/routines')
                          .push();
                      final routine = Routine(
                          name: routineName,
                          exercises: exercises,
                          id: '${routineRef.key}');
                      await routineRef.set(routine.toMap());
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Sauvegarder'),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showExerciseOptionsDialog(context);
                  },
                  child: Text('Ajouter un Exercice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Affiche la fenetre avec les options de creer un exercice ou choisir un pre concus.
   */
  void showExerciseOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un Exercice'),
          content: Text('Veuillez choisir une option:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _showAddExerciseDialog();
              },
              child: Text('Créer un Exercice'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryScreen())).then((result) {
                      setState(() {
                        print(result.toString());
                        exercises.add(result);
                      });
                });
              },
              child: Text('Utiliser un Exercice par défaut'),
            ),
          ],
        );
      },
    );
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewExerciseForm(
          onExerciseCreated: (Exercise exercise) {
            setState(() {
              exercises.add(exercise);
            });
          },
        );
      },
    );
  }
}


