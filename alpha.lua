if not LibStub then return end

local LibAG = LibStub:GetLibrary('AnimationGroup-1.0')
if not LibAG then return end


local Alpha = LibAG:New('Alpha', LibAG.Animation)

function Alpha:__Initialize()
    self.alpha_change = nil
end

function Alpha:SetChange(change)
    self.alpha_change = change
end

function Alpha:GetChange()
    return self.alpha_change
end

function Alpha:OnUpdate(elapsed)
    local properties = self.group.properties

    self.progress = self.smoothing_func(self.time / self.duration).y

    local frame = self.group.parent

    frame:SetAlpha(properties.alpha + self.progress * self.alpha_change)
end
