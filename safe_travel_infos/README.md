# Safe Travel Infos
A visual representation of your ship distance from the warp tunnel between two planets. Fly safe!

# Install
1) inject safe_travel_infos.json in a programming board
2) link core
3) link a screen
4) optionnal: link another screen to display more data

# Presentation
In addition to the ship distance from the warp tunnel, It also shows the distance traveled in the danger zone when going straight to the destination.
The danger zone, represented as a red area here, is simply the tube around the warp line. Its ray is the range of the space radar: 2su.
You can select the origin planet on left, and the destination planet on right.

Keep in mind that the height (the distance from the warp line) has not the same scale as the width (the travel route), meaning that angles between them might not represent reality.

![STI](https://i.imgur.com/VeDXlbt.png)

The safe zone status shows if you're inside the pvp zone or not. The values underneath are the ship distances from the global safe zone and the planetary protection of the closest planet or moon.

![STI](https://i.imgur.com/0t3unb8.png)

This matrice is a quick representation of all distances from travel routes.
Tiles can have different colors: red, orange or yellow if the distance is inferior to 2, 4 or 6 su respectively.
You can hover tiles for more details:

![STI](https://i.imgur.com/U74DtkU.png)
