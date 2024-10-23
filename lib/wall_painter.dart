import 'package:flutter/material.dart';
import 'line.dart'; // Importer la classe Line

class WallPainter extends CustomPainter {
  final List<Line> walls; // Liste des murs
  final Offset? startPoint; // Point de départ du mur en cours de dessin
  final Offset? endPoint; // Point d'arrivée du mur en cours de dessin
  final Line? selectedWall; // Mur sélectionné
  final Offset? selectedEndpoint; // Extrémité sélectionnée

  WallPainter({
    required this.walls,
    this.startPoint,
    this.endPoint,
    this.selectedWall,
    this.selectedEndpoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Peindre la grille
    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20.0) {
      canvas.drawLine(
          Offset(i, 0), Offset(i, size.height), paintGrid); // Lignes verticales
    }

    for (double i = 0; i < size.height; i += 20.0) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i),
          paintGrid); // Lignes horizontales
    }

    // Dessiner les murs
    for (var wall in walls) {
      final paint = Paint()
        ..color = wall.isSelected ? Colors.orange : Colors.blue
        ..strokeWidth = 10.0;

      canvas.drawLine(wall.start, wall.end, paint); // Dessiner le mur

      if (wall.isSelected) {
        // Dessiner les points de contrôle si le mur est sélectionné
        canvas.drawCircle(
            wall.start, 6, Paint()..color = Colors.green); // Point de départ
        canvas.drawCircle(
            wall.end, 6, Paint()..color = Colors.red); // Point d'arrivée
      }
    }

    // Dessiner le mur en cours de dessin
    if (startPoint != null && endPoint != null) {
      canvas.drawLine(
        startPoint!,
        endPoint!,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 10.0,
      );
    }

    // Dessiner le point de départ en cours de dessin
    if (startPoint != null) {
      canvas.drawCircle(startPoint!, 5, Paint()..color = Colors.green);
    }

    // Dessiner le point sélectionné
    if (selectedEndpoint != null) {
      canvas.drawCircle(selectedEndpoint!, 6, Paint()..color = Colors.yellow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Redessiner à chaque mise à jour
  }
}
