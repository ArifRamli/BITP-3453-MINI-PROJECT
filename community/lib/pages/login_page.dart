import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:community/helper/helper_functions.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';


class LoginPage extends StatefulWidget {

  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotpasswordController = TextEditingController();

  //login method
  void login() async{
    // show loading circle
    showDialog(context: context, builder: (context)=> const Center(child: CircularProgressIndicator(),
    ),
    );
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // try sign in
    try{
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);

      _firestore
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((value) => userCredential.user!.updateDisplayName(value['username']));


      // pop loading circle
      if (context.mounted) Navigator.pop(context);
      Navigator.pushNamed(context, '/home_page');
    }

    // display any errors
    on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  Future<void> passwordReset(String email) async {
    print(email);
    try {
      if (!email.contains('@')) {
        throw FirebaseAuthException(code: 'invalid-email'); // Example of throwing a specific error
      }

      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("A reset password link has been sent to ${email}, if the email is existed in our database, you can change the password."),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("User not found");
      } else if (e.code == 'invalid-email') {
        print("Invalid email");
      }
    } catch (e) {
      print("Other error: ${e}");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Logo
                  Icon(
                    Icons.forum,
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

                  //forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Forgot Password?"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "Enter your email address",
                                    ),
                                    controller: forgotpasswordController,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    passwordReset(forgotpasswordController.text.trim());
                                    Navigator.pop(context); // Close the dialog
                                    forgotpasswordController.text = "";
                                  },
                                  child: Text("Submit"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context), // Close the dialog
                                  child: Text("Cancel"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),



                  const SizedBox(height: 25),

                  //sign in button
                  MyButton(
                    text: "Login",
                    onTap: login,
                  ),

                  const SizedBox(height: 25),

                  //dont have account? register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text("Register Here",
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