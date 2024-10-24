import 'package:flutter/material.dart';
import 'line.dart';
import 'dart:math';

class WallPainter extends CustomPainter {
  final List<Line> walls;
  final Offset? startPoint;
  final Offset? endPoint;
  final Line? selectedWall;
  final Offset? selectedEndpoint;
  final bool isGridVisible;

  WallPainter({
    required this.walls,
    this.startPoint,
    this.endPoint,
    this.selectedWall,
    this.selectedEndpoint,
    required this.isGridVisible,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      backgroundColor: Colors.white,
    );
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Peindre la grille uniquement si elle est visible
    if (isGridVisible) {
      final paintGrid = Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..strokeWidth = 0.5;

      for (double i = 0; i < size.width; i += 20.0) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
      }

      for (double i = 0; i < size.height; i += 20.0) {
        canvas.drawLine(Offset(0, i), Offset(size.width, i), paintGrid);
      }
    }

    // Dessiner les murs
    for (var wall in walls) {
      final paint = Paint()
        ..color = wall.isSelected ? Colors.orange : Colors.blue
        ..strokeWidth = 10.0;

      canvas.drawLine(wall.start, wall.end, paint);

      // Afficher la longueur du mur
      canvas.drawCircle(wall.start, 6, Paint()..color = Colors.green);
      canvas.drawCircle(wall.end, 6, Paint()..color = Colors.red);

      // Calculer la longueur du mur
      double length = _calculateLength(wall.start, wall.end);

      // Préparer le texte à afficher
      textPainter.text = TextSpan(
        text:
            "${length.toStringAsFixed(2)} m", // Longueur arrondie à 2 décimales
        style: textStyle,
      );
      textPainter.layout();

      // Trouver la position au milieu du mur pour afficher la longueur
      Offset midpoint = Offset(
        (wall.start.dx + wall.end.dx) / 2,
        (wall.start.dy + wall.end.dy) / 2,
      );

      // Dessiner la longueur du mur
      textPainter.paint(canvas, midpoint);
    }

    // Dessiner le mur en cours de dessin
    if (startPoint != null && endPoint != null) {
      final paintWall = Paint()
        ..color = Colors.red
        ..strokeWidth = 10.0;

      canvas.drawLine(startPoint!, endPoint!, paintWall);

      // Calculer la longueur du mur en cours de dessin
      double length = _calculateLength(startPoint!, endPoint!);

      // Préparer le texte à afficher
      textPainter.text = TextSpan(
        text:
            "${length.toStringAsFixed(2)} m", // Longueur arrondie à 2 décimales
        style: textStyle,
      );
      textPainter.layout();

      // Trouver la position au milieu du mur pour afficher la longueur
      Offset midpoint = Offset(
        (startPoint!.dx + endPoint!.dx) / 2,
        (startPoint!.dy + endPoint!.dy) / 2,
      );

      // Dessiner la longueur du mur
      textPainter.paint(canvas, midpoint);
    }

    if (startPoint != null) {
      canvas.drawCircle(startPoint!, 5, Paint()..color = Colors.green);
    }

    if (selectedEndpoint != null) {
      canvas.drawCircle(selectedEndpoint!, 6, Paint()..color = Colors.yellow);
    }
  }

  // Fonction pour calculer la longueur entre deux points
  double _calculateLength(Offset start, Offset end) {
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    return sqrt(dx * dx + dy * dy) /
        100; // Conversion des pixels en mètres (ex: 1 pixel = 1 cm)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
