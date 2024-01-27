import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/profile_page.dart';

class ChangeBirthdayDialog extends StatefulWidget {
  const ChangeBirthdayDialog({super.key});

  @override
  State<ChangeBirthdayDialog> createState() => _ChangeBirthdayDialogState();
}

class _ChangeBirthdayDialogState extends State<ChangeBirthdayDialog> {
  final _formKey = GlobalKey<FormState>();
  String updateDate = "";

  DateTime _currentDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _currentDate) {
      setState(() {
        _currentDate = pickedDate;
      });
    }

    updateDate = "${_currentDate.day.toString()}-${_currentDate.month.toString()}-${_currentDate.year.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text('Birthday Changer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text('Select Date', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
              ),
              const SizedBox(height: 25),
              Text(
                'Selected Date: ${updateDate}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (updateDate != "") {
                birthdayValidation();
              } else {
                // Inform the user that no date is selected
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a date.')),
                );
              }
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
            .update({'birthday': updateDate});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Birthday updated successfully')),
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
