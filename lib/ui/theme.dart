import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const Color bluoo = Color(0xFF4e5ae8);
const Color yellow = Color(0xFFFFb746);
const Color reddd = Color(0xFFff4667);
const Color darkgrey = Color(0xFF121212);
const Color darkheader = Color(0xFF424242);
const Color white = Colors.white;
const primaryClr = bluoo;



class Themes{
 static final light =  ThemeData(
   colorScheme: const ColorScheme.light(
     surface: Colors.white,
    primary: primaryClr,
  ),
  brightness: Brightness.light,
   appBarTheme: const AppBarTheme(
     backgroundColor: Colors.white,
     foregroundColor: Colors.white,
   ),
 );


 static final dark = ThemeData(
   colorScheme: const ColorScheme.dark(
     surface: darkgrey,
     primary: primaryClr,
   ),
   brightness: Brightness.dark,
   scaffoldBackgroundColor: darkgrey,
   appBarTheme:  AppBarTheme(
     backgroundColor: darkgrey,
     foregroundColor: darkheader,
   ),
 );

}

TextStyle get subHeadingStyle{
  return GoogleFonts.lato(
  textStyle: TextStyle(
      fontSize: 24,
    fontWeight: FontWeight.bold,
      color: Get.isDarkMode?Colors.grey[400]:Colors.grey
  ),
  );
}

TextStyle get headingStyle{
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Get.isDarkMode?Colors.white:Colors.black
    ),
  );
}

TextStyle get titleStyle{
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Get.isDarkMode ? Colors.white :Colors.black

    ),
  );
}

TextStyle get subTitleStyle{
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Get.isDarkMode?Colors.grey[100]:Colors.grey[600],

    ),
  );
}