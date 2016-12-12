if not LibAG then return end

local AnimationGroup = LibAG:New('AnimationGroup')
AnimationGroup.loop_type = nil
AnimationGroup.loop_state = nil
AnimationGroup.duration = nil
AnimationGroup.is_playing = nil
AnimationGroup.is_paused = nil
AnimationGroup.done = nil

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

end

function AnimationGroup:IsDone()
    return self.done
end

function AnimationGroup:IsPlaying()
    return self.is_playing
end

function AnimationGroup:IsPaused()
    return self.is_playing and self.is_paused
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
    local animation = self['Animation'].Bind(CreateFrame('Frame', name))
    animation.__owner = self
    table.insert(self.animations, animation)

end
