# example

![Example](https://i.imgur.com/YLz5350.png)

```lua
cam = require "cam"

-- world pos of what you want to project on screen
local arkship = vec3(-10743, 111962, -61973)
local district1 = vec3(-21383, 105910, -60863)
local district2 = vec3(1834, 114980, -73641)
local district3 = vec3(1561, 102669, -52833)
local district4 = vec3(-18947, 110283, -67776)
local district5 = vec3(5964, 106644, -58626)
local district6 = vec3(-21753, 100158, -52566)
local district7 = vec3(-18908, 115397, -78647)
local district8 = vec3(-10973, 117198, -80254)
local district9 = vec3(5983, 110488, -65343)
local district10 = vec3(-5349, 101504, -52833)

-- the cam uses vec3
cam.fov = 110 -- the same as you have in the game settings
cam:updateScreen()
cam.transform.pos = vec3(core.getConstructWorldPos())
cam.transform.target = vec3(arkship)
cam.transform.vertical = -vec3(core.getWorldVertical())
cam:updateVectors()

--projected on screen
local projectedPoints = {
    arkship = cam:projectPoint(arkship),
    district1 = cam:projectPoint(district1),
    district2 = cam:projectPoint(district2),
    district3 = cam:projectPoint(district3),
    district4 = cam:projectPoint(district4),
    district5 = cam:projectPoint(district5),
    district6 = cam:projectPoint(district6),
    district7 = cam:projectPoint(district7),
    district8 = cam:projectPoint(district8),
    district9 = cam:projectPoint(district9),
    district10 = cam:projectPoint(district10)
}

function	drawPoints(points)
    local svgcode = ""
    for k, v in pairs(points) do
        svgcode = svgcode .. string.format([[
            <circle cx="%f" cy="%f" r="5" stroke="white" fill="black" />
            <text x="%f" y="%f" fill="black" stroke="white" stroke-width="2">%s</text> ]],
            v.x, v.y,
            v.x+10, v.y, k)
    end
    return svgcode
end

system.showScreen(1)
system.setScreen([[
    <svg class="svg"
    width="1920" height="1080"
    viewBox="0 0 1920 1080"
    xmlns="http://www.w3.org/2000/svg" 
    xmlns:xlink="http://www.w3.org/1999/xlink"> 
    <style>
    .svg {
    	position:absolute;
    	left: 0;
    	top: 0;
    	height: 100vh;
    	width: 100vw;
    }
    </style>
    ]] .. drawPoints(projectedPoints) .. "</svg>")
```
