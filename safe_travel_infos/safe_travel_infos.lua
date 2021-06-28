--[[
    STI v1.2

    warning: this does not handle the safe zone

    dep:
        svghelper
        BTI + brake time

    todo:
        calculate the safe zone bubble
            need 4 points?
        detect if parabol trajectory is in the middle of another travel route
            give the best parabol route depending of the angle, with a set desto point
]]

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local image_links = {
    Generic_Moon = "assets.prod.novaquark.com/20368/f410e727-9d4d-4eab-98bf-22994b3fbdcf.png",
    Sun = "assets.prod.novaquark.com/20368/0936494e-9b3d-4d60-9ea0-d93a3f3e29cd.png",
    Alioth = "assets.prod.novaquark.com/20368/954f3adb-3369-4ea9-854d-a14606334152.png",
    Alioth_bis = "assets.prod.novaquark.com/20368/b83225ed-fb96-404c-8c91-86ac15dfbbec.png",
    Sanctuary = "assets.prod.novaquark.com/20368/1a70dbff-24bc-44cb-905c-6d375d9613b8.png",
    Feli = "assets.prod.novaquark.com/20368/da91066c-b3fd-41f4-8c01-26131b0a7841.png",
    Ion = "assets.prod.novaquark.com/20368/91d10712-dc51-4b73-9fc0-6f07d96605a6.png",
    Madis = "assets.prod.novaquark.com/20368/46d57ef4-40ee-46ca-8cc5-5aee1504bbfe.png",
    Jago = "assets.prod.novaquark.com/20368/7fca8389-6b70-4198-a9c3-4875d15edb38.png",
    Lacobus = "assets.prod.novaquark.com/20368/cb67a6a4-933c-4688-a637-898c89eb5b94.png",
    Sicari = "assets.prod.novaquark.com/20368/f6e2f801-075f-4ccd-ab94-46d060517e8f.png",
    Sinnen = "assets.prod.novaquark.com/20368/54a99084-7c2b-461b-ab1f-ae4229b3b821.png",
    Symeon = "assets.prod.novaquark.com/20368/97940324-f194-4e03-808d-d71733ad545a.png",
    Talemai = "assets.prod.novaquark.com/20368/f68628d9-3245-4d76-968e-ad9c63a19c19.png",
    Teoma = "assets.prod.novaquark.com/20368/5a01dd8c-3cf8-4151-99a2-83b22f1e7249.png",
    Thades = "assets.prod.novaquark.com/20368/59f997a2-bcca-45cf-aa35-26e0e41ed5c1.png",
}
local su = 200000

function    requireSafeTravelInfos()
    local sti = {}
    sti.dangerZonesHeights = {
        2*su, -- the detection range of a space radar, 100% sure to be caught by a scout warping
        4*su, -- an arbitrary margin
        6*su, -- another one 
    }
    sti.dangerZonesColors = {"#ff4d4d", "#ff8533", "#ffff66"}
    sti.planetaryProtection = 2.5*su
    sti.safeRouteAngle = 20 --degree
    sti.bti = nil
    sti.origin = 1
    sti.destination = 2
    --[[
        1 Alioth
        2 Madis
        3 Thades
        4 Talemai
        5 Feli
        6 Sicari
        7 Sinnen
        8 Teoma
        9 Jago
        10 Symeon
        11 Ion
        12 Lacobus
    ]]

    sti.dangerZoneScreenHeight = 250 --px

    function    sti:initBti(bti)
        self.bti = bti
        for k, v in pairs(self.bti.waypoints) do
            v.image = image_links[v.name]
        end
    end

    function    sti:getSvgDangerZones(ypos)
       local svgcode = ""
       --[=[
       --large zone (yellow)
       svgcode = svgcode .. string.format([[
        <rect x="0" y="%d" width="1920" height="%d" fill="%s"/>
       ]], ypos-400, 400*2, self.dangerZonesColors[3])
       --medium zone (orange)
       svgcode = svgcode .. string.format([[
        <rect x="0" y="%d" width="1920" height="%d" fill="%s"/>
       ]], ypos-250, 250*2, self.dangerZonesColors[2])
       ]=]

       --gradient zones
       svgcode = svgcode .. string.format([[
        <rect x="0" y="%d" width="1920" height="%d" fill="url(#danger)" />
       ]], ypos-self.dangerZoneScreenHeight, self.dangerZoneScreenHeight*2)
       
       --medium zone (red)
       --[=[
       svgcode = svgcode .. string.format([[
        <rect x="0" y="%d" width="1920" height="%d" fill="%s"/>
       ]], ypos-75, 75*2, self.dangerZonesColors[1])
       ]=]

       --base route (flashy red)
       svgcode = svgcode .. string.format([[
        <line x1="0" y1="%d" x2="1920" y2="%d" stroke="red" stroke-width="7" />
        ]], ypos, ypos)

        return svgcode
    end
    function    sti:getSvgPlanetZones(ypos)
        local svgcode = ""
        local planetsize = {width=300, height=300}
        local offsetX = 100
        
        --planetary protection
        svgcode = svgcode .. string.format([[
            <circle cx="%d" cy="%d" r="%d" fill="black" />
            <circle cx="%d" cy="%d" r="%d" fill="black" />
        ]], offsetX, math.floor(ypos),  math.floor(planetsize.width),
            1920-offsetX, math.floor(ypos),  math.floor(planetsize.width))

        --image
        local imageSize = {width=512,height=512}
        local svgViewbox = {x=0, y=0, width=512, height=512}
        local screnViewbox = {
            x = math.floor(0+offsetX-planetsize.width/2),
            y = math.floor(ypos-planetsize.height/2),
            width = planetsize.width,
            height = planetsize.height
        }
        svgcode = svgcode .. svg.imageCut(self.bti.waypoints[self.origin].image, imageSize, screnViewbox, svgViewbox)
        screnViewbox.x = 1920-offsetX-planetsize.width/2
        svgcode = svgcode .. svg.imageCut(self.bti.waypoints[self.destination].image, imageSize, screnViewbox, svgViewbox)

        local pvpOrigin = offsetX + planetsize.width
        local pvpDestination = 1920 - offsetX - planetsize.width
        return svgcode, pvpOrigin, pvpDestination
    end
    function    sti:getSvgDangerZoneForDirectTrajectory(shipHeight, shipPos, destination)
        local svgcode = ""
        local dangerDist = vec3(destination - shipPos):len()
        if shipHeight > self.dangerZonesHeights[1] then
            dangerDist = dangerDist * self.dangerZonesHeights[1] / shipHeight -- thales
        end
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d" font-size="50" fill="white">Distance traveled in danger zone</text>
            <text x="%d" y="%d" font-size="50" fill="white">for direct trajectory : %s su</text>]],
            975, 50,
            975, 100, round(dangerDist / 200000 - 2.5, 2))

        return svgcode
    end
    function    sti:getSvgShip(ypos, x1, x2)
        local svgcode = ""

        local origin = vec3(self.bti.waypoints[self.origin])
        local destination = vec3(self.bti.waypoints[self.destination])
        local travel = destination - origin
        local shipPos = vec3(core.getConstructWorldPos())
        local floorVec = (shipPos - origin):project_on(travel)
        local percent = floorVec:len() / travel:len()
        local floorPos = origin + floorVec
        local shipHeight = (shipPos - floorPos):len()
        
        --[[
            debug.origin = self.bti.waypoints[self.origin].name
            debug.destination = self.bti.waypoints[self.destination].name
            debug.percent = percent
            debug.shipHeight = shipHeight
        ]]

        local xfloor = math.floor(x1 + percent * (x2 - x1))
        local yship = math.floor(self.dangerZoneScreenHeight * shipHeight / self.dangerZonesHeights[3])
        yship = math.min(yship, 350)

        svgcode = svgcode .. string.format([[
            <circle cx="%d" cy="%d" r="12" fill="black" stroke="white" stroke-width=4 />
            <text x="%d" y="%d" font-size="50" fill="white" stroke="black" stroke-width="20">%s</text>
            <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="darkgray" stroke-width="3" />]],
            xfloor, ypos-yship,
            xfloor+30, ypos-yship, (round(shipHeight/200000, 2).." su"),
            xfloor, ypos, xfloor, ypos-yship)

        --danger zone if going right to desto
        svgcode = svgcode .. self:getSvgDangerZoneForDirectTrajectory(shipHeight, shipPos, destination)
        return svgcode
    end

    function    sti:getSvgcode()
        local svgcode = ""
        local ypos = math.floor(1080*0.65)
        svgcode = svgcode .. self:getSvgDangerZones(ypos)
        local svgtmp, x1, x2 = self:getSvgPlanetZones(ypos)
        svgcode = svgcode .. svgtmp
        svgcode = svgcode .. self:getSvgShip(ypos, x1, x2)
        svgcode = svgcode .. self.bti:getSvgcode(nil, self.bti.waypoints[self.destination])

        return svgcode
    end

    return sti
end

