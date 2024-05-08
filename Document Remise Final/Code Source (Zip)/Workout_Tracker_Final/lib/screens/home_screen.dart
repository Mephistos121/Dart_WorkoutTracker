import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/addroutine_screen.dart';
import 'package:untitled/screens/login_screen.dart';
import 'package:untitled/screens/routines_screen.dart';
import 'package:untitled/screens/shared_routines_screen.dart';

/**
 * Page d'acceuil, affiche les routines partages, personelles et l'option de se deconnecter
 */
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /**
       * navigationBar s'occupe de naviguer entre les 3 pages
       */
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
              icon: Icon(Icons.folder_shared_rounded), label: 'Partagées Avec Moi'),
          NavigationDestination(
            icon: Icon(Icons.article),
            label: 'Mes Routines',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
      body: <Widget>[
        Column(children: [
          Expanded(
            child: SharedRoutinesListWidget(),
          )
        ]),
        Column(
          children: [
            Expanded(
              child: RoutinesListWidget(),
            ),
            Container(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddRoutineScreen()));
                    },
                    child: Text(
                      '+',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    )))
          ],
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              _logout();
            },
            child: Text(
              'Déconnecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ][currentPageIndex],
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        ModalRoute.withName('/'));
  }

  @override
  void deactivate() {
    super.deactivate();
  }
}
