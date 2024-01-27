import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/profile_page.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  //final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          children: [
 /*           TextField(
              controller: _oldPasswordController,
              decoration: InputDecoration(
                labelText: 'Old Password',
              ),
              obscureText: true,
            ),*/
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            passwordValidation();
          },
          child: Text('Change Password', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
        ),
      ],
    );
  }

  //Password Changer Function
  Future<void> passwordValidation() async{
    if (_newPasswordController.text == _confirmPasswordController.text) {
      try {
        await FirebaseAuth.instance.currentUser!.updatePassword(_newPasswordController.text);

        await FirebaseAuth.instance.signOut();
        /*Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LoginPage(onTap: togglePages),
        ));*/
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully. Please log in again.')),
        );
        Navigator.pop(context);
        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );*/
      } on FirebaseAuthException catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: ${e.message}')),
        );
      }
    } else {
      // Passwords don't match, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
    }
  }

}
