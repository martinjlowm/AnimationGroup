if not LibAG then return end

local Scale = LibAG:New('Scale', LibAG.Animation)
Scale.origin = {}
Scale.origin.point = nil
Scale.origin.x = nil
Scale.origin.y = nil
Scale.scale = {}
Scale.scale.x = nil
Scale.scale.y = nil

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
    self.progress = self.smoothing_func(self.time / self.duration).y

    local frame = self:GetRegionParent()
    frame:SetWidth(self.parent_width + self.progress * (self.parent_width * self.scale.x))
    frame:SetHeight(self.parent_height + self.progress * (self.parent_height * self.scale.y))
end
