## Typical usage
```lua
svg = requireSvgHelper()
system.showScreen(1)

debug = {
    whatever = "value",
    player = {
        name = player.getName(),
        pos = player.getPosition(),
    },
}

svg.body = ""
svg.body = svg.body .. [[
    <rect x="0" y="0" width="25%" height="100%" fill="#131339" opacity="0.5" />
    ]]
svg.body = svg.body .. svg.toSVG(debug, 50, 50)

system.setScreen(svg.dump())
```
![example](https://i.imgur.com/VHhuXLB.png)


### Default settings:
```lua
svg._fontsize = 20
svg._pad = 4
svg._tablepad = 30
svg._textColor = "yellow"
svg._displayKey = true
svg._displayTable = true
```

For the debug function `toSVG`, you can set a max depth for tables:
```lua
-- this will print tables and their content only on the first depth
svg.body = svg.body .. svg.toSVG(debug, 50, 50, {maxDepth=1})
```
![maxDepth](https://i.imgur.com/61eUHM4.png)