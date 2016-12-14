if not LibAG then return end

local AnimationGroup = LibAG:New('AnimationGroup')
AnimationGroup.loop_type = nil
AnimationGroup.loop_state = nil
AnimationGroup.duration = nil
AnimationGroup.playing = nil
AnimationGroup.paused = nil
AnimationGroup.done = nil
AnimationGroup.animations = {}

function AnimationGroup:Play()
    for _, animation in next, self.animations do
        animation:Play()
    end
end

function AnimationGroup:Pause()
    for _, animation in next, self.animations do
        animation:Pause()
    end
end

function AnimationGroup:Stop()
    for _, animation in next, self.animations do
        animation:Stop()
    end
end

function AnimationGroup:Finish()

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

    local parent = self:GetParent()
    animation.__owner = self
    animation.type = animation_type
    animation.parent_width = parent:GetWidth()
    animation.parent_height = parent:GetHeight()
    animation.parent_x, animation.parent_y = select(4, parent:GetPoint())

    table.insert(self.animations, animation)

    return animation
end
