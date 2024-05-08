import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled/exercise_form.dart';
import 'package:untitled/exercise_form.dart';
import 'package:untitled/models/routine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/models/exercise.dart';

/**
 * Affiche les routines de l'utilisateur.
 */
class RoutinesListWidget extends StatefulWidget {
  @override
  _RoutinesListWidgetState createState() => _RoutinesListWidgetState();
}

class _RoutinesListWidgetState extends State<RoutinesListWidget> {
  late List<Routine> routines = [];
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchRoutines();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchRoutines() async {
    DatabaseReference routinesRef = FirebaseDatabase.instance
        .ref()
        .child('users/${_auth.currentUser?.uid}/routines');
    /**
     * Partie complexe : Il faut recuperer les informations de la base de donnees,
     * mais elle sont dans des Map<String,dynamic>. Il faut faire multiples Cast afin d'arriver
     * a des donnees utilisables.
     */
    routinesRef.onValue.listen((event) {
      Map<dynamic, dynamic>? routinesMap =
          event.snapshot.value as Map<dynamic, dynamic>?;

      List<Routine> routines = [];

      if (routinesMap != null) {
        routinesMap.forEach((key, value) {
          List<dynamic> exercises = value['exercises'] ?? [];
          List<Exercise> exerciseList =
              exercises.map((exercise) => Exercise.fromMap(exercise)).toList();

          Routine routine = Routine(
            id: key,
            name: value['name'],
            exercises: exerciseList,
          );

          routines.add(routine);
        });
      }

      if (mounted) {
        setState(() {
          this.routines = routines;
        });
      }
    });
  }

  /**
   * Quand une routine est appuyez, une nouvelle page s'ouvre avec ses informations
   */
  void _navigateToRoutineDetailScreen(BuildContext context, Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RoutineDetailScreen(routine: routine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users/${_auth.currentUser?.uid}/routines');

    return ListView.builder(
      itemCount: routines.length,
      itemBuilder: (BuildContext context, int index) {
        Routine routine = routines[index];
        return ListTile(
          title: Text(routine.name),
          onTap: () => _navigateToRoutineDetailScreen(context, routine),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              /**
               * boutton pour partager
               */
              IconButton(
                icon: Icon(Icons.share_rounded),
                onPressed: () {
                  _showSharingDialog(routine);
                },
              ),
              /**
               * boutton pour effacer
               */
              IconButton(
                icon: Icon(Icons.delete_rounded),
                onPressed: () {
                  setState(() {
                    databaseReference.child('${routine.id}').remove();
                  });
                },
              )
            ],
          ),
        );
      },
    );
  }

  /**
   * Affiche le dialogue de partage et envoie la routine a l'utilisateur si il existe.
   */
  void _showSharingDialog(Routine routine) {
    String recipientEmail = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Partager une routine'),
            content: TextFormField(
              decoration: InputDecoration(labelText: 'Adresse couriel du receveur'),
              onChanged: (value) {
                recipientEmail = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _ShareRoutine(routine, recipientEmail);
                  });
                  Navigator.pop(context);
                },
                child: Text('Partager'),
              ),
            ]);
      },
    );
  }

  Future<void> _ShareRoutine(Routine routine, String recipientEmail) async {
    DatabaseReference usersEmailRef =
        FirebaseDatabase.instance.ref().child('usersEmail');
    Query query = usersEmailRef.orderByValue().equalTo(recipientEmail);
    query.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? users =
            event.snapshot.value as Map<dynamic, dynamic>?;
        String userId = users?.keys.first;
        FirebaseDatabase.instance
            .ref('users/${userId}/sharedRoutines')
            .push()
            .set(routine.toMap());
      } else {
        print('user not found');
      }
    });
  }
}
/**
 * Ecran qui affiche la routine avec les exercices. Permet de modifier la routine
 * et son contenu
 */
class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;

  const RoutineDetailScreen({Key? key, required this.routine})
      : super(key: key);

  @override
  _RoutineDetailScreenState createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    final DatabaseReference routineRef = FirebaseDatabase.instance
        .ref('users/${_auth.currentUser?.uid}/routines/${widget.routine.id}');
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            initialValue: widget.routine.name,
            onFieldSubmitted: (value) {
              widget.routine.setName(value);
              routineRef.update(widget.routine.toMap());
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.routine.exercises.length,
                itemBuilder: (BuildContext context, int index) {
                  Exercise exercise = widget.routine.exercises[index];
                  return ListTile(
                      isThreeLine: true,
                      title: Text(exercise.name),
                      subtitle: Text(
                          '${exercise.nbSets} sets, poids : ${exercise.weight}\n${exercise.description}'),
                      trailing: Wrap(spacing: 12, children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.create_rounded),
                          onPressed: () {
                            _showModifyExerciseDialog(widget.routine, index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_rounded),
                          onPressed: (){
                            setState(() {
                              widget.routine.exercises.removeAt(index);
                              routineRef.update(widget.routine.toMap());
                            });
                          },
                        )
                      ]));
                },
              ),
            ),
            Container(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    _showAddExerciseDialog();
                  },
                  child: Text('Ajouter un Exercice'),
                ))
          ],
        ));
  }

  void _showAddExerciseDialog() {
    final _auth = FirebaseAuth.instance;
    final DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child(
            'users/${_auth.currentUser?.uid}/routines/${widget.routine.id}/exercises');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewExerciseForm(
          onExerciseCreated: (Exercise exercise) {
            setState(() {
              databaseReference
                  .child('${widget.routine.exercises.length}')
                  .set(exercise.toMap());
              widget.routine.exercises.add(exercise);
            });
          },
        );
      },
    );
  }

  void _showModifyExerciseDialog(Routine routine, int index) {
    final _auth = FirebaseAuth.instance;
    final DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users/${_auth.currentUser?.uid}/routines/${widget.routine.id}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewExerciseForm(
          onExerciseCreated: (Exercise exercise) {
            setState(() {
              widget.routine.exercises[index] = exercise;
              databaseReference.child('exercises/$index').set(exercise.toMap());
            });
          },
        );
      },
    );
  }
}
