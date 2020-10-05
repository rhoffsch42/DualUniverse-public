Place these files in "Dual Universe\Game\data\lua" :
Locations.lua
planetref.lua
atlas.lua

Copy/paste the conf from locations_HUD.json in the programing board.

-------------------------------------------------------------------
-- doc
-------------------------------------------------------------------
Author: Ater Omen
WORK IN PROGRESS
03 Sept 2020

There is no dependency as it uses only vec3,
but it is recommended to use JayleBreak's pos convertor: planetref.lua and atlas.lua 

This HUD works only with a fov of 90°, with locked camera,
there will be maybe a free camera mode later but for now we miss infos from user inputs.
Since system.lockView() is disabled it is not recommanded to use 1st person.
The best use for this HUD is in locked 3rd person view when piloting, zoomed out at max range.
You can display it on a screen too, see unit>tick(hud)

Lua parameters: there are a lot of lua parameters used for calibration,
twick them if you know what you are doing.

Installation process: link a gyroscope to the programming board

Commands:
	option 3 : swap between locked 1st person and locked 3rd person
	option 9 : toggle hud

Known bugs:
	- some planets data may be wrong, making the locations display at the wrong place
	- there might be a performance bug when toggling free mouse (tab), restart to fix it.
	- calibrations need to be more precise depending on the ship core size.

Usage (there are examples with the arkship and districts in unit>start):
How to add new Location from a bookmark:

	-- create a vec3 from the bookmark
	local	space_station = toWorld("::pos{0,0,8000000.0,11000000.0,-50000.0}")
	-- all Locations are in the table Location.planets for now
	Locations.planets["Space Station"] = Location(space_station)

	-- the name of the key will be used when displaying the Location

How to add a Location within another with the parenting system:
	
	local arkship = toWorld("::pos{0,2,29.7656,95.4761,3512.4180}")
	-- added in group 2, group 1 is for moons (display with threshold of 5su from the planet)
	Locations.planets.Alioth:add(2, {
        ["Arkship"] = Location(arkship),
	}, 1 * su) -- it will be displayed below that distance from the parent (here Alioth)

	-- change distance threshold of the group 2 of Alioth:
	Locations.planets.Alioth:setGroupThreshold(2, 200 * su)

How to customize the HUD:

	-- it will affect all children of the Location
	Locations.planets.Alioth[2].Arkship.params = {
		color = "cyan",
		mode = g_keepOnBorders,
		blinking = true
	}
	-- if you want, you can also edit directly the svg lines in the library functions