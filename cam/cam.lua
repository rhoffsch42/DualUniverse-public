
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
    --[[]]
    pos = pos or self.transform.pos
    target = target or self.transform.target
    vertical = vertical or self.transform.vertical

    local relativeCam = pos - target
    local camOnVertical = relativeCam:project_on(vertical)
    local surface = relativeCam - camOnVertical

    self.transform.forward = -relativeCam:normalize()
    self.transform.right = vertical:cross(surface):normalize()
    self.transform.up = self.transform.right:cross(self.transform.forward):normalize()
    --]]
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

function cam:rotateAround(angle, axis)
    axis = axis or self.transform.vertical

    local relativeToTarget = self.transform.pos - self.transform.target
    self.transform.pos = self.transform.target + relativeToTarget:rotate(angle*deg2rad, axis)
    self:updateVectors()
end

cam:updateScreen()
cam:updateVectors()

return cam
