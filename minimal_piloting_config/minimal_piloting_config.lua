-- MPC v1.0
--[[

    alt : settings (vcursor)
    option1 : toggle handbrake
    option2 : toggle brakes
    option3 : toggle lights
    settings: toggle space brake safety (dep: BTI)

    --[[



CHECK DIMENSIA INSTALLATION: can inject json, or need to install manually?

toggle: brake if <2su of target (BTI)
demarrage instant hover/booster

basic interface:
    fuel tank : time to depletion)
	warp drive warp cells in container: need to put a spcial container for that and do same as fuel tanks
	trottle -100 +100 % (+speed km/h  m/s)
	isbraking + brake with value
	floor level (telemeter)
	hover/booster floor level 

    flags: braking, autobrake, handbrake, lights, gears

clignotage des square lights

settings:
	disable vbooster on atmo


    --]]

function    requireMinimalPilotingConfig(atmotanks, spacetanks)
    local mpc = {
        bti = requireBasicTravelInfos(),
        piloting = {},
        handbrake = false,
        autobrake = false,
        brakeAtRange = false, -- default 2su
        lights = false,
        vBoosters = true,
        atmotanks = atmotanks,
        spacetanks = spacetanks,
        nitronMass = 4,
        kergonMass = 6,
        gearsThreshold = 40,
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
        self.piloting.throttle = unit.getThrottle() --unit.getAxisCommandValue(0) * 100, -- Longitudinal = 0, lateral = 1, vertical = 2    //  unit.getThrottle()
        self.piloting.surfaceStabilization = unit.getSurfaceEngineAltitudeStabilization() -- meter
        self.piloting.telemeterRange = telemeter and telemeter.getDistance() or nil
        self.piloting.gears = unit.isAnyLandingGearExtended()
        --self.piloting.brakingPower = ??, -- done in flush
    end
    function    mpc:getSvgPilotingInfos(pos)
        pos = pos and vec3(pos) or vec3(10, 500, 0)
        local fontsize = 14
        local colorOn = "#33cc33"
        local colorOff = "darkgray"
        local svgcode = ""
        svgcode = svgcode .. svg.toSVG({piloting=self.piloting}, pos.x, pos.y)
        svgcode = svgcode .. svgTextBG("Braking", pos + vec3(0,-20,0), fontsize, (self.piloting.brakingPower > 0) and colorOn or colorOff)
        svgcode = svgcode .. svgTextBG("HandBrake", pos + vec3(70,-20,0), fontsize, (self.handbrake) and colorOn or colorOff)
        svgcode = svgcode .. svgTextBG("AutoBrake", pos + vec3(157,-20,0), fontsize, (self.autobrake) and colorOn or colorOff)
        svgcode = svgcode .. svgTextBG("Lights", pos + vec3(0,-40,0), fontsize, (self.lights) and colorOn or colorOff)
        svgcode = svgcode .. svgTextBG("Gears", pos + vec3(0,-60,0), fontsize, (self.piloting.gears == 1) and colorOn or colorOff)
        return svgcode
    end

    function    mpc:automaticFeatures()
        --gears
        if (self.piloting.telemeterRange > 0) and (self.piloting.telemeterRange <= self.gearsThreshold) then
            if self.piloting.gears == 0 then unit.extendLandingGears() end
        else
            if self.piloting.gears == 1 then unit.retractLandingGears() end
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
        svgcode = svgcode .. self:getSvgFuelGauge(vec3(1700, 1030, 0), true) -- true = right2left
        svgcode = svgcode .. self:getSvgPilotingInfos()

  --  svg.body = svg.body .. svg.toSVG({displayedMenu}, 900, 30, {maxDepth=1})
        return svgcode
    end



    return mpc
end

--[=[
    Manual install on the seat controller after reloading a default configuration for flying contruct:
        links (element : slot name) (* are optional):
            * telemeter : telemeter 
            * lightSwitch : manual switch (with relay(s) to all lights)
    
        unit
            tick(hud)
                mpc:updateTanksPercent()
                mpc:updatePilotingInfos()

                svg.body = mpc:getSvgcode()
                system.setScreen(svg.dump())
            start()
                ---------
                unit.setTimer("draw", 0.01)
                unit.setTimer("util", 0.01)
                local atmotanks = {atmofueltank_1,atmofueltank_2,atmofueltank_3,atmofueltank_4,atmofueltank_5,atmofueltank_6,atmofueltank_7,atmofueltank_8,atmofueltank_9,atmofueltank_10,atmofueltank_11,atmofueltank_12,atmofueltank_13,atmofueltank_14,atmofueltank_15,atmofueltank_16,atmofueltank_17,atmofueltank_18,atmofueltank_19,atmofueltank_20,}
                local spacetanks = {spacefueltank_1,spacefueltank_2,spacefueltank_3,spacefueltank_4,spacefueltank_5,spacefueltank_6,spacefueltank_7,spacefueltank_8,spacefueltank_9,spacefueltank_10,spacefueltank_11,spacefueltank_12,spacefueltank_13,spacefueltank_14,spacefueltank_15,spacefueltank_16,spacefueltank_17,spacefueltank_18,spacefueltank_19,spacefueltank_20,}
                --talents levels
                local ContainerOptimization = 5 --export
                local FuelTankOptimization = 5 --export
                local AtmosphericFuelTankHandling = 5 --export
                local SpaceFuelTankHandling = 4 --export

                svg = requireSvgHelper() -- or require("svghelper")
                svg.style = svg.style .. [[
                .fuel { fill: none; }
                .nitron { stroke: #3399ff; }
                .kergon { stroke: #ffff4d; }
                .gauge { stroke-width: 10; }
                .gauge-bg { stroke: #bbbbbb; stroke-width: 6; }
                .val { font-size: 20px; text-anchor: middle; fill: #bbbbbb; stroke: #bbbbbb; }
                ]]
                mpc = requireMinimalPilotingConfig(atmotanks, spacetanks)
                mpc:initTanksData(ContainerOptimization, FuelTankOptimization, AtmosphericFuelTankHandling, SpaceFuelTankHandling)

                system.showScreen(1)
                unit.setTimer("hud", 0.15)
                lightSwitch.activate()
            stop()
                lightSwitch.deactivate()
        system
            actionStart(option1)
                mpc.handbrake = not mpc.handbrake
            actionStart(option2)
                mpc.brake = not mpc.brake
            actionStart(option3)
                lightSwitch.toggle()
            actionStart(lalt)
                mpc.bti.target = (mpc.bti.target - 1 + mpc.bti.maxWaypoints + 1) % mpc.bti.maxWaypoints + 1
            actionStart(lshift)
                mpc.bti.target = (mpcbti.target - 1 + mpc.bti.maxWaypoints - 1) % mpc.bti.maxWaypoints + 1
            flush() : replace Brake part by:
                -- Brakes
                --local brakeAcceleration = -finalBrakeInput * (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
                --Nav:setEngineForceCommand('brake', brakeAcceleration)
                if mpc.handbrake then
                    unit.setEngineThrust("brake", math.maxinteger)
                else
                    local brakeAcceleration = (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
                    brakeAcceleration = mpc.brake and (-brakeAcceleration) or (-finalBrakeInput * brakeAcceleration)
                    Nav:setEngineForceCommand('brake', brakeAcceleration)
                end

        unit
            tick(util)
                function	getTankMaxVolume(tank, talentlvl)
                    local defaultTanksMass = {35.03, 182.67, 988.67, 5480} -- xs, s, m, l
                    local defaultTanksVolumes= {100, 400, 1600, 12800} -- xs, s, m, l
                    local mass = tank.getSelfMass()
                    local vol = 0
                    for i, m in pairs(defaultTanksMass) do
                        if mass == m then
                            vol = defaultTanksVolumes[i] * (1 + 0.20*talentlvl) -- 20% bonus volume / lvl
                            break
                        end
                    end
                    return math.ceil(vol)
                end

                function	getTankPercent(tank, volume, fuelMassL)
                    local mm = volume * fuelMassL
                    local m = tank.getItemsMass()
                    return math.ceil(m / mm * 100)
                end
            tick(draw)
                function    svgCircularGauge(percent, pos, r, class, bgclass)
                    pos = vec3(pos)
                    class = class or "gauge"
                    bgclass = bgclass or "gauge-bg"
                    local size = r*2
                    local da = ""
                    if percent ~= 100 then
                        local d = math.ceil(2 * math.pi * r)+1
                        local p = math.ceil(d * percent / 100)
                        da = string.format([[ stroke-dasharray="%d %d"]], p, d)
                    end
                    return string.format([[
                        <circle class="%s" cx="%d" cy="%d" r="%d"/>
                        <rect class="%s" x="%d" y="%d" width="%d" height="%d" rx="%d" ry="%d"%s/>]],
                        bgclass, pos.x, pos.y, r,
                        class, pos.x-r, pos.y-r, size, size, r, r, da)
                end
                --<circle class="%s" cx="%d" cy="%d" r="%d" stroke-dasharray="5 10" />

                unit.stopTimer("draw")
        library
            svghelper
                {...}
            BTI
                {...}

--]=]
