import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importer pour gérer les événements du clavier
import 'line.dart'; // Importer la classe Line
import 'wall_painter.dart'; // Importer le peintre de murs
import 'dart:math';

class WallBuilder extends StatefulWidget {
  @override
  _WallBuilderState createState() => _WallBuilderState();
}

class _WallBuilderState extends State<WallBuilder> {
  Offset? startPoint; // Point de départ du mur
  Offset? endPoint; // Point d'arrivée du mur
  List<Line> walls = []; // Liste des murs ajoutés
  bool isDrawingWall = false; // État pour savoir si on dessine un mur
  Line? selectedWall; // Mur sélectionné pour édition
  Offset? selectedEndpoint; // L'extrémité sélectionnée pour modification
  static const double gridSize = 20.0; // Taille de la grille

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance
        .addListener(_handleKeyEvent); // Écouter les événements du clavier
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(
        _handleKeyEvent); // Nettoyer l'écouteur lors de la destruction
    super.dispose();
  }

  // Gérer les événements de clavier
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.delete) {
      // Supprimer les murs sélectionnés si on n'est pas en mode dessin
      if (!isDrawingWall) {
        setState(() {
          walls.removeWhere((wall) => wall.isSelected);
        });
      }
    }
  }

  // Gérer le tap pour dessiner ou sélectionner un mur
  void _onTapDown(TapDownDetails details) {
    final tapPosition = details.localPosition;

    if (isDrawingWall) {
      // Si en mode dessin de mur, seulement dessiner un nouveau mur, pas d'édition
      if (startPoint == null) {
        setState(() {
          startPoint = _snapToGrid(tapPosition); // Définir le point de départ
          endPoint = startPoint; // Initialiser le point d'arrivée
        });
      } else {
        setState(() {
          walls.add(Line(startPoint!, endPoint!)); // Ajouter un nouveau mur
          startPoint = null; // Réinitialiser les points
          endPoint = null;
        });
      }
    } else {
      // Si hors du mode dessin, on peut éditer les murs
      for (var wall in walls) {
        if (isNearPoint(tapPosition, wall.start)) {
          setState(() {
            selectedWall = wall;
            selectedEndpoint = wall.start; // Sélectionner le point de départ
            wall.isSelected = true; // Marquer comme sélectionné
          });
          return;
        } else if (isNearPoint(tapPosition, wall.end)) {
          setState(() {
            selectedWall = wall;
            selectedEndpoint = wall.end; // Sélectionner le point d'arrivée
            wall.isSelected = true; // Marquer comme sélectionné
          });
          return;
        } else if (isNearLine(tapPosition, wall.start, wall.end)) {
          setState(() {
            selectedWall = wall;
            wall.isSelected = !wall.isSelected; // Inverser la sélection
          });
          return;
        }
      }

      // Si aucun mur n'est sélectionné, désélectionner tout
      setState(() {
        selectedWall = null;
        selectedEndpoint = null;
        walls.forEach((wall) => wall.isSelected = false);
      });
    }
  }

  // Mettre à jour la position du mur pendant le glissement
  void _onPanUpdate(DragUpdateDetails details) {
    final dragPosition = _snapToGrid(details.localPosition);

    if (!isDrawingWall && selectedWall != null && selectedEndpoint != null) {
      // Déplacer une extrémité du mur sélectionné si en mode édition
      setState(() {
        if (selectedEndpoint == selectedWall!.start) {
          selectedWall!.start = dragPosition; // Déplacer le point de départ
        } else {
          selectedWall!.end = dragPosition; // Déplacer le point d'arrivée
        }
      });
    } else if (isDrawingWall && startPoint != null) {
      // Mettre à jour le point d'arrivée pendant le dessin
      setState(() {
        endPoint = dragPosition;
      });
    }
  }

  // Réinitialiser la sélection après le glissement
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      selectedEndpoint = null; // Aucune extrémité sélectionnée
    });
  }

  // Vérifier si un point est proche d'une ligne
  bool isNearLine(Offset p, Offset start, Offset end, {double threshold = 10.0}) {
    double distance = _distancePointToLine(p, start, end);
    return distance < threshold; // Retourne vrai si le point est proche
  }

  // Vérifier si un point est proche d'un autre point
  bool isNearPoint(Offset p, Offset point, {double threshold = 10.0}) {
    return (p - point).distance < threshold; // Retourne vrai si le point est proche
  }

  // Calculer la distance d'un point à une ligne
  double _distancePointToLine(Offset point, Offset start, Offset end) {
    final double a = point.dx - start.dx;
    final double b = point.dy - start.dy;
    final double c = end.dx - start.dx;
    final double d = end.dy - start.dy;

    final double dot = a * c + b * d;
    final double len_sq = c * c + d * d;
    final double param = (len_sq != 0) ? dot / len_sq : -1;

    double xx, yy;

    if (param < 0) {
      xx = start.dx;
      yy = start.dy;
    } else if (param > 1) {
      xx = end.dx;
      yy = end.dy;
    } else {
      xx = start.dx + param * c;
      yy = start.dy + param * d;
    }

    final double dx = point.dx - xx;
    final double dy = point.dy - yy;
    return sqrt(dx * dx + dy * dy); // Retourner la distance
  }

  // Arrondir un point à la grille
  Offset _snapToGrid(Offset point) {
    return Offset(
      (point.dx / gridSize).round() * gridSize,
      (point.dy / gridSize).round() * gridSize,
    );
  }

  // Gérer la sélection du menu
  void _selectMenu(String value) {
    if (value == 'Poser Mur') {
      setState(() {
        isDrawingWall = true; // Activer le mode de dessin
        // Désélectionner tout quand on entre en mode mur
        selectedWall = null;
        selectedEndpoint = null;
        walls.forEach((wall) => wall.isSelected = false);
      });
    } else {
      setState(() {
        isDrawingWall = false; // Désactiver le mode de dessin
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          onSelected: _selectMenu,
          itemBuilder: (BuildContext context) {
            return {'Poser Mur', 'Editer Mur'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ),
      body: MouseRegion(
        onHover: (PointerEvent details) {
          if (isDrawingWall && startPoint != null) {
            setState(() {
              endPoint = _snapToGrid(details.localPosition);
            });
          }
        },
        child: GestureDetector(
          onTapDown: _onTapDown, // Gérer le tap
          onPanUpdate: _onPanUpdate, // Gérer le glissement
          onPanEnd: _onPanEnd, // Gérer la fin du glissement
          child: CustomPaint(
            size: Size.infinite,
            painter: WallPainter(
              walls: walls,
              startPoint: startPoint,
              endPoint: endPoint,
              selectedWall: selectedWall,
              selectedEndpoint: selectedEndpoint,
            ),
          ),
        ),
      ),
    );
  }
}
