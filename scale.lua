if not LibStub then return end

local AG = LibStub:GetLibrary('AnimationGroup-1.0')
if not AG then return end

local Scale = AG:New('Scale', AG.Animation)

function Scale:__Initialize()
    self.origin = {}
    self.origin.point = nil
    self.origin.x = nil
    self.origin.y = nil
    self.scale = {}
    self.scale.x = nil
    self.scale.y = nil
end

function Scale:SetOrigin(point, offset_x, offset_y)
    self.origin.point = point
    self.origin.x = x
    self.origin.y = y
end

function Scale:GetOrigin()
    local origin = self.origin

    return origin.point, origin.x, origin.y
end

function Scale:SetScale(x, y)
    self.scale.x = x
    self.scale.y = y
end

function Scale:GetScale()
    local scale = self.scale

    return scale.x, scale.y
end

function Scale:OnUpdate(elapsed)
    local properties = self.group.properties

    self.progress = self.smoothing_func(self.time / self.duration).y

    local frame = self.group.parent

    frame:SetWidth(properties.width + self.progress * (properties.width * self.scale.x))
    frame:SetHeight(properties.height + self.progress * (properties.height * self.scale.y))
end
