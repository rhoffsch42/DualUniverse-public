--[[
    MPC v1.0

    links (element : slot name) (* are optional):
        - core : core
        * telemeter : telemeter 
        * lightSwitch : manual switch (with relay(s) to all lights)
        * vboosterSwitch : manual switch (with relay(s) to all fuel intakes)
    
    commands:
        option1 : toggle handbrake
        option2 : toggle brakes
        option3 : toggle lights
        option4 : toggle vboosters

    todo:
        basic interface:
            fuel tank : time to depletion
        settings: toggle space brake safety if <2su (dep: BTI)

--]]

function    requireMinimalPilotingConfig(atmotanks, spacetanks)
    local mpc = {
        piloting = {
            handbrake = false,
            autobrake = false,
            vBoosters = true,
            brakeAtRange = false, -- default 2su
            lights = false,
            gears = false,
            telemeterRange = 0,
            surfaceStabilization = 4, --m
        },
        atmotanks = atmotanks,
        spacetanks = spacetanks,
        nitronMass = 4,
        kergonMass = 6,
        gearsThreshold = 40,
        uiPos = vec3(1675, 525, 0),
    }

    function	mpc:initTanksData(
            ContainerOptimization,
            FuelTankOptimization,
            AtmosphericFuelTankHandling,
            SpaceFuelTankHandling)
    
        self.nitronMass = 4 * (1 - 0.05*(ContainerOptimization + FuelTankOptimization))
        self.kergonMass = 6 * (1 - 0.05*(ContainerOptimization + FuelTankOptimization))
        for _, t in pairs(self.atmotanks) do
            t.volume = getTankMaxVolume(t, AtmosphericFuelTankHandling)
            t.percent = getTankPercent(t, t.volume, self.nitronMass)
        end
        for _, t in pairs(self.spacetanks) do
            t.volume = getTankMaxVolume(t, SpaceFuelTankHandling)
            t.percent = getTankPercent(t, t.volume, self.kergonMass)
        end
    end

    function    mpc:updateTanksPercent()
        for _, t in pairs(self.atmotanks) do
            t.percent = getTankPercent(t, t.volume, self.nitronMass)
        end
        for _, t in pairs(self.spacetanks) do
            t.percent = getTankPercent(t, t.volume, self.kergonMass)
        end
    end
    function    mpc:getSvgFuelGauge(pos, right2left)
        pos = pos and vec3(pos) or vec3(10, 100, 0)
        local r = 8
        local spacing = math.ceil(r*3)
        if right2left then spacing = -spacing end
        local svgcode = ""
        svgcode = svgcode .. [[
            <g class="fuel">
            <g class="nitron">
        ]]
        for i, t in pairs(self.atmotanks) do
            svgcode = svgcode .. svgCircularGauge(t.percent, pos + i*vec3(spacing,0,0), r, "gauge", "gauge-bg")
        end
        svgcode = svgcode .. [[</g><g class="kergon">]]
        pos = pos + vec3(0, math.abs(spacing), 0)
        for i, t in pairs(self.spacetanks) do
            svgcode = svgcode .. svgCircularGauge(t.percent, pos + i*vec3(spacing,0,0), r, "gauge", "gauge-bg")
        end
        svgcode = svgcode .. [[</g></g>]]
        return svgcode
    end

    function    mpc:updatePilotingInfos()
        --self.piloting.throttle = unit.getThrottle() --unit.getAxisCommandValue(0) * 100, -- Longitudinal = 0, lateral = 1, vertical = 2    //  unit.getThrottle()
        self.piloting.surfaceStabilization = unit.getSurfaceEngineAltitudeStabilization() -- meter
        self.piloting.telemeterRange = telemeter and telemeter.getDistance() or nil
        self.piloting.gears = unit.isAnyLandingGearExtended()
        --self.piloting.isBraking = ??, -- done in flush
    end
    function    mpc:getSvgPilotingInfos(pos)
        pos = pos and vec3(pos) or vec3(self.uiPos)
        local fontsize = 14
        local colorOn = "#33cc33"
        local color = "#99ccff"
        local svgcode = ""
        svgcode = svgcode .. svgTextBG("Braking", pos + vec3(0,-20,0), fontsize, (self.piloting.isBraking) and colorOn or color)
        svgcode = svgcode .. svgTextBG("HandBrake", pos + vec3(70,-20,0), fontsize, (self.piloting.handbrake) and colorOn or color)
        svgcode = svgcode .. svgTextBG("AutoBrake", pos + vec3(157,-20,0), fontsize, (self.piloting.autobrake) and colorOn or color)
        if lightSwitch then
            svgcode = svgcode .. svgTextBG("Lights", pos + vec3(180,-40,0), fontsize, (self.piloting.lights) and colorOn or color)
        end
        if vboosterSwitch then
            svgcode = svgcode .. svgTextBG("vBoosters", pos + vec3(94,-40,0), fontsize, (self.piloting.vboosters) and colorOn or color)
        end
        svgcode = svgcode .. svgTextBG("Gears", pos + vec3(41,-40,0), fontsize, (self.piloting.gears == 1) and colorOn or color)

        --brake calc
        local brakeData = calcBrakeTimeAndDistance(core.getConstructMass(), vec3(core.getWorldVelocity()):len(), self.brakePower)
        local text1 = math.ceil(brakeData.distance) / 1000 .. "km "
        local text2 = " |  " .. dhms(brakeData.time)
        svgcode = svgcode .. string.format([[
            <g style="fill:%s;font-size:12;font-weight:bold;">
                <text x="%d" y="%d" text-anchor="middle">Brake distance and time :</text>
                <text x="%d" y="%d" text-anchor="end">%s</text>
                <text x="%d" y="%d" >%s</text>
            </g>]],
            color,
            pos.x+120, pos.y+10,
            pos.x+120, pos.y+25, text1,
            pos.x+123, pos.y+25, text2)

        --floor dist and stabilization height
        local maxRange = 100 -- telemeter 
        local min = vec3(pos) + vec3(-15, 330, 0)
        local direction = vec3(0, -300, 0)
        local max = min + direction

        local r = 0
        local floor = 0
        local floortext = ""
        if self.piloting.telemeterRange then
            r = math.ceil(self.piloting.telemeterRange)
            r = r == -1 and 101 or r
            floor = min + direction * (r / maxRange)
            floor.x = math.ceil(floor.x)
            floor.y = math.ceil(floor.y)
            floortext = r == 101 and "100+" or r
        else
            floor = vec3(min)
            floortext = "?"
        end

        local stab = min + direction * (self.piloting.surfaceStabilization / maxRange)
        stab.x = math.ceil(stab.x)
        stab.y = math.ceil(stab.y)
        svgcode = svgcode .. string.format([[<line x1="%d" y1="%d" x2="%d" y2="%d" style="stroke:%s;stroke-width:2" />
            <g style="fill:%s;font-size:12;font-weight:bold;">
                <text x="%d" y="%d" text-anchor="end">%s</text>
                <text x="%d" y="%d">%s</text>
            </g>]],
            min.x, min.y, max.x, max.y, color,
            color, floor.x, floor.y, floortext .. " ►",
            stab.x, stab.y, ("◄ " .. math.ceil(self.piloting.surfaceStabilization)))

            --[[
        svgcode = svgcode .. svg.toSVG({
            core.getMaxKinematicsParametersAlongAxis(),
            unit.computeGroundEngineAltitudeStabilizationCapabilities(),
        }, 20, 200)
            --]]
        return svgcode
    end

    function    mpc:automaticFeatures()
        --gears
        if self.piloting.telemeterRange then
            if (self.piloting.telemeterRange > 0) and (self.piloting.telemeterRange <= self.gearsThreshold) then
                if self.piloting.gears == 0 then unit.extendLandingGears() end
            else
                if self.piloting.gears == 1 then unit.retractLandingGears() end
            end
        end
        -- on brake: red backlight
    end

    function	mpc:getSvgcode()
        local svgcode = ""
        local atmolvls = {}
        local spacelvls = {}
        for _, t in pairs(self.atmotanks) do
            table.insert(atmolvls, t.percent)
        end
        for _, t in pairs(self.spacetanks) do
            table.insert(spacelvls, t.percent)
        end
        svgcode = svgcode .. self.bti:getSvgcode()
        svgcode = svgcode .. self:getSvgFuelGauge(vec3(1800, 1030, 0), true) -- true = right2left
        svgcode = svgcode .. self:getSvgPilotingInfos()

  --  svg.body = svg.body .. svg.toSVG({displayedMenu}, 900, 30, {maxDepth=1})
        return svgcode
    end

    return mpc
end
