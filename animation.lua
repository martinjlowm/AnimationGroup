if not LibAG then return end

local Animation = LibAG:New('Animation')

function Animation:Play()
end

function Animation:Pause()
end

function Animation:Stop()
end

function Animation:IsDone()
end

function Animation:IsPlaying()
end

function Animation:IsPaused()
end

function Animation:IsStopped()
end

function Animation:IsDelaying()
end

function Animation:GetElapsed()
end

function Animation:SetStartDelay(delay_sec)
end

function Animation:GetStartDelay()
end

function Animation:SetEndDelay(delay_sec)
end

function Animation:GetEndDelay()
end

function Animation:SetDuration(duration)
end

function Animation:GetDuration()
end

function Animation:GetProgress()
end

function Animation:GetSmoothProgress()
end

function Animation:GetProgressWithDelay()
end

function Animation:SetMaxFramerate(framerate)
end

function Animation:GetMaxFramerate()
end

function Animation:SetOrder(order)
end

function Animation:GetOrder()
end

function Animation:SetSmoothing(smooth_type)
end

function Animation:GetSmoothing()
end

function Animation:GetRegionParent()
    return self.__owner:GetParent()
end
