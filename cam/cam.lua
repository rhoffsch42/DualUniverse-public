local utils  = require('cpml.utils')
local vec3   = require('cpml.vec3')
local clamp  = utils.clamp
local deg2rad = math.pi/180
local rad2deg = 180/math.pi
local _vertical = vec3(0,0,1)
-------------------------------
-- cam 
local cam = {}

cam.scale = 1

cam.transform = {}
cam.transform.pos = vec3(0,0,-1)
cam.transform.target = vec3()
cam.transform.right = vec3()
cam.transform.forward = vec3()
cam.transform.right = vec3()
cam.transform.vertical = vec3(_vertical)

cam.minfov = 5
cam.maxfov = 150
cam.fov = 90
cam.resX = 1920
cam.resY = 1080
cam.center = vec3()
cam.pixlen = 1
cam.perspective = true -- orthogonal if false

--[[
cam settings

|\
screenLen/2 |  \
|    \
|______\
z    ^cam

z = screen distance = 1
tan(fov/2) = (screenLen/2) / z
screenLen / 2 = 1   when fov = 90
]]
function cam:updateScreen(fov, resX)
    self.fov = clamp(fov or self.fov, cam.minfov, cam.maxfov)
    self.resX = clamp(resX or self.resX, 320, 8192)
    local screenLen = math.tan(self.fov * deg2rad / 2) * 2
    self.pixlen = screenLen / self.resX
    self.center = vec3(self.resX/2, self.resY/2, 0)
end

function cam:updateVectors(pos, target, vertical)
    pos = pos or self.transform.pos
    target = target or self.transform.target
    vertical = vertical or self.transform.vertical

    local relativeCam = pos - target
    local camOnVertical = relativeCam:project_on(vertical)
    local surface = relativeCam - camOnVertical

    self.transform.forward = -relativeCam:normalize()
    self.transform.right = vertical:cross(surface):normalize()
    self.transform.up = self.transform.right:cross(self.transform.forward):normalize()
end

-- use this if you don't know where to position the camera 
function cam:autoPos(target, vertical, angle, dist)
    target = target or self.target
    vertical = vertical or self.vertical
    dist = dist or 100 --meters
    angle = angle and clamp(angle, 1, 90) or 45 --degrees, between the vertical and the forward
    
    local surface
    if vertical.x ~= 0 then
        surface = vec3(0,-vertical.z,vertical.y)
    elseif vertical.y ~= 0 then
        surface = vec3(-vertical.z, 0, vertical.x)
    elseif vertical.z ~= 0 then
        surface = vec3(-vertical.y,vertical.x, 0)
    else
        -- in space?
        surface = vec3(1,0,0)
    end
    surface:normalize_inplace()

    self.transform.right = surface:rotate(-90*deg2rad, vertical) -- or cross surface vertical
    
    local relativePos = dist * surface:rotate(angle*deg2rad, self.transform.right)
    self.transform.pos = target + relativePos
    self.transform.target = target
    self.transform.vertical = vertical

    self.transform.forward = -relativePos:normalize_inplace()
    self.transform.up = self.transform.forward:rotate(-90*deg2rad, self.transform.right) -- or cross right forward
    
end

function cam:projectPoint(point, inplace)
    inplace = inplace or false
    local campoint = point - self.transform.pos
    local coo = vec3(
        self.scale * campoint:dot(self.transform.right),
        self.scale * -campoint:dot(self.transform.up), --negative because y is inverted
        1 * campoint:dot(self.transform.forward)) -- depth, used for perspective

    local depth = coo.z
    local ratio = 1
    if self.perspective then -- perspective
        ratio = 1 / math.abs(coo.z) -- 1 = z
        ratio = ratio / self.pixlen
    end
    coo = self.center + coo * (ratio * self.scale)
    coo.z = depth

    if inplace then
        point.xcam = coo.x
        point.ycam = coo.y
        point.zcam = depth
    end
    return coo
end

function cam:rotateAround(angle, axis, target)
    axis = axis or self.transform.vertical
    target = target or self.transform.target

    local relativeToTarget = self.transform.pos - target
    self.transform.pos = target + relativeToTarget:rotate(angle*deg2rad, axis)
    self:updateVectors()
end

cam:updateScreen()
cam:updateVectors()

return cam