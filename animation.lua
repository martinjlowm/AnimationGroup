--[[

    Copyright (c) 2016-2018 Martin Jesper Low Madsen <martin@martinjlowm.dk>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.

--]]

if not LibStub then return end

local AG = LibStub:GetLibrary('AnimationGroup-1.0')
if not AG then return end

if AG.Animation then return end
local Animation = AG:New('Animation')


--[[
    Private
--]]

function Animation:__SetScript(handler, func)
    if self.handlers[handler] then
        self.handlers[handler] = func
    else
        self:_SetScript(handler, func)
    end
end


--[[
    API
--]]

function Animation:Play()
    AG:Play(self)

    AG:Fire(self.group, self, 'Play')
end


function Animation:Pause()
    AG:Pause(self)

    AG:Fire(self.group, self, 'Pause')
end


function Animation:Stop()
    AG:Stop(self)

    AG:Fire(self.group, self, 'Stop')
end

function Animation:IsDone()
    return self.finished
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
    return self.delaying
end

function Animation:GetElapsed()
    local durationTime = self.group.reverse and (self.duration - self.time) or self.time
    local elapsed = (self.startdelayTime  +  durationTime + self.enddelayTime)
    if self.group.reverse then
        elapsed = self.startdelay + self.enddelay + self.duration - elapsed
    end
    return elapsed
end

function Animation:SetStartDelay(delay_sec)
    self.startdelay = delay_sec
end

function Animation:GetStartDelay()
    return self.startdelay
end

function Animation:SetEndDelay(delay_sec)
    self.enddelay = delay_sec
end

function Animation:GetEndDelay()
    return self.enddelay
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

function Animation:SetSmoothProgress(smoothProgress)
    self.smoothProgress = smoothProgress
end

function Animation:GetSmoothProgress()
    return self.smoothProgress
end

function Animation:SetMaxFramerate(framerate)
end

function Animation:GetMaxFramerate()
end

function Animation:SetOrder(order)
    AG:MoveOrder(self.group, self, order)

    self.order = order
end

function Animation:GetOrder()
    return self.order
end

function Animation:SetSmoothing(smoothing_type)
    self.smoothing_func = AG.Curves[smoothing_type]
    self.smoothing_type = smoothing_type
end

function Animation:GetSmoothing()
    return self.smooth_type
end

function Animation:GetRegionParent()
    return self.group.parent
end

function Animation:SetTarget(region)
    self.target = region
    self:SaveProperties()
end

function Animation:GetTarget()
    return self.target
end