import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/my_back_button.dart';
import '../widget/change_bio.dart';
import '../widget/change_birthday.dart';
import '../widget/change_gender.dart';
import '../widget/change_password.dart';
import '../widget/change_profile_picture.dart';
import '../widget/change_username.dart';


class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

}
class _ProfilePageState extends State<ProfilePage> {
  // current logged in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  Future<String> _fetchProfilePictureURL() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.email);
    final snapshot = await userDoc.get();
    return snapshot.get('profilepicture');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Theme
            .of(context)
            .colorScheme
            .background,
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: getUserDetails(),
            builder: (context, snapshot) {
              // loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // error
              else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }

              // data received
              else if (snapshot.hasData) {
                //extract data
                Map<String, dynamic>? user = snapshot.data!.data();

                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        // back button
                        const Padding(
                          padding: EdgeInsets.only(
                            top: 60.0,
                            left: 25,
                          ),
                          child: Row(
                            children: [
                              MyBackButton(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),


                        // profile pic
                        FutureBuilder<String>(
                          future: _fetchProfilePictureURL(),
                          builder: (context, profilePictureSnapshot) {
                            if (profilePictureSnapshot.hasData) {
                              final profilePictureURL = profilePictureSnapshot
                                  .data;
                              return CircleAvatar(
                                radius: 64,
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(
                                    profilePictureURL!),
                              );
                            } else if (profilePictureSnapshot.hasError) {
                              print(
                                  'Error fetching profile picture: ${profilePictureSnapshot
                                      .error}');
                              return const Icon(Icons.error, size: 64);
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),

                        const SizedBox(height: 25),

                        // username
                        TextButton(
                          onPressed: () {
                            // Add your button's functionality here
                          },
                          child: Text(
                            user!['username'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // email
                        Text(user['email'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(user['bio'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.only(
                              left: 12.0, right: 25.0, top: 18.0, bottom: 18.0),
                          child: Divider(
                            height: 10, thickness: 0.4, color: Colors.grey,),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("PERSONAL INFORMATION", style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 19),),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        ListTile(
                            leading: Icon(Icons.transgender),
                            title: Text("Gender"),
                            subtitle: Text(user['gender'], style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,),),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              bool? bioUpdated = await showDialog<bool>(
                                context: context,
                                builder: (context) => ChangeGenderDialog(),
                              ) ?? false;

                              if (bioUpdated) {
                                setState(() {});
                              }
                            }
                        ),

                        const SizedBox(height: 10),

                        ListTile(
                            leading: Icon(Icons.cake),
                            title: Text("Date of Birthday"),
                            subtitle: Text(user['birthday'], style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,),),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              bool? bioUpdated = await showDialog<bool>(
                                context: context,
                                builder: (context) => ChangeBirthdayDialog(),
                              ) ?? false;

                              if (bioUpdated) {
                                setState(() {});
                              }
                            }
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 25.0, top: 18.0, bottom: 18.0),
                          child: Divider(
                            height: 10, thickness: 0.4, color: Colors.grey,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("EDIT PROFILE SETTING", style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 19),),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        ListTile(
                            leading: Icon(Icons.lock),
                            title: Text("Password"),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => ChangePasswordDialog(),
                              );
                            }
                        ),

                        const SizedBox(height: 10),

                        ListTile(
                            leading: Icon(Icons.person),
                            title: Text("Username"),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              bool? bioUpdated = await showDialog<bool>(
                                context: context,
                                builder: (context) => ChangeUsernameDialog(),
                              ) ?? false;

                              if (bioUpdated) {
                                setState(() {});
                              }
                            }
                        ),

                        const SizedBox(height: 10),

                        ListTile(
                            leading: Icon(Icons.assignment),
                            title: Text("Bio"),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              bool? bioUpdated = await showDialog<bool>(
                                context: context,
                                builder: (context) => ChangeBioDialog(),
                              ) ?? false;

                              if (bioUpdated) {
                                setState(() {});
                              }
                            }
                        ),

                        const SizedBox(height: 10),

                        ListTile(
                            leading: Icon(Icons.image),
                            title: Text("Profile Picture"),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              bool? pictureUpdated = await showDialog<bool>(
                                context: context,
                                builder: (context) =>
                                    ChangeProfilePictureDialog(),
                              ) ?? false;

                              if (pictureUpdated) {
                                setState(() {});
                              }
                            }
                        ),

                        const SizedBox(height: 10),

                      ],
                    ),
                  ),
                );
              } else {
                return const Text ("No data");
              }
            }
        )
    );
  }
}
