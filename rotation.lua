if not LibStub then return end

local AG = LibStub:GetLibrary('AnimationGroup-1.0')
if not AG then return end

local sin = math.sin
local cos = math.cos
local pi = math.pi

local Rotation = AG:New('Rotation', AG.Animation)

function Rotation:__Initialize()
    self.radians = nil
    self.origin = {}
    self.origin.point = 'CENTER'
    self.origin.x = 0
    self.origin.y = 0
end

local GetRegions = function(self)
    return { self.group.parent:GetRegions() }
end

local anchor_coords = {
    ['TOP']         = { x =  0, y =  1 },
    ['LEFT']        = { x = -1, y =  0 },
    ['BOTTOM']      = { x =  0, y = -1 },
    ['RIGHT']       = { x =  1, y =  0 },
    ['TOPLEFT']     = { x = -1, y =  1 },
    ['TOPRIGHT']    = { x =  1, y =  1 },
    ['BOTTOMLEFT']  = { x = -1, y = -1 },
    ['BOTTOMRIGHT'] = { x =  1, y = -1 },
    ['CENTER']      = { x =  0, y =  0 }
}
local frame_corners = {
    [1] = { x = -1, y =  1 },   -- upper left
    [2] = { x = -1, y = -1 },   -- lower left
    [3] = { x =  1, y =  1 },   -- upper right
    [4] = { x =  1, y = -1 }    -- lower right
}
local corners = { 0, 0, 0, 0, 0, 0, 0, 0 }
local function GetCoords(self, progress)
    local rad = self.radians * progress
    local _cos = cos(rad)
    local _sin = sin(rad)

    local properties = self.group.properties

    local origin = {
        x = anchor_coords[self.origin.point].x +
            self.origin.x / properties.width,
        y = anchor_coords[self.origin.point].y +
            self.origin.y / properties.height
    }

    local i = 1
    for _, coords in next, frame_corners do
        corners[i] = origin.x +
            (coords.x - origin.x) * _cos - (coords.y - origin.y) * _sin
        corners[i] = (corners[i] + 1) / 2

        corners[i + 1] = origin.y +
            (coords.x - origin.x) * _sin + (coords.y - origin.y) * _cos
        corners[i + 1] = (corners[i + 1] - 1) / -2

        i = i + 2
    end

    return unpack(corners)
end

function Rotation:OnUpdate(elapsed)
    self.progress = self.smoothing_func(self.time / self.duration).y

    local regions = GetRegions(self)
    local coords = { GetCoords(self, self.progress) }
    for _, region in next, regions do
        if region.GetTexture then
            region:SetTexCoord(unpack(coords))
        end
    end
end

function Rotation:SetDegrees(degrees)
    self.radians = (degrees / 360) * 2 * pi
end
function Rotation:GetDegrees()
    return (self.radians / (2 * pi)) * 360
end
function Rotation:SetRadians(radians)
    self.radians = radians
end
function Rotation:GetRadians()
    return self.radians
end

function Rotation:SetOrigin(point, offsetX, offsetY)
    self.origin.point = point
    self.origin.x = x
    self.origin.y = y
end

function Rotation:GetOrigin()
    local origin = self.origin

    return origin.point, origin.x, origin.y
end
