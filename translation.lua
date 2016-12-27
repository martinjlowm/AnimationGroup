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

    local point = self.group.properties.point

    frame:ClearAllPoints()
    frame:SetPoint(point[1], point[2], point[3],
                   point[4] + self.progress * self.offset.x,
                   point[5] + self.progress * self.offset.y)
end
