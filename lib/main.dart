import 'package:flutter/material.dart';
import 'wall_builder.dart'; // Importer le fichier de construction de murs

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mvp_Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WallBuilder(), // La page principale est WallBuilder
      debugShowCheckedModeBanner: false,
    );
  }
}
