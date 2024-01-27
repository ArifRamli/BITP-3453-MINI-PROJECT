import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_back_button.dart';

class OnTapProfile extends StatefulWidget {
  final String passedEmail;

  OnTapProfile({Key? key, required this.passedEmail}) : super(key: key);

  @override
  State<OnTapProfile> createState() => _OnTapProfileState();
}

class _OnTapProfileState extends State<OnTapProfile> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String profileUsername = "";

  /*@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Retrieve user email from FirebaseAuth
    _auth.currentUser?.reload(); // Ensure latest user information
    String? userEmail = _auth.currentUser?.email;

    // Set initial status based on user login state and email
    if (userEmail != null) {
      setStatus("Online", userEmail); // User is logged in, set status to "Online" using email
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    // Ensure email is not null before setting status
    String? userEmail = _auth.currentUser?.email;
    if (userEmail != null) {
      setStatus("Offline", userEmail); // Call setStatus only if email is available
    } else {
      // Handle the case where email is null, e.g., log a message or take appropriate action
      print("User email is null, cannot update status.");
    }
  }


  void setStatus(String status, String userEmail) async {
    try {
      await _firestore.collection('Users').doc(userEmail).update({
        "status": status,
      });
    } catch (error) {
      print("Failed to update status: $error");
      // Handle the error appropriately
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_auth.currentUser != null) { // Check for logged-in user
      String? userEmail = _auth.currentUser?.email;
      if (userEmail != null) {
        if (state == AppLifecycleState.resumed) {
          setStatus("Online", userEmail);
        } else {
          setStatus("Offline", userEmail);
        }
      }
    }
  }
*/

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String passedEmail) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(passedEmail)
        .get();
  }

  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userDoc = await _firestore
          .collection('Users')
          .where("email", isEqualTo: widget.passedEmail)
          .get();
      if (userDoc.docs.isNotEmpty) {
        setState(() {
          userMap = userDoc.docs[0].data();
          isLoading = false;
        });
      } else {
        // Handle the case where the user document is not found
        print("User document not found for $widget.passedEmail");
      }
    } catch (error) {
      print("Failed to fetch profile: $error");
      // Handle the error appropriately, e.g., by notifying the user
    }
  }

  String generateChatRoomId(String user1, String user2) {
    // Combine user names with underscore separator, ensuring a consistent order
    String combinedUserNames =
    user1.toLowerCase().compareTo(user2.toLowerCase()) < 0
        ? user1 + "_" + user2
        : user2 + "_" + user1;
    return combinedUserNames; // Return the combined string as the chat room ID
  }

  Future<String> createChatRoomId(String user1, String user2) async {
    String chatRoomId = ""; // Declare the variable first

    try {
      List<String> sortedUsernames = [user1, user2]..sort();
      chatRoomId = sortedUsernames[0] + "_" + sortedUsernames[1]; // Call the correct function

      final docRef = _firestore.collection("chatroom").doc(chatRoomId);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        await docRef.set({
          "Users": sortedUsernames,
          // Add other fields as needed
        });
      }
    } catch (error) {
      print("Failed to create chat room: $error");
      // Handle the error appropriately
    }

    return chatRoomId;
  }

  Future<String> _fetchProfilePictureURL(String passedEmail) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(passedEmail);
    final snapshot = await userDoc.get();
    return snapshot.get('profilepicture');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Theme.of(context).colorScheme.background,
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: getUserDetails(widget.passedEmail),
            builder: (context, snapshot){
              // loading
              if (snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // error
              else if (snapshot.hasError){
                return Text("Error: ${snapshot.error}");
              }

              // data received
              else if (snapshot.hasData){
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
                          future: _fetchProfilePictureURL(widget.passedEmail),
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
                        Text(
                          user!['username'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // email
                        Text(user['email'],
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(user['bio'],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.only(left: 12.0, right: 25.0, top: 18.0, bottom: 18.0),
                          child: Divider(height: 10, thickness: 0.4, color: Colors.grey,),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("PERSONAL INFORMATION",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        ListTile(
                          leading: Icon(Icons.transgender),
                          title: Text("Gender"),
                          subtitle: Text(user['gender'], style: TextStyle(color: Colors.grey[600],),),
                        ),

                        const SizedBox(height: 10),

                        ListTile(
                          leading: Icon(Icons.cake),
                          title: Text("Date of Birthday"),
                          subtitle: Text(user['birthday'], style: TextStyle(color: Colors.grey[600],),),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              }else {
                return const Text ("No data");
              }

            }
        )
    );
  }
}

