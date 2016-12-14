if not LibAG then return end

local Translation = LibAG:New('Translation', LibAG.Animation)
Translation.offset = {}
Translation.offset.x = nil
Translation.offset.y = nil

function Translation:SetOffset(x, y)
    self.offset.x = x
    self.offset.y = y
end

function Translation:GetOffset()
    return self.offset.x, self.offset.y
end

function Translation:OnUpdate(elapsed)
    self.progress = self.smoothing_func(self.time / self.duration).y

    local frame = self:GetRegionParent()
    local point, relative_to, relative_point, x, y = frame:GetPoint()
    frame:ClearAllPoints()
    frame:SetPoint(point, relative_to, relative_point,
                   self.parent_x + self.progress * self.offset.x,
                   self.parent_y + self.progress * self.offset.y)
end
