--v1.3
function requireSvgHelper()
    local function isTable(t)   return type(t) == 'table'  end

    local svg = {}
    svg._fontsize = 20
    svg._pad = 4
    svg._tablepad = 30
    svg._textColor = "yellow"
    svg._displayKey = true
    svg._displayTable = true

    function svg.dump()
        return svg.header .. svg.style .. "</style><defs>" .. svg.base .. "</defs>" .. svg.body .. svg.footer
    end

    function svg.toSVG(arr, x, ystart, settings, depth)
        local svgtext = ""
        ystart = ystart or 20
        x = x or 25
        settings = settings or {}
        settings.maxDepth = settings.maxDepth or 99999
        if (settings.displayKey == nil) then settings.displayKey = svg._displayKey end
        if (settings.displayTable == nil) then settings.displayTable = svg._displayTable end
        depth = depth or 0

        local i = 0
        local ii = 0
        for k, v in pairs(arr) do
            i = i + 1
            if (depth == 0) then ii = ii + 1 end
            local valueIsTable = isTable(v)
            svgtext = svgtext .. string.format([[
                <text x="%d" y="%d"
                font-size="%dpx" fill="%s" stroke="black" stroke-width="2">
                %s%s
                </text>
                ]], x + depth*svg._tablepad, (ystart + (i + ii - 1)*(svg._fontsize + svg._pad)),
                svg._fontsize, svg._textColor,
                settings.displayKey and (k.." : ") or "", valueIsTable and "{...}" or v)
            if (settings.displayTable and valueIsTable and (depth <= settings.maxDepth)) then
                local svgtable, ret = svg.toSVG(v, x, (ystart + (i + ii)*(svg._fontsize + svg._pad)), settings, depth+1)
                ii = ii + ret
                svgtext = svgtext .. svgtable
            end
        end
        return svgtext, i + ii
    end

    function svg.imageCut(path, imageSize, screenViewbox, svgViewbox) -- viewbox are rect: x y width height
        return string.format([[
            <svg x="%d" y="%d" width="%d" height="%d" preserveAspectRatio="none"
            viewBox="%d %d %d %d"
            xmlns="http://www.w3.org/2000/svg" 
            xmlns:xlink="http://www.w3.org/1999/xlink"> 
            <image width="%d" height="%d" xlink:href="%s" />
            </svg>]],
            screenViewbox.x, screenViewbox.y, screenViewbox.width, screenViewbox.height,
            svgViewbox.x, svgViewbox.y, svgViewbox.width, svgViewbox.height,
            imageSize.width, imageSize.height, path)
    end

    function	svg.textBG(text, position, fontsize, color, inverted)--inverted is like an unselected button
        local pos = position and {x=position.x, y=position.y} or {x=0, y=0}
        fontsize = fontsize and math.floor(fontsize) or 15
        color = color or "white"
        inverted = inverted or false
        local textcolor = inverted and color or "black"
        local stroke = inverted and ("stroke-width:1;stroke:" .. color) or ""
        color = inverted and "none" or color
        local x = math.floor(pos.x)
        local y = math.floor(pos.y)
        local pad = 0.35
        local textlen = math.floor(fontsize * string.len(text) * 0.6) --depend of the font
        local xlen = math.floor(fontsize*pad*2) + textlen
        local ylen = math.floor(fontsize*(1+pad))
        local round = math.floor(fontsize*0.4)
        
        local svgcode = string.format([[
            <rect x="%d" y="%d" width="%d" height="%d" rx="%d" ry="%d" style="fill:%s;%s" />
            <text x="%d" y="%d" textLength="%d" font-size="%d" font-weight="bold" fill="%s">%s</text>]],
            x, y, xlen, ylen, round, round, color, stroke,
            x + math.floor(fontsize*pad), y + fontsize, textlen, fontsize, textcolor, text)
        
        return svgcode
    end
    
    function	svg.tag(title, description, pos, fontsize, color)
        color = color or "white"
        fontsize = fontsize and math.floor(fontsize) or 20
        local keyftsize = math.floor((13/20)*fontsize)
        local x = math.floor(pos.x)
        local y = math.floor(pos.y)
        local svgcode = svgTextBG(title, {x=x, y=y}, keyftsize, color)
        x = math.floor(x + (string.len(title)+2) * keyftsize * 0.6)
        svgcode = svgcode .. string.format([[
            <text x="%d" y="%d" font-size="%dpx" fill="%s">%s</text>]],
            x, y+math.floor((15/20)*fontsize), fontsize, color, description)
        
        return svgcode
    end
    

    svg.header = [[
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
    ]]
    svg.style = [[]]
    svg.base = [[]]
    svg.footer = [[</svg>]]
    svg.body = [[]]

    return svg
end