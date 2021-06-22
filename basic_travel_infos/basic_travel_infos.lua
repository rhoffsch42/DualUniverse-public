--[[
    BTI v1.2
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

        todo: add sanctuary
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

function requireBasicTravelInfos()
    local bti = {}
    bti.waypoints = {
        {name="Alioth", x=-8, y=-8, z=-126303},
        {name="Madis", x=17465536, y=22665536, z=-34464},
        {name="Thades", x=29165536, y=10865536, z=65536},
        {name="Talemai", x=-13234464, y=55765536, z=465536},
        {name="Feli", x=-43534464, y=22565536, z=-48934464},
        {name="Sicari", x=52765536, y=27165536, z=52065536},
        {name="Sinnen", x=58665536, y=29665536, z=58165536},
        {name="Teoma", x=80865536, y=54665536, z=-934464},
        {name="Jago", x=-94134464, y=12765536, z=-3634464},
        {name="Symeon", x=14165536, y=-85634464, z=-934464},
        {name="Ion", x=2865536, y=-99034464, z=-934464},
        {name="Lacobus", x=98865536, y=-13534464, z=-934464}
    }
    bti.maxWaypoints = 0
    for _, v in ipairs(bti.waypoints) do
        bti.maxWaypoints = bti.maxWaypoints + 1
    end
    bti.target = 1
    bti.color = "#99ccff"

    function	bti:travelInfos(target, shipPos, speed, mass, pos, fontsize)
        fontsize = fontsize or 18
        pos = pos and pos or vec3(10, 30, 0)
        local name = target.name or "?"
        local dist = (shipPos - target):len()
        local su = 200000
        local t = 1000

        local travel = {
            atCurrentSpeed = math.floor(dist / speed),
            atMaxSpeed = math.floor(dist / 8333),
            warpCells = ((mass/t) * (dist/su) / 4000)
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

        return self:travelInfos(selectedTarget, shipPos, speed, mass, pos, 18)
    end
    
    return bti
end