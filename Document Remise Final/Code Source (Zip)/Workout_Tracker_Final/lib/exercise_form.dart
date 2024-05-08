import 'package:flutter/material.dart';
import 'package:untitled/models/exercise.dart';

/**
 * formulaire qui s'occupe de valider la creation d'un nouveau Exercice
 */
class NewExerciseForm extends StatefulWidget {
  final Function(Exercise) onExerciseCreated;

  NewExerciseForm({required this.onExerciseCreated});

  @override
  _NewExerciseFormState createState() => _NewExerciseFormState();
}

class _NewExerciseFormState extends State<NewExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  int _sets = 0;
  double _weight = 0.0;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Exercise exercise = Exercise(
          name: _name,
          nbSets: _sets,
          weight: _weight,
          description: _description);

      widget.onExerciseCreated(exercise);

      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier un Exercice'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Nom de l\'exercice'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Rentrez un nom';
                }
                return null;
              },
              onSaved: (value) {
                _name = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              onSaved: (value) {
                _description = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Nombres de sets'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                if (value == null || value.isEmpty) {
                  _sets = 0;
                } else {
                  try {
                    _sets = int.parse(value);
                  } catch (e) {
                    _sets = 0;
                  }
                }
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Poids'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                if (value == null || value.isEmpty) {
                  _weight = 0;
                } else {
                  try {
                    _weight = double.parse(value);
                  } catch (e) {
                    _weight = 0;
                  }
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text('Fini'),
        ),
      ],
    );
  }
}
