--[[

    Copyright (c) 2016-2018 Martin Jesper Low Madsen <martin@martinjlowm.dk>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.

--]]

if not LibStub then return end

local AG = LibStub:GetLibrary('AnimationGroup-1.0')
if not AG then return end

if AG.Scale then return end
local Scale = AG:New('Scale', AG.Animation)

function Scale:__Initialize()
    self.origin = {}
    self.origin.point = "CENTER"
    self.origin.x = 0
    self.origin.y = 0
    self.scale = {}
    self.scale.x = 0
    self.scale.y = 0
    self.from = {}
    self.from.x = 0
    self.from.y = 0
end

function Scale:SaveProperties()
    self.properties.width = self.target:GetWidth()
    self.properties.height = self.target:GetHeight()
    --printT({"SAVE", self.properties })
end

function Scale:LoadProperties()
    if self.properties.width then self.target:SetWidth(self.properties.width) end
    if self.properties.height then self.target:SetHeight(self.properties.height) end
    --printT({"LOAD",self.properties})
end

function Scale:SetOrigin(point, offset_x, offset_y)
    self.origin.point = point
    self.origin.x = offset_x
    self.origin.y = offset_y
end

function Scale:GetOrigin()
    local origin = self.origin

    return origin.point, origin.x, origin.y
end

function Scale:SetScale(x, y)
    self.scale.x = x
    self.scale.y = y
end

function Scale:SetToScale(x, y)
    self.scale.x = x
    self.scale.y = y
end

function Scale:GetScale()
    local scale = self.scale

    return scale.x, scale.y
end

function Scale:SetFromScale(x, y)
    self.from.x = x
    self.from.y = y
end

function Scale:GetFromScale()
    local scale = self.from

    return scale.x, scale.y
end

function Scale:OnUpdate(elapsed)
    local properties = self.properties

    local from_x = self.from.x
    local from_y = self.from.y

    -- self.progress = self.smoothing_func(self.time / self.duration).y

    local frame = self.target
    frame:SetWidth(properties.width * (from_x + self.smoothProgress * (self.scale.x - from_x)))
    frame:SetHeight(properties.height * (from_y + self.smoothProgress * (self.scale.y - from_y)))
end
