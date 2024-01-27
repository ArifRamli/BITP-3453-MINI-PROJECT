import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/profile_page.dart';

class ChangeUsernameDialog extends StatefulWidget {
  const ChangeUsernameDialog({super.key});

  @override
  State<ChangeUsernameDialog> createState() => _ChangeUsernameDialog();
}

class _ChangeUsernameDialog extends State<ChangeUsernameDialog> {
  final _newUsernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc('email');
  //User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text('Username Changer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _newUsernameController,
                decoration: InputDecoration(
                  labelText: 'New Username',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              usernameValidation();
            },
            child: Text('Save', style: TextStyle(color: Colors.white),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  //Password Changer Function
  Future<void> usernameValidation() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false, // Prevent user from dismissing
    );
    final newUsername = _newUsernameController.text.trim();

    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;

      // Check for existing username (excluding the current user's document)
      final existingUser = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: newUsername)
          //.where('email', isNotEqualTo: userEmail) // Exclude the current user
          .get();

      if (existingUser.docs.isNotEmpty) {
        // Username already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username already exists. Please choose a different one.')),
        );
        return; // Exit the function without updating
      }

      // Proceed with update if username is unique
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: userEmail)
          .get();
      String oldUsername = (await userDoc.docs.first.data())['username'];

      if (userDoc.docs.isNotEmpty) {
        final docId = userDoc.docs.first.id;
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(docId)
            .update({'username': newUsername});

        // Update username in Firebase Authentication (optional)
        await FirebaseAuth.instance.currentUser!.updateDisplayName(newUsername);
        await updateChatRoomOnUsernameChange(oldUsername, newUsername);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username updated successfully')),
        );
        Navigator.pop(context);
        Navigator.pop(context, true);
      } else {
        print('User not found with email: $userEmail');
        // Display an error message to the user
      }
    } catch (error) {
      print('Error updating username: $error');
      // Display a generic error message to the user
    }
  }


  Future updateChatRoomOnUsernameChange(String oldUsername, String newUsername) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("chatroom")
          .where("Users", arrayContains: oldUsername)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Get the current document snapshot
        DocumentSnapshot currentSnapshot = await doc.reference.get();

        // Get the current document data
        Map<String, dynamic> chatRoomData = currentSnapshot.data() as Map<String, dynamic>;

        // Update the "users" list
        List<String> users = (chatRoomData["Users"] as List<dynamic>).map((user) => user.toString()).toList();
        int index = users.indexOf(oldUsername);
        if (index != -1) {
          users[index] = newUsername;
        }

        // Get the document ID
        String docId = doc.id;

        // Generate the new chatRoomId
        String newChatRoomId = docId.replaceAll(oldUsername, newUsername);

        // Create a new chatroom document with the new username
        DocumentReference newDocRef = FirebaseFirestore.instance
            .collection("chatroom")
            .doc(newChatRoomId);

        // Update the data with the new users list
        chatRoomData["Users"] = users;

        // Copy the data to the new document
        await newDocRef.set(chatRoomData);

        // Copy the chat collection and its messages
        CollectionReference chatCollectionRef = doc.reference.collection("chats");
        QuerySnapshot chatMessagesSnapshot = await chatCollectionRef.get();

        CollectionReference newChatCollectionRef = newDocRef.collection("chats");

        for (QueryDocumentSnapshot chatMessageSnapshot in chatMessagesSnapshot.docs) {
          Map<String, dynamic> chatMessageData = chatMessageSnapshot.data() as Map<String, dynamic>;
          // Update the "sender" field in each chat message
          if (chatMessageData["sendby"] == oldUsername) {
            chatMessageData["sendby"] = newUsername;
          }
          await newChatCollectionRef.add(chatMessageData);
        }

        // Delete the old chat collection and chatroom document
        await chatCollectionRef.get().then((snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete()));
        await doc.reference.delete();
      }
    } catch (error) {
      // ... error handling ...
    }
  }
}
