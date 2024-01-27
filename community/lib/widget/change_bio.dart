import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/profile_page.dart';

class ChangeBioDialog extends StatefulWidget {
  const ChangeBioDialog({super.key});

  @override
  State<ChangeBioDialog> createState() => _ChangeBioDialog();
}

class _ChangeBioDialog extends State<ChangeBioDialog> {
  final _newBioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc('email');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text('Bio Changer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _newBioController,
                decoration: InputDecoration(
                  labelText: 'New Bio',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              bioValidation();
            },
            child: Text('Save', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
          ),
        ],
      ),
    );
  }

  Future<void> bioValidation() async {
    final newBio = _newBioController.text.trim();
    try {
      // Get current user's email
      final userEmail = FirebaseAuth.instance.currentUser!.email;

      // Query for the user document based on email
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final docId = userDoc.docs.first.id;
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(docId)
            .update({'bio': newBio});

        // Update username in Firebase Authentication (optional)
        // await FirebaseAuth.instance.currentUser!.updateDisplayName(newBio);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bio updated successfully')),
        );

        Navigator.pop(context,true);

      } else {
        // Handle user not found
        print('User not found with email: $userEmail');
        // Display an error message to the user
      }
    } catch (error) {
      print('Error updating username: $error');
      // Handle other errors gracefully
    }
  }
}
