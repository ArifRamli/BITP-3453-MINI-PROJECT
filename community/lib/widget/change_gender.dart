import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/profile_page.dart';

class ChangeGenderDialog extends StatefulWidget {
  const ChangeGenderDialog({super.key});

  @override
  State<ChangeGenderDialog> createState() => _ChangeGenderDialogState();
}

class _ChangeGenderDialogState extends State<ChangeGenderDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedValue;
  List<String> _items = ['Male', 'Female', 'Rather not say'];

  Future<void> _changeGender(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Gender Changer'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: _selectedValue,
                hint: Text('Select Gender', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                items: _items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_selectedValue != null) {
                  genderValidation();
                } else {
                  // Inform the user that no gender is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a gender.')),
                  );
                }
              },
              child: Text('Save', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            ),
            TextButton(
              onPressed: () {
                // Handle selected value here
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            ),
          ],
        );
      },
    );
  }

  Future<void> genderValidation() async {
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
            .update({'gender': _selectedValue});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Birthday updated successfully')),
        );
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text('Gender Changer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _changeGender(context);
                },
                child: Text('Select Gender', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  Future<void> birthdayValidation() async {
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
            .update({'birthday': _selectedValue});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gender updated successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
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
