import 'package:flutter/material.dart';

class Line {
  Offset start; // Point de départ du mur
  Offset end; // Point d'arrivée du mur
  bool isSelected; // État de sélection du mur

  Line(this.start, this.end)
      : isSelected = false; // Constructeur avec initialisation de la sélection
}
