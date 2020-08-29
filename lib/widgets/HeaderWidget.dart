import 'package:flutter/material.dart';

 AppBar header( context, {bool isAppTitle = false, String strTitle, disappearedBackButton = false})
  {
  return AppBar(

    iconTheme:  IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: disappearedBackButton ? false :true,
    title: Text(
      isAppTitle ? "Mr.Techie" : strTitle,
      style: TextStyle(
        color: Colors.white,
        fontSize:isAppTitle ? 25.0 : 20.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.grey[900],
    brightness: Brightness.dark
  
  );
}
