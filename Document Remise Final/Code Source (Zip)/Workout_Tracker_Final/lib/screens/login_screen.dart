import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/screens/register_screen.dart';

/**
 * Premier ecran si l'utulisateur s'est deconecter ou utilise l'application pour la premiere fois
 */
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _email, _password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connexion"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return 'Rentrez une adresse valide';
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
                _submitLogin();
              },
              child: Text('Connexion'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Nouveau utilisateur? Appuyez ici'),
            )
          ],
        ),
      ),
    );
  }

  /**
   * verifie que les informations fournis sont bonnes et correspondent a un utilisateur existant.
   */
  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Il n\'y a pas d\'utilisateur avec cet Email')),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mauvais Mot de passe')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while signing in.')),
        );
        print(e);
      }
    }
  }
}


