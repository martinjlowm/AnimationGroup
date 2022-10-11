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

if AG.AnimationGroup then return end
local AnimationGroup = AG:New('AnimationGroup')


--[[
    Private
--]]

local function SetScript(self, handler, func)
    if self.handlers[handler] then
        self.handlers[handler] = func
    else
        self:_SetScript(handler, func)
    end
end

--[[
    API
--]]

function AnimationGroup:Play()
    AG:SaveProperties(self)

    self.reverse = false
    self.finishing = false
    self.order = 0

    repeat
        AG:PlayGroup(self)

        if not self.playing then
            self.order = self.order + 1
        end
    until self.playing or self.order == (AG.ORDER_LIMIT - 1)

    if self.playing then
        AG:Fire(self, nil, 'Play')
    end
end

function AnimationGroup:Pause()
    for _, animation in next, self.animations[self.order + 1] do
        AG:Pause(animation)
    end

    AG:Fire(self, nil, 'Pause')
end

function AnimationGroup:Stop()
    AG:StopGroup(self)

    AG:Fire(self, nil, 'Stop')
end

function AnimationGroup:Finish()
    self.finishing = true
end

function AnimationGroup:GetProgress()
    local lowest_progress = 1
    local anim_progress

    for _, animation in next, self.animations[self.order + 1] do
        anim_progress = animation.progress
        if anim_progress < lowest_progress then
            lowest_progress = anim_progress
        end
    end

    return lowest_progress
end

function AnimationGroup:IsDone()
    return self.done
end

function AnimationGroup:IsPlaying()
    return self.playing
end

function AnimationGroup:IsPaused()
    return self.playing and self.paused
end

function AnimationGroup:GetDuration()
    return self.duration
end

function AnimationGroup:SetLooping(loop_type)
    self.loop_type = loop_type
end

function AnimationGroup:GetLooping()
    return self.loop_type
end

function AnimationGroup:GetLoopState()
    return self.loop_state
end

function AnimationGroup:GetAnimations()
    local animations = {}
    for i = 0, AG.ORDER_LIMIT - 1, 1 do
        if self.animations[i + 1] then
            for _, animation in next, self.animations[i + 1] do
                if animation then
                    tinsert(animations, animation)
                end
            end
        end
    end
    return animations
end

function AnimationGroup:CreateAnimation(animation_type, name, inherits_from)
    animation_type = string.upper(string.sub(animation_type, 1, 1)) .. string.lower(string.sub(animation_type, 2))
    local animation = AG[animation_type]:Bind(CreateFrame('Frame', name))

    animation.group = self
    animation:SetParent(self)
    animation.type = animation_type
    animation.duration = nil
    animation.progress = nil
    animation.smoothProgress = nil
    animation.target = animation.group.parent

    animation.handlers = {
        ['OnLoad'] = true,
        ['OnPlay'] = true,
        ['OnPaused'] = true,
        ['OnStop'] = true,
        ['OnFinished'] = true,
        ['OnUpdate'] = true,
    }

    local default_smoothing = 'LINEAR'
    animation.smoothing_type = default_smoothing
    animation.smoothing_func = AG.Curves[default_smoothing]

    if animation.__Initialize then
        animation:__Initialize()
        animation.__Initialize = nil
    end

    animation._SetScript = animation.SetScript
    animation.SetScript = animation.__SetScript

    animation.properties = {
        alpha = nil,
        width = nil,
        height = nil,
        point = {}
    }

    animation:SaveProperties()

    animation.order = 0
    table.insert(self.animations[animation.order + 1], animation)

    return animation
end

--[[
    Private
--]]

-- Make these functions local
function AnimationGroup:__Initialize(parent)
    self.parent = parent
    self:SetParent(parent)
    self.loop_type = nil
    self.loop_state = nil
    self.duration = nil
    self.playing = nil
    self.paused = nil
    self.done = nil
    self.finishing = false
    self.reverse = nil
    self.order = 0

    self.handlers = {
        ['OnLoad'] = true,
        ['OnPlay'] = true,
        ['OnPaused'] = true,
        ['OnStop'] = true,
        ['OnFinished'] = true,
        ['OnLoop'] = true,
    }

    -- The original implementation claims to support up to 100 orders... yuck!
    -- Lets keep it at 10 for sanity.
    self.animations = { {} }

    self._SetScript = self.SetScript
    self.SetScript = SetScript
end
