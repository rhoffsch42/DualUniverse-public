--[[
    BTI v1.4
    dependency: SvgHelper
    
    unit > start
        svg = requireSvgHelper() -- or require("svghelper")
        bti = requireBasicTravelInfos()
        system.showScreen(1)
        unit.setTimer("eta", 0.25)
    unit > tick(eta)
        svg.body = bti:getSvgcode()
        system.setScreen(svg.dump())
    system > actionStart(lshift)
        bti.target = (bti.target - 1 + bti.maxWaypoints - 1) % bti.maxWaypoints + 1
    system > actionStart(lalt)
        bti.target = (bti.target - 1 + bti.maxWaypoints + 1) % bti.maxWaypoints + 1

]]

local function dhms(time, displayAll, sep)
    displayAll = displayAll or false
    sep = sep or {"d","h","m","s"}
    local dhmsValues = {86400, 3600, 60, 1}
    local res = ""
    for i, v in ipairs(dhmsValues) do
        local r = math.floor(time / dhmsValues[i])
        time = time % dhmsValues[i]
        if displayAll or r ~= 0 then
            res = res .. string.format([[%.2d%s]], r, sep[i])
        end
    end
    return res ~= "" and res or ("0"..sep[4])
end

local function buildWaypoints()
    local helios = require("atlas")[0]
    local ibodys = {2,1,3,4,5,6,7,8,9,100,110,120}
    local waypoints = {}
    for i, b in ipairs(ibodys) do
        waypoints[i] = {
            name = helios[b].name[1],
            x = helios[b].center[1],
            y = helios[b].center[2],
            z = helios[b].center[3],
        }
    end
    return waypoints
end

function requireBasicTravelInfos()
    local bti = {}
    bti.waypoints = buildWaypoints()
    bti.maxWaypoints = 0
    for _, v in ipairs(bti.waypoints) do
        bti.maxWaypoints = bti.maxWaypoints + 1
    end
    bti.target = 1
    bti.color = "#99ccff"
    bti.fontsize = 18

    function	bti:travelInfos(target, shipPos, speed, mass, pos, fontsize)
        fontsize = fontsize or self.fontsize
        pos = pos and pos or vec3(10, 30, 0)
        local name = target.name or "?"
        local dist = (shipPos - target):len()
        local su = 200000
        local t = 1000

        local travel = {
            atCurrentSpeed = math.floor(dist / speed),
            atMaxSpeed = math.floor(dist / 8333),
            warpCells = ((mass/t) * (dist/su) * 0.00024)
        }

        fontsize = fontsize or 20
        local x = pos.x
        local y = pos.y
        local svgcode = string.format([[<g fill="%s" font-size="%dpx">]], self.color, fontsize)
        --title
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d" font-weight="bold" text-decoration="underline">Travel time to %s (%dsu) :</text>]],
            x, y, name, math.ceil(dist/su))
        --current speed
        y = y + fontsize
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d">At current speed: %s</text>]],
            x, y, travel.atCurrentSpeed == 1/0 and "∞" or dhms(travel.atCurrentSpeed))
        --max speed
        y = y + fontsize
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d">At max speed: %s</text>]],
            x, y, dhms(travel.atMaxSpeed))
        --warp cell
        y = y + fontsize
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d">Warp cells for %dt : %s</text>]],
            x, y, math.ceil(mass/t), math.ceil(travel.warpCells))

        svgcode = svgcode .. [[</g>]]
        return svgcode
    end
    
    function	bti:getSvgcode(pos, target) -- target is a vec3 with a "name" key
        local speed = vec3(core.getWorldVelocity()):len()
        local selectedTarget = target and target or self.waypoints[self.target]
        local shipPos = vec3(core.getConstructWorldPos())
        local mass = core.getConstructMass()

        return self:travelInfos(selectedTarget, shipPos, speed, mass, pos, self.fontsize)
    end
    
    return bti
end