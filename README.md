# mvp_flutter

**mvp_flutter** est une application Flutter qui permet aux utilisateurs de dessiner et de manipuler des murs. L'application offre des fonctionnalités simples pour ajouter, déplacer et supprimer des murs, tout en fournissant une grille pour un alignement facile.

## Table des matières

- [Caractéristiques](#caractéristiques)
- [Technologies utilisées](#technologies-utilisées)
- [Installation](#installation)
- [Utilisation](#utilisation)

## Caractéristiques

- Dessin de murs avec des points de départ et d'arrivée.
- Sélection et déplacement des murs existants.
- Suppression de murs avec la touche Suppr (Delete).
- Interface intuitive avec une grille d'alignement.

## Technologies utilisées

- [Flutter](https://flutter.dev/) - Framework pour créer des applications mobiles.
- Dart - Langage de programmation utilisé pour le développement Flutter.

## Installation

1. **Cloner le dépôt :**

   ```bash
   git clone https://github.com/avekia-x-sudria-2024/mvp_flutter.git
   ```

2. **Accéder au répertoire du projet :**

   ```bash
   cd mvp_flutter
   ```

3. **Installer les dépendances :**

Assurez-vous d'avoir Flutter installé. Ensuite, exécutez :

   ```bash
   flutter pub get
   ```

4. **Lancer l'application :**

Vous pouvez exécuter l'application sur une page web ou un émulateur avec la commande :

   ```bash
   flutter run
   ```

## Utilisation

- **Dessin de murs** : Cliquez pour définir un point de départ et un point d'arrivée pour dessiner un mur.
- **Sélectionner un mur** : Cliquez sur un mur existant pour le sélectionner. Les points de contrôle apparaîtront pour déplacer le mur.
- **Déplacer un mur** : Faites glisser un point de contrôle pour déplacer l'extrémité d'un mur.
- **Supprimer un mur** : Sélectionnez un mur et appuyez sur la touche Suppr pour le supprimer.