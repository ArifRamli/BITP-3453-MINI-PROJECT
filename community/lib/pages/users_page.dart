import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../components/my_back_button.dart';
import '../components/my_list_tile.dart';
import '../helper/helper_functions.dart';
import 'onTap_profile.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Theme.of(context).colorScheme.background,
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("Users").snapshots(),
            builder: (context, snapshot){
              // any errors
              if (snapshot.hasError){
                displayMessageToUser("Something went wrong", context);
              }

              // show loading circle
              if (snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data == null){
                return const Text ("No Data");
              }

              //get all users
              final users = snapshot.data!.docs;

              return Column(
                children: [

                  // back button
                  const Padding(
                    padding: const EdgeInsets.only(
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

                  // list of users in the app
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        String username = user['username'];
                        String email = user['email'];

                        return InkWell(
                          onTap: () {
                            // Navigate to the next page and pass the email value
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnTapProfile(passedEmail: email), // Replace NextPage with your actual page
                              ),
                            );
                          },
                          child: MyListTile(
                            title: username,
                            subTitle: email,
                          ),
                        );
                      },
                    ),

                  ),
                ],
              );

            }
        )
    );
  }
}