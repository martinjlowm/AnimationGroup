if not LibStub then return end

local AG = LibStub:GetLibrary('AnimationGroup-1.0')
if not AG then return end

local Translation = AG:New('Translation', AG.Animation)

function Translation:__Initialize()
    self.offset = {}
    self.offset.x = nil
    self.offset.y = nil
end

function Translation:SetOffset(x, y)
    self.offset.x = x
    self.offset.y = y
end

function Translation:GetOffset()
    return self.offset.x, self.offset.y
end

function Translation:OnUpdate(elapsed)
    self.progress = self.smoothing_func(self.time / self.duration).y

    local frame = self.group.parent

    local properties = self.group.properties

    local point, relative_to, relative_point, x, y = frame:GetPoint()
    frame:ClearAllPoints()
    frame:SetPoint(point, relative_to, relative_point,
                   properties.x + self.progress * self.offset.x,
                   properties.y + self.progress * self.offset.y)
end
