// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importer pour gérer les événements du clavier
import 'line.dart';
import 'wall_painter.dart';
import 'dart:math';

class WallBuilder extends StatefulWidget {
  @override
  _WallBuilderState createState() => _WallBuilderState();
}

class _WallBuilderState extends State<WallBuilder> {
  Offset? startPoint; // Point de départ pour dessiner un mur
  Offset? endPoint; // Point d'arrivée pour dessiner un mur
  List<Line> walls = []; // Liste de tous les murs
  bool isDrawingWall = false; // Indique si un mur est en train d'être dessiné
  Line? selectedWall; // Mur actuellement sélectionné
  Offset? selectedEndpoint; // Extrémité actuellement sélectionnée d'un mur
  static const double gridSize = 20.0; // Taille de la grille pour le dessin

  bool isGridVisible =
      true; // Variable pour contrôler la visibilité de la grille

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(
        _handleKeyEvent); // Ajouter un écouteur d'événements clavier
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(
        _handleKeyEvent); // Retirer l'écouteur d'événements clavier
    super.dispose();
  }

  // Gérer les événements de clavier
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.delete) {
      // Si la touche "Supprimer" est enfoncée
      if (!isDrawingWall) {
        // Supprimer les murs sélectionnés si on n'est pas en mode dessin
        setState(() {
          walls.removeWhere((wall) =>
              wall.isSelected); // Retirer les murs sélectionnés de la liste
        });
      }
    }
  }

  // Gérer le tap pour dessiner ou sélectionner un mur
  void _onTapDown(TapDownDetails details) {
    final tapPosition = details.localPosition; // Récupérer la position du tap

    if (isDrawingWall) {
      // Si on est en mode dessin de mur
      if (startPoint == null) {
        // Si le point de départ n'est pas défini
        setState(() {
          startPoint = _snapToGrid(
              tapPosition); // Définir le point de départ aligné à la grille
          endPoint =
              startPoint; // Initialiser le point d'arrivée au point de départ
        });
      } else {
        // Si le point de départ est déjà défini
        setState(() {
          walls.add(Line(
              startPoint!, endPoint!)); // Ajouter un nouveau mur à la liste
          startPoint = null; // Réinitialiser les points
          endPoint = null;
        });
      }
    } else {
      // Si on n'est pas en mode dessin
      for (var wall in walls) {
        if (isNearPoint(tapPosition, wall.start)) {
          // Vérifier si le tap est près du point de départ du mur
          setState(() {
            selectedWall = wall; // Sélectionner le mur
            selectedEndpoint = wall.start; // Sélectionner le point de départ
            wall.isSelected = true; // Marquer le mur comme sélectionné
          });
          return;
        } else if (isNearPoint(tapPosition, wall.end)) {
          // Vérifier si le tap est près du point d'arrivée du mur
          setState(() {
            selectedWall = wall; // Sélectionner le mur
            selectedEndpoint = wall.end; // Sélectionner le point d'arrivée
            wall.isSelected = true; // Marquer le mur comme sélectionné
          });
          return;
        } else if (isNearLine(tapPosition, wall.start, wall.end)) {
          // Vérifier si le tap est près du mur
          setState(() {
            selectedWall = wall; // Sélectionner le mur
            wall.isSelected = !wall.isSelected; // Inverser l'état de sélection
          });
          return;
        }
      }

      // Si aucun mur n'est sélectionné, désélectionner tout
      setState(() {
        selectedWall = null; // Réinitialiser la sélection
        selectedEndpoint = null; // Réinitialiser le point sélectionné
        walls.forEach(
            (wall) => wall.isSelected = false); // Désélectionner tous les murs
      });
    }
  }

  // Mettre à jour la position du mur pendant le glissement
  void _onPanUpdate(DragUpdateDetails details) {
    final dragPosition = _snapToGrid(details
        .localPosition); // Récupérer la position de glissement alignée à la grille

    if (!isDrawingWall && selectedWall != null && selectedEndpoint != null) {
      // Déplacer une extrémité du mur sélectionné si on n'est pas en mode dessin
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
        endPoint =
            dragPosition; // Définir la nouvelle position de l'extrémité du mur
      });
    }
  }

  // Réinitialiser la sélection après le glissement
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      selectedEndpoint = null; // Réinitialiser l'extrémité sélectionnée
    });
  }

  // Vérifier si un point est proche d'une ligne
  bool isNearLine(Offset p, Offset start, Offset end,
      {double threshold = 10.0}) {
    double distance =
        _distancePointToLine(p, start, end); // Calculer la distance au mur
    return distance < threshold; // Retourne vrai si le point est proche
  }

  // Vérifier si un point est proche d'un autre point
  bool isNearPoint(Offset p, Offset point, {double threshold = 10.0}) {
    return (p - point).distance <
        threshold; // Retourne vrai si le point est proche
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
    return sqrt(dx * dx + dy * dy); // Retourne la distance
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
        selectedWall = null; // Désélectionner tout
        selectedEndpoint = null; // Réinitialiser l'extrémité sélectionnée
        walls.forEach(
            (wall) => wall.isSelected = false); // Désélectionner tous les murs
      });
    } else {
      setState(() {
        isDrawingWall = false; // Désactiver le mode de dessin
      });
    }
  }

  // Interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          onSelected: _selectMenu, // Gérer la sélection du menu
          itemBuilder: (BuildContext context) {
            return {'Poser Mur', 'Editer Mur'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice), // Afficher l'élément du menu
              );
            }).toList();
          },
        ),
        actions: [
          // Contrôle pour afficher ou masquer la grille
          Row(
            children: [
              Text("Afficher la grille"),
              Switch(
                value: isGridVisible, // État du switch
                onChanged: (value) {
                  setState(() {
                    isGridVisible = value; // Mettre à jour l'état de la grille
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: MouseRegion(
        onHover: (PointerEvent details) {
          // Mettre à jour la position de fin du mur pendant le survol de la souris
          if (isDrawingWall && startPoint != null) {
            setState(() {
              endPoint = _snapToGrid(details
                  .localPosition); // Mettre à jour le point de fin aligné à la grille
            });
          }
        },
        child: GestureDetector(
          onTapDown: _onTapDown, // Gérer le tap
          onPanUpdate: _onPanUpdate, // Gérer le glissement
          onPanEnd: _onPanEnd, // Gérer la fin du glissement
          child: CustomPaint(
            size: Size.infinite, // Peindre sur toute la surface
            painter: WallPainter(
              // Passer les infos au peintre
              walls: walls,
              startPoint: startPoint,
              endPoint: endPoint,
              selectedWall: selectedWall,
              selectedEndpoint: selectedEndpoint,
              isGridVisible: isGridVisible,
            ),
          ),
        ),
      ),
    );
  }
}
