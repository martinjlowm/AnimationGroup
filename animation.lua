if not LibAG then return end

local Animation = LibAG:New('Animation')
Animation.type = nil
Animation.duration = nil
Animation.progress = nil
Animation.smoothing_type = 'LINEAR'
Animation.smoothing_func = LibAG.Curves[Animation.smoothing_type]

local function OnUpdate(self, elapsed)
    if self.paused then
        return
    end

    self.time = self.time + (self.reverse and -elapsed or elapsed)

    if self.time > self.duration or (self.reverse and self.time < 0) then
        if self.__owner.loop_type == 'NONE' then
            self:Stop()
            -- Send OnFinished
            return
        elseif self.__owner.loop_type == 'BOUNCE' then
            self.reverse = not self.reverse
        end
        self.time = self.reverse and self.duration or 0
    end

    self:OnUpdate(elapsed)
end

function Animation:Play()
    if self.OnUpdate and not self.playing then
        self.progress = 0
        self.time = 0
        self.playing = true
        self:SetScript('OnUpdate', function() OnUpdate(this, arg1) end)
    end

    self.paused = false
end

function Animation:Pause()
    self.paused = true
end

function Animation:Stop()
    if self.OnUpdate then
        self.progress = 0
        self.time = 0
        self:SetScript('OnUpdate', nil)
    end

    self.playing = false
end

function Animation:IsDone()
    return not self.playing
end

function Animation:IsPlaying()
    return self.playing
end

function Animation:IsPaused()
    return not self.playing and self.paused
end

function Animation:IsStopped()
    return not self.playing
end

function Animation:IsDelaying()
    return not not self.delay
end

function Animation:GetElapsed()
    return self.time
end

function Animation:SetStartDelay(delay_sec)
    self.delay = delay_sec
end

function Animation:GetStartDelay()
    return self.delay
end

function Animation:SetEndDelay(delay_sec)
end

function Animation:GetEndDelay()
end

function Animation:SetDuration(duration)
    self.duration = duration
end

function Animation:GetDuration()
    return self.duration
end

function Animation:GetProgress()
    return self.progress
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

function Animation:SetSmoothing(smoothing_type)
    self.smoothing_func = LibAG.Curves[smoothing_type]
    self.smoothing_type = smoothing_type
end

function Animation:GetSmoothing()
    return self.smooth_type
end

function Animation:GetRegionParent()
    return self.__owner:GetParent()
end
