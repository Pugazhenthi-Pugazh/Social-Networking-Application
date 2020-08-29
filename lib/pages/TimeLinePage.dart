import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mr_techie/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:mr_techie/models/user.dart';
import 'package:mr_techie/widgets/HeaderWidget.dart';
import 'package:mr_techie/widgets/PostWidget.dart';
import 'package:mr_techie/widgets/ProgressWidget.dart';



class TimeLinePage extends StatefulWidget 
{
  final User gCurrentUser;

  TimeLinePage({this.gCurrentUser});


  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}




class _TimeLinePageState extends State<TimeLinePage> 
{
  List<Post> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  retrieveTimeLine() async
  {
    QuerySnapshot querySnapshot  = await  timelineReference.document(widget.gCurrentUser.id)
    .collection("timelinePosts").orderBy("timestamp", descending: true).getDocuments();

     
    List<Post> allPosts = querySnapshot.documents.map((document) => Post.fromDocument(document)).toList();
    
    
    setState(() {
      this.posts = allPosts;
    });

  }

  retrieveFollowings() async
  {
    QuerySnapshot querySnapshot =  await followingReference.document(currentUser.id).collection("userFollowing").getDocuments();

   setState(() {
     followingsList = querySnapshot.documents.map((document) => document.documentID).toList();
   });

  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveTimeLine();
    retrieveFollowings();

  }

  
  createUserTimeLine()
  {
    if(posts == null)
    {
      return circularProgress();
    }
    else 
    {
      return ListView(children: posts,);
    }
  }
 
  logoutUser() async{
     await gSignIn.signOut();
     Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
  }


  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
       drawer: new Drawer(
        elevation:25.0,
        child: ListView(
          padding: EdgeInsets.zero,
        children: <Widget>[
          new Container
          (
            height: 100,
             decoration: new BoxDecoration(
      color: Colors.grey[900],
      boxShadow: [
        new BoxShadow(blurRadius: 40.0)
      ],
      borderRadius: new BorderRadius.vertical(
          bottom: new Radius.elliptical(
              MediaQuery.of(context).size.width, 100.0)
              ),
            
    ),
          
            child: Text
            (
              "About Us",
              
            style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold,color: Colors.white),
            textAlign: TextAlign.center,
            
            ),
         
            ),
         
             new  CircleAvatar
                 (
                   backgroundColor: Colors.transparent,
                   radius: 90.0,
                   child: Image.asset("assets/images/pug.png"),        
                 ),
          
            SizedBox(height: 10.0,),
            new Text("Hi i am pugazhenthi",
                style: TextStyle(color:Colors.black,fontSize:16.0,fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.0,),
  
              new Text(" I am a Engineering Student,And this is my miniproject. Many engineering students are laged in technical knowledge. So i Developed this Mr.techie application because in this application they can post the technical contents and know some technical news and knowledge. And this application is created by Flutter framework and Dart programming with Firebase Cloud Firestore database.",
                style: TextStyle(color:Colors.black,fontSize:14.0,fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              ),

              SizedBox(height: 15,),
              
                 Padding(
              padding: EdgeInsets.only(top:10.0, left: 50.0, right:50.0),
              child:RaisedButton(
                shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(18.0),
                ),
                color: Colors.green,
                onPressed: logoutUser,
                child: Text(
                   "Logout",
                   style: TextStyle(color: Colors.white, fontSize:19.0),
                ),
                ),
            ),  
        
          ],
        ),
       

      ),
    

      appBar: new AppBar(
        brightness: Brightness.dark,
          backgroundColor: Colors.grey[900],
        title: new Text("Mr.Techie", style:TextStyle(color: Colors.white, fontSize:22.0),),
         centerTitle: true,
      leading: new IconButton
         (
           icon:  new Icon(Icons.menu),
           color: Colors.blueGrey,
           onPressed: () => _scaffoldKey.currentState.openDrawer()
         ),
      ),
      body: RefreshIndicator(child: createUserTimeLine(), onRefresh: () => retrieveTimeLine()),
    );
     
  }
}