import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../components/my_drawer.dart';
import '../components/my_post_button_2.dart';
import '../components/my_textfield.dart';
import '../database/forum_firestore.dart';

class ForumPage extends StatefulWidget {
  ForumPage({Key? key}) : super(key: key);

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final ForumFirestoreDatabase forumdatabase = ForumFirestoreDatabase();
  final TextEditingController newForumController = TextEditingController();
  final TextEditingController newTitleController = TextEditingController();
  bool _isExpanded = false;

  File? _imageFile; // Add this variable

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref();
    final imageRef = storageRef.child('forum_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = imageRef.putFile(_imageFile!);

    await uploadTask.whenComplete(() => null);

    return await imageRef.getDownloadURL();
  }

  void postMessageForum() async {
    if (newForumController.text.isNotEmpty && newTitleController.text.isNotEmpty) {
      String title = newTitleController.text;
      String message = newForumController.text;
      String? imageUrl = await _uploadImage();

      forumdatabase.addPost(
        title: title,
        message: message,
        imageUrl: imageUrl,
      );
    }
    newTitleController.clear();
    newForumController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  void _showSearchDialog() {
    String searchTitle = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Posts', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Enter post title',
            ),
            onChanged: (value) {
              searchTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            ),
            TextButton(
              onPressed: () {
                _searchPosts(searchTitle);
                Navigator.pop(context);
              },
              child: Text('Search', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            ),
          ],
        );
      },
    );
  }

  void _searchPosts(String searchTitle) {
    if (searchTitle.isNotEmpty) {
      forumdatabase.posts
          .where('PostTitle', isGreaterThanOrEqualTo: searchTitle)
          .where('PostTitle', isLessThan: searchTitle + 'z')
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          // No posts found with the given title
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Search Results', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
                content: Text('No posts found containing "$searchTitle".', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
                  ),
                ],
              );
            },
          );
        } else {
          // Posts found with the given title
          List<Map<String, dynamic>> searchResults = querySnapshot.docs
              .map((DocumentSnapshot document) {
            return {
              'postId': document.id,
              'title': document['PostTitle'] as String,
              'userEmail': document['UserEmail'] as String,
              'timestamp': document['TimeStamp'] as Timestamp,
              'imageUrl': document['ImageUrl'] as String?,
              'message': document['PostMessage'] as String?,
            };
          })
              .toList();

          _showSearchResults(searchResults);
        }
      }).catchError((error) {
        // Handle error according to your app's logic
        print('Error searching posts: $error');
      });
    } else {
      // Show a message if the search title is empty
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Search Results', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            content: Text('Please enter a post title to search.', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
              ),
            ],
          );
        },
      );
    }
  }

  void _showSearchResults(List<Map<String, dynamic>> searchResults) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Results', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Click to view the post:', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
              SizedBox(height: 10),
              for (Map<String, dynamic> result in searchResults)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close the search results dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailsPage(
                          postId: result['postId'],
                          title: result['title'],
                          userEmail: result['userEmail'],
                          timestamp: result['timestamp'],
                          imageUrl: result['imageUrl'],
                          message: result['message'],
                        ),
                      ),
                    );
                  },
                  child: Text(result['title']),



                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('F O R U M'),
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: ExpansionTile(
              initiallyExpanded: false,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded = expanded;
                });
              },
              title: Center(
                child: Text(
                  _isExpanded ? 'CREATE A POST' : 'CREATE A POST',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              children: [
                Visibility(
                  visible: _isExpanded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyTextField(
                        hintText: 'Title',
                        obscureText: false,
                        controller: newTitleController,
                      ),
                      SizedBox(height: 15),
                      MyTextField(
                        hintText: 'Say something...',
                        obscureText: false,
                        controller: newForumController,
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text(
                          'Pick Image',
                          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                        ),
                      ),
                      if (_imageFile != null)
                        Text(
                          'Image Name: ${_imageFile!.path.split('/').last}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 16.0,
                          ),
                        ),
                      SizedBox(height: 15),
                      PostButton2(onTap: postMessageForum),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: forumdatabase.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;

                if (snapshot.data == null || posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No Posts.. Post something!"),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    String title = post['PostTitle'];
                    String userEmail = post['UserEmail'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailsPage(
                              postId: post.id,
                              title: title,
                              userEmail: userEmail,
                              timestamp: post['TimeStamp'],
                              imageUrl: post['ImageUrl'],
                              message: post['PostMessage'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(userEmail),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        tooltip: 'Search',
        child: Icon(Icons.search),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}


class PostDetailsPage extends StatefulWidget {
  final String postId;
  final String title;
  final String userEmail;
  final Timestamp timestamp;
  final String? imageUrl;
  final String? message;

  const PostDetailsPage({
    required this.postId,
    required this.title,
    required this.userEmail,
    required this.timestamp,
    this.imageUrl,
    this.message,
  });

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController commentController = TextEditingController();
  final ForumFirestoreDatabase forumdatabase = ForumFirestoreDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('F O R U M'),
        actions: [
          // Add a conditional rendering of the delete icon
          if (widget.userEmail == FirebaseAuth.instance.currentUser?.email)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Moved title to the body
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20, // Adjust the size as needed
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            Text(
              'By: ${widget.userEmail}',
              style: TextStyle(fontSize: 16.0),
            ),
            if (widget.imageUrl != null) // Display image if available
              Image.network(widget.imageUrl!),
            SizedBox(height: 16.0),
            Text(
              'Posted on: ${widget.timestamp.toDate()}',
              style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.inversePrimary),
            ),
            SizedBox(height: 16.0),
            if (widget.message != null) // Display message if available
              Text(
                widget.message!,
                style: TextStyle(fontSize: 18.0),
              ),
            SizedBox(height: 16.0),
            MyTextField(
              hintText: 'Enter your comment...',
              obscureText: false,
              controller: commentController,
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  forumdatabase.addComment(
                    postId: widget.postId,
                    comment: commentController.text,
                  );
                  commentController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.primary, // Change this color to the desired color
              ),
              child: Text('Post Comment', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
            ),
            SizedBox(height: 16.0),
            Text(
              'Comments:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            StreamBuilder(
              stream: forumdatabase.getCommentsStream(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    String commentText = comment['Comment'];
                    Timestamp timestamp = comment['TimeStamp'];

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commentText,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Posted on: ${timestamp.toDate()}',
                            style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.inversePrimary),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Post', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
          content: Text('Are you sure you want to delete this post?', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            ),
            TextButton(
              onPressed: () {
                _deletePost();
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            ),
          ],
        );
      },
    );
  }

  void _deletePost() {
    // Check if the current user's email matches the post creator's email
    if (widget.userEmail == FirebaseAuth.instance.currentUser?.email) {
      // Call the function to delete the post
      forumdatabase.deletePost(widget.postId);

      // Navigate back to the previous screen after deleting
      Navigator.pop(context);
    } else {
      // Show an error message if the current user is not the creator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are not authorized to delete this post.'),
        ),
      );
    }
  }
}