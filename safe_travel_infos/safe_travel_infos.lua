--[[
    Safe Travel Infos v1.3

    links order:
        1. core
        2. screen

    warning: this does not handle the safe zone

    dep:
        svghelper
        Basic Travel Infos
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
    --[[
        todo:
        calculate all heights for all routes, 12*11 too many? display only top 10?
        calculate the safe zone bubble
            need 4 points?
        detect if parabol trajectory is in the middle of another travel route
            give the best parabol route depending of the angle, with a set desto point
    ]]
    sti.color = "white"
    sti.dangerZonesHeights = {
        2*su, -- the detection range of a space radar, 100% sure to be caught by a scout warping
        4*su, -- an arbitrary margin
        6*su, -- another one 
    }
    sti.dangerZoneScreenHeight = 250 --px
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


    function    sti:setTextColor(color)
        if type(color) == "string" then
            self.color = color
            self.bti.color = color
        else
            system.print("Error: wrong type for argument #1 of sti:setTextColor(color), string required")
        end
    end

    function    sti:initBti(bti)
        self.bti = bti
        for k, v in pairs(self.bti.waypoints) do
            v.image = image_links[v.name]
        end
    end

    function    sti:updateSvghelper(svgh)
        svgh.base = svgh.base .. string.format([[
            <linearGradient  id="danger" x1="0%%" x2="0%%" y1="0%%" y2="100%%">
            <stop offset="5%%" stop-color="none" stop-opacity="1"/>
            <stop offset="10%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="30%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="40%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="60%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="70%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="90%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="95%%" stop-color="none" stop-opacity="1"/>
            <stop offset="100%%" stop-color="none" stop-opacity="1" />
            </linearGradient>]],
            self.dangerZonesColors[3],
            self.dangerZonesColors[2],
            self.dangerZonesColors[1],
            self.dangerZonesColors[1],
            self.dangerZonesColors[2],
            self.dangerZonesColors[3])
        svgh.base = svgh.base .. string.format([[
            <linearGradient  id="half-danger" x1="0%%" x2="0%%" y1="0%%" y2="100%%">
            <stop offset="10%%" stop-color="none" stop-opacity="1"/>
            <stop offset="20%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="70%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="90%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="100%%" stop-color="%s" stop-opacity="1"/>
            </linearGradient>]],
            self.dangerZonesColors[3],
            self.dangerZonesColors[2],
            self.dangerZonesColors[1],
            self.dangerZonesColors[1])
        svgh.base = svgh.base .. string.format([[
            <linearGradient  id="black-topdown" x1="0%%" x2="0%%" y1="0%%" y2="100%%">
            <stop offset="0%%" stop-color="none" stop-opacity="1"/>
            <stop offset="80%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="100%%" stop-color="none" stop-opacity="0" />
            </linearGradient>]], "none")
        svgh.base = svgh.base .. string.format([[
            <linearGradient  id="black-leftright" x1="0%%" x2="100%%" y1="0%%" y2="0%%">
            <stop offset="0%%" stop-color="none" stop-opacity="1"/>
            <stop offset="15%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="100%%" stop-color="none" stop-opacity="0.35" />
            </linearGradient>]], "none")
        svgh.base = svgh.base .. string.format([[
            <linearGradient  id="black-rightleft" x1="100%%" x2="0%%" y1="0%%" y2="0%%">
            <stop offset="0%%" stop-color="none" stop-opacity="1"/>
            <stop offset="15%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="100%%" stop-color="none" stop-opacity="0.35" />
            </linearGradient>]], "none")
    end


    function    sti:getSvgDangerZones(ypos)
        local svgcode = ""
        --gradient zones
        svgcode = svgcode .. string.format([[
            <rect x="0" y="%d" width="%d" height="%d" fill="url(#danger)" />
            ]], ypos-self.dangerZoneScreenHeight, g.w, self.dangerZoneScreenHeight*2)
        --base route (flashy red)
        svgcode = svgcode .. string.format([[
            <line x1="0" y1="%d" x2="%s" y2="%d" stroke="#cc0000" stroke-width="7" />
            ]], ypos, g.w, ypos)
        --warp tunnel
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d" font-size="%d" fill="#660000" text-anchor="middle">warp tunnel</text>
            ]], g.w/2, ypos+25, 20)
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
            g.w-offsetX, math.floor(ypos),  math.floor(planetsize.width))

        --image
        if true then
            local pcoef = 1.35
            local imageSize = {width=512,height=512}
            local svgViewbox = {x=0, y=0, width=512, height=512}
            local originViewbox = {}
            local destinationViewbox = {}
            local c = (sti.origin == 3 and 2 or 1) * pcoef
            originViewbox.x = math.floor(0+offsetX-planetsize.width/2 * c)
            originViewbox.y = math.floor(ypos-planetsize.height/2 * c)
            originViewbox.width = planetsize.width * c
            originViewbox.height = planetsize.height * c
            c = (sti.destination == 3 and 2 or 1) * pcoef
            destinationViewbox.x = math.floor(g.w-offsetX-planetsize.width/2 * c)
            destinationViewbox.y = math.floor(ypos-planetsize.height/2 * c)
            destinationViewbox.width = planetsize.width * c
            destinationViewbox.height = planetsize.height * c

            svgcode = svgcode .. svg.imageCut(self.bti.waypoints[self.origin].image, imageSize, originViewbox, svgViewbox)
            svgcode = svgcode .. svg.imageCut(self.bti.waypoints[self.destination].image, imageSize, destinationViewbox, svgViewbox)
        else -- or simple circle
            svgcode = svgcode .. string.format([[
                <circle cx="%d" cy="%d" r="%d" fill="%s" />
                <circle cx="%d" cy="%d" r="%d" fill="%s" />
            ]], offsetX, math.floor(ypos),  math.floor(planetsize.width/2), "#734d26",
                g.w-offsetX, math.floor(ypos),  math.floor(planetsize.width/2), "#734d26")
        end

        local pvpOrigin = offsetX + planetsize.width
        local pvpDestination = g.w - offsetX - planetsize.width
        return svgcode, pvpOrigin, pvpDestination
    end
    function    sti:getSvgDangerZoneForDirectTrajectory(shipHeight, shipPos, destination)
        local svgcode = ""
        local dangerDist = vec3(destination - shipPos):len()
        if shipHeight > self.dangerZonesHeights[1] then
            dangerDist = dangerDist * self.dangerZonesHeights[1] / shipHeight -- thales
        end
        dangerDist = math.max(0, dangerDist / su - 2.5)
        local screenPos = vec3(300, 980, 0)
        svgcode = svgcode .. string.format([[
            <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="darkgray" stroke-width="6" stroke-dasharray="12" />
            <text x="%d" y="%d" font-size="50" fill="%s">Direct trajectory, %s su in danger zone</text>
            <g font-size="50" fill="%s">
            <text x="%d" y="%d">Direct trajectory, %s su in</text></g>]],
            screenPos.x, screenPos.y-17, screenPos.x + 90, screenPos.y-17,
            screenPos.x + 110, screenPos.y, self.dangerZonesColors[1], round(dangerDist, 2),
            self.color,
            screenPos.x + 110, screenPos.y, round(dangerDist, 2))

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
        --yship = math.min(yship, 350)
        local ySu = math.min(yship, 350)

        svgcode = svgcode .. string.format([[
            <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="darkgray" stroke-width="3" />
            <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="darkgray" stroke-width="6" stroke-dasharray="12" />
            <circle cx="%d" cy="%d" r="12" fill="black" stroke="white" stroke-width=4 />
            <text x="%d" y="%d" font-size="50" fill="white" stroke="black" stroke-width="20" text-anchor="end">%s</text>]],
            xfloor, ypos, xfloor, ypos-yship,
            xfloor, ypos-yship, x2, ypos,
            xfloor, ypos-yship,
            xfloor-30, ypos-ySu+30, (round(shipHeight/su, 2).." su ↥"))

        --danger zone if going right to desto
        svgcode = svgcode .. self:getSvgDangerZoneForDirectTrajectory(shipHeight, shipPos, destination)
        return svgcode
    end

    function    sti:getSvgBti(pos)
        local svgcode = ""
        svgcode = svgcode .. string.format([[
            <rect x="%d" y="%d" width="%d" height="%d" stroke="none" fill="%s" stroke-width="3" stroke-dasharray="4"/>]],
            0, 0, g.w, 350, "url(#black-topdown)")
        svgcode = svgcode .. self.bti:getSvgcode(pos, self.bti.waypoints[self.destination])
        return svgcode
    end

    function    sti:getSvgcode()
        local svgcode = ""
        local ypos = math.floor(g.h*0.60)
        svgcode = svgcode .. self:getSvgDangerZones(ypos)
        local svgtmp, x1, x2 = self:getSvgPlanetZones(ypos)
        svgcode = svgcode .. svgtmp
        svgcode = svgcode .. self:getSvgShip(ypos, x1, x2)
        svgcode = svgcode .. self:getSvgBti(vec3(30, 75, 0))

        return svgcode
    end

    function    sti:calculateAllHeights()
        local shipPos = vec3(core.getConstructWorldPos())
        local heights = {} -- array of array for 2d matrice halved (x:y = y:x and x=y is impossible)
        for j, body in ipairs(self.bti.waypoints) do
            heights[i] = {}
            local origin = vec3(body)
            for i, body in ipairs(self.bti.waypoints) do
                if (i ~= j) then
                    local destination = vec3(self.bti.waypoints[i])
                    local travel = destination - origin
                    local floorVec = (shipPos - origin):project_on(travel)
                    local floorPos = origin + floorVec
                    local shipHeight = (shipPos - floorPos):len()
                    heights[j][i] = shipHeight
                end
            end
        end
    end

    return sti
end

function    requirePlanetSelector()
    local ps = {}
    ps.color = "darkgray"
    ps.y = 325
    ps.fontsize = 45
    ps.indent = 10
    
    ps.cursorPos = {x=0,y=0}
    ps.buttons = {}
    ps.planetSelectionOrigin = ButtonGroup()
    ps.planetSelectionDestination = ButtonGroup()
    ps._destinationIndexMap = {}
    ps._originIndexMap = {}

    function    ps:initPlanets(planets)
        local size = {width=175,height=50}
        local ftsize = 35
        for i, v in ipairs(sti.bti.waypoints) do
            local b1 = Button(v.name, vec3(self.indent,self.y+(size.height+4)*(i-1),0), size, ftsize)
            b1.buttonGroup = self.planetSelectionOrigin
            b1.active = true
            b1.canToggle = true
            self.planetSelectionOrigin:add(b1)
            b1.onClick = selectOrigin
            table.insert(self.buttons, b1)
            self._originIndexMap[v.name] = i

            local b2 = Button(v.name, vec3(g.w-self.indent-size.width,self.y+(size.height+4)*(i-1),0), size, ftsize)
            b2.buttonGroup = self.planetSelectionDestination
            b2.active = true
            b2.canToggle = true
            self.planetSelectionDestination:add(b2)
            b2.onClick = selectDestination
            table.insert(self.buttons, b2)
            self._destinationIndexMap[v.name] = i
        end
    end

    function    ps:update()
        local pos = {
            x = math.floor(screen.getMouseX()*g.w),
            y = math.floor(screen.getMouseY()*g.h)
        }
        if (pos.x ~= self.cursorPos.x) or (pos.y ~= self.cursorPos.y) then
            self.cursorPos = pos
            local changes = Button.updateButtonsStates(self.buttons, self.cursorPos)
            if changes then
                g.needRefresh = true
            end
        end
    end

    function    ps:getSvgcode()
        local svgcode = ""
        svgcode = svgcode .. string.format([[
            <rect x="%d" y="%d" width="%d" height="%d" stroke="none" fill="%s" stroke-width="3" stroke-dasharray="4"/>]],
            0, self.y, 190, g.h-self.y, "url(#black-leftright)")
        svgcode = svgcode .. string.format([[
            <rect x="%d" y="%d" width="%d" height="%d" stroke="none" fill="%s" stroke-width="3" stroke-dasharray="4"/>]],
            g.w-190, self.y, 190, g.h-self.y, "url(#black-rightleft)")
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d" font-size="%d" fill="%s" stroke="black" stroke-width="10">%s</text>,
            <text x="%d" y="%d" font-size="%d" fill="%s" stroke="black" stroke-width="10" text-anchor="end">%s</text>]],
            self.indent, self.y-self.indent, self.fontsize, self.color, "Origin:",
            g.w-self.indent, self.y-self.indent, self.fontsize, self.color, "Destination:")
        for i, v in ipairs(self.buttons) do
            svgcode = svgcode .. v:draw()
        end
        return svgcode
    end

    function    ps:tryClick(x, y)
        Button.tryClickOnButtons(self.buttons, {x=x, y=y})
    end

    return ps
end

--button funcs
function    selectOrigin()
    local b = selector.planetSelectionOrigin.selected[1]
    if b then 
        local i = selector._originIndexMap[b.text]
        sti.origin = i
        if sti.destination == sti.origin then
            local p = sti.origin ~= 1 and 1 or 2
            selector.planetSelectionDestination[p]:_click()
        end
        g.needRefresh = true
    else -- clicked on the current selection, just reselect it (= always 1 selected)
        selector.planetSelectionOrigin[sti.origin]:_click()
    end
end
function    selectDestination()
    local b = selector.planetSelectionDestination.selected[1]
    if b then 
        local i = selector._destinationIndexMap[b.text]
        sti.destination = i
        if sti.origin == sti.destination then
            local p = sti.destination ~= 1 and 1 or 2
            selector.planetSelectionOrigin[p]:_click()
        end
        g.needRefresh = true
    else -- unselected the current selection, just reselect it (always 1 selected)
        selector.planetSelectionDestination[sti.destination]:_click()
    end
end
