import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {

  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  //register method
  void registerUser() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
          child: CircularProgressIndicator()
      ),
    );

    bool usernameExists = await checkUsernameExists(usernameController.text);

    // make sure passwords match

    if (passwordController.text != confirmPwController.text){
      //pop loading circle
      Navigator.pop(context);

      // show error message to user
      displayMessageToUser("Passwords don't match!", context );
    } else if (usernameExists){
      Navigator.pop(context); // Pop loading circle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username is already taken. Please try another.')),
      );
      return;
    }

    // if the passwords do match
    else{
      //try creating the users
      try{
        // create the user
        UserCredential? userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );

        // create user document and add to firestore
        createUserDocument(userCredential);

        FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .get()
            .then((value) => userCredential.user!.updateDisplayName(value['username']));

        // pop loading circle
        Navigator.pop(context);
        Navigator.pushNamed(context, '/home_page');
      } on FirebaseAuthException catch (e){
        // pop loading circle
        if (context.mounted) Navigator.pop(context);


        // display error message to user
        displayMessageToUser(e.code, context);
      }
    }
  }


  // create a user document and collect them in firestore
  Future<void> createUserDocument(UserCredential? userCredential) async{
    if (userCredential != null && userCredential.user != null){
      String firstletter= emailController.text.substring(0,1).toLowerCase();
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
        'bio': "Hey there! I am using this amazing Forum App",
        'gender': "Select your gender",
        'birthday': "Update your birthday",
        'status': "Online",
        'profilepicture' : "https://firebasestorage.googleapis.com/v0/b/new-project-497c5.appspot.com/o/profile_picture%2Fdefault_profile_picture.png?alt=media&token=6df353f0-9886-4264-b8f4-3340cc38df12",
        'SearchKey': firstletter,
      });
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    bool validation = false;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .get();

      validation = querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking username: $error');
      // Handle potential errors (e.g., show a generic error message to the user)
    }
    return validation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  //Logo
                  Icon(
                    Icons.person,
                    size: 80,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),

                  const SizedBox(height: 25),

                  //app name
                  const Text(
                    "F O R U M",
                    style: TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "A P P",
                    style: TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height: 50),

                  //username textfield
                  MyTextField(
                      hintText: "Username",
                      obscureText: false,
                      controller: usernameController
                  ),

                  const SizedBox(height: 10),

                  //email textfield
                  MyTextField(
                      hintText: "Email",
                      obscureText: false,
                      controller: emailController
                  ),

                  const SizedBox(height: 10),

                  //password textfield
                  MyTextField(
                      hintText: "Password",
                      obscureText: true,
                      controller: passwordController
                  ),

                  const SizedBox(height: 10),

                  //confirm password textfield
                  MyTextField(
                      hintText: "Confirm Password",
                      obscureText: true,
                      controller: confirmPwController
                  ),

                  const SizedBox(height: 25),

                  //register button
                  MyButton(
                    text: "Register",
                    onTap: registerUser,
                  ),

                  const SizedBox(height: 25),

                  //dont have account? register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text("Login Here",
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                ]
            ),
          ),
        ),
      ),
    );
  }
}