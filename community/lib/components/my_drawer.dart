import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_or_register.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // logout user
  Future logout(BuildContext context) async {
    final _auth = FirebaseAuth.instance;
    final _firestore = FirebaseFirestore.instance;

    try {
      if (context != null && context.mounted) {
        if (_auth.currentUser != null) {
          await _auth.currentUser!.reload();

          if (_auth.currentUser?.email != null) {
            await _firestore.collection('Users').doc(_auth.currentUser!.email).update({
              "status": "Offline",
            });
          } else {
            print("User email is null, status update skipped.");
          }
        }

        await _auth.signOut().then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginOrRegister()));
        });
      }
    } catch (e) {
      print("Error during logout: $e");
      // Handle error gracefully, e.g., show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          // drawer header
          DrawerHeader(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum,
                    size: 40,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'MAD PROJECT',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  Text(
                    'FORUM APP',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          

          const SizedBox(height: 25),

          Expanded(
          child: ListView(
          children: [
          const SizedBox(height: 25),

          // profile tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.person, color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text("P R O F I L E"),
              onTap: (){
                //pop drawer
                Navigator.pop(context);

                // navigate to profile page
                Navigator.pushNamed(context, '/profile_page');
              },
            ),
          ),

          const SizedBox(height: 25),

          // users tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.group, color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text("U S E R S"),
              onTap: (){
                Navigator.pop(context);

                Navigator.pushNamed(context, '/users_page');
              },
            ),
          ),

          const SizedBox(height: 25),

          // logout tile
            Padding(
             padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.inversePrimary,
              ),
               title: Text("L O G O U T"),
                onTap: (){
                  Navigator.pushNamedAndRemoveUntil(context, '/login_register_page',(route) => false);
                //logout
                  logout(context);
              },
            ),
          ),

        ]
      )


      )
    ]
      )
    );
  }
}
