if not LibAG then return end

local Alpha = LibAG:New('Alpha', LibAG.Animation)
Alpha.alpha_change = nil

function Alpha:SetChange(change)
    self.alpha_change = change
end

function Alpha:GetChange()
    return self.alpha_change
end
