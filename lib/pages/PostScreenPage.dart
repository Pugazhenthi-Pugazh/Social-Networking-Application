import 'package:flutter/material.dart';
import 'package:mr_techie/pages/HomePage.dart';
import 'package:mr_techie/widgets/HeaderWidget.dart';
import 'package:mr_techie/widgets/PostWidget.dart';
import 'package:mr_techie/widgets/ProgressWidget.dart';

class PostScreenPage extends StatelessWidget 
{
  final String postId;
  final String userId;

  PostScreenPage({
    this.postId,
    this.userId,

  });

  @override
  Widget build(BuildContext context)
   {
    return FutureBuilder(
      future: postsReference.document(userId).collection("usersPosts").document(postId).get(),
      builder: (context, dataSnapshot)
      {
        if(!dataSnapshot.hasData)
        {
          return circularProgress();
        }

        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: "Posts"),
            body: ListView(
              children:<Widget>[
                Container(
                  child:post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
