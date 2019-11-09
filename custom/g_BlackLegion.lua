BlackLegion = {}
-----------------------------------------------------------------------
-- DataBank Keys
-----------------------------------------------------------------------
BlackLegion.Keys = {
    speed = "speed",
    vspeed = "vspeed",
    space1 = "space1",
    space2 = "space2",
    atmo3 = "atmo3",
    atmo4 = "atmo4",
    g = "g",
    right = "right",
    forward = "forward",
    up = "up",
    i_vtol = "i_vtol",
    vertThrust = "vertThrust",
    i_atmoL = "i_atmoL",
    i_gears = "i_gears",
    i_drift = "i_drift",
    i_brake = "i_brake",
    i_brakeLock = "i_brakeLock",
}
-----------------------------------------------------------------------
-- HUD
-----------------------------------------------------------------------
BlackLegion.Color = {
    green = "#54b86d",
    red = "#b85454",
    darkblue = "#293d61",
}

BlackLegion.globalPadding = "padding-bottom: 0%;"
BlackLegion.globalBackGround = "background-color: "..BlackLegion.Color.darkblue..";"
BlackLegion.panelWidth = "25%"
BlackLegion.panelHeight = "100%"

BlackLegion.Class = {
    default = "panelDefault",
    vspeed = "panelVspeedGravity",
    drift = "panelDriftingCompensator",
    fuel = "panelFuelCapacity",
    main = "panelMainPiloting",
    engines = "panelEnginesObstruction",
    integrity = "panelIntegrity",
}
BlackLegion.FontSize = {
    default = "1.5em",
    vspeed = "1.3em",
    drift = "1.5em",
    fuel = "1.5em",
    main = "2.0em",
    engines = "1.5em",
    integrity = "0.9em",
}
BlackLegion.Width = {
    default = "100%",
    vspeed = "100%",
    drift = "100%",
    fuel = "100%",
    main = "100%",
    engines = "100%",
    integrity = "100%",
}

function BlackLegion.getBG(value)
    local color = BlackLegion.Color.green
    if (value == 0) then color = BlackLegion.Color.red end
	local s = [[style="background-color: ]]..color..[[;"]]
    return s;
end
function BlackLegion.get_defaultStyle(arg)
    local size = BlackLegion.FontSize.default
    if (arg) then size = arg.fontsize or size end
    local style = [[
<style>
H1,H2,H3,H4 {background-color: cornflowerblue; color: black !important; text-align: center;}
th, td {font-size: ]]..size..[[;}

td {
    color: cornflowerblue !important;
    background-color: ]]..BlackLegion.Color.darkblue..[[;
    font-weight: normal !important;
    text-align: center;
    padding-top: 0.5%;
    padding-bottom: 0.5%
}

.]]..BlackLegion.Class.default..[[ {
    ]]..BlackLegion.globalBackGround..[[
}

]]
    return style
end

function BlackLegion.get_voidPanel(arg)
    local title = arg.title or "<H2>Void Panel</H2>"
    local columnAmount = arg.columnAmount or 1
    local columnSpacing = arg.columnSpacing or {}
    local class = arg.class or BlackLegion.Class.default
    local width = arg.width or BlackLegion.Width.default
    
    local panel = [[
<div class="]]..class..[[">
<div style="width: ]]..width..[[; height: ]]..BlackLegion.panelHeight..[[;]]..BlackLegion.globalPadding..[[ text-align: left;">
    ]]..title..[[
    <table align=center style="width: 100%">
        <tr>
    		<th width=2%>]]
    for i = 1, columnAmount do
        panel = panel ..[[<th></th><th width=]]..(columnSpacing[i] or "2")..[[%></th>]]
    end

    panel = panel .."</tr>"
    return panel
end

return BlackLegion