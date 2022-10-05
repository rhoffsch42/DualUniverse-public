# Safe Travel Infos
A visual representation of your ship distance from the warp tunnel between two planets. Fly safe!

# Install
1) inject safe_travel_infos.json in a programming board
2) link core
3) link a screen
4) optionnal: link another screen to display more data

Also make sure that HTML screen units are not disabled (Escape > General > "Disable HTML screen units").

# Presentation
You can select the origin planet on left and the destination planet on right, to know the ship's closest distance to the warp tunnel.

In addition to that, it shows the distance traveled in the danger zone when going straight to the destination.
The danger zone, represented as a red area here, is simply a tube around the warp line. Its ray is the range of the space radar: 2su.
You can also toggle the display of two more trajectorys:
* Velocity (purple): the trajectory where your ship is currently traveling
* Forward (green): the trajectory where your ship would travel if going forward

The green ellipse is the safe zone. Why it's not a circle? Because the vertical and horizontal scales are different, the vertical one is much more stretched. So keep in mind that the height (the distance from the warp line) and the width (the travel route) have different scales, meaning that the angles of trajectorys might not represent reality.

![STI](https://i.imgur.com/8DNmFnG.png)

The safe zone status shows if you're inside the pvp zone or not. The values underneath are the ship distances from the global safe zone and the planetary protection of the closest planet or moon.

![STI](https://i.imgur.com/0t3unb8.png)

This grid is a quick representation of all distances from travel routes.
Tiles can have different colors: red, orange or yellow if the distance is inferior to 2, 4 or 6 su respectively.
You can hover tiles for more details:

![STI](https://i.imgur.com/U74DtkU.png)
