--[[

Author: Ater Omen
WORK IN PROGRESS
02 Sept 2020

]]

local vec3  = require('cpml/vec3')
local su = 200000
local default_threshold = 5 * su
Location = {}
Location.__index = Location


function Location.new(vec)
	local loc = {}
	loc.pos = vec3(vec)
	loc.childrenThreshold = {}
	return setmetatable(loc, Location)
end
function Location:add(group_index, arr, threshold)
	-- the keys are the names
	if self[group_index] == nil then
		self[group_index] = {}
		self.childrenThreshold[group_index] = threshold or default_threshold
	end
	for k, v in pairs(arr) do
		self[group_index][k] = v
  end
  self.childrenThreshold[group_index] = threshold or self.childrenThreshold[group_index]
end
function Location:delete(group_index, arr)
	for k, v in pairs(arr) do
		self[group_index][k] = nil
	end
end
function Location:setGroupThreshold(group_index, threshold)
	if self[group_index] == nil then
		self[group_index] = {}
	end
	self.childrenThreshold[group_index] = threshold
end

-- planets data
Locations = {}
Locations.planets = {}
Locations.planets.Alioth = Location.new(vec3(-8, -8, -126303))
Locations.planets.Alioth:add(1, {	["Alioth M1"] = Location.new(vec3(457933,-1509011,115524)),
                  ["Alioth M4"] = Location.new(vec3(-1692694,729681,-411464)),
                  ["Sanctuary"] = Location.new(vec3(-1404835.000, 562655, -285074)) })
Locations.planets.Alioth:setGroupThreshold(1, 20 * su)
Locations.planets.Feli = Location.new(vec3(-43534464, 22565536, -48934464))
Locations.planets.Feli:add(1, {		["Feli M1"] = Location.new(vec3(-43902841, 22261034, -48862386))	})
Locations.planets.Ion = Location.new(vec3(2865536, -99034464, -934464))
Locations.planets.Ion:add(1, {		["Ion M1"] = Location.new(vec3(2472917, -99133746, -1133581)),
									["Ion M2"] = Location.new(vec3(2995424, -99275008, -1378482))		})
Locations.planets.Jago = Location.new(vec3(-94134464, 12765536, -3634464))
Locations.planets.Lacobus = Location.new(vec3(98865536, -13534464, -934464))
Locations.planets.Lacobus:add(1, {	["Lacobus M1"] = Location.new(vec3(99180967, -13783860, -926156)),
									["Lacobus M2"] = Location.new(vec3(99250054, -13629215, -1059341)),
									["Lacobus M3"] = Location.new(vec3(98905290, -13950923, -647589))	})
Locations.planets.Madis = Location.new(vec3(17465536, 22665536, -34464))
Locations.planets.Madis:add(1, {	["Madis M1"] = Location.new(vec3(17448118, 22966848, 143079)),
									["Madis M2"] = Location.new(vec3(17194626, 22243633, -214962)),
									["Madis M3"] = Location.new(vec3(17520617, 22184726, 309986))		})
Locations.planets.Sicari = Location.new(vec3(52765536, 27165536, 52065536))
Locations.planets.Sinnen = Location.new(vec3(58665536, 29665536, 58165536))
Locations.planets.Sinnen:add(1, {	["Sinnen M1"] = Location.new(vec3(58969618, 29797943, 57969448))	})
Locations.planets.Symeon = Location.new(vec3(14165536, -85634464, -934464))
Locations.planets.Talemai = Location.new(vec3(-13234464, 55765536, 465536))
Locations.planets.Talemai:add(1, {	["Talemai M1"] = Location.new(vec3(-13058408, 55781856, 740177)),
									["Talemai M2"] = Location.new(vec3(-13503090, 55594324, 769836)),
									["Talemai M3"] = Location.new(vec3(-12800514, 55700257, 325207))	})
Locations.planets.Teoma = Location.new(vec3(80865536, 54665536, -934464))
Locations.planets.Thades = Location.new(vec3(29165536, 10865536, 65536))
Locations.planets.Thades:add(1, {	["Thades M1"] = Location.new(vec3(29214403, 10907080, 433861)),
									["Thades M2"] = Location.new(vec3(29404194, 10432766, 19553))		})

--end module
return setmetatable( Location, {
		__call = function(_, ...) return Location.new(...) end
	})
