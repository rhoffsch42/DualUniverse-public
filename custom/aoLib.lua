aolib = {}

aolib.atmoFuelMass = 4 -- kg/L
aolib.spaceFuelMass = 6 -- kg/L
aolib.atmoTankCapacity = 1600 -- L
aolib.spaceTankCapacity = 1600 -- L

function aolib.getFuelPercent(fuelTank, capacity, fuelMass)
    local mass = fuelTank.getItemsMass()
    local litres = mass / fuelMass
    return (litres / capacity) * 100
end
function aolib.roundStr(num, numDecimalPlaces)
	return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
end
function aolib.getAltitude()
	local alt = math.floor(core.getAltitude())
	local text = (alt == 0) and "space " or "atmo "
    return text .. alt .. "m"
end
function aolib.paragraphSized(str, size)
    local html = '<p style="font-size: ' .. size .. 'px;">' .. str .. '</p>'
    return html
end
function aolib.vector3ToHtml(vec, size)
    local html =   'r: ' .. aoRoundStr(vec[1], 3) .. '<br>'
    html = html .. 'f: ' .. aoRoundStr(vec[2], 3) .. '<br>'
	html = html .. 'u: ' .. aoRoundStr(vec[3], 3)
    return aoPsized(html, size)
end

return aolib