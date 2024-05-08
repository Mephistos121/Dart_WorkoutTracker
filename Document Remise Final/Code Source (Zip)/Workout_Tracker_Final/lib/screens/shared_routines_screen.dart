import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled/exercise_form.dart';
import 'package:untitled/models/exercise.dart';
import 'package:untitled/models/routine.dart';
import 'package:firebase_auth/firebase_auth.dart';

/**
 * Cette classe est casiment identique a sa contrepartie RoutinesListWidget, mais
 * la difference est la reference dans la base de donnee. Gerer quand utiliser quelle reference serait
 * trop compliquer et insecuritaire dans un fichier donc on recopie.
 */
class SharedRoutinesListWidget extends StatefulWidget {
  @override
  _SharedRoutinesListWidgetState createState() =>
      _SharedRoutinesListWidgetState();
}

class _SharedRoutinesListWidgetState extends State<SharedRoutinesListWidget> {
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
        .child('users/${_auth.currentUser?.uid}/sharedRoutines');

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

  void _navigateToSharedRoutineDetailScreen(
      BuildContext context, Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SharedRoutineDetailScreen(routine: routine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users/${_auth.currentUser?.uid}/sharedRoutines');

    return ListView.builder(
      itemCount: routines.length,
      itemBuilder: (BuildContext context, int index) {
        Routine routine = routines[index];
        return ListTile(
          title: Text(routine.name),
          onTap: () => _navigateToSharedRoutineDetailScreen(context, routine),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.share_rounded),
                onPressed: () {
                  _showSharingDialog(routine);
                },
              ),
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
            .set(routine.toMap());
      } else {
        print('user not found');
      }
    });
  }
}

class SharedRoutineDetailScreen extends StatefulWidget {
  final Routine routine;

  const SharedRoutineDetailScreen({Key? key, required this.routine})
      : super(key: key);

  @override
  _SharedRoutineDetailScreenState createState() =>
      _SharedRoutineDetailScreenState();
}

class _SharedRoutineDetailScreenState extends State<SharedRoutineDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    final DatabaseReference routineRef = FirebaseDatabase.instance.ref(
        'users/${_auth.currentUser?.uid}/sharedRoutines/${widget.routine.id}');
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
                  child: Text('Ajouter un exercice'),
                ))
          ],
        ));
  }

  void _showAddExerciseDialog() {
    final _auth = FirebaseAuth.instance;
    final DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users/${_auth.currentUser?.uid}/sharedRoutines/${widget.routine.id}/exercises');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewExerciseForm(
          onExerciseCreated: (Exercise exercise) {
            setState(() {
              databaseReference.child('${widget.routine.exercises.length}').set(exercise.toMap());
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
        .child('users/${_auth.currentUser?.uid}/sharedRoutines/${widget.routine.id}');
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
