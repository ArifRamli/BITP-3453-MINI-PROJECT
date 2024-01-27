import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../pages/profile_page.dart';
import 'package:image/image.dart' as img;

class ChangeProfilePictureDialog extends StatefulWidget {
  const ChangeProfilePictureDialog({super.key});

  @override
  State<ChangeProfilePictureDialog> createState() => _ChangeProfilePictureDialogState();
}

class _ChangeProfilePictureDialogState extends State<ChangeProfilePictureDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _newImageURL;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text('Change Profile Picture'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _newImageURL != null
                  ? Image.network(_newImageURL!)
                  : const Icon(Icons.person, size: 150),
              ElevatedButton(
                onPressed: () => _pickImage(),
                child: Text('Choose Image', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _saveImage(),
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

  Future<void> _pickImage() async {
    // Implement image picking logic using a plugin like image_picker or image_cropper
    // Here's an example using image_picker:
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageURL = pickedFile.path; // Temporary URL for preview
      });
      _uploadImage(pickedFile);
    }
  }

  Future<void> _uploadImage(XFile pickedFile) async {
    try {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
        barrierDismissible: false, // Prevent user from dismissing
      );
      final user = _auth.currentUser;

      img.Image image = img.decodeImage(await pickedFile.readAsBytes())!;

      final pngBytes = img.encodePng(image);

      final ref = FirebaseStorage.instance.ref('profile_picture/${user!.email}.png');
      final uploadTask = ref.putData(Uint8List.fromList(pngBytes));
      final url = await (await uploadTask).ref.getDownloadURL();
      setState(() {
        _newImageURL = url;
      });
      await _updateUserProfilePicture(url);
      Navigator.pop(context);
    } catch (error) {
      print('Error uploading image: $error');
    }
  }


  Future<void> _saveImage() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _updateUserProfilePicture(_newImageURL!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
        Navigator.pop(context, true);
      } catch (error) {
        print('Error updating profile picture: $error');
        // Display an error message to the user
      }
    }
  }

  Future<void> _updateUserProfilePicture(String url) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(_auth.currentUser!.email);
    await userDoc.update({'profilepicture': url});
  }
}
