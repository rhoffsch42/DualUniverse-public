--[[
    Safe Travel Infos v1.7

    links order:
        1. core
        2. screen
        3. screen 2 (optionnal)

    dep:
        svghelper
        Basic Travel Infos
]]
local min, max, floor, sqrt, abs = math.min, math.max, math.floor, math.sqrt, math.abs
local function roundStr(num, numDecimalPlaces)
    return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
end
local function    fancy_sukm(distance, thresholds)
    thresholds = thresholds or {km=200000, m=10000}
    --display in su/km/m depending on its distance
    if (distance < thresholds.m) then
        distance = roundStr(distance, 0) .. " m"
    elseif (distance < thresholds.km) then
        distance = roundStr(distance / 1000, 1) .. " km"
    else
        distance = roundStr(distance / 200000, 2) .. " su"
    end
    return distance
end
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return floor(num * mult + 0.5) / mult
end
local function interSpherePlan(sphere, plan)
    local circle = {}
    circle.center = sphere.center:project_on_plane(plan)
    circle.r = 0
    local translation = circle.center - sphere.center
    local dist2 = translation:len2()
    local r2 = sphere.r*sphere.r
    if dist2 < r2 then
        circle.r = sqrt(r2 - dist2)
    end
    return circle
end

local svglib = {
    pvp = [[
        <svg id="pvp" x="0" y="0" width="250" height="250"
        xmlns="http://www.w3.org/2000/svg"
        xmlns:xlink="http://www.w3.org/1999/xlink" 
             viewBox="0 4 22.778 22.778" >
            <g>
                <polygon points="17.931,15.433 18.83,10.328 14.412,12.625 12.438,8.625 10.468,12.616 6.05,10.269 
                    6.912,15.437 2.098,16.137 4.685,18.66 5.68,18.66 3.59,16.622 7.713,16.021 6.967,11.542 10.773,13.566 12.438,10.193 
                    14.103,13.568 17.903,11.593 17.122,16.017 21.285,16.622 19.196,18.66 20.19,18.66 22.778,16.137 		"/>
                <polygon points="16.322,16.545 16.95,12.977 13.84,14.594 12.427,11.732 11.02,14.583 7.917,12.935 
                    8.518,16.548 5.119,17.042 6.777,18.66 8.766,18.66 8.102,18.012 10.121,17.718 9.748,15.481 11.631,16.483 12.427,14.87 
                    13.222,16.479 15.095,15.507 14.704,17.714 16.752,18.012 16.088,18.66 18.076,18.66 19.737,17.042 		"/>
                <path d="M12.438,17.909c-0.503,0-0.91,0.408-0.91,0.911h1.822C13.35,18.316,12.942,17.909,12.438,17.909z"
                    />
                <polygon points="17.915,3.958 14.888,10.515 15.382,10.72 "/>
                <polygon points="5.694,14.399 0,9.958 5.348,14.809 "/>
                <polygon points="21.633,11.866 19.072,14.083 19.453,14.458 "/>
                <polygon points="10.303,10.5 8.866,7.43 9.801,10.688 "/>
                <text x="12.2" y="25.5" font-size="8" text-anchor="middle">PVP</text>
            </g>
        </svg>
    ]],
    safe = [[
        <svg id="safe" x="0" y="0" width="160" height="160"
        xmlns="http://www.w3.org/2000/svg"
        xmlns:xlink="http://www.w3.org/1999/xlink"
             viewBox="0 0 32 32" >
             <path d="M29.6,5.2C29.3,5,29,4.9,28.7,5.1c-4.3,1.4-8.7,0.3-12-2.8c-0.4-0.4-1-0.4-1.4,0c-3.3,3.1-7.7,4.2-12,2.8
            C3,4.9,2.7,5,2.4,5.2S2,5.7,2,6c0,15.7,6.9,20.9,13.6,23.9C15.7,30,15.9,30,16,30s0.3,0,0.4-0.1C23.1,26.9,30,21.7,30,6
            C30,5.7,29.8,5.4,29.6,5.2z"/>
        </svg>
    ]]
}

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
    sti.__index = sti
    --[[
        todo:
        ship trajectory simulation (screen 3?):
            slider for the desto dist , or the remaining dist in the ship trajectory until it hit the destination wall
            autoplay, repeat
        detect if parabol trajectory is in the middle of another travel route
            give the best parabol route depending of the angle, with a set desto point
    ]]
    sti.experimental = false
    sti.color = "white"
    sti.dangerZonesHeights = {
        2*su, -- the detection range of a space radar, 100% sure to be caught by a scout warping
        4*su, -- an arbitrary margin
        6*su, -- another one 
    }
    sti.dangerZoneScreenHeight = 250 --px
    sti.dangerZonesColors = {"#ff4d4d", "#ff8533", "#ffff66"}
    sti.planetaryProtection = 2.5*su
    sti.bti = nil
    sti.origin = 1
    sti.destination = 2
    sti.safeZone = { -- a sphere
        center = vec3(13771471, 7435803, -128971), -- from Archaegeo
        r = 18000000, -- 90su
    }
    sti.shipPos = vec3(core.getConstructWorldPos())

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
        svgh.style = svgh.style .. [[text {font-family:sans-serif;}]]
        for k, v in pairs(svglib) do
            svgh.base = svgh.base .. v
        end
        svgh.base = svgh.base .. string.format([[
            <linearGradient  id="danger" x1="0%%" x2="0%%" y1="0%%" y2="100%%">
            <stop offset="5%%" stop-color="none" stop-opacity="0"/>
            <stop offset="10%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="30%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="40%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="60%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="70%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="90%%" stop-color="%s" stop-opacity="1"/>
            <stop offset="95%%" stop-color="none" stop-opacity="0"/>
            <stop offset="100%%" stop-color="none" stop-opacity="0" />
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

    function    sti.getHeight(shipPos, origin, destination)
        local travel = destination - origin
        local floorVec = (shipPos - origin):project_on(travel)
        local floorPos = origin + floorVec
        local heightVec = shipPos - floorPos
        return heightVec:len(), heightVec
    end
    function    sti:getSvgDangerZones(ypos, x1, x2)
        local svgcode = ""
        --gradient zones
        svgcode = svgcode .. string.format([[
            <rect x="%d" y="%d" rx="%d" ry="%d"
            width="%d" height="%d" fill="url(#danger)" />]],
            x1-5, ypos-self.dangerZoneScreenHeight, 50, self.dangerZoneScreenHeight,
            x2-x1+10, self.dangerZoneScreenHeight*2)
        --warp tunnel (flashy red)
        svgcode = svgcode .. string.format([[
            <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="#cc0000" stroke-width="7" />]],
            x1, ypos, x2, ypos)
        --warp tunnel text
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d" font-size="%d" fill="#660000" text-anchor="middle">warp tunnel</text>]],
            (x1+x2)/2, ypos+25, 20)
        return svgcode
    end
    function    sti:getSvgPlanetZones(ypos, x1, x2)
        local svgcode = ""
        local planetsize = {width=300, height=300}
        local offsetX = 100
        
        --planetary protection
        -- svgcode = svgcode .. string.format([[
        --     <circle cx="%d" cy="%d" r="%d" fill="black" />
        --     <circle cx="%d" cy="%d" r="%d" fill="black" />
        -- ]], offsetX, floor(ypos),  floor(planetsize.width),
        --     g.w-offsetX, floor(ypos),  floor(planetsize.width))

        --image
        if true then
            local pcoef = 1.35
            local imageSize = {width=512,height=512}
            local svgViewbox = {x=0, y=0, width=512, height=512}
            local originViewbox = {}
            local destinationViewbox = {}
            local c = (sti.origin == 3 and 2 or 1) * pcoef
            originViewbox.x = floor(0+offsetX-planetsize.width/2 * c)
            originViewbox.y = floor(ypos-planetsize.height/2 * c)
            originViewbox.width = planetsize.width * c
            originViewbox.height = planetsize.height * c
            c = (sti.destination == 3 and 2 or 1) * pcoef
            destinationViewbox.x = floor(g.w-offsetX-planetsize.width/2 * c)
            destinationViewbox.y = floor(ypos-planetsize.height/2 * c)
            destinationViewbox.width = planetsize.width * c
            destinationViewbox.height = planetsize.height * c

            --resized for bg
            if true then
                c = (sti.origin == 3 and 1.5 or 1)
                originViewbox.width = floor(g.w * 0.4 * c)
                originViewbox.height = floor(g.w * 0.4 * c)
                originViewbox.x = x1 - originViewbox.width/2
                originViewbox.y = ypos - originViewbox.height/2
                originViewbox.y = floor(originViewbox.height*0.25) - originViewbox.height/2
                c = (sti.destination == 3 and 1.5 or 1)
                destinationViewbox.width = floor(g.w * 0.4 * c)
                destinationViewbox.height = floor(g.w * 0.4 * c)
                destinationViewbox.x = x2 - destinationViewbox.width/2
                destinationViewbox.y = ypos - destinationViewbox.height/2
                destinationViewbox.y = floor(destinationViewbox.height*0.25) - destinationViewbox.height/2
            end
            --end
            svgcode = svgcode .. [[<g opacity="0.80">]]
            svgcode = svgcode .. svg.imageCut(self.bti.waypoints[self.origin].image, imageSize, originViewbox, svgViewbox)
            svgcode = svgcode .. svg.imageCut(self.bti.waypoints[self.destination].image, imageSize, destinationViewbox, svgViewbox)
            svgcode = svgcode .. [[</g>]]
        else -- or simple circle
            svgcode = svgcode .. string.format([[
                <circle cx="%d" cy="%d" r="%d" fill="%s" />
                <circle cx="%d" cy="%d" r="%d" fill="%s" />
            ]], offsetX, floor(ypos),  floor(planetsize.width/2), "#734d26",
                g.w-offsetX, floor(ypos),  floor(planetsize.width/2), "#734d26")
        end

        -- local pvpOrigin = offsetX + planetsize.width
        -- local pvpDestination = g.w - offsetX - planetsize.width
        return svgcode--, pvpOrigin, pvpDestination
    end
    function    sti:getSvgDangerZoneForDirectTrajectory(ypos, shipHeight, shipPos, destination)
        local dangerDist = vec3(destination - shipPos):len()
        if shipHeight > self.dangerZonesHeights[1] then
            dangerDist = dangerDist * self.dangerZonesHeights[1] / shipHeight -- thales
        end
        dangerDist = max(0, dangerDist / su - 2.5)
        local screenPos = vec3(300, ypos + 280, 0)

        local svgcode = ""
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
    function    sti:getSvgShipHeight(ypos, x1, x2)--and safe zone projection on the plan({origin, destination, shipPos})
        --todo?: use the cam object to free all projection code, place it depending of the travel route and ship pos&height plan
        local origin = vec3(self.bti.waypoints[self.origin])
        local destination = vec3(self.bti.waypoints[self.destination])
        local travelVec = destination - origin
        local travelDist = travelVec:len()
        local floorVec = (self.shipPos - origin):project_on(travelVec)
        local sign = (floorVec:dot(travelVec) > 0) and 1 or -1
        local percent = floorVec:len() / travelDist * sign --travel scale
        local floorPos = origin + floorVec
        local shipHeightVec = self.shipPos - floorPos
        local shipHeight = shipHeightVec:len()
        --shipHeight = sti.getHeight(self.shipPos, origin, destination)

        local warpLineScreenLen = x2 - x1
        local xfloor = floor(x1 + percent * warpLineScreenLen)
        local yship = floor(self.dangerZoneScreenHeight * shipHeight / self.dangerZonesHeights[3])
        local ySu = min(yship, 350)

        local svgcode = ""
        --planet on warp line
        svgcode = svgcode .. string.format([[
            <circle cx="%d" cy="%d" r="%d" fill="%s" />
            <circle cx="%d" cy="%d" r="%d" fill="%s" />]],
            x1-25, ypos, 38, self.color,
            x2+25, ypos, 38, self.color)

        --ship height and pos
        svgcode = svgcode .. string.format([[
            <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="darkgray" stroke-width="3" />
            <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="darkgray" stroke-width="6" stroke-dasharray="12" />
            <circle cx="%d" cy="%d" r="12" fill="black" stroke="white" stroke-width=4 />
            <text x="%d" y="%d" font-size="50" fill="white" stroke="black" stroke-width="20" text-anchor="end">%s</text>]],
            xfloor, ypos, xfloor, ypos-yship,
            x2, ypos, xfloor, ypos-yship,
            xfloor, ypos-yship,
            min(x2+35,max(x1+180, xfloor-30)), ypos-ySu+30, (round(shipHeight/su, 2).." su ↥"))

        --text : danger zone if going right to desto
        svgcode = svgcode .. self:getSvgDangerZoneForDirectTrajectory(ypos, shipHeight, self.shipPos, destination)
        
        -- safe zone bubble
        local svgSafeZone = ""
        if self.experimental then
            --coordinate system of the current travel route on screen
            local coosys = {origin=origin, x=travelVec:normalize(), y=shipHeightVec:normalize()}
            coosys.z = (coosys.x:cross(coosys.y)):normalize()
            local scale = {x = travelDist / warpLineScreenLen, y = self.dangerZonesHeights[3] / self.dangerZoneScreenHeight}

            -- manual recon
            -- local recon = {}
            -- for yy=1, 10, 1 do
            --     recon[yy] = {}
            --     for xx=5, 35, 1 do
            --         local fakepos = coosys.origin + coosys.x * xx * su * 2.5
            --                                + coosys.y * yy * su * 1
            --         local safefrontierDist = self.safeZone.r - (fakepos - self.safeZone.center):len()
            --         local color = (safefrontierDist > 0) and "green" or "red"
            --         svgSafeZone = svgSafeZone .. string.format([[
            --             <circle cx="%d" cy="%d" r="5" fill="%s" />]],
            --             floor(x1 + (xx * su * 2.5 / scale.x)),
            --             floor(ypos - (yy * su / scale.y)),
            --       --      floor(x1 + xx / scale.x),
            --       --      floor(ypos + yy / scale.y),
            --             color)
            --     end
            -- end

            local safeZoneCircle = interSpherePlan({center=self.safeZone.center - coosys.origin, r=self.safeZone.r}, coosys.z)-- relative to the origin of the coosys
            if safeZoneCircle.r > 0 then
                local proj = {-- projected in the coosys and scaled to the screen
                    x = x1 + safeZoneCircle.center:dot(coosys.x) / scale.x,
                    y = ypos - safeZoneCircle.center:dot(coosys.y) / scale.y,
                }
                svgSafeZone = svgSafeZone .. string.format([[
                    <ellipse cx="%d" cy="%d" rx="%d" ry="%d" fill-opacity="0.15" fill="#33cc33" stroke="#33cc33" stroke-width="3" />]],
                    floor(proj.x), floor(proj.y), floor(safeZoneCircle.r / scale.x), floor(safeZoneCircle.r / scale.y))
            end
        end
        return svgSafeZone .. svgcode
    end
    function    sti:getSvgBti(screenPos)
        local svgcode = ""
        -- svgcode = svgcode .. string.format([[
        --     <rect x="%d" y="%d" width="%d" height="%d" stroke="none" fill="%s" stroke-width="3" stroke-dasharray="4"/>]],
        --     0, 0, g.w, 500, "url(#black-topdown)")
        svgcode = svgcode .. self.bti:getSvgcode(screenPos, self.bti.waypoints[self.destination])
        return svgcode
    end

    function    sti:initHeightsMatrice(screenPos) --need bti
        self.matrice = {
            heights = sti.getHeightsFor(self.shipPos, self.bti.waypoints),
            buttons = {},
            buttonsMatrice = {},
        }
        local count = #self.bti.waypoints
        local pad = 0
        local s = 32
        self.matrice.rect = rect(screenPos.x, screenPos.y, (s+pad)*count, (s+pad)*count)

        for j = 1, count do
            self.matrice.buttonsMatrice[j] = {}
            for i = j+1, count do
                local b = Button(nil, screenPos + vec3((i-1)*(s+pad), (j-1)*(s+pad), 0), {width=s,height=s})
                b.selected = false
                b.canToggle = false
                b.showHintWhenHovered = true
                b.hint = self.bti.waypoints[j].name .. "⇔" .. self.bti.waypoints[i].name --⇔
                b.color = "green"
                self.matrice.buttonsMatrice[j][i] = b
                table.insert(self.matrice.buttons, b)
            end
        end
    end
    function    sti:getHeightColor(height)
        for i, h in ipairs(self.dangerZonesHeights) do 
            if height < h then
                return self.dangerZonesColors[i]
            end
        end
        return "none"
    end
    function    sti.getHeightsFor(shipPos, waypoints)
        local heights = {} -- array of array for 2d matrice halved (x:y = y:x and x=y is impossible)
        local bodyCount = #waypoints
        for j = 1, bodyCount do
            heights[j] = {}
            heights[j][j] = -1 -- should never use this entry
            local origin = vec3(waypoints[j])
            for i = j+1, bodyCount do
                local destination = vec3(waypoints[i])
                heights[j][i] = sti.getHeight(shipPos, origin, destination)
            end
        end
        return heights
    end
    function    sti:updateMatriceButtonsStates(cursorPos)
        local changes = false
        if isWithinRect(self.matrice.rect, cursorPos) then
            changes = Button.updateButtonsStates(self.matrice.buttons, cursorPos)
        else--manual reset of hover cauz out of the box
            for i, b in ipairs(self.matrice.buttons) do
                if b.hovered then
                    b.hovered = false
                    changes = true
                end
            end
        end
        if changes then
            g.needRefresh = true
        end
    end
    function    sti:getSvgMatrice()
        local svgcode = ""
        for i, b in ipairs(self.matrice.buttons) do
            -- if b.active then
                svgcode = svgcode .. b:draw(nil, {noRound=true})
            -- end
        end
        return svgcode
    end
    function    sti:updateMatriceHeights(shipPos)
        shipPos = shipPos or vec3(core.getConstructWorldPos())
        self.matrice.heights = sti.getHeightsFor(shipPos, self.bti.waypoints)
        local bodyCount = #self.bti.waypoints
        for j = 1, bodyCount do
            for i = j+1, bodyCount do
                self.matrice.buttonsMatrice[j][i].color = self:getHeightColor(self.matrice.heights[j][i])
                 --⇔
                self.matrice.buttonsMatrice[j][i].hint = string.format([[%s⇔%s %s su]],
                    self.bti.waypoints[j].name, self.bti.waypoints[i].name, round(self.matrice.heights[j][i]/su,2))
                self.matrice.buttonsMatrice[j][i].active = (self.matrice.heights[j][i] < self.dangerZonesHeights[3]) and true or false
            end
        end
    end
    function    sti:getHtmlCompleteMatrice()
        local bodyCount = #self.bti.waypoints
        local htmlcode = ""
        --header
        local classes = {"danger1","danger2","danger3","no-danger"}
        htmlcode = htmlcode .. string.format([[
            <style>
            tr th {font-size:4.2vh;font-family:Arial;}
            .%s {color:%s}
            .%s {color:%s}
            .%s {color:%s}
            .%s {color:%s}
            </style>
            <div style="width:100%%;height:100%%;">
            <table style="width:100%%;height:100%%">]],
            classes[1], self.dangerZonesColors[1],
            classes[2], self.dangerZonesColors[2],
            classes[3], self.dangerZonesColors[3],
            classes[4], "white")
        htmlcode = htmlcode .. [[<tr>]]
        for i = 2, bodyCount do
                htmlcode = htmlcode .. string.format([[<th>%s</th>]], self.bti.waypoints[i].name)
        end
        htmlcode = htmlcode .. string.format([[<th></th></tr>]])
        --rows
        for j = 1, bodyCount-1 do
            htmlcode = htmlcode .. [[<tr>]]
            for i = 2, bodyCount do
                local height = ""
                local class = ""
                if (i > j) then
                    height = self.matrice.heights[j][i]
                    class = classes[4]
                    for i, h in ipairs(self.dangerZonesHeights) do 
                        if height < h then
                            class = classes[i]
                            break
                        end
                    end
                    class = string.format([[class="%s"]], class)
                    local close = 8*su
                    if height > close then -- white gradient
                        local c = max(50,floor(255*(1-(height-close)/(20*su))))
                        class = string.format([[style="color:rgb(%d, %d, %d);"]], c,c,c)
                    end
                    local d = height < (10*su) and 2 or 1
                    height = round(height/su, d)
                end
                htmlcode = htmlcode .. string.format([[<th %s>%s</th>]], class, height)
            end
            htmlcode = htmlcode .. string.format([[<th>%s</th>]], self.bti.waypoints[j].name)
            htmlcode = htmlcode .. [[</tr>]]
        end
        htmlcode = htmlcode .. [[</table></div>]]
        return htmlcode
    end

    -- adapted JayleBreak function PlanetarySystem:closestBody(coordinates)
    function    sti:getClosestBody(shipPos)
        --planets
        local minDistance2 = (self.atlas[1].center - shipPos):len2()
        local body = self.atlas[1]
        for _, b in ipairs(self.atlas) do
            local distance2 = (b.center - shipPos):len2()
            if distance2 < minDistance2 then
                body = b
                minDistance2 = distance2
            end
        end
        --moons
        for _, m in ipairs(body.moons) do
            local distance2 = (m.center - shipPos):len2()
            if distance2 < minDistance2 then
                body = m
                minDistance2 = distance2
            end
        end
        return body, sqrt(minDistance2)
    end
    function    sti:getSvgSafeZoneStatus(shipPos, screenPos)
        screenPos = screenPos or vec3(10, 10, 0)
        local safefrontierDist = self.safeZone.r - (shipPos - self.safeZone.center):len()
        --planetary protection
        local closestBody, closestBodyDist = sti:getClosestBody(shipPos)
        local bodyFrontierDist = 500000 - closestBodyDist -- 2.5su

        local safe = (safefrontierDist > 0) or (bodyFrontierDist > 0)

        local svgcode = ""
        --icons
        svgcode = svgcode .. string.format([[<use x="%d" y="%d" fill="%s" xlink:href="#pvp" />]],
            screenPos.x, screenPos.y, safe and self.color or "#ff4d4d")
        if safe then
            svgcode = svgcode .. string.format([[<use x="%d" y="%d" fill="#33cc33" xlink:href="#safe" />]],
                screenPos.x+85, screenPos.y+125)
        end
        --text
        local textpos = screenPos + vec3(140, 310, 0)
        local fs = 28
        local pad = 3
        svgcode = svgcode .. string.format([[
            <g text-anchor="middle" fill="%s" font-size="%d">
            <text x="%d" y="%d">Boundarys:</text>
            <text x="%d" y="%d">%s - Safe Zone</text>
            <text x="%d" y="%d">%s - %s</text>
            </g>]],
            self.color, fs,
            textpos.x, textpos.y,
            textpos.x, textpos.y+fs*1+pad*2, fancy_sukm(abs(safefrontierDist)),
            textpos.x, textpos.y+fs*2+pad*1, fancy_sukm(abs(bodyFrontierDist)), closestBody.name)
            return svgcode
    end

    function    sti:getSvgcode(shipPos)
        self.shipPos = shipPos or vec3(core.getConstructWorldPos())
        local svgcode = ""
        --first panel
        local ypos = floor(g.h*0.70)
        local x1 = 250
        local x2 = g.w - x1
        svgcode = svgcode .. self:getSvgPlanetZones(ypos, x1, x2)
        svgcode = svgcode .. self:getSvgDangerZones(ypos, x1, x2)
        svgcode = svgcode .. self:getSvgShipHeight(ypos, x1, x2)
        svgcode = svgcode .. self:getSvgBti(vec3(30, 60, 0))
        self:updateMatriceHeights(self.shipPos)
        svgcode = svgcode .. self:getSvgMatrice()
        svgcode = svgcode .. self:getSvgSafeZoneStatus(self.shipPos, vec3(1580,15,0))
        return svgcode
    end
    function    sti:getLateSvgcode()
        local svgcode = ""
        for i, b in ipairs(self.matrice.buttons) do
            if b.active then
                svgcode = svgcode .. b:lateDraw()
            end
        end
        return svgcode
    end

    return sti
end

function    requirePlanetSelector()
    local ps = {}
    ps.color = "darkgray"
    ps.y = floor(g.h*0.4)
    ps.fontsize = 45
    ps.indent = 10
    
    --planets
    ps.buttons = {}
    ps.planetSelectionOrigin = ButtonGroup()
    ps.planetSelectionDestination = ButtonGroup()
    ps._destinationIndexMap = {}
    ps._originIndexMap = {}

    --simulation
    ps.simulation = {
        running = false,
        repeating = false,
        automaticSpeed = false,
        deltaTime = 0.05,
        duration = 5, --sec if automaticSpeed, adapted depending on travel dist)
        shipSpeed = 1*su, -- / sec
        shipTrajectory = vec3(core.getConstructWorldOrientationForward()):normalize(),
    }

    function    ps:initPlanets(planets)
        local size = {width=175,height=50}
        local ftsize = 35
        for i, v in ipairs(sti.bti.waypoints) do
            local b1 = Button(v.name, vec3(self.indent,self.y+(size.height+4)*(i-1),0), size, ftsize)
            b1.buttonGroup = self.planetSelectionOrigin
            b1.active = true
            b1.canToggle = true
            b1.onClick = selectOrigin
            self.planetSelectionOrigin:add(b1)
            table.insert(self.buttons, b1)
            self._originIndexMap[v.name] = i

            local b2 = Button(v.name, vec3(g.w-self.indent-size.width,self.y+(size.height+4)*(i-1),0), size, ftsize)
            b2.buttonGroup = self.planetSelectionDestination
            b2.active = true
            b2.canToggle = true
            b2.onClick = selectDestination
            self.planetSelectionDestination:add(b2)
            table.insert(self.buttons, b2)
            self._destinationIndexMap[v.name] = i
        end
    end
    function    ps:update(cursorPos)
        local changes = Button.updateButtonsStates(self.buttons, cursorPos)
        if changes then
            g.needRefresh = true
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
    function    ps:getLateSvgcode()
        local svgcode = ""
        for i, v in ipairs(self.buttons) do
            svgcode = svgcode .. v:lateDraw()
        end
        return svgcode
    end
    function    ps:tryClick(x, y)
        Button.tryClickOnButtons(self.buttons, {x=x, y=y})
    end

    function    ps:prepareSimulation()
        self.simulation.shipTrajectory = vec3(core.getConstructWorldOrientationForward()):normalize()
        if self.simulation.automaticSpeed then
            local travelDist = (sti.bti.waypoints[sti.destination] - sti.shipPos):len()
            self.simulation.shipSpeed = travelDist / self.simulation.duration
        end
    end
    function    ps:toggleSimulation(forcedState)
        self.simulation.running = (forcedState ~= nil) and forcedState or (not self.simulation.running)
        if self.simulation.running then
            self:prepareSimulation()
            unit.setTimer("simulation", self.simulation.deltaTime)
        else
            unit.stopTimer("simulation")
            g.needRefresh = true
        end
    end
    function    ps:runSimulationStep()
        sti.shipPos = sti.shipPos + self.simulation.shipTrajectory * self.simulation.shipSpeed * self.simulation.deltaTime
    end

    return ps
end

--button funcs
function    selectOrigin()
    local b = selector.planetSelectionOrigin.selected[1]
    if b then 
        local old_origin = sti.origin
        sti.origin = selector._originIndexMap[b.text]
        if sti.destination == sti.origin then
            selector.planetSelectionDestination[old_origin]:_click()
        end
        g.needRefresh = true
    else -- clicked on the current selection, just reselect it (= always 1 selected)
        selector.planetSelectionOrigin[sti.origin]:_click()
    end
end
function    selectDestination()
    local b = selector.planetSelectionDestination.selected[1]
    if b then 
        local old_destination = sti.destination
        sti.destination = selector._destinationIndexMap[b.text]
        if sti.origin == sti.destination then
            selector.planetSelectionOrigin[old_destination]:_click()
        end
        g.needRefresh = true
    else -- unselected the current selection, just reselect it (always 1 selected)
        selector.planetSelectionDestination[sti.destination]:_click()
    end
end
function    toggleSimulation()
    selector:toggleSimulation()
end