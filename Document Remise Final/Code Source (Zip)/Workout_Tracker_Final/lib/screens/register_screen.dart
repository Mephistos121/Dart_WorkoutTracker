import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/screens/login_screen.dart';

/**
 * Ecran pour creer un compte
 */
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late String _email, _password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un compte'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return 'Rentrez une adresse courriel';
                }
                return null;
              },
              onSaved: (input) => _email = input!,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return 'Rentrez un mot de passe';
                }
                return null;
              },
              onSaved: (input) => _password = input!,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                _submitRegister();
              },
              child: Text('Créer un compte'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Vous avez déjà un compte? connectez-vous ici'),
            )
          ],
        ),
      ),
    );
  }

  /**
   * si les informations sont valides, un nouvel utilisateur est creer. Son UUID est associer a son adresse couriel dans la base de donnee a ce moment
   */
  void _submitRegister() async {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('usersEmail');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        databaseReference.child('${FirebaseAuth.instance.currentUser?.uid}').set('$_email');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mot de passe trop faible')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Il existe déjà un compte avec cette adresse courriel')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while registering.')),
        );
        print(e);
      }
    }
  }
}
