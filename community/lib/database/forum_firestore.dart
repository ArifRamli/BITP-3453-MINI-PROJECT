import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForumFirestoreDatabase {
  // current logged in user
  User? user = FirebaseAuth.instance.currentUser;

  // get collection of posts from firebase
  final CollectionReference posts = FirebaseFirestore.instance.collection('Forums');

  // post a message with an image URL
  Future<void> addPost({
    required String title,
    required String message,
    String? imageUrl,
  }) async {
    try {
      await posts.add({
        'UserEmail': user!.email,
        'PostTitle': title,
        'PostMessage': message,
        'ImageUrl': imageUrl,
        'TimeStamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding post: $e');
      // Handle error according to your app's logic
    }
  }

  // read posts from database
  Stream<QuerySnapshot> getPostsStream() {
    final postsStream = FirebaseFirestore.instance
        .collection('Forums')
        .orderBy('TimeStamp', descending: true)
        .snapshots();
    return postsStream;
  }

  // add a comment to a specific post
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      await posts.doc(postId).collection('Comments').add({
        'Comment': comment,
        'TimeStamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding comment: $e');
      // Handle error according to your app's logic
    }
  }

  // read comments for a specific post
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    final commentsStream = posts.doc(postId).collection('Comments').orderBy('TimeStamp').snapshots();
    return commentsStream;
  }

  // delete a post
  Future<void> deletePost(String postId) async {
    try {
      await posts.doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

}


