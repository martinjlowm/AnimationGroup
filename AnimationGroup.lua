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
    local ag = AG.AnimationGroup:Bind(CreateFrame('Frame', nil, self))

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

    self.time = self.time + (self.group.reverse and -elapsed or elapsed)

    if self.time > self.duration or (self.group.reverse and self.time < 0) then
        AG:Stop(self)
        AG:Fire(self.group, self, 'Finished')

        return
    end

    -- Temporary until all animation types are implemented
    if self.OnUpdate then
        self:OnUpdate(elapsed)
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
    group.properties.alpha = group.parent:GetAlpha()
    group.properties.width = group.parent:GetWidth()
    group.properties.height = group.parent:GetHeight()
    group.properties.point = { group.parent:GetPoint() }
end

function AG:LoadProperties(group)
    group.parent:SetAlpha(group.properties.alpha)
    group.parent:SetWidth(group.properties.width)
    group.parent:SetHeight(group.properties.height)

    local point = group.properties.point
    if point and point[1] then
        group.parent:SetPoint(unpack(point))
    end
end

function AG:Stop(animation)
    animation.time = 0

    if animation.OnUpdate then
        animation:SetScript('OnUpdate', nil)
    end

    animation.playing = false
end

function AG:Play(animation)
    if not animation.playing and animation.group.parent:IsVisible() then
        animation.time = animation.group.reverse and animation.duration or 0
        animation.playing = true
        animation:SetScript('OnUpdate', function() OnUpdate(this, arg1) end)
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

        if not animation then
            local handler_func
            for _, anim in next, group.animations[group.order + 1] do
                handler_func = anim.handlers['On' .. signal]
                if type(handler_func) == 'function' then
                    table.insert(func, { anim, handler_func })
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

    local shift

    -- Try the remaining orders
    if (signal == 'Finished' and all_finished) or signal == 'Bounce' then
        if group.shifted then
            if not group.finishing then
                group.reverse = not group.reverse
                AG:PlayGroup(group)
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
        if (group.finishing and bouncing) or (not bouncing) then
            AG:StopGroup(group)

            group_func = group.handlers['OnFinished']
            table.insert(args, group.finishing)
        else
            group_func = group.handlers['OnLoop']

            table.insert(args, group.reverse and 'REVERSE' or 'FORWARD')
        end
    end

    -- Call AnimationGroup's callback
    if type(group_func) == 'function' then
        group_func(group, unpack(args))
    end

    -- We `bounce' if the boundary orders have no animations
    if (not group.playing and shift and
        (not group.finishing) and bouncing) then
        group.reverse = not group.reverse
        AG:Fire(group, nil, 'Bounce')
    end
end

function AG:MoveOrder(group, animation, new_order)
    local old_order = group.order

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
