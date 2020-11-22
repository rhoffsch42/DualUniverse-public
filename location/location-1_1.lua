local function tablecpy(dst, src)
	--copy existing src key/value in dst (not a deep copy)
	for k, v in pairs(src) do
		dst[k] = v
	end
end
local vec3  = require('cpml/vec3')
local su = 200000
local default_threshold = 5 * su
local Location = {}
Location.__index = Location
Location._list = {} -- contains all locations for easy access

function Location.new(name, pos, key)
	local loc = {}
	loc.name = name or "noname"
	loc.pos = vec3(pos or vec3())
	loc.key = key
	loc[1] = {}
	loc.childrenThreshold = {default_threshold}
	loc = setmetatable(loc, Location)
	table.insert(Location._list, loc)
	return loc
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
	self.childrenThreshold[group_index] = threshold or default_threshold
end


--build the Location(s) with a set of data (can be unsorted)
--[[
example address = {1, "Helios", 1, "Ion", 2}
ie {group, location, group, location, ...}
groups have odd index
locations have even index
]]
local function	buildLocation(root, data, locaKey)
	local dst = root
	local lastLoca = root
	local entry = data[locaKey]
	local address = entry.address

	for i, key in ipairs(address) do
		if dst[key] == nil then -- group
			if (i%2) == 1 then
				dst:setGroupThreshold(key) -- will create the group with default threshold
			else -- location
				buildLocation(root, data, key)
			end
		end
		if (i%2) == 0 then -- key should be a location
			lastLoca = dst[key]
		end
		dst = dst[key]
	end
	--after that, all of the Locations in the address should be created
	-- + if #address fini par une loca sans index, faire index 1 par defaut
	if (dst[entry.key] == nil) then
		local newLoca = Location(entry.name, entry.pos, entry.key)
		tablecpy(newLoca, entry.params or {})
		lastLoca:add(address[#address], {
				[entry.key] = newLoca
			})
	end
end

--[[
	--example for a station on Madis M1 group 2
	{
		["station 1"] = {
			key = "My Station",
			name = "My Station",
			pos = {...}, -- vec3() format
			address = {1, "Helios", 1,"Madis", 1, "Madis M1", 2} 
		},
	}
]]
-- check atlas3d for more data format (params are optional)
function	Location:buildLocations(data)
	local i = 0
	for k, loca in pairs(data) do
		buildLocation(self, data, k)
		i = i + 1
	end
	return i
end

return setmetatable( Location, {
		__call = function(_, ...) return Location.new(...) end
	})
