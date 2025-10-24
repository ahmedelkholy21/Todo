import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo/home/home.dart';

void main() {
  sqfliteFfiInit();  
  databaseFactory = databaseFactoryFfi;
  runApp(
    
    const MyApp());
}

 class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,home: Home(),);
  }
}