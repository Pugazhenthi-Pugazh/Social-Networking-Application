import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mr_techie/models/user.dart';
import 'package:mr_techie/pages/CreateAccountPage.dart';
import 'package:mr_techie/pages/NotificationsPage.dart';
import 'package:mr_techie/pages/ProfilePage.dart';
import 'package:mr_techie/pages/SearchPage.dart';
import 'package:mr_techie/pages/TimeLinePage.dart';
import 'package:mr_techie/pages/UploadPage.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
final StorageReference storageReference =FirebaseStorage.instance.ref().child("Posts Pictures");
final postsReference = Firestore.instance.collection("posts");
final activityFeedReference = Firestore.instance.collection("feed");
final commentsReference = Firestore.instance.collection("comments");
final followersReference = Firestore.instance.collection("followers");
final followingReference = Firestore.instance.collection("following");
final timelineReference = Firestore.instance.collection("timeline");


final DateTime timestamp =DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
 {

   bool isSignedIn = false;
   PageController pageController;
   int getPageIndex = 0;
   FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
   final _scaffoldKey = GlobalKey<ScaffoldState>();

    void initState(){
     super.initState();
     pageController = PageController();
  

     
     gSignIn.onCurrentUserChanged.listen((gSigninAccount){
       controlSignIn(gSigninAccount);
     }, onError: (gError){
       print("Error Message: "+ gError);
     });
   

     gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount){
       controlSignIn(gSignInAccount);
    }).catchError((gError){
     print("Error Message: "+ gError);
    });

   }


    controlSignIn(GoogleSignInAccount signInAccount) async
    {
      if(signInAccount != null)
      {
        await saveUserInfoToFireStore();
        setState(() {
          isSignedIn = true;
        });

        configureRealTimePushNotification();
      }
      else
      {
        setState(() {
          isSignedIn = false;
        });
       
      }
    } 

    configureRealTimePushNotification()
    {
     final GoogleSignInAccount gUser = gSignIn.currentUser;

     if(Platform.isIOS)
     {
       getIOSPermissions();
     }
     _firebaseMessaging.getToken().then((token){
       usersReference.document(gUser.id).updateData({"androidNotificationToken" : token});
     });

     _firebaseMessaging.configure(
       onMessage: (Map<String, dynamic> msg)async{
        final String recipientId = msg["data"]["recipient"];
        final String body = msg["notification"]["body"];

        if(recipientId == gUser.id)
        {
          SnackBar snackBar = SnackBar(
            backgroundColor: Colors.grey,
            content: Text(body, style: TextStyle(color: Colors.black), overflow: TextOverflow.ellipsis),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }

       },
     );
   }

   getIOSPermissions()
   {
     _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert: true, badge: true, sound:true));

     _firebaseMessaging.onIosSettingsRegistered.listen((settings){
       print("Settings Registered : $settings");
      });
        }
     
          
         saveUserInfoToFireStore() async {
           final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
           DocumentSnapshot documentSnapshot = await usersReference.document(gCurrentUser.id).get();
     
           if(! documentSnapshot.exists){
             final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateAccountPage()));
     
              usersReference.document(gCurrentUser.id).setData({
             "id": gCurrentUser.id,
             "profileName": gCurrentUser.displayName,
             "username": username,
             "url": gCurrentUser.photoUrl,
             "email": gCurrentUser.email,
             "bio":"",
             "timestamp": timestamp,
           });
           
           await followersReference.document(gCurrentUser.id).collection("userFollowers").document(gCurrentUser.id).setData({});
     
           documentSnapshot = await usersReference.document(gCurrentUser.id).get();
     
           }  
     
           currentUser = User.fromDocument(documentSnapshot);
         }
     
          void dispose(){
            pageController.dispose();
            super.dispose();
          }
         loginUser(){
          gSignIn.signIn();
     
       }
     
       logoutUser(){
           gSignIn.signOut();
         }
     
          whenPageChanges(int pageIndex){
            setState(() {
                this.getPageIndex = pageIndex;  
            });
          
     
          }
     
          onTapChangePage(int pageIndex){
            pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 300),curve: Curves.bounceInOut);
     
          }
     
       Scaffold buildHomeScreen(){
         return Scaffold(
           key: _scaffoldKey,
           body:PageView(
             children: <Widget>[
               TimeLinePage(gCurrentUser: currentUser,),
               SearchPage(),
               UploadPage(gCurrentUser: currentUser,),
               NotificationsPage(),
               ProfilePage(userProfileId: currentUser?.id),
             ],
             controller: pageController,
             onPageChanged: whenPageChanges,
             physics:  NeverScrollableScrollPhysics(),
           ),
           bottomNavigationBar: 
            ClipRRect(
             borderRadius: BorderRadius.only(
               topRight: Radius.circular(50),
               topLeft: Radius.circular(50),
               bottomRight: Radius.circular(50),
               bottomLeft: Radius.circular(50)
             ),
           child: CupertinoTabBar(
             currentIndex: getPageIndex,
             onTap: onTapChangePage,
             activeColor: Colors.white,
             inactiveColor: Colors.blueGrey,
             backgroundColor: Colors.grey[900],
             items: [
               BottomNavigationBarItem(icon:  Icon(Icons.home)),
               BottomNavigationBarItem(icon:  Icon(Icons.search)),
               BottomNavigationBarItem(icon:  Icon(Icons.add_circle_outline, size: 35.0,)),
               BottomNavigationBarItem(icon:  Icon(Icons.notifications)),
               BottomNavigationBarItem(icon:  Icon(Icons.person)),
             ],
           )
            ),
         );
                                                                                                                                                                                                                     
     
       }
     
       Scaffold buildSignInScreen(){
          return Scaffold(
               
                body: Container(
                         color: Colors.white,
                 
                     alignment: Alignment.center,
                  child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                       Text(
                          "Mr.Techie",
                          style: TextStyle(fontSize:40.0,color:Colors.black,),
                        ),
                        Text("Think out of box",
                         style: TextStyle(fontSize:20.0,color:Colors.black,),
                        ),
     
                     SizedBox(height:70.0),
                      Container(
                        alignment: Alignment.center ,
                       height: 220,
                       width: 220,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("assets/images/back22.jpg"),fit: BoxFit.cover,)
                        ),
                      ),
                      
                        SizedBox(height:100.0),
     
                         GestureDetector(
                           onTap: loginUser,
                           child: Container(
                             width: 270.0,
                             height: 65.0,
                             decoration: BoxDecoration(
                               image: DecorationImage(
                                 image:AssetImage("assets/images/google_signin_button.png"),
                                 fit: BoxFit.cover
                                  )
                             )
                           ),
                         )
                    ],
                    )
                  )
             );
       }
     
     
       @override
       Widget build(BuildContext context) {
        if(isSignedIn)
       {
         return buildHomeScreen();
       }
       else
       {
         return buildSignInScreen();
       }
   }
}
     
     