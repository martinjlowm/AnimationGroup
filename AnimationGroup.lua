if not LibStub then return end

local AG = LibStub:NewLibrary('AnimationGroup-1.0', 0)
if not AG then return end

local Classy = LibStub('Classy-1.0')

function AG:New(name, parent)
    self[name] = Classy:New('Frame', parent)

    return self[name]
end

local Region = AG:New('Region')

function Region:CreateAnimationGroup(name, inherits_from)
    local ag = AG.AnimationGroup:Bind(CreateFrame('Frame'))

    ag:__Initialize(self)

    return ag
end

local _CreateFrame = CreateFrame
function CreateFrame(...)
    local frame = _CreateFrame(unpack(arg))

    frame.CreateAnimationGroup = function()
        return AG.Region.CreateAnimationGroup(frame, nil, nil)
    end

    return frame
end
