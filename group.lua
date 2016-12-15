if not LibStub then return end

local LibAG = LibStub:GetLibrary('AnimationGroup-1.0')
if not LibAG then return end

local AnimationGroup = LibAG:New('AnimationGroup')

--[[
    API
--]]

function AnimationGroup:Play()
    self.reverse = false
    self.finishing = false

    self:__Play()
    self:__Notify(nil, 'Play')
end

function AnimationGroup:Pause()
    for _, animation in next, self.animations do
        animation:__Pause()
    end

    self:__Notify(nil, 'Pause')
end

function AnimationGroup:Stop()
    for _, animation in next, self.animations do
        animation:__Stop()
    end

    self:__Notify(nil, 'Stop')
    self.playing = false
end

function AnimationGroup:Finish()
    self.finishing = true
end

function AnimationGroup:GetProgress()
    local lowest_progress = 1
    local anim_progress

    for _, animation in next, self.animations do
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

function AnimationGroup:CreateAnimation(animation_type, name, inherits_from)
    local animation = LibAG[animation_type]:Bind(CreateFrame('Frame', name))

    animation.group = self
    animation:SetParent(self)
    animation.type = animation_type
    animation.duration = nil
    animation.progress = nil
    animation.handlers = {
        ['OnLoad'] = true,
        ['OnPlay'] = true,
        ['OnPaused'] = true,
        ['OnStop'] = true,
        ['OnFinished'] = true
    }

    local default_smoothing = 'LINEAR'
    animation.smoothing_type = default_smoothing
    animation.smoothing_func = LibAG.Curves[default_smoothing]

    if animation.__Initialize then
        animation:__Initialize()
    end

    animation._SetScript = animation.SetScript
    animation.SetScript = animation.__SetScript

    table.insert(self.animations, animation)

    return animation
end


--[[
    Private
--]]

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

    self.handlers = {
        ['OnLoad'] = true,
        ['OnPlay'] = true,
        ['OnPaused'] = true,
        ['OnStop'] = true,
        ['OnFinished'] = true
    }

    self.animations = {}
    self.properties = {
        alpha = nil,
        width = nil,
        height = nil,
        x = nil,
        y = nil
    }


    self.parent:SetScript('OnSizeChanged', function()
                              self.properties.width = self.properties.width or this:GetWidth()
                              self.properties.height = self.properties.height or this:GetHeight()
    end)

    self.properties.alpha = self.parent:GetAlpha()
    self.properties.width = self.parent:GetWidth()
    self.properties.height = self.parent:GetHeight()
    self.properties.x, self.properties.y = select(4, self.parent:GetPoint())

    self._SetScript = self.SetScript
    self.SetScript = self.__SetScript
end

function AnimationGroup:__SetScript(handler, func)
    if self.handlers[handler] then
        self.handlers[handler] = func
    else
        self:_SetScript(handler, func)
    end
end

function AnimationGroup:__Play()
    for _, animation in next, self.animations do
        animation.finished = false
        animation:__Play()
    end

    self.playing = true
end

function AnimationGroup:__Notify(animation, signal)
    local group_func, func

    -- Allocate table of functions
    func = not animation and {}

    local args = {}

    local all_finished = true
    local bouncing = self.loop_type == 'BOUNCE'

    -- Only animations notify with `FINISHED' signals!
    if signal == 'Finished' then
        animation.finished = true

        for _, anim in next, self.animations do
            all_finished = all_finished and anim.finished
        end

        -- Animation: Fires after this Animation finishes playing
        func = animation.handlers['OnFinished']
    elseif signal == 'Stop' then
        table.insert(args, not animation)
    end

    if signal == 'Play' or signal == 'Stop' or signal == 'Pause' then
        group_func = self.handlers['On' .. signal]

        if not animation then
            local handler_func
            for _, anim in next, self.animations do
                handler_func = anim.handlers['On' .. signal]
                if type(handler_func) == 'function' then
                    table.insert(func, {anim, handler_func})
                end
            end
        else
            func = animation.handlers['On' .. signal]
        end
    end

    -- Call Animation's callback
    if type(func) == 'function' then
        func(animation, unpack(args))
    elseif type(func) == 'table' then
        for _, f in next, func do
            f[2](f[1], unpack(args))
        end
    end

    -- self.finishing requires the animation to be notified first, thus this
    -- block must be performed AFTER the animation callback
    if signal == 'Finished' and all_finished then
        if (self.finishing and bouncing) or (not bouncing) then
            group_func = self.handlers['OnFinished']
            table.insert(args, self.finishing)
        else
            group_func = self.handlers['OnLoop']
            self.reverse = not self.reverse

            table.insert(args, self.reverse and 'REVERSE' or 'FORWARD')
        end
    end

    -- Call AnimationGroup's callback
    if type(group_func) == 'function' then
        group_func(self, unpack(args))
    end

    if (signal == 'Finished' and all_finished and
        (not self.finishing) and bouncing) then
        self:__Play()
    end
end
