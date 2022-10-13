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

local MAJOR_VERSION, MINOR_VERSION = 'AnimationGroup-1.0', '$Format:%ct-%h$'

-- Probably not a release
if not string.find(MINOR_VERSION, '%d+') then MINOR_VERSION = 0 end

local AG = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not AG then return end

local Classy = LibStub('Classy-1.0')

AG.ORDER_LIMIT = 100

function AG:New(name, parent)
    self[name] = Classy:New('Frame', parent)

    return self[name]
end

local function CreateAnimationGroup(self, name, inherits_from)
    local ag = AG.AnimationGroup:Bind(CreateFrame('Frame', name, self))

    ag:__Initialize(self)
    ag.__Initialize = nil

    return ag
end

local _CreateFrame = CreateFrame
function CreateFrame(...)
    local frame = _CreateFrame(unpack(arg))

    frame.CreateAnimationGroup = CreateAnimationGroup

    return frame
end

local function OnUpdate(self, elapsed)
    if self.paused then
        return
    end
    local in_reverse = self.group.reverse

    self.time = self.time + (in_reverse and -elapsed or elapsed)
    local animation_time = self.time - self.startDelay

    self.progress = animation_time / self.duration
    -- Fast min/max to ensure progress is bound within `0 < self.progress < 1'
        self.progress = self.progress < 0 and 0 or self.progress
        self.progress = self.progress > 1 and 1 or self.progress

    -- These represent whether the time "pointer" is in the left- or the right delay part, at which it is not animating, but should remain visible.
    local is_delayed_start = self.time < self.startDelay and 0 < self.time
    local is_delayed_end = (self.totalTime - self.endDelay) < self.time and self.time < self.totalTime

    local is_animation_complete = (in_reverse and self.time < 0) or self.totalTime < self.time
    self.delayed = is_delayed_start or is_delayed_end

     -- We should calculate smoothProgress before Users's callback_handlers
        self.smoothProgress = self.smoothing_func(self.progress).y

    -- Calling user's callback_handlers
    if type(self.handlers["OnUpdate"]) == 'function' then
        self.handlers["OnUpdate"](self, elapsed)
    end

    -- Calling animations OnUpdate
    if self.OnUpdate then
        self:OnUpdate(elapsed)
    end

    -- Stop animation after last update
    if is_animation_complete then
        AG:Stop(self)
        AG:Fire(self.group, self, 'Finished')
        return
    end

end

--[[
    Global library routines
--]]

function AG:PlayGroup(group)
    local animations = group.animations[group.order + 1]

    if not animations or table.getn(animations) < 1 then
        group.playing = false
        return
    end

    for _, animation in next, animations do
        animation.finished = false
        AG:Play(animation)
    end

    group.playing = true
end

function AG:StopGroup(group)
    local animations = group.animations[group.order + 1]
    if animations then
        for _, animation in next, animations do
            AG:Stop(animation)
        end
    end
    self:LoadProperties(group)
    group.playing = false
end

function AG:SaveProperties(group)
    for k, v in pairs(group:GetAnimations()) do
        v:SaveProperties()
    end
end

function AG:LoadProperties(group)
    for k, v in pairs(group:GetAnimations()) do
        v:LoadProperties()
    end
end

function AG:Stop(animation)
    animation.time = 0

    if animation.OnUpdate then
        animation:_SetScript('OnUpdate', nil)
    end

    animation.playing = false
end

function AG:Play(animation)
    if not animation.playing and animation.target:IsVisible() then
        animation.totalTime = animation.startDelay + animation.duration + animation.endDelay
        animation.time = animation.group.reverse and animation.totalTime or 0
        animation.progress = 0
        animation.smoothProgress = 0
        animation.playing = true
        animation:_SetScript('OnUpdate', function() OnUpdate(this, arg1) end)
    end

    animation.paused = false
end

function AG:Pause(animation)
    animation.paused = true
end

local callback_handlers = {
    ['Play'] = true,
    ['Stop'] = true,
    ['Pause'] = true,
    ['Finished'] = true,
}

-- TODO: Check shine effect callbacks!
function AG:Fire(group, animation, signal)
    local group_func, func

    -- Allocate table of functions
    func = not animation and {}

    local args = {}

    local all_finished = true
    local bouncing = group.loop_type == 'BOUNCE'
    local repeating = group.loop_type == 'REPEAT'

    -- Only animations notify with `FINISHED' signals!
    if signal == 'Finished' then
        animation.finished = true

        for _, anim in next, group.animations[group.order + 1] do
            all_finished = all_finished and anim.finished
        end

        -- Animation: Fires after this Animation finishes playing
        func = animation.handlers['OnFinished']
    elseif signal == 'Stop' then
        table.insert(args, not animation)
    end

    if callback_handlers[signal] then
        group_func = group.handlers['On' .. signal]

        if not animation and group.animations[group.order + 1] then
            local handler_func
            for _, anim in next, group.animations[group.order + 1] do
                handler_func = anim.handlers['On' .. signal]
                if type(handler_func) == 'function' then
                    table.insert(func, { anim, handler_func })
                end
            end
        elseif animation then
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

    local shift

    -- Try the remaining orders
    if (signal == 'Finished' and all_finished) or signal == 'Bounce' then
        if group.shifted then
            if not group.finishing then
                group.reverse = bouncing and (not group.reverse)
                AG:PlayGroup(group)
                group_func = group.handlers['OnLoop']
                table.insert(args, group.reverse and 'REVERSE' or 'FORWARD')
            end
            group.shifted = false
        else
            local first_order, last_order
            repeat
                group.order = group.order + (group.reverse and -1 or 1)

                first_order = group.order == 0
                last_order = not group.animations[group.order + 1] or
                    group.order == (AG.ORDER_LIMIT - 1)

                shift = (not group.reverse and last_order) or
                    (group.reverse and first_order)

                -- Play next order animations... if they exist!
                AG:PlayGroup(group)
            until group.playing or shift

            -- Repeat the next
            if shift and group.playing then
                group.shifted = true
            end
        end
    end

    -- group.finishing requires the animation to be notified first. This block
    -- must therefore be performed AFTER the animation callback and BEFORE the
    -- group's callback
    if (signal == 'Finished' and all_finished and shift) then
        if (group.finishing and (bouncing or repeating)) or not (bouncing or repeating) then
            AG:StopGroup(group)
            group_func = group.handlers['OnFinished']
            table.insert(args, group.finishing)
        end
    end

    -- Call AnimationGroup's callback
    if type(group_func) == 'function' then
        group_func(group, unpack(args))
    end

    -- We `bounce' if the boundary orders have no animations
    if (signal == 'Finished' and not group.playing and shift and
        (not group.finishing) and (bouncing or repeating)) then
        if repeating then
            group.order = -1
        else
            group.reverse = not group.reverse
        end
        group_func = group.handlers['OnLoop']
        table.insert(args, group.reverse and 'REVERSE' or 'FORWARD')
        if type(group_func) == 'function' then
            group_func(group, unpack(args))
        end
        AG:Fire(group, nil, 'Bounce')
    end
end

function AG:MoveOrder(group, animation, new_order)
    local old_order = animation.order

    for i, anim in next, group.animations[old_order + 1] do
        if anim == animation then
            table.remove(group.animations[old_order + 1], i)
        end
    end

    if not group.animations[new_order + 1] then
        for order = old_order + 1, new_order do
            if not group.animations[order + 1] then
                group.animations[order + 1] = {}
            end
        end
    end

    -- Zero-indexing, nope
    table.insert(group.animations[new_order + 1], animation)
end
