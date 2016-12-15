if not LibAG then return end

local Scale = LibAG:New('Scale', LibAG.Animation)

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
    assert(x > 0, 'x must be greater than 0!')
    assert(y > 0, 'y must be greater than 0!')

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

    local sign_x = self.scale.x < 1 and -1 or 1
    local sign_y = self.scale.y < 1 and -1 or 1

    frame:SetWidth(properties.width + sign_x * self.progress * (properties.width * self.scale.x))
    frame:SetHeight(properties.height + sign_y * self.progress * (properties.height * self.scale.y))
end
